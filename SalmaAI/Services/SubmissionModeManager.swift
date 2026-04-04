import SwiftUI

@MainActor
class SubmissionModeManager: ObservableObject {
    enum SubmissionMode {
        case perPage
        case batch
    }

    @Published var currentMode: SubmissionMode = .perPage

    private let connectivity: ConnectivityMonitor

    init(connectivity: ConnectivityMonitor = .shared) {
        self.connectivity = connectivity
        updateMode()
    }

    func updateMode() {
        currentMode = connectivity.isConnected ? .perPage : .batch
    }

    var isPerPage: Bool { currentMode == .perPage }
    var isBatch: Bool { currentMode == .batch }
}
