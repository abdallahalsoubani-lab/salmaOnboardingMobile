import SwiftUI

struct JourneyLoadingView: View {
    @EnvironmentObject var container: DependencyContainer
    @EnvironmentObject var flowState: VerificationFlowState
    @EnvironmentObject var router: NavigationRouter
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var connectivity: ConnectivityMonitor

    @Environment(\.colorScheme) private var colorScheme
    @State private var spinAngle: Double = 0
    @State private var hasStartedLoading = false

    var body: some View {
        ZStack {
            ThemedColors.background(for: colorScheme).ignoresSafeArea()

            if flowState.isLoadingJourney {
                loadingContent
            } else if let error = flowState.journeyError {
                errorContent(error: error)
            } else {
                loadingContent
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    router.presentSheet(.languageSwitch)
                } label: {
                    Image(systemName: "globe")
                        .font(.system(size: 18))
                        .foregroundColor(SalmaDesign.Colors.textSecondary)
                }
            }
        }
        .onAppear {
            loadJourney()
        }
    }

    // MARK: - Loading State

    private var loadingContent: some View {
        VStack(spacing: SalmaDesign.Spacing.lg) {
            Spacer()

            Text("Salma AI")
                .font(SalmaDesign.Typography.largeTitle)
                .foregroundColor(ThemedColors.primary)

            // Spinner
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(ThemedColors.primary, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .frame(width: 36, height: 36)
                .rotationEffect(.degrees(spinAngle))
                .onAppear {
                    withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                        spinAngle = 360
                    }
                }

            Text(L("loading_journey"))
                .font(SalmaDesign.Typography.callout)
                .foregroundColor(SalmaDesign.Colors.textSecondary)

            Spacer()
        }
    }

    // MARK: - Error State

    private func errorContent(error: APIError) -> some View {
        VStack(spacing: SalmaDesign.Spacing.md) {
            Spacer()

            Image(systemName: errorIcon(for: error))
                .font(.system(size: 48))
                .foregroundColor(errorColor(for: error))
                .padding(.bottom, SalmaDesign.Spacing.sm)

            Text(error.errorDescription ?? L("error"))
                .font(SalmaDesign.Typography.body)
                .foregroundColor(ThemedColors.textPrimary(for: colorScheme))
                .multilineTextAlignment(.center)
                .padding(.horizontal, SalmaDesign.Spacing.xl)

            if case .noData = error {
                Text(L("try_again_later"))
                    .font(SalmaDesign.Typography.callout)
                    .foregroundColor(SalmaDesign.Colors.textSecondary)
            }

            SalmaButton(
                title: L("retry"),
                style: .secondary
            ) {
                hasStartedLoading = false
                loadJourney()
            }
            .padding(.horizontal, SalmaDesign.Spacing.xxl)
            .padding(.top, SalmaDesign.Spacing.md)

            Spacer()
        }
    }

    // MARK: - Helpers

    private func errorIcon(for error: APIError) -> String {
        switch error {
        case .noInternet: return "wifi.slash"
        case .noData: return "doc.text.magnifyingglass"
        default: return "exclamationmark.triangle.fill"
        }
    }

    private func errorColor(for error: APIError) -> Color {
        switch error {
        case .noInternet: return SalmaDesign.Colors.warning
        case .noData: return SalmaDesign.Colors.textTertiary
        default: return SalmaDesign.Colors.danger
        }
    }

    private func loadJourney() {
        guard !hasStartedLoading else { return }
        hasStartedLoading = true

        Task {
            flowState.isLoadingJourney = true
            flowState.journeyError = nil

            do {
                if flowState.startJourneyFresh {
                    await container.journeyService.clearCache()
                }

                let journey = try await container.journeyService.getActiveJourney(
                    code: flowState.selectedJourneyCode,
                    journeyId: flowState.selectedJourneyId
                )
                flowState.journey = journey
                flowState.isLoadingJourney = false

                container.submissionModeManager.updateMode()
                flowState.submissionMode = container.submissionModeManager.currentMode

                if flowState.submissionMode == .perPage {
                    if flowState.startJourneyFresh {
                        if let activeDraft = try? await container.draftService.getActiveDraft(
                            journeyId: journey.id,
                            deviceId: DeviceIdHelper.deviceId
                        ) {
                            try? await container.draftService.deleteDraft(draftId: activeDraft.draftId)
                        }
                        let draft = try await container.draftService.startDraft(
                            journeyId: journey.id,
                            journeyCode: flowState.selectedJourneyCode,
                            deviceId: DeviceIdHelper.deviceId
                        )
                        await MainActor.run {
                            flowState.startJourneyFresh = false
                            flowState.draftId = draft.draftId
                        }
                        if !journey.pages.isEmpty {
                            router.push(.formPage(pageIndex: 0))
                        }
                        return
                    }

                    if let activeDraft = try? await container.draftService.getActiveDraft(
                        journeyId: journey.id,
                        deviceId: DeviceIdHelper.deviceId
                    ) {
                        flowState.draftId = activeDraft.draftId
                        if let savedValues = activeDraft.fieldValues {
                            flowState.fieldValues.merge(savedValues) { _, new in new }
                        }
                        let resumeIndex = min(activeDraft.currentPageIndex, journey.pages.count - 1)
                        pushPagesUpTo(resumeIndex)
                        return
                    }

                    let draft = try await container.draftService.startDraft(
                        journeyId: journey.id,
                        journeyCode: flowState.selectedJourneyCode,
                        deviceId: DeviceIdHelper.deviceId
                    )
                    flowState.draftId = draft.draftId
                }

                await MainActor.run { flowState.startJourneyFresh = false }

                if !journey.pages.isEmpty {
                    router.push(.formPage(pageIndex: 0))
                }
            } catch let error as APIError {
                flowState.journeyError = error
                flowState.isLoadingJourney = false
            } catch {
                flowState.journeyError = .unknown(error)
                flowState.isLoadingJourney = false
            }
        }
    }

    private func pushPagesUpTo(_ targetIndex: Int) {
        for i in 0...targetIndex {
            router.push(.formPage(pageIndex: i))
        }
    }
}
