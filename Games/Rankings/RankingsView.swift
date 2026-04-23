import SwiftUI

struct RankingsView: View {
    @State private var viewModel: RankingsViewModel
    @State private var rankings: [UUID: Int] = [:]
    @State private var selectedPlayerID: UUID?

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
            initialValue: RankingsViewModel(
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
                // Question
                if let question = viewModel.currentQuestion {
                    VStack(spacing: AppTheme.spacing12) {
                        Text("Round \(viewModel.currentQuestionIndex)/\(viewModel.questions.count)")
                            .font(AppTheme.captionFont)
                            .foregroundColor(AppTheme.textSecondary)

                        Text(question.text)
                            .font(AppTheme.subtitleFont)
                            .foregroundColor(AppTheme.textPrimary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(AppTheme.spacing16)
                    .frame(maxWidth: .infinity)
                    .background(AppTheme.surface)
                    .cornerRadius(AppTheme.cornerMedium)
                }

                // Ranking UI
                if viewModel.gameState == .ranking {
                    ScrollView {
                        VStack(spacing: AppTheme.spacing12) {
                            Text("Rank everyone (1 = most likely)")
                                .font(AppTheme.bodyFont)
                                .foregroundColor(AppTheme.textSecondary)

                            ForEach(viewModel.players.filter { $0.id != viewModel.localPlayerID }, id: \.id) { player in
                                RankingSliderRow(
                                    player: player,
                                    currentRank: rankings[player.id] ?? 0,
                                    maxPlayers: viewModel.players.count - 1,
                                    onRankChange: { newRank in
                                        rankings[player.id] = newRank
                                    }
                                )
                            }
                        }
                    }

                    Spacer()

                    // Submit Button
                    if rankingsComplete {
                        Button(action: submitRankings) {
                            Text("Submit Rankings")
                                .frame(maxWidth: .infinity)
                                .padding(AppTheme.spacing16)
                                .background(AppTheme.primary)
                                .foregroundColor(.white)
                                .cornerRadius(AppTheme.cornerMedium)
                                .font(AppTheme.bodyFont.weight(.semibold))
                        }
                    } else {
                        Text("Rank all players to submit")
                            .font(AppTheme.bodyFont)
                            .foregroundColor(AppTheme.textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(AppTheme.spacing16)
                    }
                }

                // Results View
                if viewModel.gameState == .reveal, let results = viewModel.currentResults {
                    ResultsView(results: results, players: viewModel.players)

                    Spacer()

                    if viewModel.isHost {
                        Button(action: viewModel.advanceQuestion) {
                            Text("Next Question")
                                .frame(maxWidth: .infinity)
                                .padding(AppTheme.spacing16)
                                .background(AppTheme.secondary)
                                .foregroundColor(AppTheme.background)
                                .cornerRadius(AppTheme.cornerMedium)
                                .font(AppTheme.bodyFont.weight(.semibold))
                        }
                    }
                }

                // Game Over
                if viewModel.gameState == .gameOver {
                    VStack(spacing: AppTheme.spacing20) {
                        Text("Game Over!")
                            .font(AppTheme.titleFont)
                            .foregroundColor(AppTheme.primary)

                        Text("Thanks for playing The Rankings!")
                            .font(AppTheme.bodyFont)
                            .foregroundColor(AppTheme.textSecondary)
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

    private var rankingsComplete: Bool {
        let otherPlayerCount = viewModel.players.count - 1
        return rankings.count == otherPlayerCount &&
            rankings.values.allSatisfy { $0 > 0 }
    }

    private func submitRankings() {
        viewModel.submitRanking(rankings)
    }
}

// MARK: - Ranking Slider Row

struct RankingSliderRow: View {
    let player: PlayerDTO
    let currentRank: Int
    let maxPlayers: Int
    let onRankChange: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing8) {
            HStack {
                Circle()
                    .fill(player.avatarColor)
                    .frame(width: 28, height: 28)

                Text(player.displayName)
                    .font(AppTheme.bodyFont)
                    .foregroundColor(AppTheme.textPrimary)

                Spacer()

                if currentRank > 0 {
                    Text("Rank \(currentRank)")
                        .font(AppTheme.bodyFont.weight(.semibold))
                        .foregroundColor(AppTheme.primary)
                } else {
                    Text("Not ranked")
                        .font(AppTheme.bodyFont)
                        .foregroundColor(AppTheme.textTertiary)
                }
            }

            Slider(value: Binding(
                get: { Double(currentRank) },
                set: { onRankChange(Int($0)) }
            ), in: 0...Double(maxPlayers), step: 1)
            .tint(AppTheme.primary)
        }
        .padding(AppTheme.spacing12)
        .background(AppTheme.surfaceAlt)
        .cornerRadius(AppTheme.cornerSmall)
    }
}

// MARK: - Results View

struct ResultsView: View {
    let results: QuestionResults
    let players: [PlayerDTO]

    var body: some View {
        VStack(spacing: AppTheme.spacing16) {
            Text("Results")
                .font(AppTheme.subtitleFont)
                .foregroundColor(AppTheme.textPrimary)

            VStack(spacing: AppTheme.spacing12) {
                ForEach(
                    results.averageRanks.sorted { $0.value < $1.value }.prefix(3),
                    id: \.key
                ) { (playerID, avgRank) in
                    if let player = players.first(where: { $0.id == playerID }) {
                        HStack {
                            Circle()
                                .fill(player.avatarColor)
                                .frame(width: 32, height: 32)

                            Text(player.displayName)
                                .font(AppTheme.bodyFont)
                                .foregroundColor(AppTheme.textPrimary)

                            Spacer()

                            Text(String(format: "Avg: %.1f", avgRank))
                                .font(AppTheme.bodyFont.weight(.semibold))
                                .foregroundColor(AppTheme.primary)
                        }
                        .padding(AppTheme.spacing12)
                        .background(AppTheme.surface)
                        .cornerRadius(AppTheme.cornerSmall)
                    }
                }
            }
        }
    }
}

#Preview {
    let players = [
        PlayerDTO(from: Player(displayName: "Alice", avatarColorIndex: 0)),
        PlayerDTO(from: Player(displayName: "Bob", avatarColorIndex: 1)),
        PlayerDTO(from: Player(displayName: "Charlie", avatarColorIndex: 2))
    ]

    return RankingsView(
        multipeerSession: MultipeerSession(displayName: "Alice"),
        players: players,
        localPlayerID: players[0].id,
        isHost: true,
        displayName: "Alice"
    )
}
