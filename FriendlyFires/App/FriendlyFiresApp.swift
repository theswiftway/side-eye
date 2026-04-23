import SwiftUI
import SwiftData

@main
struct FriendlyFiresApp: App {
    let modelContainer: ModelContainer

    init() {
        do {
            let schema = Schema([Player.self, GameSession.self])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(modelContainer)
    }
}
