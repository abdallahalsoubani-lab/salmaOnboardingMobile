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

        let cropped = Self.cropToIDFrame(image: image) ?? image

        if currentSide == .front {
            frontImage = cropped
        } else {
            backImage = cropped
        }

        let quality = ImageQualityChecker.check(cropped)

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
        let front = frontImage.flatMap { img -> CapturedImage? in
            guard let data = img.jpegData(compressionQuality: 0.85) else { return nil }
            return CapturedImage(fieldId: fieldId, imageData: data, type: .idFront)
        }
        let back = backImage.flatMap { img -> CapturedImage? in
            guard let data = img.jpegData(compressionQuality: 0.85) else { return nil }
            return CapturedImage(fieldId: fieldId + "_back", imageData: data, type: .idBack)
        }
        return (front, back)
    }

    // MARK: - Crop to ID Frame

    /// Crops a full-camera image to just the ID card frame area,
    /// matching the overlay rectangle from IDCardOverlay.
    static func cropToIDFrame(image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }

        let imageW = CGFloat(cgImage.width)
        let imageH = CGFloat(cgImage.height)
        let screenSize = UIScreen.main.bounds.size

        // Frame rect in screen coords (mirrors IDCardOverlay's GeometryReader calculation)
        let frameWidth = screenSize.width * SalmaDesign.Camera.idCardFrameWidthRatio
        let frameHeight = frameWidth / SalmaDesign.Camera.idCardAspectRatio
        let frameX = (screenSize.width - frameWidth) / 2
        let frameY = (screenSize.height - frameHeight) / 2 - 40

        // The preview layer uses .resizeAspectFill — the image is scaled so the
        // *smaller* relative dimension fills the screen, and the other overflows.
        let displayScale = max(screenSize.width / imageW, screenSize.height / imageH)

        // Offset: how far the image origin is from the screen origin (negative = overflow)
        let offsetX = (screenSize.width - imageW * displayScale) / 2
        let offsetY = (screenSize.height - imageH * displayScale) / 2

        // Convert screen-space frame rect → image-pixel rect
        let cropRect = CGRect(
            x: (frameX - offsetX) / displayScale,
            y: (frameY - offsetY) / displayScale,
            width: frameWidth / displayScale,
            height: frameHeight / displayScale
        )

        let imageBounds = CGRect(origin: .zero, size: CGSize(width: imageW, height: imageH))
        let clampedRect = cropRect.intersection(imageBounds)
        guard !clampedRect.isEmpty else { return nil }

        guard let croppedCG = cgImage.cropping(to: clampedRect) else { return nil }
        return UIImage(cgImage: croppedCG, scale: image.scale, orientation: image.imageOrientation)
    }
}
