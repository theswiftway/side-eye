import SwiftUI

struct PlayerChip: View {
    let player: PlayerDTO
    let isSelected: Bool
    let isHost: Bool
    var onTap: (() -> Void)?

    var body: some View {
        Button(action: { onTap?() }) {
            HStack(spacing: AppTheme.spacing8) {
                Circle()
                    .fill(player.avatarColor)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Circle()
                            .stroke(AppTheme.textPrimary, lineWidth: isSelected ? 2 : 0)
                    )

                VStack(alignment: .leading, spacing: AppTheme.spacing2) {
                    Text(player.displayName)
                        .font(AppTheme.bodyFont)
                        .foregroundColor(AppTheme.textPrimary)
                        .lineLimit(1)

                    if isHost {
                        Text("HOST")
                            .font(AppTheme.captionFont)
                            .foregroundColor(AppTheme.primary)
                    }
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppTheme.success)
                        .font(.system(size: 16))
                }
            }
            .padding(AppTheme.spacing12)
            .background(isSelected ? AppTheme.primaryLight.opacity(0.15) : AppTheme.surface)
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
    let player = PlayerDTO(
        from: Player(
            displayName: "Alice",
            avatarColorIndex: 0,
            isHost: false
        )
    )

    return VStack(spacing: AppTheme.spacing12) {
        PlayerChip(player: player, isSelected: false, isHost: false)
        PlayerChip(player: player, isSelected: true, isHost: false)
        PlayerChip(player: player, isSelected: false, isHost: true)
    }
    .padding(AppTheme.spacing20)
    .withAppBackground()
}
