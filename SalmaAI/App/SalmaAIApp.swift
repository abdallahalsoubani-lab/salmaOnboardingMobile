import SwiftUI

@main
struct SalmaAIApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var container = DependencyContainer()
    @StateObject private var languageManager = LanguageManager.shared
    @StateObject private var connectivity = ConnectivityMonitor.shared

    init() {
        AmplifyConfigurator.configure()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(container)
                .environmentObject(languageManager)
                .environmentObject(connectivity)
                .environment(\.layoutDirection, languageManager.layoutDirection)
                .environment(\.locale, languageManager.currentLanguage.locale)
        }
    }
}

struct RootView: View {
    @EnvironmentObject var container: DependencyContainer
    @State private var showSplash = true

    var body: some View {
        ZStack {
            if showSplash {
                SplashView()
                    .transition(.opacity)
            } else {
                AppCoordinator()
                    .transition(.opacity)
            }
        }
        .task { await loadTheme() }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showSplash = false
                }
            }
        }
    }

    private func loadTheme() async {
        do {
            let theme: AppTheme = try await container.apiClient.get(.getTheme)
            await MainActor.run {
                ThemeManager.shared.applyAppTheme(theme)
            }
            #if DEBUG
            print("[Theme] loaded — logo: \(theme.logoUrl ?? "none"), app: \(theme.appName ?? "none")")
            #endif
        } catch {
            #if DEBUG
            print("[Theme] failed to load: \(error)")
            #endif
        }
    }
}
