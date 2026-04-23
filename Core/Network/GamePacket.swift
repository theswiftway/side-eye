import Foundation

// MARK: - Packet Types

enum PacketType: String, Codable {
    // Lobby lifecycle
    case playerJoined
    case playerLeft
    case lobbyStateUpdate
    case gameSelected
    case gameStarted

    // Game lifecycle
    case roundStarted
    case roundEnded
    case gameEnded

    // Player actions (game-specific payloads)
    case submitAction
    case submitVote
    case submitRanking

    // Host broadcasts
    case stateUpdate
    case revealResults
    case showScore

    // Utility
    case ping
    case pong
}

// MARK: - Main Packet

struct GamePacket: Codable {
    let id: UUID
    let type: PacketType
    let sender: UUID
    let senderName: String
    let payload: Data?
    let timestamp: Date

    init(
        type: PacketType,
        sender: UUID,
        senderName: String,
        payload: Encodable? = nil
    ) {
        self.id = UUID()
        self.type = type
        self.sender = sender
        self.senderName = senderName
        self.payload = payload.map { packet in
            (try? JSONEncoder().encode(AnyCodable(packet))) ?? Data()
        }
        self.timestamp = Date()
    }

    // Helper to decode payload
    func decodePayload<T: Decodable>(_ type: T.Type) -> T? {
        guard let data = payload else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
}

// MARK: - Type-erased Codable wrapper

struct AnyCodable: Codable {
    let value: Encodable

    init(_ value: Encodable) {
        self.value = value
    }

    func encode(to encoder: Encoder) throws {
        try value.encode(to: encoder)
    }
}

// MARK: - Common Payloads

struct SimpleActionPayload: Codable {
    let actionType: String
    let data: [String: String]
}

struct VotePayload: Codable {
    let targetPlayerID: UUID
    let voteValue: String
}

struct TextSubmissionPayload: Codable {
    let text: String
}
