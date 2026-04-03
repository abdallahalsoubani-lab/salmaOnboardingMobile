import SwiftUI

struct PhotoCaptureView: View {
    let fieldId: String

    @StateObject private var cameraManager = CameraSessionManager(position: .back)
    @State private var capturedImage: UIImage?
    @State private var isReviewing = false
    @State private var flashTrigger = false

    @EnvironmentObject var flowState: VerificationFlowState
    @EnvironmentObject var router: NavigationRouter

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if isReviewing, let image = capturedImage {
                reviewView(image: image)
            } else {
                cameraView
            }
        }
        .cameraFlash(trigger: $flashTrigger)
        .statusBarHidden(true)
        .onAppear {
            cameraManager.onPhotoCaptured = { [self] image in
                flashTrigger = true
                HapticManager.impact(.heavy)
                capturedImage = image
                isReviewing = true
            }
            cameraManager.configureAndStart()
        }
        .onDisappear { cameraManager.stop() }
    }

    @ViewBuilder
    private var cameraView: some View {
        ZStack {
            CameraPreviewView(session: cameraManager.session)
                .ignoresSafeArea()

            VStack {
                Spacer()
                CameraBottomBar(
                    onCapture: { cameraManager.capturePhoto() },
                    onTorchToggle: { cameraManager.toggleTorch() },
                    onClose: { cameraManager.stop(); router.dismissFullScreen() },
                    isTorchOn: cameraManager.isTorchOn
                )
            }
        }
    }

    @ViewBuilder
    private func reviewView(image: UIImage) -> some View {
        ZStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .ignoresSafeArea()

            VStack {
                Spacer()
                HStack(spacing: SalmaDesign.Spacing.md) {
                    Button {
                        capturedImage = nil
                        isReviewing = false
                        cameraManager.configureAndStart()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.counterclockwise")
                            Text(L("retake"))
                        }
                        .font(SalmaDesign.Typography.bodyMedium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity).frame(height: 52)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(SalmaDesign.Radius.lg)
                    }

                    Button {
                        if let data = image.jpegData(compressionQuality: 0.85) {
                            flowState.setCapturedImage(
                                CapturedImage(fieldId: fieldId, imageData: data, type: .photo),
                                for: fieldId
                            )
                        }
                        HapticManager.notification(.success)
                        router.dismissFullScreen()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark")
                            Text(L("use_photo"))
                        }
                        .font(SalmaDesign.Typography.bodyMedium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity).frame(height: 52)
                        .background(SalmaDesign.Colors.primary)
                        .cornerRadius(SalmaDesign.Radius.lg)
                    }
                }
                .padding(.horizontal, SalmaDesign.Spacing.lg)
                .padding(.bottom, 40)
                .background(
                    LinearGradient(colors: [.clear, .black.opacity(0.7)],
                                   startPoint: .top, endPoint: .bottom)
                    .frame(height: 180).allowsHitTesting(false),
                    alignment: .bottom
                )
            }
        }
    }
}
