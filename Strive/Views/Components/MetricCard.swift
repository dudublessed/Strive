import SwiftUI

struct MetricCard: View {
    let title: String
    let value: String
    let caption: String?
    let systemIcon: String

    init(title: String, value: String, caption: String? = nil, systemIcon: String) {
        self.title = title
        self.value = value
        self.caption = caption
        self.systemIcon = systemIcon
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.s) {
            HStack(spacing: Theme.Spacing.s) {
                Image(systemName: systemIcon)
                    .foregroundStyle(Theme.Palette.accent)
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(Theme.Palette.subtleText)
            }
            Text(value)
                .font(.title2.weight(.semibold))
                .foregroundStyle(Theme.Palette.accentText)
            if let caption {
                Text(caption)
                    .font(.caption)
                    .foregroundStyle(Theme.Palette.subtleText)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Theme.Spacing.l)
        .background(Theme.Palette.accentFill)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
    }
}
