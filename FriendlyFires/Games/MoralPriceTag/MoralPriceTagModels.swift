import Foundation

struct Dilemma: Codable, Identifiable {
    let id: UUID
    let text: String
    let amount: Int  // Dollar amount

    init(id: UUID = UUID(), text: String, amount: Int) {
        self.id = id
        self.text = text
        self.amount = amount
    }
}

struct PlayerCommit: Codable {
    let playerID: UUID
    let playerName: String
    let dilemmaID: UUID
    let wouldDo: Bool
    let justification: String
}

struct SelloutScore: Codable {
    let playerID: UUID
    let playerName: String
    var moralScore: Int = 100  // Starts at 100
    var timesWouldDo: Int = 0
    var totalMoneyWouldTake: Int = 0

    mutating func recordCommit(wouldDo: Bool, amount: Int) {
        if wouldDo {
            timesWouldDo += 1
            totalMoneyWouldTake += amount
            moralScore = max(0, moralScore - (amount / 100))
        } else {
            moralScore = min(100, moralScore + 5)
        }
    }
}

struct DilemmaRound: Codable {
    let dilemma: Dilemma
    let roundNumber: Int
    var commits: [UUID: PlayerCommit] = [:]

    mutating func addCommit(_ commit: PlayerCommit) {
        commits[commit.playerID] = commit
    }
}

// Payloads
struct SubmitCommitPayload: Codable {
    let playerID: UUID
    let playerName: String
    let dilemmaID: UUID
    let wouldDo: Bool
    let justification: String
}

struct BroadcastDilemmaPayload: Codable {
    let dilemma: Dilemma
    let roundNumber: Int
}

struct RevealCommitsPayload: Codable {
    let dilemma: Dilemma
    let commits: [PlayerCommit]
}

// Default dilemmas bank
let defaultDilemmas: [Dilemma] = [
    Dilemma(text: "Would you humiliate your best friend publicly for $500?", amount: 500),
    Dilemma(text: "Would you never speak to a family member again for $10,000?", amount: 10000),
    Dilemma(text: "Would you confess a lie you've kept for years for $200?", amount: 200),
    Dilemma(text: "Would you donate a kidney to a stranger for $100,000?", amount: 100000),
    Dilemma(text: "Would you ghost someone you're dating for $1,000?", amount: 1000),
    Dilemma(text: "Would you spend a night in jail for $50,000?", amount: 50000),
    Dilemma(text: "Would you delete all your social media forever for $5,000?", amount: 5000),
    Dilemma(text: "Would you eat a live bug for $300?", amount: 300),
]
