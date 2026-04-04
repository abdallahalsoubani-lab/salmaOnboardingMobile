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
        .task { await loadThemeIfNeeded() }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: SalmaDesign.Spacing.sm) {
            Group {
                if let logoUrlString = flowState.appTheme?.logoUrl ?? ThemeManager.shared.appTheme?.logoUrl,
                   !logoUrlString.isEmpty,
                   let url = URL(string: logoUrlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                        default:
                            defaultShieldIcon()
                        }
                    }
                    .frame(height: 60)
                } else {
                    defaultShieldIcon()
                }
            }
            .padding(.top, SalmaDesign.Spacing.xxl)

//            Text(flowState.appTheme?.appName ?? ThemeManager.shared.appTheme?.appName ?? L("welcome"))
//                .font(SalmaDesign.Typography.largeTitle)
//                .foregroundColor(ThemedColors.textPrimary(for: colorScheme))

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

    @FocusState private var identifierFocused: Bool
    @State private var shakeIdentifier = false

    private var resumeSection: some View {
        VStack(spacing: SalmaDesign.Spacing.md) {
            IdentifierField(
                label: L("phone_or_national_id"),
                placeholder: L("enter_identifier_placeholder"),
                text: $identifier,
                errorMessage: searchError,
                isFocused: $identifierFocused,
                shakeError: $shakeIdentifier
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

    @ViewBuilder
    private func defaultShieldIcon() -> some View {
        Image(systemName: "shield.checkered")
            .font(.system(size: 44, weight: .medium))
            .foregroundColor(ThemedColors.primary)
    }

    private func loadThemeIfNeeded() async {
        guard flowState.appTheme == nil, ThemeManager.shared.appTheme == nil else {
            if flowState.appTheme == nil, let cached = ThemeManager.shared.appTheme {
                flowState.appTheme = cached
            }
            return
        }
        do {
            let theme: AppTheme = try await container.apiClient.get(.getTheme)
            await MainActor.run {
                flowState.appTheme = theme
                ThemeManager.shared.applyAppTheme(theme)
            }
            #if DEBUG
            print("[Theme] ResumeView fallback loaded — logo: \(theme.logoUrl ?? "none")")
            #endif
        } catch {
            #if DEBUG
            print("[Theme] ResumeView fallback failed: \(error)")
            #endif
        }
    }

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

// MARK: - LTR Identifier Input (UIKit-backed)

private struct IdentifierField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    let errorMessage: String?
    var isFocused: FocusState<Bool>.Binding
    @Binding var shakeError: Bool

    private var borderColor: Color {
        if errorMessage != nil { return SalmaDesign.Colors.danger }
        if isFocused.wrappedValue { return ThemedColors.primary }
        return SalmaDesign.Colors.border
    }

    var body: some View {
        VStack(alignment: .leading, spacing: SalmaDesign.Spacing.xs) {
            HStack(spacing: 2) {
                Text(label)
                    .font(SalmaDesign.Typography.callout)
                    .foregroundColor(SalmaDesign.Colors.textSecondary)
            }

            IdentifierUITextField(
                text: $text,
                placeholder: placeholder,
                isFocused: isFocused
            )
            .frame(height: 52)
            .background(SalmaDesign.Colors.backgroundSecondary)
            .cornerRadius(SalmaDesign.Radius.md)
            .overlay(
                RoundedRectangle(cornerRadius: SalmaDesign.Radius.md)
                    .stroke(borderColor, lineWidth: 1.5)
            )
            .shake(trigger: shakeError)
            .animation(.easeInOut(duration: 0.2), value: isFocused.wrappedValue)

            if let error = errorMessage {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle")
                        .font(.system(size: 12))
                    Text(error)
                        .font(SalmaDesign.Typography.caption)
                }
                .foregroundColor(SalmaDesign.Colors.danger)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(AppAnimations.fadeIn, value: errorMessage)
        .onChange(of: errorMessage) { newValue in
            if newValue != nil { shakeError.toggle() }
        }
    }
}

private struct IdentifierUITextField: UIViewRepresentable {
    @Binding var text: String
    let placeholder: String
    var isFocused: FocusState<Bool>.Binding

    func makeUIView(context: Context) -> UITextField {
        let tf = UITextField()
        tf.textAlignment = .left
        tf.semanticContentAttribute = .forceLeftToRight
        tf.keyboardType = .numberPad
        tf.placeholder = placeholder
        tf.font = .systemFont(ofSize: 17)
        tf.textColor = UIColor.label
        tf.delegate = context.coordinator
        tf.setContentHuggingPriority(.defaultLow, for: .horizontal)
        tf.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let hPad = SalmaDesign.Spacing.md
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: hPad, height: 1))
        tf.leftViewMode = .always
        tf.rightView = UIView(frame: CGRect(x: 0, y: 0, width: hPad, height: 1))
        tf.rightViewMode = .always

        tf.addTarget(context.coordinator, action: #selector(Coordinator.textChanged(_:)), for: .editingChanged)
        tf.addTarget(context.coordinator, action: #selector(Coordinator.editingDidBegin(_:)), for: .editingDidBegin)
        tf.addTarget(context.coordinator, action: #selector(Coordinator.editingDidEnd(_:)), for: .editingDidEnd)
        tf.inputAccessoryView = makeDoneToolbar(target: context.coordinator)
        return tf
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        if uiView.text != text { uiView.text = text }
        if uiView.placeholder != placeholder { uiView.placeholder = placeholder }
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    private func makeDoneToolbar(target: Coordinator) -> UIToolbar {
        let bar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        bar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: L("done"), style: .done, target: target, action: #selector(Coordinator.doneTapped))
        ]
        bar.sizeToFit()
        return bar
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: IdentifierUITextField
        init(_ parent: IdentifierUITextField) { self.parent = parent }

        @objc func doneTapped() {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }

        @objc func textChanged(_ tf: UITextField) {
            parent.text = tf.text ?? ""
        }

        @objc func editingDidBegin(_ tf: UITextField) {
            parent.isFocused.wrappedValue = true
        }

        @objc func editingDidEnd(_ tf: UITextField) {
            parent.isFocused.wrappedValue = false
        }

        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            let allowed = CharacterSet.decimalDigits
            return string.unicodeScalars.allSatisfy { allowed.contains($0) }
        }
    }
}
