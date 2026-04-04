import SwiftUI

struct ResumeView: View {
    @EnvironmentObject var container: DependencyContainer
    @EnvironmentObject var flowState: VerificationFlowState
    @EnvironmentObject var router: NavigationRouter
    @EnvironmentObject var languageManager: LanguageManager

    @Environment(\.colorScheme) private var colorScheme

    @State private var identifier = ""
    @State private var isSearching = false
    @State private var searchResult: ResumeResponse?
    @State private var searchError: String?
    @State private var showResumeSection = false
    @State private var isSendingOtp = false
    @State private var appeared = false

    var body: some View {
        ZStack {
            ThemedColors.background(for: colorScheme).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    headerSection
                    startNewSection
                    dividerSection
                    resumeToggle
                    if showResumeSection {
                        resumeSection
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    Spacer(minLength: SalmaDesign.Spacing.xxl)
                }
                .padding(.horizontal, SalmaDesign.Spacing.lg)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { router.pop() } label: {
                    Image(systemName: languageManager.currentLanguage == .arabic ? "chevron.right" : "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(ThemedColors.textPrimary(for: colorScheme))
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button { router.presentSheet(.languageSwitch) } label: {
                    Image(systemName: "globe")
                        .font(.system(size: 18))
                        .foregroundColor(SalmaDesign.Colors.textSecondary)
                }
            }
        }
        .onAppear {
            withAnimation(AppAnimations.fadeIn) { appeared = true }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: SalmaDesign.Spacing.sm) {
            Image(systemName: "shield.checkered")
                .font(.system(size: 44, weight: .medium))
                .foregroundColor(ThemedColors.primary)
                .padding(.top, SalmaDesign.Spacing.xxl)

            Text(L("welcome"))
                .font(SalmaDesign.Typography.largeTitle)
                .foregroundColor(ThemedColors.textPrimary(for: colorScheme))

            Text(L("get_started_subtitle"))
                .font(SalmaDesign.Typography.callout)
                .foregroundColor(SalmaDesign.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .opacity(appeared ? 1 : 0)
        .padding(.bottom, SalmaDesign.Spacing.xl)
    }

    // MARK: - Start New Journey

    private var startNewSection: some View {
        SalmaButton(
            title: L("start_new_journey"),
            style: .primary,
            size: .large,
            icon: "arrow.right",
            iconPosition: languageManager.currentLanguage == .arabic ? .leading : .trailing,
            fullWidth: true
        ) {
            HapticManager.impact(.medium)
            flowState.prepareForNewJourney()
            if flowState.selectedJourneyCode != nil || flowState.selectedJourneyId != nil {
                router.push(.journeyLoading)
            } else {
                router.push(.journeySelection)
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
    }

    // MARK: - Divider

    private var dividerSection: some View {
        HStack(spacing: SalmaDesign.Spacing.md) {
            Rectangle()
                .fill(SalmaDesign.Colors.divider)
                .frame(height: 1)
            Text(L("or"))
                .font(SalmaDesign.Typography.caption)
                .foregroundColor(SalmaDesign.Colors.textTertiary)
            Rectangle()
                .fill(SalmaDesign.Colors.divider)
                .frame(height: 1)
        }
        .padding(.vertical, SalmaDesign.Spacing.lg)
    }

    // MARK: - Resume Toggle

    private var resumeToggle: some View {
        Button {
            withAnimation(AppAnimations.stateChange) {
                showResumeSection.toggle()
                if !showResumeSection { resetSearch() }
            }
        } label: {
            HStack(spacing: SalmaDesign.Spacing.sm) {
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.system(size: 16))
                Text(L("have_previous_application"))
                    .font(SalmaDesign.Typography.bodyMedium)
                Spacer()
                Image(systemName: showResumeSection ? "chevron.up" : "chevron.down")
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundColor(ThemedColors.primary)
            .padding(SalmaDesign.Spacing.md)
            .background(ThemedColors.primaryLight.opacity(0.12))
            .cornerRadius(SalmaDesign.Radius.md)
        }
    }

    // MARK: - Resume Section

    private var resumeSection: some View {
        VStack(spacing: SalmaDesign.Spacing.md) {
            SalmaTextField(
                label: L("phone_or_national_id"),
                text: $identifier,
                placeholder: L("enter_identifier_placeholder"),
                errorMessage: searchError,
                keyboardType: .numberPad
            )

            SalmaButton(
                title: L("search"),
                style: .outline,
                size: .medium,
                isLoading: isSearching,
                isDisabled: identifier.trimmingCharacters(in: .whitespaces).isEmpty,
                icon: "magnifyingglass",
                iconPosition: .leading
            ) {
                searchDraft()
            }

            if let result = searchResult {
                if result.found {
                    foundCard(result)
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                } else {
                    notFoundCard
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                }
            }
        }
        .padding(.top, SalmaDesign.Spacing.md)
    }

    // MARK: - Found Card

    private func foundCard(_ result: ResumeResponse) -> some View {
        VStack(spacing: SalmaDesign.Spacing.md) {
            HStack(spacing: SalmaDesign.Spacing.md) {
                ZStack {
                    Circle()
                        .fill(SalmaDesign.Colors.success.opacity(0.12))
                        .frame(width: 44, height: 44)
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(SalmaDesign.Colors.success)
                }

                VStack(alignment: .leading, spacing: SalmaDesign.Spacing.xs) {
                    Text(result.maskedName ?? L("application_found"))
                        .font(SalmaDesign.Typography.bodyMedium)
                        .foregroundColor(ThemedColors.textPrimary(for: colorScheme))

                    if let page = result.currentPageIndex, let total = result.totalPages {
                        Text(L("page_progress") + " \(page + 1)/\(total)")
                            .font(SalmaDesign.Typography.caption)
                            .foregroundColor(SalmaDesign.Colors.textSecondary)
                    }
                }

                Spacer()
            }

            SalmaButton(
                title: L("continue"),
                style: .primary,
                size: .medium,
                isLoading: isSendingOtp,
                icon: "arrow.right",
                iconPosition: languageManager.currentLanguage == .arabic ? .leading : .trailing
            ) {
                sendOtpAndNavigate(result)
            }
        }
        .padding(SalmaDesign.Spacing.md)
        .background(SalmaDesign.Colors.surface)
        .cornerRadius(SalmaDesign.Radius.lg)
        .overlay(
            RoundedRectangle(cornerRadius: SalmaDesign.Radius.lg)
                .stroke(SalmaDesign.Colors.success.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Not Found Card

    private var notFoundCard: some View {
        VStack(spacing: SalmaDesign.Spacing.md) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 28))
                .foregroundColor(SalmaDesign.Colors.textTertiary)

            Text(L("no_application_found"))
                .font(SalmaDesign.Typography.body)
                .foregroundColor(SalmaDesign.Colors.textSecondary)
                .multilineTextAlignment(.center)

            SalmaButton(
                title: L("start_new_journey"),
                style: .secondary,
                size: .medium
            ) {
                flowState.prepareForNewJourney()
                if flowState.selectedJourneyCode != nil || flowState.selectedJourneyId != nil {
                    router.push(.journeyLoading)
                } else {
                    router.push(.journeySelection)
                }
            }
        }
        .padding(SalmaDesign.Spacing.lg)
        .background(SalmaDesign.Colors.surface)
        .cornerRadius(SalmaDesign.Radius.lg)
        .overlay(
            RoundedRectangle(cornerRadius: SalmaDesign.Radius.lg)
                .stroke(SalmaDesign.Colors.border, lineWidth: 1)
        )
    }

    // MARK: - Actions

    private func searchDraft() {
        guard !identifier.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        guard ConnectivityMonitor.shared.isConnected else {
            searchError = L("no_internet")
            return
        }

        isSearching = true
        searchError = nil
        searchResult = nil

        Task {
            do {
                let result = try await container.draftService.findDraftByIdentifier(
                    identifier: identifier.trimmingCharacters(in: .whitespaces),
                    journeyId: nil,
                    journeyCode: flowState.selectedJourneyCode
                )
                await MainActor.run {
                    withAnimation(AppAnimations.stateChange) {
                        searchResult = result
                        isSearching = false
                        if result.found {
                            HapticManager.notification(.success)
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    withAnimation(AppAnimations.stateChange) {
                        searchError = L("search_failed")
                        isSearching = false
                        HapticManager.notification(.error)
                    }
                }
            }
        }
    }

    private func sendOtpAndNavigate(_ result: ResumeResponse) {
        guard let draftId = result.draftId else { return }
        guard ConnectivityMonitor.shared.isConnected else {
            searchError = L("no_internet")
            return
        }

        isSendingOtp = true

        let identifierType = identifier.count <= 10 && identifier.allSatisfy(\.isNumber) && identifier.count >= 9
            ? "phone" : "national_id"

        Task {
            do {
                _ = try await container.draftService.sendOtp(
                    identifier: identifier.trimmingCharacters(in: .whitespaces),
                    identifierType: identifierType
                )
                await MainActor.run {
                    isSendingOtp = false
                    flowState.draftId = draftId
                    router.push(.otpVerification(
                        identifier: identifier.trimmingCharacters(in: .whitespaces),
                        draftId: draftId
                    ))
                }
            } catch {
                await MainActor.run {
                    isSendingOtp = false
                    searchError = L("otp_send_failed")
                    HapticManager.notification(.error)
                }
            }
        }
    }

    private func resetSearch() {
        identifier = ""
        searchResult = nil
        searchError = nil
        isSearching = false
        isSendingOtp = false
    }
}
