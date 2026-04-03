import SwiftUI

struct AppCoordinator: View {
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var container: DependencyContainer
    @EnvironmentObject var connectivity: ConnectivityMonitor
    @StateObject private var flowState = VerificationFlowState()
    @StateObject private var router = NavigationRouter()

    var body: some View {
        ZStack(alignment: .top) {
            Group {
                if !languageManager.isLanguageSelected {
                    LanguageSelectionView()
                        .transition(.opacity)
                } else {
                    mainNavigationView
                        .transition(.opacity)
                }
            }
            .animation(AppAnimations.stateChange, value: languageManager.isLanguageSelected)

            // No internet banner
            NoInternetBanner()
        }
        .environmentObject(flowState)
        .environmentObject(router)
    }

    @ViewBuilder
    private var mainNavigationView: some View {
        NavigationStack(path: $router.navigationPath) {
            JourneyLoadingView()
                .navigationDestination(for: Route.self) { route in
                    routeView(for: route)
                }
        }
        .sheet(item: $router.presentedSheet) { sheet in
            sheetView(for: sheet)
        }
        .fullScreenCover(item: $router.presentedFullScreen) { fullScreen in
            fullScreenView(for: fullScreen)
        }
    }

    // MARK: - Route Mapping

    @ViewBuilder
    private func routeView(for route: Route) -> some View {
        switch route {
        case .languageSelection:
            LanguageSelectionView()

        case .journeyLoading:
            JourneyLoadingView()

        case .formPage(let pageIndex):
            FormPageView(pageIndex: pageIndex)

        case .review:
            ReviewView()

        case .submitting:
            SubmissionProgressView()

        case .result:
            ResultView()
        }
    }

    @ViewBuilder
    private func sheetView(for sheet: SheetRoute) -> some View {
        switch sheet {
        case .languageSwitch:
            LanguageSwitchSheet()
                .environmentObject(languageManager)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)

        case .fieldInfo(let fieldId):
            FieldInfoSheet(fieldId: fieldId)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }

    @ViewBuilder
    private func fullScreenView(for route: FullScreenRoute) -> some View {
        switch route {
        case .idCapture(let fieldId, let side):
            IDCaptureView(fieldId: fieldId, side: side)
                .environmentObject(flowState)
                .environmentObject(router)
                .environmentObject(container)

        case .selfieCapture(let fieldId):
            SelfieCaptureView(fieldId: fieldId)
                .environmentObject(flowState)
                .environmentObject(router)

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
            .environmentObject(flowState)

        case .photoCapture(let fieldId):
            PhotoCaptureView(fieldId: fieldId)
                .environmentObject(flowState)
                .environmentObject(router)

        case .signaturePad(let fieldId):
            SignaturePadView(fieldId: fieldId)
                .environmentObject(flowState)
                .environmentObject(router)

        case .imagePreview(let fieldId, let imageData):
            ImagePreviewView(fieldId: fieldId, imageData: imageData)
                .environmentObject(flowState)
                .environmentObject(router)
        }
    }
}
