import SwiftUI

@MainActor
class SelfieCaptureViewModel: ObservableObject {
    @Published var captureState: CaptureState = .capturing
    @Published var capturedImage: UIImage?
    @Published var qualityIssues: [ImageQualityChecker.QualityIssue] = []
    @Published var showQualityWarning: Bool = false
    @Published var isProcessing: Bool = false

    let cameraSession = SelfieCameraSession()
    let faceDetector = FaceDetectorService()
    let fieldId: String

    enum CaptureState {
        case capturing
        case reviewing
        case qualityCheck
    }

    init(fieldId: String) {
        self.fieldId = fieldId
    }

    func setupCamera() {
        cameraSession.onVideoFrame = { [weak self] sampleBuffer in
            self?.faceDetector.detectFace(in: sampleBuffer)
        }
        cameraSession.onPhotoCaptured = { [weak self] image in
            self?.handleCapturedImage(image)
        }
        cameraSession.configureAndStart()
    }

    func stopCamera() {
        cameraSession.stop()
    }

    func capturePhoto() {
        guard captureState == .capturing else { return }
        isProcessing = true
        HapticManager.impact(.heavy)
        cameraSession.capturePhoto()
    }

    func handleCapturedImage(_ image: UIImage) {
        isProcessing = false
        capturedImage = image

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
        HapticManager.notification(.success)
    }

    func retakePhoto() {
        capturedImage = nil
        captureState = .capturing
        qualityIssues = []
        showQualityWarning = false
        faceDetector.reset()
        cameraSession.configureAndStart()
    }

    func buildCapturedImage() -> CapturedImage? {
        guard let image = capturedImage,
              let data = image.jpegData(compressionQuality: 0.85) else { return nil }
        return CapturedImage(fieldId: fieldId, imageData: data, type: .selfie)
    }
}
