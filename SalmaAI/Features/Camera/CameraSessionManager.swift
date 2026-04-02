import AVFoundation
import UIKit

class CameraSessionManager: NSObject, ObservableObject {
    @Published var isSessionRunning = false
    @Published var capturedImage: UIImage?
    @Published var error: CameraError?
    @Published var isTorchOn = false

    let session = AVCaptureSession()
    private var videoOutput = AVCapturePhotoOutput()
    private var currentDevice: AVCaptureDevice?
    private var currentInput: AVCaptureDeviceInput?
    private(set) var cameraPosition: AVCaptureDevice.Position

    enum CameraError: LocalizedError {
        case deviceNotAvailable
        case cannotAddInput
        case cannotAddOutput
        case captureFailed(Error)

        var errorDescription: String? {
            switch self {
            case .deviceNotAvailable: return String(localized: "camera_not_available")
            case .cannotAddInput, .cannotAddOutput: return String(localized: "camera_config_error")
            case .captureFailed(let e): return e.localizedDescription
            }
        }
    }

    init(position: AVCaptureDevice.Position = .back) {
        self.cameraPosition = position
        super.init()
    }

    // MARK: - Setup

    func configure() {
        session.beginConfiguration()
        session.sessionPreset = .photo

        guard let device = AVCaptureDevice.default(
            .builtInWideAngleCamera, for: .video, position: cameraPosition
        ) else {
            error = .deviceNotAvailable
            session.commitConfiguration()
            return
        }
        currentDevice = device

        session.inputs.forEach { session.removeInput($0) }

        do {
            let input = try AVCaptureDeviceInput(device: device)
            guard session.canAddInput(input) else {
                error = .cannotAddInput
                session.commitConfiguration()
                return
            }
            session.addInput(input)
            currentInput = input
        } catch {
            self.error = .cannotAddInput
            session.commitConfiguration()
            return
        }

        session.outputs.forEach { session.removeOutput($0) }

        guard session.canAddOutput(videoOutput) else {
            error = .cannotAddOutput
            session.commitConfiguration()
            return
        }
        session.addOutput(videoOutput)

        if let connection = videoOutput.connection(with: .video) {
            if connection.isVideoOrientationSupported {
                connection.videoOrientation = .portrait
            }
            if cameraPosition == .front && connection.isVideoMirroringSupported {
                connection.isVideoMirrored = true
            }
        }

        session.commitConfiguration()
    }

    // MARK: - Start/Stop

    func start() {
        guard !session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
            DispatchQueue.main.async {
                self?.isSessionRunning = self?.session.isRunning ?? false
            }
        }
    }

    func stop() {
        guard session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.stopRunning()
            DispatchQueue.main.async {
                self?.isSessionRunning = false
            }
        }
    }

    // MARK: - Capture

    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        settings.photoQualityPrioritization = .quality
        if let device = currentDevice, device.hasFlash {
            settings.flashMode = isTorchOn ? .on : .off
        }
        videoOutput.capturePhoto(with: settings, delegate: self)
    }

    // MARK: - Torch

    func toggleTorch() {
        guard let device = currentDevice, device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            if device.torchMode == .on {
                device.torchMode = .off
                isTorchOn = false
            } else {
                try device.setTorchModeOn(level: 1.0)
                isTorchOn = true
            }
            device.unlockForConfiguration()
        } catch {}
    }

    // MARK: - Switch Camera

    func switchCamera() {
        cameraPosition = (cameraPosition == .back) ? .front : .back
        isTorchOn = false
        configure()
    }

    // MARK: - Focus

    func focus(at point: CGPoint, in viewSize: CGSize) {
        guard let device = currentDevice, device.isFocusPointOfInterestSupported else { return }
        let focusPoint = CGPoint(
            x: point.y / viewSize.height,
            y: 1.0 - point.x / viewSize.width
        )
        do {
            try device.lockForConfiguration()
            device.focusPointOfInterest = focusPoint
            device.focusMode = .autoFocus
            if device.isExposurePointOfInterestSupported {
                device.exposurePointOfInterest = focusPoint
                device.exposureMode = .autoExpose
            }
            device.unlockForConfiguration()
        } catch {}
    }
}

// MARK: - AVCapturePhotoCaptureDelegate

extension CameraSessionManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        if let error = error {
            DispatchQueue.main.async { self.error = .captureFailed(error) }
            return
        }

        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            DispatchQueue.main.async {
                self.error = .captureFailed(
                    NSError(domain: "CameraSession", code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Failed to process photo"])
                )
            }
            return
        }

        DispatchQueue.main.async {
            self.capturedImage = image
        }
    }
}
