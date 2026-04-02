import Vision
import AVFoundation
import SwiftUI

class FaceDetectorService: NSObject, ObservableObject {
    @Published var faceDetected: Bool = false
    @Published var instruction: FaceInstruction = .none
    @Published var faceBounds: CGRect = .zero

    private let minFaceSizeRatio: CGFloat = 0.20
    private let maxFaceSizeRatio: CGFloat = 0.55
    private let centerToleranceX: CGFloat = 0.15
    private let centerToleranceY: CGFloat = 0.15

    private var stableFrameCount: Int = 0
    private let requiredStableFrames: Int = 10

    private lazy var faceDetectionRequest: VNDetectFaceRectanglesRequest = {
        VNDetectFaceRectanglesRequest { [weak self] request, _ in
            self?.handleResults(request.results as? [VNFaceObservation])
        }
    }()

    private let sequenceHandler = VNSequenceRequestHandler()

    func detectFace(in sampleBuffer: CMSampleBuffer) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        try? sequenceHandler.perform([faceDetectionRequest], on: pixelBuffer, orientation: .leftMirrored)
    }

    func reset() {
        faceDetected = false
        instruction = .none
        faceBounds = .zero
        stableFrameCount = 0
    }

    private func handleResults(_ results: [VNFaceObservation]?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            guard let face = results?.first else {
                self.faceDetected = false
                self.instruction = .none
                self.faceBounds = .zero
                self.stableFrameCount = 0
                return
            }

            self.faceDetected = true
            self.faceBounds = face.boundingBox

            let faceWidth = face.boundingBox.width
            let faceCenterX = face.boundingBox.midX
            let faceCenterY = face.boundingBox.midY

            if faceWidth < self.minFaceSizeRatio {
                self.instruction = .moveCloser
                self.stableFrameCount = 0
                return
            }

            if faceWidth > self.maxFaceSizeRatio {
                self.instruction = .moveBack
                self.stableFrameCount = 0
                return
            }

            let offX = abs(faceCenterX - 0.5)
            let offY = abs(faceCenterY - 0.5)

            if offX > self.centerToleranceX || offY > self.centerToleranceY {
                self.instruction = .holdStill
                self.stableFrameCount = 0
                return
            }

            self.stableFrameCount += 1
            self.instruction = self.stableFrameCount >= self.requiredStableFrames ? .centered : .holdStill
        }
    }
}
