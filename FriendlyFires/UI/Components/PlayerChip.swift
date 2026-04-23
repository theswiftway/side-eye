import SwiftUI

struct PlayerChip: View {
    let player: PlayerDTO
    var isSelected: Bool = false

    var body: some View {
        HStack(spacing: AppTheme.spacing8) {
            Circle()
                .fill(Color.gray.opacity(0.5))
                .frame(width: 36, height: 36)
                .overlay(Text(String(player.displayName.first ?? "?")).foregroundColor(.white))

            VStack(alignment: .leading, spacing: 2) {
                Text(player.displayName).font(AppTheme.bodyFont).foregroundColor(AppTheme.textPrimary)
                if player.isHost {
                    Text("Host").font(AppTheme.captionFont).foregroundColor(AppTheme.accent)
                }
            }

            Spacer()

            if isSelected {
                Image(systemName: "checkmark.circle.fill").foregroundColor(AppTheme.primary)
            }
        }
        .padding(AppTheme.spacing12)
        .background(isSelected ? AppTheme.primary.opacity(0.1) : AppTheme.surface)
        .cornerRadius(AppTheme.cornerSmall)
    }
}
