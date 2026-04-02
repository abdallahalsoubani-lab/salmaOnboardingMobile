import SwiftUI

@MainActor
class NavigationRouter: ObservableObject {
    @Published var path = NavigationPath()

    func push(_ route: Route) {
        path.append(route)
    }

    func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }

    func popToRoot() {
        path = NavigationPath()
    }
}
