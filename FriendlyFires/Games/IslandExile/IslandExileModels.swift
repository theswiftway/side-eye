import Foundation

enum Role: String, Codable {
    case schemer       // Trying to survive (can lie)
    case loyalist      // Trying to save schemers
    case wildcard      // Unknown allegiance
    case survivalist   // Solo player

    var description: String {
        switch self {
        case .schemer: return "Schemer - you're on your own"
        case .loyalist: return "Loyalist - protect the schemers"
        case .wildcard: return "Wildcard - no one knows your allegiance"
        case .survivalist: return "Survivalist - survive alone"
        }
    }
}

struct PlayerRole: Codable {
    let playerID: UUID
    let role: Role
    let agendaText: String

    init(playerID: UUID, role: Role) {
        self.playerID = playerID
        self.role = role
        self.agendaText = role.description
    }
}

struct IslandChallenge: Codable {
    let id: UUID
    let text: String
    let category: String

    init(id: UUID = UUID(), text: String, category: String) {
        self.id = id
        self.text = text
        self.category = category
    }
}

struct ExileVote: Codable {
    let voterID: UUID
    let targetID: UUID
    let reason: String
}

// Default challenges
let defaultIslandChallenges: [IslandChallenge] = [
    IslandChallenge(text: "Who is most likely to be a liar?", category: "deduction"),
    IslandChallenge(text: "Who poses the biggest threat to your survival?", category: "threat"),
    IslandChallenge(text: "Who would you trust with your life?", category: "trust"),
    IslandChallenge(text: "Who's playing the hardest game?", category: "strategy"),
    IslandChallenge(text: "Who's most likely to backstab?", category: "betrayal"),
]

// Payloads
struct AssignRolePayload: Codable {
    let playerID: UUID
    let role: Role
}

struct BroadcastExilePayload: Codable {
    let challengeID: UUID
    let challengeText: String
    let remainingPlayers: Int
}

struct SubmitExileVotePayload: Codable {
    let voterID: UUID
    let targetID: UUID
    let reason: String
}

struct RevealExilePayload: Codable {
    let exiledPlayerID: UUID
    let exiledPlayerName: String
    let exiledPlayerRole: Role
    let voteCount: Int
}
