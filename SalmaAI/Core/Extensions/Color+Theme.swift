import SwiftUI

// MARK: - Hex Initializer

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Convenience Color Aliases

extension Color {
    static let salmaPrimary = SalmaDesign.Colors.primary
    static let salmaPrimaryDark = SalmaDesign.Colors.primaryDark
    static let salmaPrimaryLight = SalmaDesign.Colors.primaryLight
    static let salmaBackground = SalmaDesign.Colors.background
    static let salmaBackgroundSecondary = SalmaDesign.Colors.backgroundSecondary
    static let salmaSurface = SalmaDesign.Colors.surface
    static let salmaTextPrimary = SalmaDesign.Colors.textPrimary
    static let salmaTextSecondary = SalmaDesign.Colors.textSecondary
    static let salmaTextTertiary = SalmaDesign.Colors.textTertiary
    static let salmaSuccess = SalmaDesign.Colors.success
    static let salmaDanger = SalmaDesign.Colors.danger
    static let salmaWarning = SalmaDesign.Colors.warning
    static let salmaInfo = SalmaDesign.Colors.info
    static let salmaBorder = SalmaDesign.Colors.border
    static let salmaDivider = SalmaDesign.Colors.divider
}

// MARK: - Themed Colors (reads from ThemeManager at access time)

@MainActor
struct ThemedColors {
    static var primary: Color {
        ThemeManager.shared.hasCustomTheme ? ThemeManager.shared.primaryColor : SalmaDesign.Colors.primary
    }
    static var primaryDark: Color {
        ThemeManager.shared.hasCustomTheme ? ThemeManager.shared.primaryDarkColor : SalmaDesign.Colors.primaryDark
    }
    static var primaryLight: Color {
        ThemeManager.shared.hasCustomTheme ? ThemeManager.shared.primaryLightColor : SalmaDesign.Colors.primaryLight
    }
    static var background: Color {
        ThemeManager.shared.hasCustomTheme ? ThemeManager.shared.backgroundColor : SalmaDesign.Colors.background
    }
    static var textPrimary: Color {
        ThemeManager.shared.hasCustomTheme ? ThemeManager.shared.textColor : SalmaDesign.Colors.textPrimary
    }
    static var buttonRadius: CGFloat {
        ThemeManager.shared.hasCustomTheme ? ThemeManager.shared.buttonRadius : SalmaDesign.Radius.md
    }
    static var cardRadius: CGFloat {
        ThemeManager.shared.hasCustomTheme ? ThemeManager.shared.cardRadius : SalmaDesign.Radius.lg
    }

    static func background(for colorScheme: ColorScheme) -> Color {
        if ThemeManager.shared.hasCustomTheme {
            return colorScheme == .dark
                ? ThemeManager.shared.backgroundDarkColor
                : ThemeManager.shared.backgroundColor
        }
        return SalmaDesign.Colors.background
    }

    static func textPrimary(for colorScheme: ColorScheme) -> Color {
        if ThemeManager.shared.hasCustomTheme {
            return colorScheme == .dark
                ? ThemeManager.shared.textDarkColor
                : ThemeManager.shared.textColor
        }
        return SalmaDesign.Colors.textPrimary
    }
}
