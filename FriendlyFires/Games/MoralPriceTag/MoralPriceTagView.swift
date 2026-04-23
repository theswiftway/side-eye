import SwiftUI
import MultipeerConnectivity

struct MoralPriceTagView: View {
    // Note: Player, PlayerDTO, GamePacket, PacketHandler imported via target membership
    @State private var viewModel: MoralPriceTagViewModel
    @State private var selectedChoice: Bool?
    @State private var justification: String = ""
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
            initialValue: MoralPriceTagViewModel(
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
                    Text("Moral Price Tag")
                        .font(AppTheme.titleFont)
                        .foregroundColor(AppTheme.primary)
                    Text("Round \(viewModel.currentRoundIndex)/\(viewModel.totalRounds)")
                        .font(AppTheme.bodyFont)
                        .foregroundColor(AppTheme.textSecondary)
                }

                // Dilemma
                if let dilemma = viewModel.currentDilemma, viewModel.gameState == .commit {
                    VStack(spacing: AppTheme.spacing16) {
                        Text(dilemma.text)
                            .font(AppTheme.subtitleFont)
                            .foregroundColor(AppTheme.textPrimary)

                        HStack {
                            Image(systemName: "dollarsign.circle.fill")
                                .foregroundColor(AppTheme.accent)
                            Text("$\(dilemma.amount)")
                                .font(AppTheme.subtitleFont)
                                .foregroundColor(AppTheme.accent)
                        }
                        .padding(AppTheme.spacing12)
                        .background(AppTheme.surfaceAlt)
                        .cornerRadius(AppTheme.cornerMedium)

                        // Choice Buttons
                        HStack(spacing: AppTheme.spacing12) {
                            Button(action: { selectedChoice = true }) {
                                Text("Yes, I would")
                                    .frame(maxWidth: .infinity)
                                    .padding(AppTheme.spacing12)
                                    .background(selectedChoice == true ? AppTheme.primary : AppTheme.surface)
                                    .foregroundColor(selectedChoice == true ? .white : AppTheme.textPrimary)
                                    .cornerRadius(AppTheme.cornerMedium)
                            }

                            Button(action: { selectedChoice = false }) {
                                Text("No way")
                                    .frame(maxWidth: .infinity)
                                    .padding(AppTheme.spacing12)
                                    .background(selectedChoice == false ? AppTheme.secondary : AppTheme.surface)
                                    .foregroundColor(selectedChoice == false ? AppTheme.background : AppTheme.textPrimary)
                                    .cornerRadius(AppTheme.cornerMedium)
                            }
                        }

                        if selectedChoice != nil {
                            VStack(alignment: .leading, spacing: AppTheme.spacing8) {
                                Text("Your justification:")
                                    .font(AppTheme.bodyFont)
                                    .foregroundColor(AppTheme.textSecondary)

                                TextEditor(text: $justification)
                                    .frame(height: 80)
                                    .padding(AppTheme.spacing12)
                                    .background(AppTheme.surfaceAlt)
                                    .cornerRadius(AppTheme.cornerSmall)
                                    .foregroundColor(AppTheme.textPrimary)
                            }

                            Button(action: submitCommit) {
                                Text("Submit")
                                    .frame(maxWidth: .infinity)
                                    .padding(AppTheme.spacing12)
                                    .background(AppTheme.primary)
                                    .foregroundColor(.white)
                                    .cornerRadius(AppTheme.cornerMedium)
                            }
                        }
                    }

                    Spacer()
                }

                // Reveal Phase
                if viewModel.gameState == .reveal {
                    VStack(spacing: AppTheme.spacing16) {
                        Text("Everyone's Choice")
                            .font(AppTheme.subtitleFont)
                            .foregroundColor(AppTheme.primary)

                        ScrollView {
                            VStack(spacing: AppTheme.spacing12) {
                                ForEach(Array(viewModel.playerCommits.values), id: \.playerID) { commit in
                                    HStack {
                                        Image(systemName: commit.wouldDo ? "checkmark.circle.fill" : "xmark.circle.fill")
                                            .foregroundColor(commit.wouldDo ? AppTheme.warning : AppTheme.success)

                                        VStack(alignment: .leading, spacing: AppTheme.spacing4) {
                                            Text(commit.playerName)
                                                .font(AppTheme.bodyFont)
                                                .foregroundColor(AppTheme.textPrimary)

                                            Text(commit.justification)
                                                .font(AppTheme.bodyFont)
                                                .foregroundColor(AppTheme.textSecondary)
                                                .lineLimit(2)
                                        }

                                        Spacer()
                                    }
                                    .padding(AppTheme.spacing12)
                                    .background(AppTheme.surface)
                                    .cornerRadius(AppTheme.cornerSmall)
                                }
                            }
                        }
                    }

                    Spacer()

                    if viewModel.isHost {
                        Button(action: viewModel.advanceRound) {
                            Text("Next Dilemma")
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
                        Text("Final Scores")
                            .font(AppTheme.titleFont)
                            .foregroundColor(AppTheme.primary)

                        ScrollView {
                            VStack(spacing: AppTheme.spacing12) {
                                ForEach(
                                    viewModel.scores.values.sorted { $0.moralScore > $1.moralScore },
                                    id: \.playerID
                                ) { score in
                                    HStack {
                                        Text(score.playerName)
                                            .font(AppTheme.bodyFont)
                                            .foregroundColor(AppTheme.textPrimary)

                                        Spacer()

                                        Text("Moral: \(score.moralScore)")
                                            .font(AppTheme.bodyFont.weight(.semibold))
                                            .foregroundColor(AppTheme.accent)
                                    }
                                    .padding(AppTheme.spacing12)
                                    .background(AppTheme.surface)
                                    .cornerRadius(AppTheme.cornerSmall)
                                }
                            }
                        }
                    }
                    .frame(maxHeight: .infinity)
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

    private func submitCommit() {
        guard let choice = selectedChoice else { return }
        viewModel.submitCommit(wouldDo: choice, justification: justification)
        selectedChoice = nil
        justification = ""
    }
}

#Preview {
    let players = [
        PlayerDTO(from: Player(displayName: "Alice", avatarColorIndex: 0)),
        PlayerDTO(from: Player(displayName: "Bob", avatarColorIndex: 1))
    ]

    return MoralPriceTagView(
        multipeerSession: MultipeerSession(displayName: "Alice"),
        players: players,
        localPlayerID: players[0].id,
        isHost: true,
        displayName: "Alice"
    )
}
