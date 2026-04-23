import SwiftUI

struct TimerRing: View {
    let duration: TimeInterval
    let isRunning: Bool
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?

    private var percentage: Double {
        guard duration > 0 else { return 0 }
        return min(elapsedTime / duration, 1.0)
    }

    private var remainingSeconds: Int {
        Int(max(duration - elapsedTime, 0))
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(AppTheme.surfaceAlt, lineWidth: 4)

            Circle()
                .trim(from: 0, to: percentage)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [AppTheme.primary, AppTheme.primaryLight]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear, value: percentage)

            VStack(spacing: AppTheme.spacing4) {
                Text("\(remainingSeconds)")
                    .font(.system(size: 48, weight: .bold, design: .default))
                    .foregroundColor(AppTheme.textPrimary)
                    .monospacedDigit()

                Text("seconds")
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
        .onReceive(Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()) { _ in
            guard isRunning else { return }
            elapsedTime += 0.1
            if elapsedTime >= duration {
                timer?.invalidate()
                timer = nil
            }
        }
        .onChange(of: isRunning) {
            if !isRunning {
                timer?.invalidate()
            }
        }
    }
}

#Preview {
    VStack(spacing: AppTheme.spacing32) {
        TimerRing(duration: 60, isRunning: true)
            .frame(width: 120, height: 120)

        TimerRing(duration: 30, isRunning: false)
            .frame(width: 100, height: 100)
    }
    .padding(AppTheme.spacing20)
    .withAppBackground()
}
