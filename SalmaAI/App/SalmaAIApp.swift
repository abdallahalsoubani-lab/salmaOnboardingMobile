import SwiftUI

@main
struct SalmaAIApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var container = DependencyContainer()
    @StateObject private var languageManager = LanguageManager.shared
    @StateObject private var navigationRouter = NavigationRouter()
    @StateObject private var connectivity = ConnectivityMonitor.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(container)
                .environmentObject(languageManager)
                .environmentObject(navigationRouter)
                .environment(\.layoutDirection, languageManager.layoutDirection)
                .environment(\.locale, languageManager.currentLanguage.locale)
                .environmentObject(connectivity)
        }
    }
}

struct RootView: View {
    @State private var showSplash = true
    @EnvironmentObject var languageManager: LanguageManager

    var body: some View {
        ZStack {
            if showSplash {
                SplashView()
                    .transition(.opacity)
            } else {
                if !languageManager.isLanguageSelected {
                    LanguageSelectionView()
                        .transition(.opacity)
                } else {
                    MainAppView()
                        .transition(.opacity)
                }
            }
        }
        .animation(AppAnimations.stateChange, value: languageManager.isLanguageSelected)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showSplash = false
                }
            }
        }
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
