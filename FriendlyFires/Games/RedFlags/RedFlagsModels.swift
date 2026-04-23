import Foundation

struct FlagCard: Codable, Identifiable {
    let id: UUID
    let text: String
    let type: FlagType

    enum FlagType: String, Codable {
        case green
        case red
    }

    init(id: UUID = UUID(), text: String, type: FlagType) {
        self.id = id
        self.text = text
        self.type = type
    }
}

struct DatePitch: Codable, Identifiable {
    let id: UUID
    let playerID: UUID
    let playerName: String
    let greenFlags: [FlagCard]
    let redFlag: FlagCard
    let additionalText: String
    var votes: Int = 0

    init(id: UUID = UUID(), playerID: UUID, playerName: String, greenFlags: [FlagCard], redFlag: FlagCard, additionalText: String, votes: Int = 0) {
        self.id = id
        self.playerID = playerID
        self.playerName = playerName
        self.greenFlags = greenFlags
        self.redFlag = redFlag
        self.additionalText = additionalText
        self.votes = votes
    }
}

struct RoundResults: Codable {
    let pitches: [DatePitch]
    let chosenPitch: DatePitch?
    let chosenBy: String?
}

// Default flags bank
let defaultGreenFlags: [FlagCard] = [
    FlagCard(text: "Makes me laugh constantly", type: .green),
    FlagCard(text: "Has a stable job and ambitions", type: .green),
    FlagCard(text: "Great listener and empath", type: .green),
    FlagCard(text: "Adventure seeker", type: .green),
    FlagCard(text: "Cooks incredible meals", type: .green),
    FlagCard(text: "Supportive of my dreams", type: .green),
    FlagCard(text: "Financially independent", type: .green),
    FlagCard(text: "Incredibly intelligent", type: .green),
]

let defaultRedFlags: [FlagCard] = [
    FlagCard(text: "Still talks to their ex", type: .red),
    FlagCard(text: "Lives with their mom", type: .red),
    FlagCard(text: "No plans for the future", type: .red),
    FlagCard(text: "Spends all weekend gaming", type: .red),
    FlagCard(text: "Avoids all conflict by ghosting", type: .red),
    FlagCard(text: "\"I'm too busy for a relationship\"", type: .red),
    FlagCard(text: "Has questionable morals", type: .red),
    FlagCard(text: "Is deeply in debt", type: .red),
]

// Payloads
struct SubmitPitchPayload: Codable {
    let playerID: UUID
    let playerName: String
    let greenFlags: [FlagCard]
    let redFlag: FlagCard
    let additionalText: String
}

struct BroadcastPitchesPayload: Codable {
    let pitches: [DatePitch]
}

struct ChooseDatePayload: Codable {
    let chosenPitchID: UUID
    let bachelorID: UUID
}

struct RevealChoicePayload: Codable {
    let chosenPitch: DatePitch
    let chosenBy: String
}
