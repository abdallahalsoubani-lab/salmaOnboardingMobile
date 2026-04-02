import SwiftUI

@main
struct SalmaAIApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var container = DependencyContainer()
    @StateObject private var languageManager = LanguageManager.shared
    @StateObject private var navigationRouter = NavigationRouter()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(container)
                .environmentObject(languageManager)
                .environmentObject(navigationRouter)
                .environment(\.layoutDirection, languageManager.layoutDirection)
                .environment(\.locale, languageManager.currentLanguage.locale)
        }
    }
}

struct RootView: View {
    @EnvironmentObject var languageManager: LanguageManager

    var body: some View {
        Group {
            if !languageManager.isLanguageSelected {
                LanguageSelectionView()
            } else {
                MainAppView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: languageManager.isLanguageSelected)
    }
}

struct MainAppView: View {
    @EnvironmentObject var languageManager: LanguageManager

    var body: some View {
        VStack(spacing: SalmaDesign.Spacing.md) {
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 64))
                .foregroundColor(SalmaDesign.Colors.primary)

            Text("Salma AI")
                .font(SalmaDesign.Typography.largeTitle)
                .foregroundColor(SalmaDesign.Colors.textPrimary)

            Text(languageManager.currentLanguage == .arabic
                 ? "مرحباً بك في سلمى"
                 : "Welcome to Salma AI")
                .font(SalmaDesign.Typography.body)
                .foregroundColor(SalmaDesign.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(SalmaDesign.Colors.background)
    }
}
