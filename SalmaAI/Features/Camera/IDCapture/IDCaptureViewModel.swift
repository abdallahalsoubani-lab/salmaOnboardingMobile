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
        cameraManager.configure()
        cameraManager.start()
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
        captureState = .qualityCheck

        let quality = ImageQualityChecker.check(image)

        if currentSide == .front {
            frontImage = image
        } else {
            backImage = image
        }

        if quality.isAcceptable {
            captureState = .reviewing
            qualityIssues = []
            showQualityWarning = false
        } else {
            captureState = .reviewing
            qualityIssues = quality.issues
            showQualityWarning = true
            HapticManager.notification(.warning)
        }
    }

    func usePhoto() {
        showQualityWarning = false

        if currentSide == .front {
            HapticManager.notification(.success)
            currentSide = .back
            captureState = .capturing
            cameraManager.capturedImage = nil
        } else {
            HapticManager.notification(.success)
            captureState = .completed
        }
    }

    func retakePhoto() {
        if currentSide == .front { frontImage = nil }
        else { backImage = nil }

        captureState = .capturing
        cameraManager.capturedImage = nil
        qualityIssues = []
        showQualityWarning = false

        if !cameraManager.isSessionRunning {
            cameraManager.start()
        }
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
