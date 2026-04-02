import SwiftUI

struct AppCoordinator: View {
    @EnvironmentObject var navigationRouter: NavigationRouter
    @EnvironmentObject var languageManager: LanguageManager

    var body: some View {
        NavigationStack(path: $navigationRouter.path) {
            MainAppView()
        }
    }
}
