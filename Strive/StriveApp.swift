import SwiftUI
import SwiftData

@main
struct StriveApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [RunActivity.self, BestSplit.self])
    }
}
