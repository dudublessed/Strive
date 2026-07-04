import SwiftUI
import SwiftData

struct ActivityListView: View {
    enum Sort: String, CaseIterable, Identifiable {
        case date, distance, pace
        var id: String { rawValue }
        var label: String {
            switch self {
            case .date: return "Data"
            case .distance: return "Distância"
            case .pace: return "Ritmo"
            }
        }
    }

    @Query(sort: \RunActivity.date, order: .reverse) private var activities: [RunActivity]
    @State private var sort: Sort = .date

    var sorted: [RunActivity] {
        switch sort {
        case .date:
            return activities.sorted { $0.date > $1.date }
        case .distance:
            return activities.sorted { $0.distanceMeters > $1.distanceMeters }
        case .pace:
            return activities.sorted { $0.averagePaceSecPerKm < $1.averagePaceSecPerKm }
        }
    }

    var body: some View {
        List {
            ForEach(sorted) { a in
                NavigationLink(value: a.stravaId) {
                    row(for: a)
                }
            }
        }
        .navigationTitle("Atividades")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Picker("Ordenar por", selection: $sort) {
                        ForEach(Sort.allCases) { s in
                            Text(s.label).tag(s)
                        }
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                }
            }
        }
        .navigationDestination(for: String.self) { id in
            ActivityDetailView(stravaId: id)
        }
        .overlay {
            if activities.isEmpty {
                ContentUnavailableView(
                    "Nenhuma atividade",
                    systemImage: Icons.activities,
                    description: Text("Importe um arquivo da Strava para preencher esta lista.")
                )
            }
        }
    }

    private func row(for a: RunActivity) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(a.name.isEmpty ? "Corrida" : a.name)
                .font(.body.weight(.medium))
            HStack(spacing: Theme.Spacing.m) {
                Label(Formatters.distance(a.distanceMeters), systemImage: Icons.distance)
                Label(Formatters.duration(Double(a.movingTimeSeconds)), systemImage: Icons.duration)
                Label(Formatters.pace(secPerKm: a.averagePaceSecPerKm), systemImage: Icons.pace)
            }
            .font(.caption)
            .foregroundStyle(Theme.Palette.subtleText)
            Text(Formatters.mediumDate.string(from: a.date))
                .font(.caption2)
                .foregroundStyle(Theme.Palette.subtleText)
        }
        .padding(.vertical, 4)
    }
}
