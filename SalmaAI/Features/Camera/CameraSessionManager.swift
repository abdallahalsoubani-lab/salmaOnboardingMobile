import AVFoundation
import UIKit

class CameraSessionManager: NSObject, ObservableObject {
    @Published var isSessionRunning = false
    @Published var error: CameraError?
    @Published var isTorchOn = false

    let session = AVCaptureSession()
    private var videoOutput = AVCaptureVideoDataOutput()
    private var currentDevice: AVCaptureDevice?
    private var currentInput: AVCaptureDeviceInput?
    private(set) var cameraPosition: AVCaptureDevice.Position

    var onPhotoCaptured: ((UIImage) -> Void)?

    private let sessionQueue = DispatchQueue(label: "com.salmaai.camera.session")
    private let videoQueue = DispatchQueue(label: "com.salmaai.camera.video")

    private var isConfigured = false
    private var pendingCapture = false

    enum CameraError: LocalizedError {
        case deviceNotAvailable
        case cannotAddInput
        case cannotAddOutput
        case captureFailed(Error)

        var errorDescription: String? {
            switch self {
            case .deviceNotAvailable: return L("camera_not_available")
            case .cannotAddInput, .cannotAddOutput: return L("camera_config_error")
            case .captureFailed(let e): return e.localizedDescription
            }
        }
    }

    init(position: AVCaptureDevice.Position = .back) {
        self.cameraPosition = position
        super.init()
    }

    // MARK: - Setup

    func configureAndStart() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            if self.isConfigured {
                self.startSession()
                return
            }

            self.session.beginConfiguration()
            self.session.sessionPreset = .photo

            guard let device = AVCaptureDevice.default(
                .builtInWideAngleCamera, for: .video, position: self.cameraPosition
            ) else {
                DispatchQueue.main.async { self.error = .deviceNotAvailable }
                self.session.commitConfiguration()
                return
            }
            self.currentDevice = device

            self.session.inputs.forEach { self.session.removeInput($0) }

            do {
                let input = try AVCaptureDeviceInput(device: device)
                guard self.session.canAddInput(input) else {
                    DispatchQueue.main.async { self.error = .cannotAddInput }
                    self.session.commitConfiguration()
                    return
                }
                self.session.addInput(input)
                self.currentInput = input
            } catch {
                DispatchQueue.main.async { self.error = .cannotAddInput }
                self.session.commitConfiguration()
                return
            }

            self.session.outputs.forEach { self.session.removeOutput($0) }

            self.videoOutput.setSampleBufferDelegate(self, queue: self.videoQueue)
            self.videoOutput.alwaysDiscardsLateVideoFrames = true
            self.videoOutput.videoSettings = [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
            ]

            guard self.session.canAddOutput(self.videoOutput) else {
                DispatchQueue.main.async { self.error = .cannotAddOutput }
                self.session.commitConfiguration()
                return
            }
            self.session.addOutput(self.videoOutput)

            if let connection = self.videoOutput.connection(with: .video) {
                if connection.isVideoOrientationSupported {
                    connection.videoOrientation = .portrait
                }
                if self.cameraPosition == .front && connection.isVideoMirroringSupported {
                    connection.isVideoMirrored = true
                }
            }

            self.session.commitConfiguration()
            self.isConfigured = true
            self.startSession()
        }
    }

    @available(*, deprecated, message: "Use configureAndStart() instead")
    func configure() {
        configureAndStart()
    }

    // MARK: - Start/Stop

    private func startSession() {
        sessionQueue.async { [weak self] in
            guard let self = self, !self.session.isRunning else { return }
            self.session.startRunning()
            let running = self.session.isRunning
            DispatchQueue.main.async { self.isSessionRunning = running }
        }
    }

    func start() {
        startSession()
    }

    func stop() {
        sessionQueue.async { [weak self] in
            self?.session.stopRunning()
            DispatchQueue.main.async { self?.isSessionRunning = false }
        }
    }

    // MARK: - Capture

    func capturePhoto() {
        pendingCapture = true
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
        isConfigured = false
        configureAndStart()
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

    // MARK: - Image Conversion

    private func imageFromSampleBuffer(_ sampleBuffer: CMSampleBuffer) -> UIImage? {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension CameraSessionManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if pendingCapture {
            pendingCapture = false
            if let image = imageFromSampleBuffer(sampleBuffer) {
                session.stopRunning()
                DispatchQueue.main.async {
                    self.isSessionRunning = false
                    self.onPhotoCaptured?(image)
                }
            }
            return
        }
    }
}
