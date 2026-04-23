import SwiftUI

struct AppTheme {
    // Colors
    static let primary = Color(red: 1.0, green: 0.2, blue: 0.5)        // Hot pink
    static let secondary = Color(red: 0.0, green: 1.0, blue: 1.0)      // Cyan
    static let accent = Color(red: 1.0, green: 0.8, blue: 0.0)         // Gold
    static let success = Color(red: 0.2, green: 0.8, blue: 0.2)        // Green
    static let warning = Color(red: 1.0, green: 0.5, blue: 0.0)        // Orange

    static let background = Color(UIColor { $0.userInterfaceStyle == .dark ? UIColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 1) : UIColor(red: 0.95, green: 0.95, blue: 0.98, alpha: 1) })
    static let surface = Color(UIColor { $0.userInterfaceStyle == .dark ? UIColor(red: 0.15, green: 0.15, blue: 0.2, alpha: 1) : UIColor(red: 1, green: 1, blue: 1, alpha: 1) })
    static let surfaceAlt = Color(UIColor { $0.userInterfaceStyle == .dark ? UIColor(red: 0.2, green: 0.2, blue: 0.25, alpha: 1) : UIColor(red: 0.9, green: 0.9, blue: 0.95, alpha: 1) })

    static let textPrimary = Color(UIColor { $0.userInterfaceStyle == .dark ? UIColor(white: 0.95, alpha: 1) : UIColor(white: 0.1, alpha: 1) })
    static let textSecondary = Color(UIColor { $0.userInterfaceStyle == .dark ? UIColor(white: 0.7, alpha: 1) : UIColor(white: 0.4, alpha: 1) })
    static let textTertiary = Color(UIColor { $0.userInterfaceStyle == .dark ? UIColor(white: 0.5, alpha: 1) : UIColor(white: 0.6, alpha: 1) })

    // Spacing (8pt grid)
    static let spacing4: CGFloat = 4
    static let spacing8: CGFloat = 8
    static let spacing12: CGFloat = 12
    static let spacing16: CGFloat = 16
    static let spacing20: CGFloat = 20
    static let spacing24: CGFloat = 24

    // Corner radius
    static let cornerSmall: CGFloat = 4
    static let cornerMedium: CGFloat = 8
    static let cornerLarge: CGFloat = 12

    // Typography
    static let titleFont = Font.system(size: 32, weight: .bold, design: .default)
    static let subtitleFont = Font.system(size: 20, weight: .semibold, design: .default)
    static let bodyFont = Font.system(size: 16, weight: .regular, design: .default)
    static let captionFont = Font.system(size: 12, weight: .regular, design: .default)
}

extension View {
    func withAppBackground() -> some View {
        self.background(AppTheme.background).ignoresSafeArea()
    }

    func cardStyle() -> some View {
        self.padding(AppTheme.spacing16)
            .background(AppTheme.surface)
            .cornerRadius(AppTheme.cornerMedium)
    }
}
