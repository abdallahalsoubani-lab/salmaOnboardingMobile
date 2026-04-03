import SwiftUI
import FaceLiveness

struct LivenessCheckView: View {
    let fieldId: String
    let onComplete: (Bool, Float, String) -> Void
    let onCancel: () -> Void

    @StateObject private var viewModel: LivenessViewModel
    @Environment(\.dismiss) private var dismiss

    init(
        fieldId: String,
        apiClient: APIClient,
        onComplete: @escaping (Bool, Float, String) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.fieldId = fieldId
        self.onComplete = onComplete
        self.onCancel = onCancel
        self._viewModel = StateObject(wrappedValue: LivenessViewModel(apiClient: apiClient))
    }

    var body: some View {
        ZStack {
            SalmaDesign.Colors.background.ignoresSafeArea()

            if viewModel.isLoading && viewModel.sessionId == nil {
                preparingView
            } else if let sessionId = viewModel.sessionId, !viewModel.isComplete {
                livenessDetectorView(sessionId: sessionId)
            } else if viewModel.isComplete, let result = viewModel.result {
                livenessResultView(result)
            } else if let error = viewModel.error {
                errorView(error)
            }
        }
        .onAppear {
            Task { await viewModel.createSession() }
        }
    }

    // MARK: - Liveness Detector

    @ViewBuilder
    private func livenessDetectorView(sessionId: String) -> some View {
        FaceLivenessDetectorView(
            sessionID: sessionId,
            region: AmplifyConfigurator.awsRegion,
            isPresented: .constant(true),
            onCompletion: { result in
                switch result {
                case .success:
                    Task { await viewModel.verifySession() }
                case .failure(let error):
                    viewModel.error = error.localizedDescription
                }
            }
        )
    }

    // MARK: - Preparing

    private var preparingView: some View {
        VStack(spacing: SalmaDesign.Spacing.lg) {
            ProgressView()
                .scaleEffect(1.5)
            Text(L("liveness_preparing"))
                .font(SalmaDesign.Typography.body)
                .foregroundColor(SalmaDesign.Colors.textSecondary)
        }
    }

    // MARK: - Result

    @ViewBuilder
    private func livenessResultView(_ result: LivenessViewModel.LivenessCheckResult) -> some View {
        VStack(spacing: SalmaDesign.Spacing.xl) {
            Spacer()

            if result.isLive {
                SuccessCheckmarkView(size: 100, color: SalmaDesign.Colors.success)
                Text(L("liveness_passed"))
                    .font(SalmaDesign.Typography.title2)
                    .foregroundColor(SalmaDesign.Colors.success)
                Text(String(format: L("liveness_confidence"), Int(result.confidence)))
                    .font(SalmaDesign.Typography.caption)
                    .foregroundColor(SalmaDesign.Colors.textSecondary)
            } else {
                RejectedXMarkView(size: 100, color: SalmaDesign.Colors.danger)
                Text(L("liveness_failed"))
                    .font(SalmaDesign.Typography.title2)
                    .foregroundColor(SalmaDesign.Colors.danger)
                Text(L("liveness_failed_message"))
                    .font(SalmaDesign.Typography.body)
                    .foregroundColor(SalmaDesign.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            VStack(spacing: SalmaDesign.Spacing.sm) {
                SalmaButton(
                    title: result.isLive
                        ? L("continue")
                        : L("retry"),
                    size: .large,
                    action: {
                        if result.isLive {
                            onComplete(true, result.confidence, viewModel.sessionId ?? "")
                        } else {
                            viewModel.resetForRetry()
                            Task { await viewModel.createSession() }
                        }
                    }
                )

                if !result.isLive {
                    SalmaButton(
                        title: L("cancel"),
                        style: .ghost,
                        size: .medium,
                        action: onCancel
                    )
                }
            }
        }
        .padding(.horizontal, SalmaDesign.Spacing.lg)
        .padding(.bottom, SalmaDesign.Spacing.xl)
    }

    // MARK: - Error

    @ViewBuilder
    private func errorView(_ error: String) -> some View {
        VStack(spacing: SalmaDesign.Spacing.lg) {
            Spacer()

            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(SalmaDesign.Colors.warning)

            Text(L("liveness_error"))
                .font(SalmaDesign.Typography.title2)
                .foregroundColor(SalmaDesign.Colors.textPrimary)

            Text(error)
                .font(SalmaDesign.Typography.caption)
                .foregroundColor(SalmaDesign.Colors.textSecondary)
                .multilineTextAlignment(.center)

            Spacer()

            VStack(spacing: SalmaDesign.Spacing.sm) {
                SalmaButton(
                    title: L("retry"),
                    size: .large,
                    action: {
                        viewModel.resetForRetry()
                        Task { await viewModel.createSession() }
                    }
                )

                SalmaButton(
                    title: L("cancel"),
                    style: .ghost,
                    size: .medium,
                    action: onCancel
                )
            }
        }
        .padding(.horizontal, SalmaDesign.Spacing.lg)
        .padding(.bottom, SalmaDesign.Spacing.xl)
    }
}
