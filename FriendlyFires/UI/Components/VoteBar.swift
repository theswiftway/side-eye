import SwiftUI

struct VoteBar: View {
    let label: String
    let voteCount: Int
    let maxVotes: Int
    let color: Color

    var progress: Double {
        maxVotes > 0 ? Double(voteCount) / Double(maxVotes) : 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacing4) {
            HStack {
                Text(label).font(AppTheme.bodyFont).foregroundColor(AppTheme.textPrimary)
                Spacer()
                Text("\(voteCount)").font(AppTheme.bodyFont.weight(.semibold)).foregroundColor(color)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: AppTheme.cornerSmall)
                        .fill(AppTheme.surfaceAlt)

                    RoundedRectangle(cornerRadius: AppTheme.cornerSmall)
                        .fill(color)
                        .frame(width: geometry.size.width * progress)
                }
            }
            .frame(height: 8)
        }
    }
}
