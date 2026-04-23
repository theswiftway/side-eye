import Foundation

enum GameType: String, Codable, CaseIterable {
    case rankings = "The Rankings"
    case hotTakes = "Hot Takes Court"
    case moralPriceTag = "Moral Price Tag"
    case islandExile = "Island Exile"
    case redFlags = "Red Flags"

    var description: String {
        switch self {
        case .rankings:
            return "Rank your friends anonymously"
        case .hotTakes:
            return "Vote hot or cold on spicy opinions"
        case .moralPriceTag:
            return "Would you do it for the money?"
        case .islandExile:
            return "Deduction game with secret roles"
        case .redFlags:
            return "Dating show parody with card deals"
        }
    }

    var minPlayers: Int {
        switch self {
        case .rankings, .hotTakes, .moralPriceTag, .islandExile:
            return 2
        case .redFlags:
            return 3
        }
    }

    var maxPlayers: Int { 8 }
}
