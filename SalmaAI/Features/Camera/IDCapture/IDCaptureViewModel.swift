import SwiftUI

@MainActor
class IDCaptureViewModel: ObservableObject {
    @Published var currentSide: IDSide = .front
    @Published var captureState: CaptureState = .capturing
    @Published var frontImage: UIImage?
    @Published var backImage: UIImage?
    @Published var qualityIssues: [ImageQualityChecker.QualityIssue] = []
    @Published var isProcessing: Bool = false
    @Published var showQualityWarning: Bool = false

    let cameraManager = CameraSessionManager(position: .back)
    let fieldId: String

    enum CaptureState: Equatable {
        case capturing
        case reviewing
        case qualityCheck
        case completed
    }

    init(fieldId: String, side: IDSide = .front) {
        self.fieldId = fieldId
        self.currentSide = side
    }

    func setupCamera() {
        cameraManager.onPhotoCaptured = { [weak self] image in
            self?.handleCapturedImage(image)
        }
        cameraManager.configureAndStart()
    }

    func stopCamera() {
        cameraManager.stop()
    }

    func capturePhoto() {
        guard captureState == .capturing else { return }
        isProcessing = true
        HapticManager.impact(.heavy)
        cameraManager.capturePhoto()
    }

    func handleCapturedImage(_ image: UIImage) {
        isProcessing = false

        if currentSide == .front {
            frontImage = image
        } else {
            backImage = image
        }

        let quality = ImageQualityChecker.check(image)

        if quality.isAcceptable {
            qualityIssues = []
            showQualityWarning = false
        } else {
            qualityIssues = quality.issues
            showQualityWarning = true
            HapticManager.notification(.warning)
        }

        captureState = .reviewing
    }

    func usePhoto() {
        showQualityWarning = false

        if currentSide == .front {
            HapticManager.notification(.success)
            currentSide = .back
            captureState = .capturing
            cameraManager.configureAndStart()
        } else {
            HapticManager.notification(.success)
            captureState = .completed
        }
    }

    func retakePhoto() {
        if currentSide == .front { frontImage = nil }
        else { backImage = nil }

        captureState = .capturing
        qualityIssues = []
        showQualityWarning = false
        cameraManager.configureAndStart()
    }

    func toggleTorch() {
        cameraManager.toggleTorch()
    }

    var currentImage: UIImage? {
        currentSide == .front ? frontImage : backImage
    }

    func buildCapturedImages() -> (front: CapturedImage?, back: CapturedImage?) {
        let front = backImage.flatMap { img -> CapturedImage? in
            guard let data = img.jpegData(compressionQuality: 0.85) else { return nil }
            return CapturedImage(fieldId: fieldId, imageData: data, type: .idFront)
        }
        let back = frontImage.flatMap { img -> CapturedImage? in
            guard let data = img.jpegData(compressionQuality: 0.85) else { return nil }
            return CapturedImage(fieldId: fieldId + "_back", imageData: data, type: .idBack)
        }
        return (front, back)
    }
}
