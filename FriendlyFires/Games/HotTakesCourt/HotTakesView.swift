import SwiftUI
import MultipeerConnectivity

struct HotTakesView: View {
    // Note: Player, PlayerDTO, GamePacket, PacketHandler imported via target membership
    @State private var viewModel: HotTakesViewModel
    @State private var takeText: String = ""
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
            initialValue: HotTakesViewModel(
                multipeerSession: multipeerSession,
                players: players,
                localPlayerID: localPlayerID,
                isHost: isHost
            )
        )
    }

    var body: some View {
        ZStack {
            VStack(spacing: AppTheme.spacing20) {
                // Header
                VStack(spacing: AppTheme.spacing8) {
                    Text("Hot Takes Court")
                        .font(AppTheme.titleFont)
                        .foregroundColor(AppTheme.primary)

                    Text("Round \(viewModel.roundsCompleted)/\(viewModel.totalRounds)")
                        .font(AppTheme.bodyFont)
                        .foregroundColor(AppTheme.textSecondary)
                }

                // Submission Phase
                if viewModel.gameState == .submission {
                    VStack(spacing: AppTheme.spacing12) {
                        Text("Submit your spiciest take 🌶️")
                            .font(AppTheme.subtitleFont)
                            .foregroundColor(AppTheme.textPrimary)

                        TextEditor(text: $takeText)
                            .frame(height: 100)
                            .padding(AppTheme.spacing12)
                            .background(AppTheme.surfaceAlt)
                            .cornerRadius(AppTheme.cornerMedium)
                            .foregroundColor(AppTheme.textPrimary)

                        Button(action: submitTake) {
                            Text("Submit")
                                .frame(maxWidth: .infinity)
                                .padding(AppTheme.spacing12)
                                .background(takeText.trimmingCharacters(in: .whitespaces).isEmpty ? AppTheme.surfaceAlt : AppTheme.primary)
                                .foregroundColor(takeText.trimmingCharacters(in: .whitespaces).isEmpty ? AppTheme.textTertiary : .white)
                                .cornerRadius(AppTheme.cornerMedium)
                        }
                        .disabled(takeText.trimmingCharacters(in: .whitespaces).isEmpty)
                    }

                    Spacer()
                }

                // Voting Phase
                if viewModel.gameState == .voting {
                    VStack(spacing: AppTheme.spacing16) {
                        Text("Vote hot 🔥 or cold ❄️")
                            .font(AppTheme.subtitleFont)
                            .foregroundColor(AppTheme.textPrimary)

                        ScrollView {
                            VStack(spacing: AppTheme.spacing12) {
                                ForEach(viewModel.currentRound.takes, id: \.id) { take in
                                    TakeVoteCard(
                                        take: take,
                                        onHotTap: { viewModel.submitVote(take.id, isHot: true) },
                                        onColdTap: { viewModel.submitVote(take.id, isHot: false) }
                                    )
                                }
                            }
                        }
                    }

                    Spacer()
                }

                // Reveal Phase
                if viewModel.gameState == .reveal {
                    VStack(spacing: AppTheme.spacing16) {
                        Text("Results 🏆")
                            .font(AppTheme.subtitleFont)
                            .foregroundColor(AppTheme.primary)

                        ScrollView {
                            VStack(spacing: AppTheme.spacing12) {
                                ForEach(viewModel.results.prefix(5), id: \.id) { take in
                                    ResultCard(take: take)
                                }
                            }
                        }
                    }

                    Spacer()

                    if viewModel.isHost {
                        Button(action: viewModel.advanceRound) {
                            Text("Next Round")
                                .frame(maxWidth: .infinity)
                                .padding(AppTheme.spacing12)
                                .background(AppTheme.secondary)
                                .foregroundColor(AppTheme.background)
                                .cornerRadius(AppTheme.cornerMedium)
                        }
                    }
                }

                // Game Over
                if viewModel.gameState == .gameOver {
                    VStack(spacing: AppTheme.spacing20) {
                        Text("Game Over!")
                            .font(AppTheme.titleFont)
                            .foregroundColor(AppTheme.primary)

                        if let hottest = viewModel.results.first {
                            VStack(spacing: AppTheme.spacing8) {
                                Text("🔥 Hottest Take 🔥")
                                    .font(AppTheme.subtitleFont)
                                    .foregroundColor(AppTheme.primary)

                                Text(hottest.text)
                                    .font(AppTheme.bodyFont)
                                    .foregroundColor(AppTheme.textPrimary)

                                Text("by \(hottest.playerName)")
                                    .font(AppTheme.bodyFont)
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                            .padding(AppTheme.spacing16)
                            .background(AppTheme.surface)
                            .cornerRadius(AppTheme.cornerMedium)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .padding(AppTheme.spacing20)
        }
        .withAppBackground()
        .onAppear {
            if viewModel.isHost {
                viewModel.startGame()
            }
        }
    }

    private func submitTake() {
        guard !takeText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        viewModel.submitTake(takeText)
        takeText = ""
    }
}

// MARK: - Take Vote Card

struct TakeVoteCard: View {
    let take: Take
    let onHotTap: () -> Void
    let onColdTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing12) {
            Text(take.text)
                .font(AppTheme.bodyFont)
                .foregroundColor(AppTheme.textPrimary)
                .lineLimit(3)

            HStack(spacing: AppTheme.spacing12) {
                Button(action: onHotTap) {
                    HStack {
                        Image(systemName: "flame.fill")
                        Text("Hot")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(AppTheme.spacing12)
                    .background(AppTheme.primary)
                    .foregroundColor(.white)
                    .cornerRadius(AppTheme.cornerSmall)
                }

                Button(action: onColdTap) {
                    HStack {
                        Image(systemName: "snowflake")
                        Text("Cold")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(AppTheme.spacing12)
                    .background(AppTheme.secondary)
                    .foregroundColor(AppTheme.background)
                    .cornerRadius(AppTheme.cornerSmall)
                }
            }
        }
        .padding(AppTheme.spacing16)
        .background(AppTheme.surface)
        .cornerRadius(AppTheme.cornerMedium)
    }
}

// MARK: - Result Card

struct ResultCard: View {
    let take: Take

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing8) {
            Text(take.text)
                .font(AppTheme.bodyFont)
                .foregroundColor(AppTheme.textPrimary)

            HStack(spacing: AppTheme.spacing8) {
                VoteBar(label: "🔥 Hot", voteCount: take.hotVotes, maxVotes: 10, color: AppTheme.primary)
                VoteBar(label: "❄️ Cold", voteCount: take.coldVotes, maxVotes: 10, color: AppTheme.secondary)
            }

            Text("— \(take.playerName)")
                .font(AppTheme.captionFont)
                .foregroundColor(AppTheme.textSecondary)
                .italic()
        }
        .padding(AppTheme.spacing16)
        .background(AppTheme.surface)
        .cornerRadius(AppTheme.cornerMedium)
    }
}

#Preview {
    let players = [
        PlayerDTO(from: Player(displayName: "Alice", avatarColorIndex: 0)),
        PlayerDTO(from: Player(displayName: "Bob", avatarColorIndex: 1))
    ]

    return HotTakesView(
        multipeerSession: MultipeerSession(displayName: "Alice"),
        players: players,
        localPlayerID: players[0].id,
        isHost: true,
        displayName: "Alice"
    )
}
