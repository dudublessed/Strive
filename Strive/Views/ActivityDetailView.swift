import SwiftUI
import SwiftData

struct ActivityDetailView: View {
    let stravaId: String
    @Query private var activities: [RunActivity]

    init(stravaId: String) {
        self.stravaId = stravaId
        _activities = Query(
            filter: #Predicate<RunActivity> { $0.stravaId == stravaId }
        )
    }

    var body: some View {
        ScrollView {
            if let a = activities.first {
                VStack(alignment: .leading, spacing: Theme.Spacing.l) {
                    Text(Formatters.mediumDate.string(from: a.date))
                        .font(.caption)
                        .foregroundStyle(Theme.Palette.subtleText)

                    LazyVGrid(
                        columns: [GridItem(.flexible(), spacing: Theme.Spacing.m),
                                  GridItem(.flexible(), spacing: Theme.Spacing.m)],
                        spacing: Theme.Spacing.m
                    ) {
                        MetricCard(title: "Distance",
                                   value: Formatters.distance(a.distanceMeters),
                                   systemIcon: Icons.distance)
                        MetricCard(title: "Moving time",
                                   value: Formatters.duration(Double(a.movingTimeSeconds)),
                                   systemIcon: Icons.duration)
                        MetricCard(title: "Pace",
                                   value: Formatters.pace(secPerKm: a.averagePaceSecPerKm),
                                   systemIcon: Icons.pace)
                        MetricCard(title: "Elevation gain",
                                   value: Formatters.elevation(a.elevationGainMeters),
                                   systemIcon: Icons.elevation)
                    }
                }
                .padding(Theme.Spacing.l)
                .navigationTitle(a.name.isEmpty ? "Run" : a.name)
                .navigationBarTitleDisplayMode(.inline)
            } else {
                ContentUnavailableView("Activity not found",
                                       systemImage: "questionmark.circle")
            }
        }
    }
}
