import SwiftUI

struct GameSelectionView: View {
    @State private var viewModel: GameSelectionViewModel
    let displayName: String

    init(
        sessionState: GameSessionState,
        multipeerSession: MultipeerSession,
        isHost: Bool,
        players: [PlayerDTO],
        displayName: String
    ) {
        self.displayName = displayName
        _viewModel = State(
            initialValue: GameSelectionViewModel(
                sessionState: sessionState,
                multipeerSession: multipeerSession,
                isHost: isHost,
                players: players
            )
        )
    }

    var body: some View {
        ZStack {
            VStack(spacing: AppTheme.spacing20) {
                // Header
                VStack(spacing: AppTheme.spacing8) {
                    Text("Pick Your Game")
                        .font(AppTheme.titleFont)
                        .foregroundColor(AppTheme.primary)

                    if !viewModel.isHost {
                        Text("Host is selecting...")
                            .font(AppTheme.bodyFont)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }

                // Players Row
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppTheme.spacing8) {
                        ForEach(viewModel.players, id: \.id) { player in
                            VStack(spacing: AppTheme.spacing4) {
                                Circle()
                                    .fill(player.avatarColor)
                                    .frame(width: 40, height: 40)

                                Text(player.displayName)
                                    .font(AppTheme.captionFont)
                                    .foregroundColor(AppTheme.textPrimary)
                                    .lineLimit(1)
                            }
                        }
                    }
                    .padding(AppTheme.spacing12)
                }

                // Games Grid
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: AppTheme.spacing12) {
                        ForEach(GameType.allCases, id: \.self) { game in
                            GameCardLarge(
                                game: game,
                                isSelected: viewModel.selectedGame == game,
                                minPlayersReached: viewModel.players.count >= game.minPlayers,
                                canSelect: viewModel.isHost,
                                action: { viewModel.selectGame(game) }
                            )
                        }
                    }
                }

                Spacer()

                // Start Button
                if viewModel.isHost {
                    Button(action: viewModel.startGame) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Start Game")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(AppTheme.spacing16)
                        .background(viewModel.canStart ? AppTheme.primary : AppTheme.surfaceAlt)
                        .foregroundColor(viewModel.canStart ? .white : AppTheme.textTertiary)
                        .cornerRadius(AppTheme.cornerMedium)
                        .font(AppTheme.bodyFont.weight(.semibold))
                    }
                    .disabled(!viewModel.canStart)
                }
            }
            .padding(AppTheme.spacing20)
        }
        .withAppBackground()
    }
}

// MARK: - Large Game Card

struct GameCardLarge: View {
    let game: GameType
    let isSelected: Bool
    let minPlayersReached: Bool
    let canSelect: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: AppTheme.spacing12) {
                HStack {
                    VStack(alignment: .leading, spacing: AppTheme.spacing8) {
                        Text(game.displayName)
                            .font(AppTheme.subtitleFont)
                            .foregroundColor(AppTheme.textPrimary)

                        Text(game.description)
                            .font(AppTheme.bodyFont)
                            .foregroundColor(AppTheme.textSecondary)
                            .lineLimit(2)

                        HStack(spacing: AppTheme.spacing8) {
                            Label("\(game.minPlayers)–\(game.maxPlayers)", systemImage: "person.2.fill")
                                .font(AppTheme.captionFont)
                                .foregroundColor(
                                    minPlayersReached ? AppTheme.success : AppTheme.warning
                                )
                        }
                    }

                    Spacer()

                    if isSelected {
                        VStack {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(AppTheme.primary)
                            Spacer()
                        }
                    }
                }

                if !minPlayersReached {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 12))
                        Text("Need \(game.minPlayers - (4)) more players")
                            .font(AppTheme.captionFont)
                        Spacer()
                    }
                    .foregroundColor(AppTheme.warning)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(AppTheme.spacing16)
            .background(
                isSelected ? AppTheme.primaryLight.opacity(0.2) : AppTheme.surface
            )
            .cornerRadius(AppTheme.cornerMedium)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerMedium)
                    .stroke(
                        isSelected ? AppTheme.primary : AppTheme.surfaceAlt,
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .opacity(canSelect ? 1.0 : 0.6)
        }
        .disabled(!canSelect)
    }
}

#Preview {
    let sessionState = GameSessionState(
        sessionID: UUID(),
        sessionName: "Test",
        hostID: UUID(),
        isHost: true
    )
    let multipeerSession = MultipeerSession(displayName: "TestPlayer")

    return GameSelectionView(
        sessionState: sessionState,
        multipeerSession: multipeerSession,
        isHost: true,
        players: [
            PlayerDTO(from: Player(displayName: "Alice", avatarColorIndex: 0)),
            PlayerDTO(from: Player(displayName: "Bob", avatarColorIndex: 1)),
            PlayerDTO(from: Player(displayName: "Charlie", avatarColorIndex: 2))
        ],
        displayName: "Alice"
    )
}
