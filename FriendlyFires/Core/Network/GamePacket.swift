import Foundation

enum PacketType: String, Codable {
    // Lobby
    case playerJoined, playerLeft, lobbyState
    // Game lifecycle
    case gameSelected, gameStarted, roundStarted, roundEnded, gameEnded
    // Player actions
    case submitAction, submitVote, submitRanking
    // Host broadcasts
    case stateUpdate, revealResults, showScore
}

struct GamePacket: Codable {
    let id: UUID = UUID()
    let type: PacketType
    let sender: UUID
    let senderName: String
    let payload: Data?
    let timestamp: Date = Date()

    init(type: PacketType, sender: UUID, senderName: String) {
        self.type = type
        self.sender = sender
        self.senderName = senderName
        self.payload = nil
    }

    init<T: Codable>(type: PacketType, sender: UUID, senderName: String, payload: T) {
        self.type = type
        self.sender = sender
        self.senderName = senderName
        self.payload = try? JSONEncoder().encode(payload)
    }

    func decodePayload<T: Codable>(_ type: T.Type) -> T? {
        guard let payload = payload else { return nil }
        return try? JSONDecoder().decode(type, from: payload)
    }
}
