import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            NavigationStack {
                DashboardView()
            }
            .tabItem { Label("Records", systemImage: Icons.dashboard) }

            NavigationStack {
                ActivityListView()
            }
            .tabItem { Label("Activities", systemImage: Icons.activities) }

            NavigationStack {
                ImportView()
            }
            .tabItem { Label("Import", systemImage: Icons.importArchive) }
        }
        .tint(Theme.Palette.accent)
    }
}
