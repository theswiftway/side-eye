import SwiftUI

struct AppTheme {
    // MARK: - Colors

    static let background = Color(red: 0.05, green: 0.05, blue: 0.08)
    static let surface = Color(red: 0.12, green: 0.12, blue: 0.16)
    static let surfaceAlt = Color(red: 0.15, green: 0.15, blue: 0.20)

    static let primary = Color(red: 1.0, green: 0.2, blue: 0.4)      // Hot pink/red
    static let primaryLight = Color(red: 1.0, green: 0.4, blue: 0.6)
    static let secondary = Color(red: 0.3, green: 0.8, blue: 1.0)    // Cyan
    static let accent = Color(red: 1.0, green: 0.8, blue: 0.0)       // Gold

    static let success = Color(red: 0.2, green: 0.8, blue: 0.4)
    static let warning = Color(red: 1.0, green: 0.6, blue: 0.0)
    static let error = Color(red: 0.95, green: 0.2, blue: 0.2)

    static let textPrimary = Color(red: 0.95, green: 0.95, blue: 1.0)
    static let textSecondary = Color(red: 0.7, green: 0.7, blue: 0.75)
    static let textTertiary = Color(red: 0.5, green: 0.5, blue: 0.55)

    // MARK: - Spacing

    static let spacing2 = 2.0
    static let spacing4 = 4.0
    static let spacing8 = 8.0
    static let spacing12 = 12.0
    static let spacing16 = 16.0
    static let spacing20 = 20.0
    static let spacing24 = 24.0
    static let spacing32 = 32.0

    // MARK: - Corner Radius

    static let cornerSmall = 8.0
    static let cornerMedium = 12.0
    static let cornerLarge = 16.0
    static let cornerXL = 24.0

    // MARK: - Typography

    static let titleFont = Font.system(size: 32, weight: .bold, design: .default)
    static let subtitleFont = Font.system(size: 20, weight: .semibold, design: .default)
    static let bodyFont = Font.system(size: 16, weight: .regular, design: .default)
    static let captionFont = Font.system(size: 12, weight: .regular, design: .default)
}

// MARK: - View Extensions

extension View {
    func withAppBackground() -> some View {
        background(AppTheme.background)
    }

    func cardStyle() -> some View {
        modifier(CardModifier())
    }
}

// MARK: - Custom Modifiers

struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(AppTheme.surface)
            .cornerRadius(AppTheme.cornerMedium)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerMedium)
                    .stroke(AppTheme.surfaceAlt, lineWidth: 1)
            )
    }
}
