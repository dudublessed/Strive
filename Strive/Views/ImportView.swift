import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ImportView: View {
    @Environment(\.modelContext) private var context
    @State private var isPickerPresented = false
    @State private var isImporting = false
    @State private var lastSummary: ImportService.Summary?
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.l) {
                header
                howItWorks
                actionButton
                if let s = lastSummary {
                    summaryCard(s)
                }
                if let msg = errorMessage {
                    Text(msg)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
            }
            .padding(Theme.Spacing.l)
        }
        .background(Theme.Palette.surface)
        .navigationTitle("Import")
        .fileImporter(
            isPresented: $isPickerPresented,
            allowedContentTypes: [.folder, .commaSeparatedText],
            allowsMultipleSelection: false
        ) { result in
            handle(result)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.s) {
            Text("Import Strava archive")
                .font(.title2.weight(.semibold))
                .foregroundStyle(Theme.Palette.accentText)
            Text("Point the picker at your unzipped export folder, or directly at `activities.csv`.")
                .font(.subheadline)
                .foregroundStyle(Theme.Palette.subtleText)
        }
    }

    private var howItWorks: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.s) {
            Label("Request an archive from Strava (Settings → My Account).", systemImage: "1.circle.fill")
            Label("Unzip it with the Files app.", systemImage: "2.circle.fill")
            Label("Pick the folder here — re-imports are safe (upsert by ID).", systemImage: "3.circle.fill")
        }
        .font(.subheadline)
        .foregroundStyle(Theme.Palette.accentText)
        .padding(Theme.Spacing.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.Palette.accentFill)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
    }

    private var actionButton: some View {
        Button {
            errorMessage = nil
            isPickerPresented = true
        } label: {
            HStack {
                Image(systemName: Icons.importArchive)
                Text(isImporting ? "Importing…" : "Choose folder or CSV")
                    .font(.body.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(Theme.Spacing.l)
            .background(Theme.Palette.accent)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.control))
        }
        .disabled(isImporting)
    }

    private func summaryCard(_ s: ImportService.Summary) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.s) {
            Text("Last import")
                .font(.headline)
                .foregroundStyle(Theme.Palette.accentText)
            Text("\(s.inserted) new · \(s.updated) updated")
                .font(.subheadline)
                .foregroundStyle(Theme.Palette.subtleText)
        }
        .padding(Theme.Spacing.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.Palette.accentFill)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
    }

    private func handle(_ result: Result<[URL], Error>) {
        switch result {
        case .failure(let e):
            errorMessage = e.localizedDescription
        case .success(let urls):
            guard let url = urls.first else { return }
            Task { await runImport(from: url) }
        }
    }

    @MainActor
    private func runImport(from url: URL) async {
        isImporting = true
        defer { isImporting = false }
        errorMessage = nil

        let needsScope = url.startAccessingSecurityScopedResource()
        defer { if needsScope { url.stopAccessingSecurityScopedResource() } }

        do {
            let service = ImportService(context: context)
            let summary: ImportService.Summary
            if url.hasDirectoryPath {
                summary = try service.importExport(from: url)
            } else {
                summary = try service.importCSV(from: url)
            }
            lastSummary = summary
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription
                ?? error.localizedDescription
        }
    }
}
