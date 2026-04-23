import SwiftUI

struct TimerRing: View {
    let remainingSeconds: Int
    let totalSeconds: Int

    var progress: Double {
        totalSeconds > 0 ? Double(remainingSeconds) / Double(totalSeconds) : 0
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(AppTheme.surfaceAlt, lineWidth: 4)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(AppTheme.primary, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))

            Text("\(remainingSeconds)s")
                .font(AppTheme.titleFont)
                .foregroundColor(AppTheme.primary)
        }
        .frame(width: 120, height: 120)
    }
}
