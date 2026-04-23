import Foundation
import SwiftData
import SwiftUI
import MultipeerConnectivity

@Model
final class Player {
    @Attribute(.unique) var id: UUID
    var displayName: String
    var avatarColorIndex: Int
    var isHost: Bool = false
    var joinedAt: Date = Date()

    init(
        id: UUID = UUID(),
        displayName: String,
        avatarColorIndex: Int = 0,
        isHost: Bool = false
    ) {
        self.id = id
        self.displayName = displayName
        self.avatarColorIndex = avatarColorIndex
        self.isHost = isHost
    }

    // Computed: avatar color from theme
    var avatarColor: Color {
        let colors: [Color] = [
            AppTheme.primary, AppTheme.secondary, AppTheme.accent,
            AppTheme.success, AppTheme.warning, AppTheme.error
        ]
        return colors[avatarColorIndex % colors.count]
    }
}

// For use in packet data
struct PlayerDTO: Codable {
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

// Extension to make MCPeerID identifiable (for lists/navigation)
extension MCPeerID: Identifiable {
    public var id: String { displayName }
}
