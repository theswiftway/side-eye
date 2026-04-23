import SwiftUI
import MultipeerConnectivity

struct IslandExileView: View {
    // Note: Player, PlayerDTO, GamePacket, PacketHandler imported via target membership
    @State private var viewModel: IslandExileViewModel
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
            initialValue: IslandExileViewModel(
                multipeerSession: multipeerSession,
                players: players,
                localPlayerID: localPlayerID,
                isHost: isHost
            )
        )
    }

    var body: some View {
        VStack {
            Text("Island Exile")
                .font(AppTheme.titleFont)
                .foregroundColor(AppTheme.primary)

            Text("Survivor-style deduction - coming soon!")
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
    return IslandExileView(
        multipeerSession: MultipeerSession(displayName: "Alice"),
        players: players,
        localPlayerID: players[0].id,
        isHost: true,
        displayName: "Alice"
    )
}
