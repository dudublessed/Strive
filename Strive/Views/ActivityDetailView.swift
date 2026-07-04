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
                        MetricCard(title: "Distância",
                                   value: Formatters.distance(a.distanceMeters),
                                   systemIcon: Icons.distance)
                        MetricCard(title: "Tempo em movimento",
                                   value: Formatters.duration(Double(a.movingTimeSeconds)),
                                   systemIcon: Icons.duration)
                        MetricCard(title: "Ritmo",
                                   value: Formatters.pace(secPerKm: a.averagePaceSecPerKm),
                                   systemIcon: Icons.pace)
                        MetricCard(title: "Elevação",
                                   value: Formatters.elevation(a.elevationGainMeters),
                                   systemIcon: Icons.elevation)
                    }
                }
                .padding(Theme.Spacing.l)
                .navigationTitle(a.name.isEmpty ? "Corrida" : a.name)
                .navigationBarTitleDisplayMode(.inline)
            } else {
                ContentUnavailableView("Atividade não encontrada",
                                       systemImage: "questionmark.circle")
            }
        }
    }
}
