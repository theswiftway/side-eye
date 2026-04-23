import SwiftUI

struct VoteBar: View {
    let label: String
    let voteCount: Int
    let maxVotes: Int
    let color: Color

    private var percentage: Double {
        guard maxVotes > 0 else { return 0 }
        return Double(voteCount) / Double(maxVotes)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing8) {
            HStack {
                Text(label)
                    .font(AppTheme.bodyFont)
                    .foregroundColor(AppTheme.textPrimary)

                Spacer()

                Text("\(voteCount)")
                    .font(AppTheme.bodyFont)
                    .foregroundColor(color)
                    .fontWeight(.semibold)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: AppTheme.cornerSmall)
                        .fill(AppTheme.surfaceAlt)

                    RoundedRectangle(cornerRadius: AppTheme.cornerSmall)
                        .fill(color)
                        .frame(width: geometry.size.width * percentage)
                }
            }
            .frame(height: 12)
        }
    }
}

#Preview {
    VStack(spacing: AppTheme.spacing16) {
        VoteBar(label: "Hot 🔥", voteCount: 12, maxVotes: 20, color: AppTheme.primary)
        VoteBar(label: "Cold ❄️", voteCount: 8, maxVotes: 20, color: AppTheme.secondary)
        VoteBar(label: "Neutral 😐", voteCount: 20, maxVotes: 20, color: AppTheme.accent)
    }
    .padding(AppTheme.spacing20)
    .withAppBackground()
}
