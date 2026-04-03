import AVFoundation
import UIKit

class SelfieCameraSession: NSObject, ObservableObject {
    @Published var isSessionRunning = false
    @Published var capturedImage: UIImage?
    @Published var error: CameraSessionManager.CameraError?

    let session = AVCaptureSession()
    private var photoOutput = AVCapturePhotoOutput()
    private var videoOutput = AVCaptureVideoDataOutput()

    var onVideoFrame: ((CMSampleBuffer) -> Void)?

    private let sessionQueue = DispatchQueue(label: "com.salmaai.selfie.session")
    private let videoQueue = DispatchQueue(label: "com.salmaai.selfie.video")

    private var isConfigured = false
    private var retryCount = 0
    private let maxRetries = 5

    func configureAndStart() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }

            if !self.isConfigured {
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

                if self.session.canAddOutput(self.photoOutput) {
                    self.session.addOutput(self.photoOutput)
                    if let connection = self.photoOutput.connection(with: .video) {
                        connection.videoOrientation = .portrait
                        connection.isVideoMirrored = true
                    }
                }

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
            }

            self.session.startRunning()

            let running = self.session.isRunning
            DispatchQueue.main.async { self.isSessionRunning = running }

            if !running && self.retryCount < self.maxRetries {
                self.retryCount += 1
                let delay = Double(self.retryCount) * 0.5
                print("[SalmaAI] Camera session not running, retry \(self.retryCount)/\(self.maxRetries) in \(delay)s")
                self.sessionQueue.asyncAfter(deadline: .now() + delay) { [weak self] in
                    guard let self = self else { return }
                    self.session.startRunning()
                    let nowRunning = self.session.isRunning
                    DispatchQueue.main.async { self.isSessionRunning = nowRunning }
                    if !nowRunning && self.retryCount < self.maxRetries {
                        self.retryCount += 1
                        self.retryStart()
                    }
                }
            }
        }
    }

    private func retryStart() {
        guard retryCount < maxRetries else {
            print("[SalmaAI] Camera session failed to start after \(maxRetries) retries")
            return
        }
        retryCount += 1
        let delay = Double(retryCount) * 0.5
        print("[SalmaAI] Camera retry \(retryCount)/\(maxRetries) in \(delay)s")
        sessionQueue.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self = self else { return }
            self.session.startRunning()
            let running = self.session.isRunning
            DispatchQueue.main.async { self.isSessionRunning = running }
            if !running {
                self.retryStart()
            } else {
                print("[SalmaAI] Camera session started on retry \(self.retryCount)")
            }
        }
    }

    func stop() {
        sessionQueue.async { [weak self] in
            self?.session.stopRunning()
            DispatchQueue.main.async { self?.isSessionRunning = false }
        }
    }

    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        settings.photoQualityPrioritization = photoOutput.maxPhotoQualityPrioritization
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
}

extension SelfieCameraSession: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        onVideoFrame?(sampleBuffer)
    }
}

extension SelfieCameraSession: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil,
              let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else {
            DispatchQueue.main.async {
                self.error = .captureFailed(error ?? NSError(domain: "SelfieCameraSession", code: -1))
            }
            return
        }
        DispatchQueue.main.async { self.capturedImage = image }
    }
}
