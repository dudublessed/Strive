import SwiftUI

struct SplitRow: View {
    let label: String
    let duration: String?
    let date: Date?

    var body: some View {
        HStack(spacing: Theme.Spacing.m) {
            Image(systemName: Icons.split)
                .foregroundStyle(Theme.Palette.accent)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.body.weight(.medium))
                if let date {
                    Text(Formatters.mediumDate.string(from: date))
                        .font(.caption)
                        .foregroundStyle(Theme.Palette.subtleText)
                }
            }
            Spacer()
            Text(duration ?? "—")
                .font(.body.monospacedDigit())
                .foregroundStyle(Theme.Palette.accentText)
        }
        .padding(.vertical, Theme.Spacing.xs)
    }
}
