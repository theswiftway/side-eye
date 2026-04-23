import SwiftUI

struct LobbyView: View {
    @State private var viewModel: LobbyViewModel
    let sessionState: GameSessionState
    let multipeerSession: MultipeerSession
    let displayName: String

    init(
        sessionState: GameSessionState,
        multipeerSession: MultipeerSession,
        displayName: String
    ) {
        self.sessionState = sessionState
        self.multipeerSession = multipeerSession
        self.displayName = displayName

        let localPlayerID = UUID()
        _viewModel = State(
            initialValue: LobbyViewModel(
                sessionState: sessionState,
                multipeerSession: multipeerSession,
                localPlayerID: localPlayerID,
                isHost: true
            )
        )
    }

    var body: some View {
        VStack(spacing: AppTheme.spacing20) {
            // Header
            VStack(spacing: AppTheme.spacing8) {
                Text("Waiting Room")
                    .font(AppTheme.titleFont)
                    .foregroundColor(AppTheme.primary)

                Text(sessionState.sessionName)
                    .font(AppTheme.bodyFont)
                    .foregroundColor(AppTheme.textSecondary)
            }

            // Players List
            VStack(alignment: .leading, spacing: AppTheme.spacing12) {
                Text("Players (\(viewModel.players.count) / \(multipeerSession.connectedPeers.count + 1))")
                    .font(AppTheme.subtitleFont)
                    .foregroundColor(AppTheme.textPrimary)

                ScrollView {
                    VStack(spacing: AppTheme.spacing8) {
                        HStack {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 12, height: 12)
                            Text(displayName)
                                .font(AppTheme.bodyFont)
                                .foregroundColor(AppTheme.textPrimary)
                            Spacer()
                            Text("HOST")
                                .font(AppTheme.captionFont)
                                .foregroundColor(AppTheme.primary)
                        }
                        .padding(AppTheme.spacing12)
                        .cardStyle()

                        ForEach(viewModel.players, id: \.id) { player in
                            HStack {
                                Circle()
                                    .fill(player.avatarColor)
                                    .frame(width: 12, height: 12)
                                Text(player.displayName)
                                    .font(AppTheme.bodyFont)
                                    .foregroundColor(AppTheme.textPrimary)
                                Spacer()
                            }
                            .padding(AppTheme.spacing12)
                            .cardStyle()
                        }
                    }
                }
            }

            if viewModel.isHost {
                Divider()
                    .background(AppTheme.surfaceAlt)

                // Game Selection (Host only)
                VStack(alignment: .leading, spacing: AppTheme.spacing12) {
                    Text("Select a Game")
                        .font(AppTheme.subtitleFont)
                        .foregroundColor(AppTheme.textPrimary)

                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: AppTheme.spacing12) {
                            ForEach(GameType.allCases, id: \.self) { game in
                                GameSelectionCard(
                                    game: game,
                                    isSelected: viewModel.selectedGame == game,
                                    action: { viewModel.selectGame(game) }
                                )
                            }
                        }
                    }
                }

                Spacer()

                if let selectedGame = viewModel.selectedGame,
                   viewModel.players.count >= selectedGame.minPlayers {
                    Button(action: viewModel.startGame) {
                        Text("Start Game: \(selectedGame.displayName)")
                            .frame(maxWidth: .infinity)
                            .padding(AppTheme.spacing16)
                            .background(AppTheme.primary)
                            .foregroundColor(.white)
                            .cornerRadius(AppTheme.cornerMedium)
                            .font(AppTheme.bodyFont)
                    }
                }
            } else {
                Spacer()
                Text("Waiting for host to start...")
                    .font(AppTheme.bodyFont)
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
        .padding(AppTheme.spacing20)
        .withAppBackground()
    }
}

// MARK: - Game Selection Card

struct GameSelectionCard: View {
    let game: GameType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: AppTheme.spacing8) {
                Text(game.displayName)
                    .font(AppTheme.subtitleFont)
                    .foregroundColor(AppTheme.textPrimary)

                Text(game.description)
                    .font(AppTheme.bodyFont)
                    .foregroundColor(AppTheme.textSecondary)
                    .lineLimit(2)

                HStack {
                    Text("Min: \(game.minPlayers) | Max: \(game.maxPlayers)")
                        .font(AppTheme.captionFont)
                        .foregroundColor(AppTheme.textTertiary)
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(AppTheme.success)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(AppTheme.spacing12)
            .background(isSelected ? AppTheme.primaryLight.opacity(0.2) : AppTheme.surface)
            .cornerRadius(AppTheme.cornerMedium)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerMedium)
                    .stroke(
                        isSelected ? AppTheme.primary : AppTheme.surfaceAlt,
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
    }
}

#Preview {
    let sessionState = GameSessionState(
        sessionID: UUID(),
        sessionName: "Test Session",
        hostID: UUID(),
        isHost: true
    )
    let multipeerSession = MultipeerSession(displayName: "TestHost")

    return LobbyView(
        sessionState: sessionState,
        multipeerSession: multipeerSession,
        displayName: "TestHost"
    )
}
