import SwiftUI

struct RootView: View {
    @State private var showLobby = false

    var body: some View {
        if showLobby {
            LobbyView()
        } else {
            VStack(spacing: 20) {
                Text("Friendly Fires")
                    .font(AppTheme.titleFont)
                    .foregroundColor(AppTheme.primary)

                Spacer()

                Button(action: { showLobby = true }) {
                    Text("Enter Lobby")
                        .frame(maxWidth: .infinity)
                        .padding(AppTheme.spacing16)
                        .background(AppTheme.primary)
                        .foregroundColor(.white)
                        .cornerRadius(AppTheme.cornerMedium)
                }

                Spacer()
            }
            .padding(AppTheme.spacing20)
            .withAppBackground()
        }
    }
}

#Preview {
    RootView()
}
