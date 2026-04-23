import SwiftUI
import SwiftData

@main
struct FriendlyFiresApp: App {
    let modelContainer: ModelContainer

    init() {
        do {
            let config = ModelConfiguration(
                isStoredInMemoryOnly: false,
                allowsSave: true
            )
            modelContainer = try ModelContainer(
                for: Player.self, GameSession.self,
                configurations: config
            )
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .modelContainer(modelContainer)
        }
    }
}
