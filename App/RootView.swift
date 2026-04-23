import SwiftUI
import Observation

struct RootView: View {
    @State private var displayName: String = ""
    @State private var sessionState: GameSessionState?
    @State private var multipeerSession: MultipeerSession?
    @State private var showLobby: Bool = false

    var body: some View {
        Group {
            if showLobby, let sessionState, let multipeerSession {
                LobbyView(
                    sessionState: sessionState,
                    multipeerSession: multipeerSession,
                    displayName: displayName
                )
            } else {
                LaunchView(
                    displayName: $displayName,
                    onStart: handleStart
                )
            }
        }
        .withAppBackground()
    }

    private func handleStart() {
        guard !displayName.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        let hostID = UUID()
        let sessionState = GameSessionState(
            sessionID: UUID(),
            sessionName: displayName,
            hostID: hostID,
            isHost: true
        )
        let multipeer = MultipeerSession(displayName: displayName)
        multipeer.startHosting(sessionName: displayName)

        self.sessionState = sessionState
        self.multipeerSession = multipeer
        self.showLobby = true
    }
}

// MARK: - Launch View

struct LaunchView: View {
    @Binding var displayName: String
    let onStart: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: AppTheme.spacing32) {
                VStack(spacing: AppTheme.spacing12) {
                    Text("🔥 Friendly Fires")
                        .font(AppTheme.titleFont)
                        .foregroundColor(AppTheme.primary)

                    Text("Party games for groups that know each other")
                        .font(AppTheme.bodyFont)
                        .foregroundColor(AppTheme.textSecondary)
                }
                .padding(.top, AppTheme.spacing32)

                VStack(spacing: AppTheme.spacing16) {
                    VStack(alignment: .leading, spacing: AppTheme.spacing8) {
                        Text("Your Display Name")
                            .font(AppTheme.bodyFont)
                            .foregroundColor(AppTheme.textSecondary)

                        TextField("Enter your name", text: $displayName)
                            .padding(AppTheme.spacing12)
                            .background(AppTheme.surfaceAlt)
                            .cornerRadius(AppTheme.cornerMedium)
                            .foregroundColor(AppTheme.textPrimary)
                    }

                    VStack(spacing: AppTheme.spacing12) {
                        Button(action: onStart) {
                            Text("Host a Game")
                                .frame(maxWidth: .infinity)
                                .padding(AppTheme.spacing16)
                                .background(AppTheme.primary)
                                .foregroundColor(.white)
                                .cornerRadius(AppTheme.cornerMedium)
                                .font(AppTheme.bodyFont)
                        }
                        .disabled(displayName.trimmingCharacters(in: .whitespaces).isEmpty)

                        NavigationLink("Join a Game", destination: JoinGameView(displayName: displayName))
                            .frame(maxWidth: .infinity)
                            .padding(AppTheme.spacing16)
                            .background(AppTheme.secondary)
                            .foregroundColor(AppTheme.background)
                            .cornerRadius(AppTheme.cornerMedium)
                            .font(AppTheme.bodyFont)
                            .disabled(displayName.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }

                Spacer()
            }
            .padding(AppTheme.spacing24)
        }
    }
}

// MARK: - Join Game View (Placeholder)

struct JoinGameView: View {
    let displayName: String

    var body: some View {
        VStack {
            Text("Join Game")
                .font(AppTheme.subtitleFont)
            Text("Feature coming soon")
                .foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .withAppBackground()
    }
}

#Preview {
    RootView()
}
