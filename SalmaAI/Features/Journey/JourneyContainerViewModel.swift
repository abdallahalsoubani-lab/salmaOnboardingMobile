import SwiftUI

// Will be implemented in Prompt 6
@MainActor
class JourneyContainerViewModel: ObservableObject {
    @Published var journey: JourneyDetail?
    @Published var isLoading = false
    @Published var error: String?
}
