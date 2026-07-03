import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query(sort: \RunActivity.date, order: .reverse) private var activities: [RunActivity]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
                if activities.isEmpty {
                    EmptyDashboard()
                } else {
                    metricsGrid
                    splitsSection
                }
            }
            .padding(Theme.Spacing.l)
        }
        .background(Theme.Palette.surface)
        .navigationTitle("Records")
    }

    private var metricsGrid: some View {
        let longest = activities.max(by: { $0.distanceMeters < $1.distanceMeters })
        let mostGain = activities.max(by: { $0.elevationGainMeters < $1.elevationGainMeters })
        let longestDur = activities.max(by: { $0.movingTimeSeconds < $1.movingTimeSeconds })

        return LazyVGrid(
            columns: [GridItem(.flexible(), spacing: Theme.Spacing.m),
                      GridItem(.flexible(), spacing: Theme.Spacing.m)],
            spacing: Theme.Spacing.m
        ) {
            MetricCard(
                title: "Longest run",
                value: longest.map { Formatters.distance($0.distanceMeters) } ?? "—",
                caption: longest.map { Formatters.mediumDate.string(from: $0.date) },
                systemIcon: Icons.distance
            )
            MetricCard(
                title: "Most elevation",
                value: mostGain.map { Formatters.elevation($0.elevationGainMeters) } ?? "—",
                caption: mostGain.map { Formatters.mediumDate.string(from: $0.date) },
                systemIcon: Icons.elevation
            )
            MetricCard(
                title: "Longest duration",
                value: longestDur.map { Formatters.duration(Double($0.movingTimeSeconds)) } ?? "—",
                caption: longestDur.map { Formatters.mediumDate.string(from: $0.date) },
                systemIcon: Icons.duration
            )
            MetricCard(
                title: "Runs imported",
                value: "\(activities.count)",
                caption: nil,
                systemIcon: Icons.activities
            )
        }
    }

    private var splitsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.m) {
            Text("Fastest splits")
                .font(.headline)
                .foregroundStyle(Theme.Palette.accentText)

            VStack(spacing: 0) {
                let all = SplitDistance.allCases
                ForEach(Array(all.enumerated()), id: \.offset) { idx, d in
                    SplitRow(label: d.label, duration: nil, date: nil)
                    if idx < all.count - 1 {
                        Divider().background(Theme.Palette.divider)
                    }
                }
            }
            .padding(Theme.Spacing.m)
            .background(Theme.Palette.accentFill)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))

            Text("Splits are computed once activity file parsing lands.")
                .font(.caption)
                .foregroundStyle(Theme.Palette.subtleText)
        }
    }
}

private struct EmptyDashboard: View {
    var body: some View {
        VStack(spacing: Theme.Spacing.l) {
            Image(systemName: Icons.dashboard)
                .font(.system(size: 44))
                .foregroundStyle(Theme.Palette.accent)
            Text("No runs yet")
                .font(.title3.weight(.semibold))
            Text("Import a Strava archive from the Import tab to get started.")
                .font(.subheadline)
                .foregroundStyle(Theme.Palette.subtleText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.Spacing.xl)
    }
}
