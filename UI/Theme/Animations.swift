import SwiftUI

struct Animations {
    static let quick = Animation.easeInOut(duration: 0.2)
    static let standard = Animation.easeInOut(duration: 0.3)
    static let smooth = Animation.easeInOut(duration: 0.5)
    static let slow = Animation.easeInOut(duration: 0.8)

    static let bounce = Animation.spring(response: 0.6, dampingFraction: 0.7)
    static let springy = Animation.spring(response: 0.5, dampingFraction: 0.5)

    static func delay(_ seconds: Double) -> Animation {
        Animation.easeInOut(duration: 0.3).delay(seconds)
    }
}

// MARK: - Transition Helpers

extension AnyTransition {
    static var slideInFromBottom: AnyTransition {
        AnyTransition.move(edge: .bottom).combined(with: .opacity)
    }

    static var slideInFromTop: AnyTransition {
        AnyTransition.move(edge: .top).combined(with: .opacity)
    }

    static var fadeScale: AnyTransition {
        AnyTransition.scale.combined(with: .opacity)
    }
}
