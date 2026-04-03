import SwiftUI

struct ResultView: View {
    @EnvironmentObject var flowState: VerificationFlowState
    @EnvironmentObject var router: NavigationRouter
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var container: DependencyContainer

    @State private var polledStatus: String?
    @State private var isPolling = false
    @State private var pollTimer: Timer?
    @State private var showDetails = false

    private var status: String {
        polledStatus ?? flowState.submissionResult?.status ?? "Pending"
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: SalmaDesign.Spacing.xl) {
                    Spacer().frame(height: SalmaDesign.Spacing.xl)
                    statusIcon
                    statusText
                    messageSection

                    if showDetails, let ocr = flowState.submissionResult?.ocrData {
                        ocrSummaryCard(ocr)
                    }

                    submissionIdRow
                    Spacer().frame(height: SalmaDesign.Spacing.lg)
                }
                .padding(.horizontal, SalmaDesign.Spacing.lg)
            }

            bottomActions
        }
        .background(SalmaDesign.Colors.background.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .onAppear { onScreenAppear() }
        .onDisappear { stopPolling() }
    }

    // MARK: - Status Icon

    @ViewBuilder
    private var statusIcon: some View {
        ZStack {
            Circle()
                .fill(statusColor.opacity(0.12))
                .frame(width: 140, height: 140)

            Circle()
                .fill(statusColor.opacity(0.2))
                .frame(width: 110, height: 110)
                .scaleEffect(isPending ? 1.08 : 1.0)
                .animation(
                    isPending ? .easeInOut(duration: 1.5).repeatForever(autoreverses: true) : .default,
                    value: isPending
                )

            ZStack {
                Circle().fill(statusColor).frame(width: 80, height: 80)
                Image(systemName: statusIconName)
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
        .padding(.top, SalmaDesign.Spacing.lg)
    }

    // MARK: - Status Text

    @ViewBuilder
    private var statusText: some View {
        VStack(spacing: SalmaDesign.Spacing.sm) {
            Text(statusTitle)
                .font(SalmaDesign.Typography.title1)
                .foregroundColor(SalmaDesign.Colors.textPrimary)
                .multilineTextAlignment(.center)

            Text(statusSubtitle)
                .font(SalmaDesign.Typography.body)
                .foregroundColor(SalmaDesign.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, SalmaDesign.Spacing.md)
        }
    }

    // MARK: - Message

    @ViewBuilder
    private var messageSection: some View {
        if let result = flowState.submissionResult, !result.message.isEmpty {
            Text(result.message)
                .font(SalmaDesign.Typography.callout)
                .foregroundColor(SalmaDesign.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(SalmaDesign.Spacing.md)
                .frame(maxWidth: .infinity)
                .background(statusColor.opacity(0.06))
                .cornerRadius(SalmaDesign.Radius.md)
        }
    }

    // MARK: - OCR Summary

    @ViewBuilder
    private func ocrSummaryCard(_ ocr: OcrData) -> some View {
        VStack(alignment: .leading, spacing: SalmaDesign.Spacing.md) {
            HStack {
                Image(systemName: "doc.text.viewfinder")
                    .font(.system(size: 16))
                    .foregroundColor(SalmaDesign.Colors.primary)
                Text(L("extracted_data"))
                    .font(SalmaDesign.Typography.title3)
                    .foregroundColor(SalmaDesign.Colors.textPrimary)
            }

            VStack(spacing: 1) {
                if let name = ocr.fullNameAr, !name.isEmpty {
                    ocrRow(label: L("full_name"), value: name)
                }
                if let nid = ocr.nationalId, !nid.isEmpty {
                    ocrRow(label: L("national_id"), value: nid)
                }
                if let dob = ocr.dateOfBirth, !dob.isEmpty {
                    ocrRow(label: L("date_of_birth"), value: dob)
                }
                if let gender = ocr.gender, !gender.isEmpty {
                    ocrRow(label: L("gender"), value: gender)
                }
                if let confidence = ocr.confidence {
                    ocrRow(
                        label: L("ocr_confidence"),
                        value: "\(Int(confidence * 100))%",
                        valueColor: confidence >= 0.8 ? SalmaDesign.Colors.success : SalmaDesign.Colors.warning
                    )
                }
            }
            .background(SalmaDesign.Colors.backgroundSecondary)
            .cornerRadius(SalmaDesign.Radius.sm)
        }
        .padding(SalmaDesign.Spacing.md)
        .background(SalmaDesign.Colors.surface)
        .cornerRadius(SalmaDesign.Radius.md)
        .overlay(
            RoundedRectangle(cornerRadius: SalmaDesign.Radius.md)
                .stroke(SalmaDesign.Colors.divider, lineWidth: 1)
        )
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }

    @ViewBuilder
    private func ocrRow(label: String, value: String, valueColor: Color? = nil) -> some View {
        HStack {
            Text(label)
                .font(SalmaDesign.Typography.caption)
                .foregroundColor(SalmaDesign.Colors.textTertiary)
                .frame(width: 100, alignment: .trailing)
            Text(value)
                .font(SalmaDesign.Typography.callout)
                .foregroundColor(valueColor ?? SalmaDesign.Colors.textPrimary)
            Spacer()
        }
        .padding(.horizontal, SalmaDesign.Spacing.md)
        .padding(.vertical, SalmaDesign.Spacing.sm)
    }

    // MARK: - Submission ID

    @ViewBuilder
    private var submissionIdRow: some View {
        if let id = flowState.submissionResult?.submissionId {
            HStack(spacing: SalmaDesign.Spacing.sm) {
                Text(L("submission_id"))
                    .font(SalmaDesign.Typography.caption)
                    .foregroundColor(SalmaDesign.Colors.textTertiary)
                Text(String(id.prefix(8)) + "...")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(SalmaDesign.Colors.textSecondary)
                Button {
                    UIPasteboard.general.string = id
                    HapticManager.notification(.success)
                } label: {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 12))
                        .foregroundColor(SalmaDesign.Colors.primary)
                }
            }
            .padding(.vertical, SalmaDesign.Spacing.sm)
            .padding(.horizontal, SalmaDesign.Spacing.md)
            .background(SalmaDesign.Colors.backgroundSecondary)
            .cornerRadius(SalmaDesign.Radius.sm)
        }
    }

    // MARK: - Bottom Actions

    @ViewBuilder
    private var bottomActions: some View {
        VStack(spacing: SalmaDesign.Spacing.md) {
            switch status {
            case "Approved":
                SalmaButton(title: L("done"), size: .large, icon: "checkmark",
                            action: { finishFlow() })

            case "Rejected":
                SalmaButton(title: L("try_again"), size: .large,
                            icon: "arrow.counterclockwise", action: { restartFlow() })
                SalmaButton(title: L("done"), style: .ghost, size: .medium,
                            action: { finishFlow() })

            default: // Pending, Flagged, InReview
                if isPolling {
                    HStack(spacing: SalmaDesign.Spacing.sm) {
                        ProgressView().tint(SalmaDesign.Colors.primary)
                        Text(L("checking_status"))
                            .font(SalmaDesign.Typography.caption)
                            .foregroundColor(SalmaDesign.Colors.textSecondary)
                    }
                }
                SalmaButton(title: L("check_status"), style: .outline, size: .medium,
                            isLoading: isPolling, icon: "arrow.clockwise", action: { pollStatusOnce() })
                SalmaButton(title: L("done"), size: .large, action: { finishFlow() })
            }
        }
        .padding(.horizontal, SalmaDesign.Spacing.md)
        .padding(.vertical, SalmaDesign.Spacing.md)
        .background(
            SalmaDesign.Colors.background
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: -4)
                .mask(Rectangle().padding(.top, -20))
        )
    }

    // MARK: - Helpers

    private var isPending: Bool {
        ["Pending", "InReview", "Flagged"].contains(status)
    }

    private var statusIconName: String {
        switch status {
        case "Approved": return "checkmark"
        case "Rejected": return "xmark"
        default: return "clock"
        }
    }

    private var statusColor: Color {
        switch status {
        case "Approved": return SalmaDesign.Colors.success
        case "Rejected": return SalmaDesign.Colors.danger
        default: return SalmaDesign.Colors.warning
        }
    }

    private var statusTitle: String {
        switch status {
        case "Approved": return L("result_approved_title")
        case "Rejected": return L("result_rejected_title")
        case "InReview": return L("result_in_review_title")
        case "Flagged": return L("result_flagged_title")
        default: return L("result_pending_title")
        }
    }

    private var statusSubtitle: String {
        switch status {
        case "Approved": return L("result_approved_subtitle")
        case "Rejected": return L("result_rejected_subtitle")
        case "InReview": return L("result_in_review_subtitle")
        case "Flagged": return L("result_flagged_subtitle")
        default: return L("result_pending_subtitle")
        }
    }

    // MARK: - Polling

    private func onScreenAppear() {
        if status == "Approved" || status == "Rejected" {
            withAnimation(.easeInOut(duration: 0.5).delay(0.3)) { showDetails = true }
        }
        if isPending { startAutoPolling() }
    }

    private func startAutoPolling() {
        var pollCount = 0
        pollTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { _ in
            pollCount += 1
            if pollCount > 12 { stopPolling(); return }
            pollStatusOnce()
        }
    }

    private func stopPolling() {
        pollTimer?.invalidate()
        pollTimer = nil
    }

    private func pollStatusOnce() {
        guard let submissionId = flowState.submissionResult?.submissionId else { return }
        isPolling = true
        Task {
            do {
                let result = try await container.submissionService.getSubmissionStatus(id: submissionId)
                await MainActor.run {
                    isPolling = false
                    if result.status != status {
                        withAnimation(.easeInOut(duration: 0.5)) { polledStatus = result.status }
                        HapticManager.notification(result.status == "Approved" ? .success : .warning)
                        if result.status == "Approved" || result.status == "Rejected" {
                            stopPolling()
                            withAnimation(.easeInOut(duration: 0.5).delay(0.3)) { showDetails = true }
                        }
                    }
                }
            } catch {
                await MainActor.run { isPolling = false }
            }
        }
    }

    // MARK: - Actions

    private func restartFlow() {
        flowState.reset()
        router.popToRoot()
    }

    private func finishFlow() {
        flowState.reset()
        router.popToRoot()
    }
}
