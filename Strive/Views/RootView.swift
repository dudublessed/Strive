import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            NavigationStack {
                DashboardView()
            }
            .tabItem { Label("Recordes", systemImage: Icons.dashboard) }

            NavigationStack {
                ActivityListView()
            }
            .tabItem { Label("Atividades", systemImage: Icons.activities) }

            NavigationStack {
                ImportView()
            }
            .tabItem { Label("Importar", systemImage: Icons.importArchive) }
        }
        .tint(Theme.Palette.accent)
    }
}
