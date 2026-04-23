import Foundation
import SwiftData

@Model
final class GameSession {
    @Attribute(.unique) var id: UUID
    var sessionName: String
    var gameType: GameType?
    var hostID: UUID
    var playerCount: Int = 1
    var maxPlayers: Int = 8
    var createdAt: Date = Date()

    init(
        id: UUID = UUID(),
        sessionName: String,
        gameType: GameType? = nil,
        hostID: UUID,
        maxPlayers: Int = 8
    ) {
        self.id = id
        self.sessionName = sessionName
        self.gameType = gameType
        self.hostID = hostID
        self.maxPlayers = maxPlayers
    }
}

// MARK: - Runtime State (not persisted)

class GameSessionState: NSObject, ObservableObject {
    @Published var sessionID: UUID
    @Published var sessionName: String
    @Published var hostID: UUID
    @Published var isHost: Bool
    @Published var players: [PlayerDTO] = []
    @Published var selectedGameType: GameType?

    init(
        sessionID: UUID,
        sessionName: String,
        hostID: UUID,
        isHost: Bool
    ) {
        self.sessionID = sessionID
        self.sessionName = sessionName
        self.hostID = hostID
        self.isHost = isHost
    }
}

// MARK: - Session-level packets

struct LobbyStatePacket: Codable {
    let sessionID: UUID
    let sessionName: String
    let players: [PlayerDTO]
    let selectedGameType: GameType?
}
