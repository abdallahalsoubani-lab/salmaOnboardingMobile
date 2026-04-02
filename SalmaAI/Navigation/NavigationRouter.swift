import SwiftUI

@MainActor
class NavigationRouter: ObservableObject {
    @Published var navigationPath = NavigationPath()
    @Published var presentedSheet: SheetRoute?
    @Published var presentedFullScreen: FullScreenRoute?

    // MARK: - Push/Pop

    func push(_ route: Route) {
        navigationPath.append(route)
    }

    func pop() {
        guard !navigationPath.isEmpty else { return }
        navigationPath.removeLast()
    }

    func popToRoot() {
        navigationPath = NavigationPath()
    }

    // MARK: - Sheets

    func presentSheet(_ sheet: SheetRoute) {
        presentedSheet = sheet
    }

    func dismissSheet() {
        presentedSheet = nil
    }

    // MARK: - Full Screen Covers

    func presentFullScreen(_ route: FullScreenRoute) {
        presentedFullScreen = route
    }

    func dismissFullScreen() {
        presentedFullScreen = nil
    }

    // MARK: - Flow Helpers

    func startVerification() {
        popToRoot()
    }

    func goToNextPage(currentIndex: Int, totalPages: Int) {
        if currentIndex < totalPages - 1 {
            push(.formPage(pageIndex: currentIndex + 1))
        } else {
            push(.review)
        }
    }

    func goToResult() {
        push(.result)
    }

    func restartVerification() {
        popToRoot()
    }
}
