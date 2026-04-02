import SwiftUI

// Will be implemented in Prompt 8
@MainActor
class IDCaptureViewModel: ObservableObject {
    @Published var capturedFront: UIImage?
    @Published var capturedBack: UIImage?
    @Published var currentSide: IDSide = .front
}
