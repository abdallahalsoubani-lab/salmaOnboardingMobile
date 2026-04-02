import SwiftUI

// Will be implemented in Prompt 10
@MainActor
class SubmissionViewModel: ObservableObject {
    @Published var isSubmitting = false
    @Published var progress: Double = 0
    @Published var error: String?
}
