import SwiftUI

// Will be implemented in Prompt 11
@MainActor
class ResultViewModel: ObservableObject {
    @Published var result: SubmissionResult?
    @Published var isPolling = false
}
