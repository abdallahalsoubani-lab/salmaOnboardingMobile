import SwiftUI

struct SubmissionProgressView: View {
    @EnvironmentObject var flowState: VerificationFlowState
    @EnvironmentObject var router: NavigationRouter
    @EnvironmentObject var container: DependencyContainer
    @EnvironmentObject var languageManager: LanguageManager

    @State private var currentStep: SubmitStep = .uploading
    @State private var error: APIError?
    @State private var progress: Double = 0.0

    enum SubmitStep: Int, CaseIterable {
        case uploading = 0
        case processing = 1
        case complete = 2

        var labelAr: String {
            switch self {
            case .uploading: return "جاري رفع الملفات..."
            case .processing: return "جاري معالجة البيانات..."
            case .complete: return "تم!"
            }
        }
        var labelEn: String {
            switch self {
            case .uploading: return "Uploading files..."
            case .processing: return "Processing data..."
            case .complete: return "Done!"
            }
        }
        var icon: String {
            switch self {
            case .uploading: return "icloud.and.arrow.up"
            case .processing: return "gearshape.2"
            case .complete: return "checkmark.circle"
            }
        }
    }

    var body: some View {
        VStack(spacing: SalmaDesign.Spacing.xl) {
            Spacer()
            if let error = error {
                errorView(error)
            } else {
                progressView
            }
            Spacer()
        }
        .padding(.horizontal, SalmaDesign.Spacing.lg)
        .background(SalmaDesign.Colors.background.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .interactiveDismissDisabled(true)
        .onAppear { startSubmission() }
    }

    // MARK: - Progress

    @ViewBuilder
    private var progressView: some View {
        VStack(spacing: SalmaDesign.Spacing.xl) {
            ZStack {
                Circle()
                    .fill(SalmaDesign.Colors.primaryLight)
                    .frame(width: 100, height: 100)
                Image(systemName: currentStep.icon)
                    .font(.system(size: 36))
                    .foregroundColor(SalmaDesign.Colors.primary)
            }

            Text(languageManager.currentLanguage == .arabic ? currentStep.labelAr : currentStep.labelEn)
                .font(SalmaDesign.Typography.title2)
                .foregroundColor(SalmaDesign.Colors.textPrimary)
                .animation(.easeInOut, value: currentStep)

            VStack(spacing: SalmaDesign.Spacing.sm) {
                HStack(spacing: 0) {
                    ForEach(SubmitStep.allCases, id: \.rawValue) { step in
                        Circle()
                            .fill(step.rawValue <= currentStep.rawValue
                                  ? SalmaDesign.Colors.primary : SalmaDesign.Colors.border)
                            .frame(width: 12, height: 12)
                        if step != .complete {
                            Rectangle()
                                .fill(step.rawValue < currentStep.rawValue
                                      ? SalmaDesign.Colors.primary : SalmaDesign.Colors.border)
                                .frame(height: 3)
                        }
                    }
                }
                .padding(.horizontal, SalmaDesign.Spacing.xl)

                if currentStep == .uploading {
                    Text("\(Int(progress * 100))%")
                        .font(SalmaDesign.Typography.caption)
                        .foregroundColor(SalmaDesign.Colors.textSecondary)
                }
            }

            Text(L("do_not_close_app"))
                .font(SalmaDesign.Typography.caption)
                .foregroundColor(SalmaDesign.Colors.textTertiary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Error

    @ViewBuilder
    private func errorView(_ error: APIError) -> some View {
        VStack(spacing: SalmaDesign.Spacing.lg) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(SalmaDesign.Colors.danger)

            Text(L("submission_failed"))
                .font(SalmaDesign.Typography.title2)
                .foregroundColor(SalmaDesign.Colors.textPrimary)

            Text(error.errorDescription ?? L("server_error_generic"))
                .font(SalmaDesign.Typography.body)
                .foregroundColor(SalmaDesign.Colors.textSecondary)
                .multilineTextAlignment(.center)

            VStack(spacing: SalmaDesign.Spacing.md) {
                SalmaButton(title: L("retry"), size: .large, icon: "arrow.clockwise") {
                    self.error = nil
                    currentStep = .uploading
                    progress = 0.0
                    startSubmission()
                }
                SalmaButton(title: L("back_to_review"), style: .ghost, size: .medium) {
                    router.pop()
                }
            }
        }
    }

    // MARK: - Submit

    private func startSubmission() {
        guard let journey = flowState.journey else { return }

        Task {
            do {
                currentStep = .uploading

                let progressTask = Task {
                    for i in 1...80 {
                        try? await Task.sleep(nanoseconds: 50_000_000)
                        await MainActor.run { progress = Double(i) / 100.0 }
                    }
                }

                let images = Array(flowState.capturedImages.values)

                var fields = flowState.fieldValues
                if let livenessId = flowState.livenessSessionId {
                    fields["livenessSessionId"] = livenessId
                }

                for page in journey.pages {
                    for field in page.fields where field.validationRules?.terms?.isTermsField == true {
                        if fields[field.id] == "true" {
                            fields[field.id + "_acceptedAt"] = ISO8601DateFormatter().string(from: Date())
                            fields[field.id + "_version"] = String(journey.version)
                        }
                    }
                }

                currentStep = .processing
                progressTask.cancel()
                await MainActor.run { progress = 0.9 }

                let result = try await container.submissionService.submitVerification(
                    journeyId: journey.id,
                    fields: fields,
                    images: images
                )

                await MainActor.run {
                    progress = 1.0
                    currentStep = .complete
                    flowState.submissionResult = result
                    HapticManager.notification(.success)
                }

                try? await Task.sleep(nanoseconds: 800_000_000)
                await MainActor.run { router.push(.result) }

            } catch let apiError as APIError {
                await MainActor.run {
                    self.error = apiError
                    HapticManager.notification(.error)
                }
            } catch {
                await MainActor.run {
                    self.error = .unknown(error)
                    HapticManager.notification(.error)
                }
            }
        }
    }
}
