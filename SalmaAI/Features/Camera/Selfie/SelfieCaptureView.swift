import SwiftUI

struct SelfieCaptureView: View {
    let fieldId: String

    @StateObject private var viewModel: SelfieCaptureViewModel
    @EnvironmentObject var flowState: VerificationFlowState
    @EnvironmentObject var router: NavigationRouter

    @State private var flashTrigger = false

    init(fieldId: String) {
        self.fieldId = fieldId
        self._viewModel = StateObject(wrappedValue: SelfieCaptureViewModel(fieldId: fieldId))
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            switch viewModel.captureState {
            case .capturing:
                capturingView
            case .qualityCheck:
                qualityCheckView
            case .reviewing:
                reviewingView
            }
        }
        .cameraFlash(trigger: $flashTrigger)
        .statusBarHidden(true)
        .onAppear { viewModel.setupCamera() }
        .onDisappear { viewModel.stopCamera() }
        .onChange(of: viewModel.captureState) { state in
            if state == .reviewing {
                flashTrigger = true
            }
        }
    }

    // MARK: - Capturing

    private var capturingView: some View {
        ZStack {
            CameraPreviewView(session: viewModel.cameraSession.session)
                .ignoresSafeArea()

            FaceOvalOverlay(
                faceDetected: viewModel.faceDetector.faceDetected,
                faceInstruction: viewModel.faceDetector.instruction
            )
            .ignoresSafeArea()

            VStack {
                Spacer()

                if viewModel.faceDetector.faceDetected {
                    faceStatusBadge
                        .padding(.bottom, SalmaDesign.Spacing.sm)
                }

                CameraBottomBar(
                    onCapture: { viewModel.capturePhoto() },
                    onTorchToggle: nil,
                    onClose: { dismissSelfie() },
                    isCapturing: viewModel.isProcessing
                )
            }
        }
    }

    private var faceStatusBadge: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(viewModel.faceDetector.instruction == .centered
                      ? SalmaDesign.Colors.success
                      : SalmaDesign.Colors.warning)
                .frame(width: 8, height: 8)

            Text(NSLocalizedString(viewModel.faceDetector.instruction.messageKey, bundle: .localized, comment: ""))
                .font(SalmaDesign.Typography.caption)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.black.opacity(0.6))
        .cornerRadius(SalmaDesign.Radius.full)
        .animation(.easeInOut(duration: 0.2), value: viewModel.faceDetector.instruction)
    }

    // MARK: - Quality Check

    private var qualityCheckView: some View {
        VStack(spacing: SalmaDesign.Spacing.md) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.5)
            Text(L("image_quality_checking"))
                .font(SalmaDesign.Typography.body)
                .foregroundColor(.white)
        }
    }

    // MARK: - Reviewing

    private var reviewingView: some View {
        ZStack {
            if let image = viewModel.capturedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .ignoresSafeArea()
            }

            VStack {
                if viewModel.showQualityWarning {
                    VStack(spacing: 4) {
                        ForEach(viewModel.qualityIssues.indices, id: \.self) { i in
                            HStack(spacing: 6) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(SalmaDesign.Colors.warning)
                                Text(NSLocalizedString(viewModel.qualityIssues[i].messageKey, bundle: .localized, comment: ""))
                                    .font(SalmaDesign.Typography.caption)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(SalmaDesign.Radius.sm)
                    .padding(.top, 60)
                }

                Spacer()

                VStack(spacing: SalmaDesign.Spacing.md) {
                    HStack(spacing: 6) {
                        Image(systemName: "person.crop.circle.fill.badge.checkmark")
                            .font(.system(size: 16))
                        Text(L("selfie_captured"))
                            .font(SalmaDesign.Typography.captionMedium)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(SalmaDesign.Colors.success.opacity(0.8))
                    .cornerRadius(SalmaDesign.Radius.full)

                    HStack(spacing: SalmaDesign.Spacing.md) {
                        Button {
                            viewModel.retakePhoto()
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.system(size: 16, weight: .semibold))
                                Text(L("retake"))
                                    .font(SalmaDesign.Typography.bodyMedium)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity).frame(height: 52)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(SalmaDesign.Radius.lg)
                        }

                        Button {
                            viewModel.usePhoto()
                            saveAndDismiss()
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 16, weight: .semibold))
                                Text(L("use_photo"))
                                    .font(SalmaDesign.Typography.bodyMedium)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity).frame(height: 52)
                            .background(SalmaDesign.Colors.primary)
                            .cornerRadius(SalmaDesign.Radius.lg)
                        }
                    }
                    .padding(.horizontal, SalmaDesign.Spacing.lg)
                }
                .padding(.bottom, 40)
                .background(
                    LinearGradient(colors: [.clear, .black.opacity(0.7)],
                                   startPoint: .top, endPoint: .bottom)
                    .frame(height: 200).allowsHitTesting(false),
                    alignment: .bottom
                )
            }
        }
    }

    // MARK: - Actions

    private func saveAndDismiss() {
        if let captured = viewModel.buildCapturedImage() {
            flowState.setCapturedImage(captured, for: fieldId)
        }
        router.dismissFullScreen()
    }

    private func dismissSelfie() {
        viewModel.stopCamera()
        router.dismissFullScreen()
    }
}
