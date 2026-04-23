import SwiftUI
import MultipeerConnectivity

struct RedFlagsView: View {
    // Note: Player, PlayerDTO, GamePacket, PacketHandler imported via target membership
    @State private var viewModel: RedFlagsViewModel
    let displayName: String

    init(
        multipeerSession: MultipeerSession,
        players: [PlayerDTO],
        localPlayerID: UUID,
        isHost: Bool,
        displayName: String
    ) {
        self.displayName = displayName
        _viewModel = State(
            initialValue: RedFlagsViewModel(
                multipeerSession: multipeerSession,
                players: players,
                localPlayerID: localPlayerID,
                isHost: isHost
            )
        )
    }

    var body: some View {
        VStack {
            Text("Red Flags & Deal Breakers")
                .font(AppTheme.titleFont)
                .foregroundColor(AppTheme.primary)

            Text("Dating show parody - coming soon!")
                .font(AppTheme.bodyFont)
                .foregroundColor(AppTheme.textSecondary)

            Spacer()
        }
        .padding(AppTheme.spacing20)
        .withAppBackground()
        .onAppear {
            if viewModel.isHost {
                viewModel.startGame()
            }
        }
    }
}

#Preview {
    let players = [PlayerDTO(from: Player(displayName: "Alice", avatarColorIndex: 0))]
    return RedFlagsView(
        multipeerSession: MultipeerSession(displayName: "Alice"),
        players: players,
        localPlayerID: players[0].id,
        isHost: true,
        displayName: "Alice"
    )
}
