import Foundation

enum GameType: String, Codable, CaseIterable {
    case rankings = "The Rankings"
    case hotTakesCourt = "Hot Takes Court"
    case moralPriceTag = "Moral Price Tag"
    case islandExile = "Island Exile"
    case redFlags = "Red Flags"

    var displayName: String {
        rawValue
    }

    var description: String {
        switch self {
        case .rankings:
            return "Anonymous heat-map polls. Who'd survive the apocalypse? See how the group ranks each other."
        case .hotTakesCourt:
            return "Submit spicy opinions. The group votes hot or cold. Then we reveal who said what."
        case .moralPriceTag:
            return "Escalating moral dilemmas with dollar amounts. Would you sell out for $500?"
        case .islandExile:
            return "Survivor-style deduction. Secret roles. Vote someone off each round. Betrayals guaranteed."
        case .redFlags:
            return "Dating show parody. Pitch dates with green flags and red flags. Watch someone pick you anyway."
        }
    }

    var minPlayers: Int {
        switch self {
        case .rankings, .hotTakesCourt, .islandExile, .redFlags:
            return 3
        case .moralPriceTag:
            return 2
        }
    }

    var maxPlayers: Int { 8 }
}
