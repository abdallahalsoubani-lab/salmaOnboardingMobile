import SwiftUI

@MainActor
class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @Published var primaryColor: Color = SalmaDesign.Colors.primary
    @Published var primaryDarkColor: Color = SalmaDesign.Colors.primaryDark
    @Published var primaryLightColor: Color = SalmaDesign.Colors.primaryLight
    @Published var backgroundColor: Color = SalmaDesign.Colors.background
    @Published var backgroundDarkColor: Color = Color(hex: "#1A1A2E")
    @Published var textColor: Color = SalmaDesign.Colors.textPrimary
    @Published var textDarkColor: Color = Color(hex: "#F0F0F0")
    @Published var buttonRadius: CGFloat = SalmaDesign.Radius.md
    @Published var cardRadius: CGFloat = SalmaDesign.Radius.lg
    @Published var logoUrl: String? = nil
    @Published var showPoweredBy: Bool = true
    @Published var hasCustomTheme: Bool = false

    private init() {}

    func applyTheme(_ theme: JourneyTheme?) {
        guard let theme = theme else {
            resetToDefaults()
            return
        }

        hasCustomTheme = true

        if let hex = theme.primaryColor {
            primaryColor = Color(hex: hex)
        }
        if let hex = theme.primaryDarkColor {
            primaryDarkColor = Color(hex: hex)
        }
        if let hex = theme.primaryLightColor {
            primaryLightColor = Color(hex: hex)
        }
        if let hex = theme.backgroundColor {
            backgroundColor = Color(hex: hex)
        }
        if let hex = theme.backgroundDarkColor {
            backgroundDarkColor = Color(hex: hex)
        }
        if let hex = theme.textColor {
            textColor = Color(hex: hex)
        }
        if let hex = theme.textDarkColor {
            textDarkColor = Color(hex: hex)
        }
        if let radius = theme.buttonRadius {
            buttonRadius = CGFloat(radius)
        }
        if let radius = theme.cardRadius {
            cardRadius = CGFloat(radius)
        }
        logoUrl = theme.logoUrl
        showPoweredBy = theme.showPoweredBy ?? true
    }

    func resetToDefaults() {
        hasCustomTheme = false
        primaryColor = SalmaDesign.Colors.primary
        primaryDarkColor = SalmaDesign.Colors.primaryDark
        primaryLightColor = SalmaDesign.Colors.primaryLight
        backgroundColor = SalmaDesign.Colors.background
        backgroundDarkColor = Color(hex: "#1A1A2E")
        textColor = SalmaDesign.Colors.textPrimary
        textDarkColor = Color(hex: "#F0F0F0")
        buttonRadius = SalmaDesign.Radius.md
        cardRadius = SalmaDesign.Radius.lg
        logoUrl = nil
        showPoweredBy = true
    }
}
