import SwiftUI

struct SDKContainerView: View {
    let config: SalmaConfig
    let completion: (SalmaResult) -> Void

    @StateObject private var container: DependencyContainer
    @StateObject private var languageManager = LanguageManager.shared
    @StateObject private var flowState = VerificationFlowState()
    @StateObject private var router = NavigationRouter()
    @StateObject private var connectivity = ConnectivityMonitor.shared

    init(config: SalmaConfig, completion: @escaping (SalmaResult) -> Void) {
        self.config = config
        self.completion = completion
        self._container = StateObject(wrappedValue: DependencyContainer(baseURL: config.apiBaseURL))
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            mainFlow
                .environmentObject(container)
                .environmentObject(languageManager)
                .environmentObject(flowState)
                .environmentObject(router)
                .environmentObject(connectivity)
                .environment(\.layoutDirection, languageManager.layoutDirection)
                .environment(\.locale, languageManager.currentLanguage.locale)

            // Close button
            Button { completion(.cancelled) } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(SalmaDesign.Colors.textSecondary)
                    .frame(width: 32, height: 32)
                    .background(SalmaDesign.Colors.backgroundSecondary)
                    .clipShape(Circle())
            }
            .padding(.horizontal, SalmaDesign.Spacing.md)
            .padding(.top, SalmaDesign.Spacing.sm)
        }
        .onAppear { applyLanguageConfig() }
        .onChange(of: router.navigationPath) { path in
            if path.isEmpty && flowState.submissionResult != nil {
                deliverResult()
            }
        }
    }

    @ViewBuilder
    private var mainFlow: some View {
        if config.allowLanguageSwitch && !languageManager.isLanguageSelected {
            LanguageSelectionView()
        } else {
            NavigationStack(path: $router.navigationPath) {
                JourneyLoadingView()
                    .navigationDestination(for: Route.self) { route in
                        routeDestination(route)
                    }
            }
            .sheet(item: $router.presentedSheet) { sheet in
                sheetDestination(sheet)
            }
            .fullScreenCover(item: $router.presentedFullScreen) { route in
                fullScreenDestination(route)
                    .environmentObject(flowState)
                    .environmentObject(router)
                    .environmentObject(container)
            }
        }
    }

    @ViewBuilder
    private func routeDestination(_ route: Route) -> some View {
        switch route {
        case .formPage(let index): FormPageView(pageIndex: index)
        case .review: ReviewView()
        case .submitting: SubmissionProgressView()
        case .result: ResultView()
        case .journeyLoading: JourneyLoadingView()
        default: EmptyView()
        }
    }

    @ViewBuilder
    private func sheetDestination(_ sheet: SheetRoute) -> some View {
        switch sheet {
        case .languageSwitch:
            if config.allowLanguageSwitch {
                LanguageSwitchSheet()
                    .environmentObject(languageManager)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
        case .fieldInfo(let fieldId):
            FieldInfoSheet(fieldId: fieldId)
                .presentationDetents([.medium])
        }
    }

    @ViewBuilder
    private func fullScreenDestination(_ route: FullScreenRoute) -> some View {
        switch route {
        case .idCapture(let fieldId, let side):
            IDCaptureView(fieldId: fieldId, side: side)
        case .selfieCapture(let fieldId):
            SelfieCaptureView(fieldId: fieldId)
        case .livenessCheck(let fieldId):
            LivenessCheckView(
                fieldId: fieldId,
                apiClient: container.apiClient,
                onComplete: { isLive, confidence, sessionId in
                    flowState.livenessResult = isLive
                    flowState.livenessConfidence = confidence
                    flowState.livenessSessionId = sessionId
                    router.dismissFullScreen()
                    if isLive {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            router.presentFullScreen(.selfieCapture(fieldId: fieldId))
                        }
                    }
                },
                onCancel: {
                    router.dismissFullScreen()
                }
            )
        case .photoCapture(let fieldId):
            PhotoCaptureView(fieldId: fieldId)
        case .signaturePad(let fieldId):
            SignaturePadView(fieldId: fieldId)
        case .imagePreview(_, let data):
            if let img = UIImage(data: data) {
                ImagePreviewOverlay(
                    image: img, isPresented: .constant(true),
                    onRetake: { router.dismissFullScreen() },
                    onUse: { router.dismissFullScreen() }
                )
            }
        }
    }

    private func applyLanguageConfig() {
        let language: AppLanguage
        if config.followDeviceLanguage {
            language = Locale.current.language.languageCode?.identifier == "ar" ? .arabic : .english
        } else {
            language = config.defaultLanguage == .arabic ? .arabic : .english
        }

        if !config.allowLanguageSwitch {
            languageManager.setLanguage(language)
        }
    }

    private func deliverResult() {
        guard let result = flowState.submissionResult else {
            completion(.cancelled)
            return
        }

        switch result.status {
        case "Approved":
            completion(.approved(SalmaVerificationData(
                submissionId: result.submissionId,
                fullName: result.ocrData?.fullNameAr,
                nationalId: result.ocrData?.nationalId,
                dateOfBirth: result.ocrData?.dateOfBirth,
                gender: result.ocrData?.gender,
                ocrConfidence: result.ocrData?.confidence,
                rawResponse: nil
            )))
        case "Rejected":
            completion(.rejected(SalmaRejectionData(
                submissionId: result.submissionId,
                reason: result.message,
                rawResponse: nil
            )))
        default:
            completion(.pending(SalmaPendingData(
                submissionId: result.submissionId,
                message: result.message,
                estimatedWaitTime: nil
            )))
        }
    }
}
