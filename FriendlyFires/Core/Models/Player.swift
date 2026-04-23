import Foundation
import SwiftData

@Model
final class Player {
    var id: UUID = UUID()
    var displayName: String
    var avatarColorIndex: Int
    var isHost: Bool = false

    init(displayName: String, avatarColorIndex: Int, isHost: Bool = false) {
        self.displayName = displayName
        self.avatarColorIndex = avatarColorIndex
        self.isHost = isHost
    }
}

struct PlayerDTO: Codable, Identifiable {
    let id: UUID
    let displayName: String
    let avatarColorIndex: Int
    let isHost: Bool

    init(from player: Player) {
        self.id = player.id
        self.displayName = player.displayName
        self.avatarColorIndex = player.avatarColorIndex
        self.isHost = player.isHost
    }
}
