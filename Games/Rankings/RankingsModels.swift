import Foundation

struct RankingQuestion: Codable {
    let id: UUID
    let text: String
    let category: String

    init(id: UUID = UUID(), text: String, category: String) {
        self.id = id
        self.text = text
        self.category = category
    }
}

// Ballot: one player's ranking of all other players
struct RankingBallot: Codable {
    let playerID: UUID
    let playerName: String
    let questionID: UUID
    let rankings: [UUID: Int]  // targetPlayerID -> rank (1 = highest)
}

// Results for a single question
struct QuestionResults: Codable {
    let question: RankingQuestion
    let ballots: [RankingBallot]
    let averageRanks: [UUID: Double]  // targetPlayerID -> avg rank

    init(question: RankingQuestion, ballots: [RankingBallot]) {
        self.question = question
        self.ballots = ballots
        self.averageRanks = Self.computeAverageRanks(ballots)
    }

    private static func computeAverageRanks(_ ballots: [RankingBallot]) -> [UUID: Double] {
        var rankSums: [UUID: (sum: Int, count: Int)] = [:]

        for ballot in ballots {
            for (targetID, rank) in ballot.rankings {
                let current = rankSums[targetID] ?? (sum: 0, count: 0)
                rankSums[targetID] = (sum: current.sum + rank, count: current.count + 1)
            }
        }

        var averages: [UUID: Double] = [:]
        for (targetID, (sum, count)) in rankSums {
            if count > 0 {
                averages[targetID] = Double(sum) / Double(count)
            }
        }
        return averages
    }
}

// Payload for submission
struct SubmitRankingPayload: Codable {
    let playerID: UUID
    let playerName: String
    let questionID: UUID
    let rankings: [UUID: Int]
}

// Payload for reveal
struct RevealResultsPayload: Codable {
    let questionID: UUID
    let averageRanks: [UUID: Double]
    let topThree: [(UUID, Double)]  // Top 3 ranked players
}

// Default questions bank
let defaultRankingQuestions: [RankingQuestion] = [
    RankingQuestion(text: "Who would survive the apocalypse the longest?", category: "survival"),
    RankingQuestion(text: "Who's most likely to ghost on a date?", category: "dating"),
    RankingQuestion(text: "Who would be the best heist leader?", category: "leadership"),
    RankingQuestion(text: "Who's most likely to be a secret billionaire?", category: "success"),
    RankingQuestion(text: "Who's most likely to start a cult?", category: "influence"),
    RankingQuestion(text: "Who would win in a fight (no weapons)?", category: "physical"),
    RankingQuestion(text: "Who's the most charismatic in the group?", category: "social"),
    RankingQuestion(text: "Who would last longest on Survivor?", category: "survival"),
]
