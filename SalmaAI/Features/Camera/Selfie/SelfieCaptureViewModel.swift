import SwiftUI

// Will be implemented in Prompt 9
@MainActor
class SelfieCaptureViewModel: ObservableObject {
    @Published var capturedImage: UIImage?
    @Published var isFaceDetected = false
}
