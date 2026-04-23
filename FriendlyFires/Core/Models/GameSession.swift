import Foundation
import SwiftData

@Model
final class GameSession {
    var id: UUID = UUID()
    var sessionName: String
    var hostID: UUID
    var selectedGameType: GameType?
    var createdAt: Date = Date()

    init(sessionName: String, hostID: UUID) {
        self.sessionName = sessionName
        self.hostID = hostID
    }
}
