import SwiftUI

struct OtpVerificationView: View {
    let identifier: String
    let draftId: String

    @EnvironmentObject var container: DependencyContainer
    @EnvironmentObject var flowState: VerificationFlowState
    @EnvironmentObject var router: NavigationRouter
    @EnvironmentObject var languageManager: LanguageManager

    @Environment(\.colorScheme) private var colorScheme

    @State private var otpDigits: [String] = Array(repeating: "", count: 6)
    @State private var isVerifying = false
    @State private var errorMessage: String?
    @State private var attemptsRemaining = 3
    @State private var isMaxAttempts = false
    @State private var shakeFields = false
    @State private var resendCountdown = 60
    @State private var canResend = false
    @State private var isResending = false
    @State private var appeared = false

    @FocusState private var focusedField: Int?

    private let timerInterval: TimeInterval = 1

    var body: some View {
        ZStack {
            ThemedColors.background(for: colorScheme).ignoresSafeArea()

            ScrollView {
                VStack(spacing: SalmaDesign.Spacing.lg) {
                    headerSection
                    otpFieldsSection
                    errorSection
                    verifyButton
                    resendSection
                }
                .padding(.horizontal, SalmaDesign.Spacing.lg)
                .padding(.top, SalmaDesign.Spacing.xl)
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
        }
        .onAppear {
            withAnimation(AppAnimations.fadeIn) { appeared = true }
            focusedField = 0
            startCountdown()
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: SalmaDesign.Spacing.sm) {
            ZStack {
                Circle()
                    .fill(ThemedColors.primaryLight.opacity(0.15))
                    .frame(width: 72, height: 72)
                Image(systemName: "lock.shield")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(ThemedColors.primary)
            }
            .opacity(appeared ? 1 : 0)
            .scaleEffect(appeared ? 1 : 0.8)

            Text(L("enter_otp"))
                .font(SalmaDesign.Typography.title1)
                .foregroundColor(ThemedColors.textPrimary(for: colorScheme))

            Text(String(format: L("otp_sent_to"), maskedIdentifier))
                .font(SalmaDesign.Typography.callout)
                .foregroundColor(SalmaDesign.Colors.textSecondary)
                .multilineTextAlignment(.center)

            Text(L("otp_demo_hint"))
                .font(SalmaDesign.Typography.caption)
                .foregroundColor(SalmaDesign.Colors.warning)
                .padding(.horizontal, SalmaDesign.Spacing.md)
                .padding(.vertical, SalmaDesign.Spacing.xs)
                .background(SalmaDesign.Colors.warning.opacity(0.1))
                .cornerRadius(SalmaDesign.Radius.sm)
        }
        .opacity(appeared ? 1 : 0)
        .padding(.bottom, SalmaDesign.Spacing.md)
    }

    // MARK: - OTP Fields

    private var otpFieldsSection: some View {
        HStack(spacing: SalmaDesign.Spacing.sm) {
            ForEach(0..<6, id: \.self) { index in
                otpDigitField(index: index)
            }
        }
        .modifier(ShakeEffect(trigger: shakeFields))
        .environment(\.layoutDirection, .leftToRight)
    }

    private func otpDigitField(index: Int) -> some View {
        TextField("", text: $otpDigits[index])
            .keyboardType(.numberPad)
            .textContentType(.oneTimeCode)
            .multilineTextAlignment(.center)
            .font(.system(size: 24, weight: .bold, design: .monospaced))
            .foregroundColor(ThemedColors.textPrimary(for: colorScheme))
            .frame(width: 48, height: 56)
            .background(SalmaDesign.Colors.backgroundSecondary)
            .cornerRadius(SalmaDesign.Radius.md)
            .overlay(
                RoundedRectangle(cornerRadius: SalmaDesign.Radius.md)
                    .stroke(
                        fieldBorderColor(for: index),
                        lineWidth: focusedField == index ? 2 : 1
                    )
            )
            .focused($focusedField, equals: index)
            .onChange(of: otpDigits[index]) { newValue in
                handleDigitChange(index: index, newValue: newValue)
            }
            .disabled(isMaxAttempts || isVerifying)
            .opacity(isMaxAttempts ? 0.5 : 1)
            .animation(.easeInOut(duration: 0.15), value: focusedField)
    }

    private func fieldBorderColor(for index: Int) -> Color {
        if errorMessage != nil { return SalmaDesign.Colors.danger }
        if focusedField == index { return ThemedColors.primary }
        if !otpDigits[index].isEmpty { return ThemedColors.primary.opacity(0.4) }
        return SalmaDesign.Colors.border
    }

    // MARK: - Error

    @ViewBuilder
    private var errorSection: some View {
        if let error = errorMessage {
            HStack(spacing: SalmaDesign.Spacing.xs) {
                Image(systemName: isMaxAttempts ? "xmark.octagon.fill" : "exclamationmark.circle.fill")
                    .font(.system(size: 14))
                Text(error)
                    .font(SalmaDesign.Typography.caption)
            }
            .foregroundColor(SalmaDesign.Colors.danger)
            .padding(SalmaDesign.Spacing.sm)
            .frame(maxWidth: .infinity)
            .background(SalmaDesign.Colors.danger.opacity(0.08))
            .cornerRadius(SalmaDesign.Radius.sm)
            .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }

    // MARK: - Verify Button

    private var verifyButton: some View {
        SalmaButton(
            title: L("verify"),
            style: .primary,
            size: .large,
            isLoading: isVerifying,
            isDisabled: otpCode.count < 6 || isMaxAttempts,
            fullWidth: true
        ) {
            verifyOtp()
        }
        .padding(.top, SalmaDesign.Spacing.sm)
    }

    // MARK: - Resend

    private var resendSection: some View {
        VStack(spacing: SalmaDesign.Spacing.xs) {
            if canResend {
                Button {
                    resendOtp()
                } label: {
                    HStack(spacing: SalmaDesign.Spacing.xs) {
                        if isResending {
                            ProgressView()
                                .tint(ThemedColors.primary)
                                .scaleEffect(0.8)
                        }
                        Text(L("resend_code"))
                            .font(SalmaDesign.Typography.bodyMedium)
                            .foregroundColor(ThemedColors.primary)
                    }
                }
                .disabled(isResending)
            } else {
                Text(String(format: L("resend_after"), resendCountdown))
                    .font(SalmaDesign.Typography.caption)
                    .foregroundColor(SalmaDesign.Colors.textTertiary)
                    .monospacedDigit()
            }
        }
        .padding(.top, SalmaDesign.Spacing.sm)
        .animation(AppAnimations.stateChange, value: canResend)
    }

    // MARK: - Computed

    private var otpCode: String {
        otpDigits.joined()
    }

    private var maskedIdentifier: String {
        guard identifier.count > 4 else { return identifier }
        let suffix = String(identifier.suffix(4))
        let masked = String(repeating: "•", count: identifier.count - 4)
        return masked + suffix
    }

    // MARK: - Digit Handling

    private func handleDigitChange(index: Int, newValue: String) {
        let filtered = newValue.filter(\.isNumber)

        if filtered.count > 1 {
            let chars = Array(filtered.prefix(6))
            for (i, char) in chars.enumerated() where i < 6 {
                otpDigits[i] = String(char)
            }
            focusedField = min(chars.count, 5)
            return
        }

        if filtered.count == 1 {
            otpDigits[index] = filtered
            if index < 5 {
                focusedField = index + 1
            }
        } else if filtered.isEmpty && newValue.isEmpty {
            otpDigits[index] = ""
            if index > 0 {
                focusedField = index - 1
            }
        } else {
            otpDigits[index] = filtered
        }

        if errorMessage != nil {
            withAnimation(AppAnimations.fadeIn) { errorMessage = nil }
        }
    }

    // MARK: - Countdown

    private func startCountdown() {
        resendCountdown = 60
        canResend = false
        Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { timer in
            Task { @MainActor in
                if resendCountdown > 1 {
                    resendCountdown -= 1
                } else {
                    timer.invalidate()
                    withAnimation(AppAnimations.stateChange) {
                        canResend = true
                    }
                }
            }
        }
    }

    // MARK: - Actions

    private func verifyOtp() {
        guard otpCode.count == 6 else { return }
        guard ConnectivityMonitor.shared.isConnected else {
            errorMessage = L("no_internet")
            return
        }

        isVerifying = true
        errorMessage = nil

        Task {
            do {
                let response = try await container.draftService.verifyOtpAndResume(
                    identifier: identifier,
                    otpCode: otpCode,
                    draftId: draftId
                )

                await MainActor.run {
                    isVerifying = false

                    if response.verified {
                        HapticManager.notification(.success)

                        if let values = response.fieldValues {
                            for (key, value) in values {
                                flowState.fieldValues[key] = value
                            }
                        }
                        flowState.draftId = response.draftId ?? draftId
                        flowState.currentPageIndex = response.currentPageIndex ?? 0

                        router.push(.journeyLoading)
                    } else {
                        handleFailedAttempt(message: response.message)
                    }
                }
            } catch {
                await MainActor.run {
                    isVerifying = false
                    handleFailedAttempt(message: nil)
                }
            }
        }
    }

    private func handleFailedAttempt(message: String?) {
        attemptsRemaining -= 1
        shakeFields.toggle()
        HapticManager.notification(.error)

        withAnimation(AppAnimations.stateChange) {
            if attemptsRemaining <= 0 {
                isMaxAttempts = true
                errorMessage = L("max_attempts_reached")
            } else {
                errorMessage = (message ?? L("incorrect_otp")) + " (\(attemptsRemaining) " + L("attempts_remaining") + ")"
            }
        }

        otpDigits = Array(repeating: "", count: 6)
        focusedField = 0
    }

    private func resendOtp() {
        guard ConnectivityMonitor.shared.isConnected else {
            errorMessage = L("no_internet")
            return
        }

        isResending = true

        let identifierType = identifier.count <= 10 && identifier.allSatisfy(\.isNumber) && identifier.count >= 9
            ? "phone" : "national_id"

        Task {
            do {
                _ = try await container.draftService.sendOtp(
                    identifier: identifier,
                    identifierType: identifierType
                )
                await MainActor.run {
                    isResending = false
                    attemptsRemaining = 3
                    isMaxAttempts = false
                    errorMessage = nil
                    otpDigits = Array(repeating: "", count: 6)
                    focusedField = 0
                    startCountdown()
                    HapticManager.notification(.success)
                }
            } catch {
                await MainActor.run {
                    isResending = false
                    errorMessage = L("otp_send_failed")
                    HapticManager.notification(.error)
                }
            }
        }
    }
}
