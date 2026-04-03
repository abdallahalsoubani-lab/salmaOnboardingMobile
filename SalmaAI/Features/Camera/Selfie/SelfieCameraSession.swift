import AVFoundation
import UIKit

class SelfieCameraSession: NSObject, ObservableObject {
    @Published var isSessionRunning = false
    @Published var error: CameraSessionManager.CameraError?

    let session = AVCaptureSession()
    private var videoOutput = AVCaptureVideoDataOutput()

    var onVideoFrame: ((CMSampleBuffer) -> Void)?
    var onPhotoCaptured: ((UIImage) -> Void)?

    private let sessionQueue = DispatchQueue(label: "com.salmaai.selfie.session")
    private let videoQueue = DispatchQueue(label: "com.salmaai.selfie.video")

    private var isConfigured = false
    private var pendingCapture = false

    func configureAndStart() {
        sessionQueue.async { [weak self] in
            guard let self = self, !self.isConfigured else {
                self?.startSession()
                return
            }

            self.session.beginConfiguration()
            self.session.sessionPreset = .photo

            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
                DispatchQueue.main.async { self.error = .deviceNotAvailable }
                self.session.commitConfiguration()
                return
            }

            guard let input = try? AVCaptureDeviceInput(device: device),
                  self.session.canAddInput(input) else {
                DispatchQueue.main.async { self.error = .cannotAddInput }
                self.session.commitConfiguration()
                return
            }
            self.session.addInput(input)

            self.videoOutput.setSampleBufferDelegate(self, queue: self.videoQueue)
            self.videoOutput.alwaysDiscardsLateVideoFrames = true
            self.videoOutput.videoSettings = [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
            ]

            if self.session.canAddOutput(self.videoOutput) {
                self.session.addOutput(self.videoOutput)
                if let connection = self.videoOutput.connection(with: .video) {
                    connection.videoOrientation = .portrait
                    connection.isVideoMirrored = true
                }
            }

            self.session.commitConfiguration()
            self.isConfigured = true
            self.startSession()
        }
    }

    private func startSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            if !self.session.isRunning {
                self.session.startRunning()
            }
            let running = self.session.isRunning
            DispatchQueue.main.async { self.isSessionRunning = running }
        }
    }

    func stop() {
        sessionQueue.async { [weak self] in
            self?.session.stopRunning()
            DispatchQueue.main.async { self?.isSessionRunning = false }
        }
    }

    func capturePhoto() {
        pendingCapture = true
    }

    private func imageFromSampleBuffer(_ sampleBuffer: CMSampleBuffer) -> UIImage? {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}

extension SelfieCameraSession: AVCaptureVideoDataOutputSampleBufferDelegate {
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
        onVideoFrame?(sampleBuffer)
    }
}
