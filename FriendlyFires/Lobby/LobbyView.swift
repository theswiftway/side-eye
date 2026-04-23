import SwiftUI

struct LobbyView: View {
    @State private var viewModel = LobbyViewModel()
    @State private var selectedGame: GameType?

    var body: some View {
        VStack(spacing: AppTheme.spacing20) {
            Text("Waiting Room")
                .font(AppTheme.titleFont)
                .foregroundColor(AppTheme.primary)

            ScrollView {
                VStack(spacing: AppTheme.spacing12) {
                    ForEach(viewModel.players, id: \.id) { player in
                        HStack {
                            Circle()
                                .fill(Color.gray.opacity(0.5))
                                .frame(width: 40, height: 40)
                                .overlay(Text(String(player.displayName.first ?? "?")).foregroundColor(.white))

                            Text(player.displayName)
                                .font(AppTheme.bodyFont)
                                .foregroundColor(AppTheme.textPrimary)

                            if player.isHost {
                                Text("Host").font(AppTheme.captionFont).foregroundColor(AppTheme.accent)
                            }

                            Spacer()
                        }
                        .padding(AppTheme.spacing12)
                        .background(AppTheme.surface)
                        .cornerRadius(AppTheme.cornerSmall)
                    }
                }
            }

            if viewModel.isHost {
                VStack(spacing: AppTheme.spacing12) {
                    Text("Select Game").font(AppTheme.subtitleFont).foregroundColor(AppTheme.textPrimary)
                    ForEach(GameType.allCases, id: \.self) { game in
                        Button(action: { selectedGame = game }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(game.rawValue).font(AppTheme.bodyFont).foregroundColor(.white)
                                    Text(game.description).font(AppTheme.captionFont).foregroundColor(.white).opacity(0.7)
                                }
                                Spacer()
                            }
                            .padding(AppTheme.spacing12)
                            .background(selectedGame == game ? AppTheme.primary : AppTheme.surface)
                            .cornerRadius(AppTheme.cornerSmall)
                        }
                    }
                }

                if let selected = selectedGame {
                    Button(action: { viewModel.selectGame(selected) }) {
                        Text("Start \(selected.rawValue)")
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
        .padding(AppTheme.spacing20)
        .withAppBackground()
        .onAppear {
            viewModel.startBrowsing()
        }
    }
}

#Preview {
    LobbyView()
}
