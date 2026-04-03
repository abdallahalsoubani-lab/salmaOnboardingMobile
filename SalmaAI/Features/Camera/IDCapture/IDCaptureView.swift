import SwiftUI

struct IDCaptureView: View {
    let fieldId: String
    let side: IDSide

    @StateObject private var viewModel: IDCaptureViewModel
    @EnvironmentObject var flowState: VerificationFlowState
    @EnvironmentObject var router: NavigationRouter
    @EnvironmentObject var container: DependencyContainer

    @State private var focusPoint: CGPoint = .zero
    @State private var showFocusIndicator = false
    @State private var flashTrigger = false

    init(fieldId: String, side: IDSide) {
        self.fieldId = fieldId
        self.side = side
        self._viewModel = StateObject(wrappedValue: IDCaptureViewModel(fieldId: fieldId, side: side))
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
            case .completed:
                Color.black.ignoresSafeArea()
            }
        }
        .cameraFlash(trigger: $flashTrigger)
        .statusBarHidden(true)
        .onAppear { viewModel.setupCamera() }
        .onDisappear { viewModel.stopCamera() }
        .onChange(of: viewModel.captureState) { newState in
            if newState == .reviewing {
                flashTrigger = true
            } else if newState == .completed {
                saveAndDismiss()
            }
        }
    }

    // MARK: - Capturing

    private var capturingView: some View {
        ZStack {
            CameraPreviewView(session: viewModel.cameraManager.session)
                .ignoresSafeArea()
                .onTapGesture { location in
                    viewModel.cameraManager.focus(at: location, in: UIScreen.main.bounds.size)
                    focusPoint = location
                    showFocusIndicator = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        showFocusIndicator = false
                    }
                }

            IDCardOverlay(side: viewModel.currentSide)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.4), value: viewModel.currentSide)

            // Focus indicator
            if showFocusIndicator {
                RoundedRectangle(cornerRadius: 4)
                    .stroke(SalmaDesign.Colors.primary, lineWidth: 2)
                    .frame(width: 60, height: 60)
                    .position(focusPoint)
                    .transition(.scale.combined(with: .opacity))
            }

            VStack {
                Spacer()
                CameraBottomBar(
                    onCapture: { viewModel.capturePhoto() },
                    onTorchToggle: { viewModel.toggleTorch() },
                    onClose: { dismissCapture() },
                    isTorchOn: viewModel.cameraManager.isTorchOn,
                    isCapturing: viewModel.isProcessing
                )
            }
        }
        .animation(.easeOut(duration: 0.3), value: showFocusIndicator)
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
            if let image = viewModel.currentImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .ignoresSafeArea()
            }

            VStack {
                // Top: side badge + quality warning
                VStack(spacing: SalmaDesign.Spacing.sm) {
                    Text(viewModel.currentSide == .front
                         ? L("front_side")
                         : L("back_side"))
                        .font(SalmaDesign.Typography.title2)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(SalmaDesign.Colors.primary.opacity(0.8))
                        .cornerRadius(SalmaDesign.Radius.sm)

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
                        .padding(.vertical, 8)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(SalmaDesign.Radius.sm)
                    }
                }
                .padding(.top, 60)

                Spacer()

                // Bottom: dots + buttons
                VStack(spacing: SalmaDesign.Spacing.md) {
                    HStack(spacing: 8) {
                        Circle().fill(SalmaDesign.Colors.primary).frame(width: 10, height: 10)
                        Circle().fill(viewModel.currentSide == .back
                                      ? SalmaDesign.Colors.primary
                                      : Color.white.opacity(0.3))
                            .frame(width: 10, height: 10)
                    }

                    HStack(spacing: SalmaDesign.Spacing.md) {
                        Button { viewModel.retakePhoto() } label: {
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

                        Button { viewModel.usePhoto() } label: {
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

    // MARK: - Save & Dismiss

    private func saveAndDismiss() {
        let images = viewModel.buildCapturedImages()
        if let front = images.front { flowState.setCapturedImage(front, for: fieldId) }
        if let back = images.back { flowState.setCapturedImage(back, for: fieldId + "_back") }
        router.dismissFullScreen()

        Task {
            await extractOcr(frontImage: images.front, backImage: images.back)
        }
    }

    private func dismissCapture() {
        viewModel.stopCamera()
        router.dismissFullScreen()
    }

    // MARK: - OCR Extraction

    private func extractOcr(frontImage: CapturedImage?, backImage: CapturedImage?) async {
        await MainActor.run { flowState.isExtractingOcr = true }

        do {
            var result = OcrExtractionResult.empty

            if let frontData = frontImage?.imageData {
                let frontResult = try await container.ocrExtractionService.extractFromImage(
                    imageData: frontData, side: "front"
                )
                result = OcrExtractionResult.merged(result, with: frontResult)
            }

            if let backData = backImage?.imageData {
                let backResult = try await container.ocrExtractionService.extractFromImage(
                    imageData: backData, side: "back"
                )
                result = OcrExtractionResult.merged(result, with: backResult)
            }

            await MainActor.run {
                flowState.ocrExtractionResult = result
                flowState.isExtractingOcr = false
                HapticManager.notification(.success)
            }
        } catch {
            await MainActor.run {
                flowState.isExtractingOcr = false
                print("[SalmaAI] OCR extraction failed: \(error)")
            }
        }
    }
}
