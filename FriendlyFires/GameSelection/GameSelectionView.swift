import SwiftUI
import UIKit

struct GameSelectionView: View {
    @State private var viewModel = GameSelectionViewModel()

    var body: some View {
        VStack(spacing: AppTheme.spacing20) {
            Text("Select Your Game")
                .font(AppTheme.titleFont)
                .foregroundColor(AppTheme.primary)

            ScrollView {
                VStack(spacing: AppTheme.spacing16) {
                    ForEach(GameType.allCases, id: \.self) { game in
                        NavigationLink(destination: gameView(for: game)) {
                            VStack(alignment: .leading, spacing: AppTheme.spacing8) {
                                Text(game.rawValue)
                                    .font(AppTheme.subtitleFont)
                                    .foregroundColor(.white)

                                Text(game.description)
                                    .font(AppTheme.bodyFont)
                                    .foregroundColor(.white.opacity(0.7))

                                HStack {
                                    Text("Players: \(game.minPlayers)-\(game.maxPlayers)")
                                        .font(AppTheme.captionFont)
                                        .foregroundColor(.white.opacity(0.6))
                                    Spacer()
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(AppTheme.spacing16)
                            .background(AppTheme.primary)
                            .cornerRadius(AppTheme.cornerMedium)
                        }
                    }
                }
            }

            Spacer()
        }
        .padding(AppTheme.spacing20)
        .withAppBackground()
    }

    @ViewBuilder
    private func gameView(for gameType: GameType) -> some View {
        let multipeerSession = MultipeerSession(displayName: UIDevice.current.name)
        let players: [PlayerDTO] = []
        let localPlayerID = UUID()

        switch gameType {
        case .rankings:
            Text("Rankings - Coming Soon").font(AppTheme.titleFont)
        case .hotTakes:
            HotTakesView(
                multipeerSession: multipeerSession,
                players: players,
                localPlayerID: localPlayerID,
                isHost: true,
                displayName: UIDevice.current.name
            )
        case .moralPriceTag:
            MoralPriceTagView(
                multipeerSession: multipeerSession,
                players: players,
                localPlayerID: localPlayerID,
                isHost: true,
                displayName: UIDevice.current.name
            )
        case .islandExile:
            IslandExileView(
                multipeerSession: multipeerSession,
                players: players,
                localPlayerID: localPlayerID,
                isHost: true,
                displayName: UIDevice.current.name
            )
        case .redFlags:
            RedFlagsView(
                multipeerSession: multipeerSession,
                players: players,
                localPlayerID: localPlayerID,
                isHost: true,
                displayName: UIDevice.current.name
            )
        }
    }
}

#Preview {
    GameSelectionView()
}
