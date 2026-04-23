import Foundation

struct Take: Codable, Identifiable {
    let id: UUID
    let playerID: UUID
    let playerName: String
    let text: String
    var hotVotes: Int = 0
    var coldVotes: Int = 0

    init(id: UUID = UUID(), playerID: UUID, playerName: String, text: String) {
        self.id = id
        self.playerID = playerID
        self.playerName = playerName
        self.text = text
    }
}

struct TakeVote: Codable {
    let voterID: UUID
    let takeID: UUID
    let vote: VoteType

    enum VoteType: String, Codable {
        case hot    // 🔥
        case cold   // ❄️
    }
}

struct TakesRound: Codable {
    let roundID: UUID
    let takes: [Take]
    var votes: [UUID: TakeVote] = [:]  // voterID -> vote

    init(roundID: UUID = UUID(), takes: [Take]) {
        self.roundID = roundID
        self.takes = takes
    }

    mutating func addVote(_ vote: TakeVote) {
        votes[vote.voterID] = vote
    }

    var results: [Take] {
        takes.map { take in
            var updated = take
            updated.hotVotes = votes.values.filter { $0.takeID == take.id && $0.vote == .hot }.count
            updated.coldVotes = votes.values.filter { $0.takeID == take.id && $0.vote == .cold }.count
            return updated
        }
    }

    var sortedResults: [Take] {
        results.sorted { ($0.hotVotes - $0.coldVotes) > ($1.hotVotes - $1.coldVotes) }
    }
}

// Payloads
struct SubmitTakePayload: Codable {
    let playerID: UUID
    let playerName: String
    let text: String
}

struct BroadcastTakesPayload: Codable {
    let takes: [Take]
}

struct SubmitVotePayload: Codable {
    let voterID: UUID
    let takeID: UUID
    let vote: TakeVote.VoteType
}

struct RevealTakesPayload: Codable {
    let results: [Take]
    let topHottest: [Take]
}
