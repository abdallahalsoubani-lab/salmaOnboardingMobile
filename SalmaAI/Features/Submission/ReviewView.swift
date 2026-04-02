import SwiftUI

struct ReviewView: View {
    @EnvironmentObject var flowState: VerificationFlowState
    @EnvironmentObject var router: NavigationRouter
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var container: DependencyContainer

    @State private var validationErrors: [String: String] = [:]
    @State private var showSubmitConfirm = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: SalmaDesign.Spacing.lg) {
                    // Subtitle
                    Text(String(localized: "review_subtitle"))
                        .font(SalmaDesign.Typography.callout)
                        .foregroundColor(SalmaDesign.Colors.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // Validation warning
                    if !validationErrors.isEmpty {
                        validationWarningCard
                    }

                    // Page sections
                    if let journey = flowState.journey {
                        let sortedPages = journey.pages.sorted(by: { $0.order < $1.order })
                        ForEach(Array(sortedPages.enumerated()), id: \.element.id) { index, page in
                            pageReviewSection(page: page, pageIndex: index)
                        }
                    }
                }
                .padding(.horizontal, SalmaDesign.Spacing.md)
                .padding(.top, SalmaDesign.Spacing.md)
                .padding(.bottom, 140)
            }

            Spacer(minLength: 0)
            bottomBar
        }
        .background(SalmaDesign.Colors.background)
        .navigationTitle(String(localized: "review_data"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { router.pop() } label: {
                    HStack(spacing: 4) {
                        Image(systemName: languageManager.currentLanguage == .arabic ? "chevron.right" : "chevron.left")
                            .font(.system(size: 14))
                        Text(String(localized: "edit"))
                    }
                    .font(SalmaDesign.Typography.callout)
                    .foregroundColor(SalmaDesign.Colors.primary)
                }
            }
        }
        .onAppear { runValidation() }
        .confirmationDialog(
            String(localized: "confirm_submit_title"),
            isPresented: $showSubmitConfirm,
            titleVisibility: .visible
        ) {
            Button(String(localized: "submit")) { submitData() }
            Button(String(localized: "cancel"), role: .cancel) {}
        } message: {
            Text(String(localized: "confirm_submit_message"))
        }
    }

    // MARK: - Validation Warning

    @ViewBuilder
    private var validationWarningCard: some View {
        VStack(alignment: .leading, spacing: SalmaDesign.Spacing.sm) {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(SalmaDesign.Colors.danger)
                Text(String(localized: "has_validation_errors"))
                    .font(SalmaDesign.Typography.bodyMedium)
                    .foregroundColor(SalmaDesign.Colors.danger)
            }

            Text(String(format: String(localized: "errors_count"), validationErrors.count))
                .font(SalmaDesign.Typography.callout)
                .foregroundColor(SalmaDesign.Colors.textSecondary)

            SalmaButton(
                title: String(localized: "fix_errors"), style: .outline, size: .small,
                icon: "arrow.right", action: { navigateToFirstError() }
            )
        }
        .padding(SalmaDesign.Spacing.md)
        .background(SalmaDesign.Colors.danger.opacity(0.08))
        .cornerRadius(SalmaDesign.Radius.md)
        .overlay(
            RoundedRectangle(cornerRadius: SalmaDesign.Radius.md)
                .stroke(SalmaDesign.Colors.danger.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Page Section

    @ViewBuilder
    private func pageReviewSection(page: JourneyPage, pageIndex: Int) -> some View {
        VStack(alignment: .leading, spacing: SalmaDesign.Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(languageManager.localizedTitle(for: page))
                        .font(SalmaDesign.Typography.title3)
                        .foregroundColor(SalmaDesign.Colors.textPrimary)
                    Text(String(format: String(localized: "page_of"), pageIndex + 1, flowState.totalPages))
                        .font(SalmaDesign.Typography.caption)
                        .foregroundColor(SalmaDesign.Colors.textTertiary)
                }

                Spacer()

                Button {
                    router.popToRoot()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        router.push(.formPage(pageIndex: pageIndex))
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "pencil").font(.system(size: 12))
                        Text(String(localized: "edit")).font(SalmaDesign.Typography.captionMedium)
                    }
                    .foregroundColor(SalmaDesign.Colors.primary)
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(SalmaDesign.Colors.primaryLight)
                    .cornerRadius(SalmaDesign.Radius.sm)
                }
            }

            VStack(spacing: 1) {
                let sortedFields = page.fields.sorted(by: { $0.order < $1.order })
                ForEach(sortedFields) { field in
                    if PageValidator.isFieldVisible(field, allFieldValues: flowState.fieldValues) {
                        fieldReviewRow(field: field)
                    }
                }
            }
            .background(SalmaDesign.Colors.surface)
            .cornerRadius(SalmaDesign.Radius.md)
            .overlay(
                RoundedRectangle(cornerRadius: SalmaDesign.Radius.md)
                    .stroke(SalmaDesign.Colors.divider, lineWidth: 1)
            )
        }
    }

    // MARK: - Field Row

    @ViewBuilder
    private func fieldReviewRow(field: PageField) -> some View {
        let fieldType = FieldType(rawValue: field.type) ?? .text
        let label = languageManager.localizedLabel(for: field)
        let hasError = validationErrors[field.id] != nil

        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(SalmaDesign.Typography.caption)
                .foregroundColor(hasError ? SalmaDesign.Colors.danger : SalmaDesign.Colors.textTertiary)

            if fieldType.isMediaField {
                mediaFieldReview(field: field, fieldType: fieldType)
            } else if fieldType == .checkbox {
                checkboxReview(field: field)
            } else {
                textFieldReview(field: field, fieldType: fieldType)
            }

            if let error = validationErrors[field.id] {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle.fill").font(.system(size: 11))
                    Text(error).font(SalmaDesign.Typography.small)
                }
                .foregroundColor(SalmaDesign.Colors.danger)
            }
        }
        .padding(.horizontal, SalmaDesign.Spacing.md)
        .padding(.vertical, SalmaDesign.Spacing.sm)
        .background(hasError ? SalmaDesign.Colors.danger.opacity(0.04) : Color.clear)
    }

    @ViewBuilder
    private func textFieldReview(field: PageField, fieldType: FieldType) -> some View {
        let value = flowState.getValue(for: field.id)
        if value.isEmpty {
            Text(field.isRequired ? String(localized: "not_filled_required") : String(localized: "not_filled"))
                .font(SalmaDesign.Typography.body)
                .foregroundColor(field.isRequired ? SalmaDesign.Colors.danger : SalmaDesign.Colors.textTertiary)
                .italic()
        } else {
            switch fieldType {
            case .date:
                Text(formatDate(value))
                    .font(SalmaDesign.Typography.body)
                    .foregroundColor(SalmaDesign.Colors.textPrimary)
            case .phone:
                let prefix = field.validationRules?.countryCode ?? ""
                Text("\(prefix) \(value)")
                    .font(SalmaDesign.Typography.body)
                    .foregroundColor(SalmaDesign.Colors.textPrimary)
            default:
                Text(value)
                    .font(SalmaDesign.Typography.body)
                    .foregroundColor(SalmaDesign.Colors.textPrimary)
            }
        }
    }

    @ViewBuilder
    private func mediaFieldReview(field: PageField, fieldType: FieldType) -> some View {
        if let captured = flowState.getCapturedImage(for: field.id),
           let uiImage = UIImage(data: captured.imageData) {
            HStack(spacing: SalmaDesign.Spacing.sm) {
                if fieldType == .selfie {
                    Image(uiImage: uiImage).resizable().scaledToFill()
                        .frame(width: 48, height: 48).clipShape(Circle())
                } else {
                    Image(uiImage: uiImage).resizable().scaledToFill()
                        .frame(width: 64, height: 44).cornerRadius(6).clipped()
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(String(localized: "photo_captured"))
                        .font(SalmaDesign.Typography.callout)
                        .foregroundColor(SalmaDesign.Colors.success)
                    let kb = captured.imageData.count / 1024
                    Text(kb > 1024 ? String(format: "%.1f MB", Double(kb) / 1024.0) : "\(kb) KB")
                        .font(SalmaDesign.Typography.caption)
                        .foregroundColor(SalmaDesign.Colors.textTertiary)
                }

                if fieldType == .idScan {
                    Spacer()
                    if flowState.getCapturedImage(for: field.id + "_back") != nil {
                        Text("\u{2713} " + String(localized: "both_sides"))
                            .font(SalmaDesign.Typography.caption)
                            .foregroundColor(SalmaDesign.Colors.success)
                    } else {
                        Text(String(localized: "back_side_missing"))
                            .font(SalmaDesign.Typography.caption)
                            .foregroundColor(SalmaDesign.Colors.warning)
                    }
                }
            }
        } else {
            Text(field.isRequired ? String(localized: "not_captured_required") : String(localized: "not_captured"))
                .font(SalmaDesign.Typography.body)
                .foregroundColor(field.isRequired ? SalmaDesign.Colors.danger : SalmaDesign.Colors.textTertiary)
                .italic()
        }
    }

    @ViewBuilder
    private func checkboxReview(field: PageField) -> some View {
        let isChecked = flowState.getValue(for: field.id) == "true"
        HStack(spacing: 6) {
            Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 18))
                .foregroundColor(isChecked ? SalmaDesign.Colors.success : SalmaDesign.Colors.textTertiary)
            Text(isChecked ? String(localized: "agreed") : String(localized: "not_agreed"))
                .font(SalmaDesign.Typography.callout)
                .foregroundColor(isChecked ? SalmaDesign.Colors.success : SalmaDesign.Colors.textTertiary)
        }
    }

    // MARK: - Bottom Bar

    @ViewBuilder
    private var bottomBar: some View {
        VStack(spacing: SalmaDesign.Spacing.sm) {
            HStack(spacing: SalmaDesign.Spacing.lg) {
                summaryItem(icon: "doc.text", count: countFilledFields(), total: countTotalFields(),
                            label: String(localized: "fields_filled"))
                summaryItem(icon: "camera", count: flowState.capturedImages.count, total: countMediaFields(),
                            label: String(localized: "photos_captured"))
            }

            SalmaButton(
                title: String(localized: "submit"), size: .large,
                isDisabled: !validationErrors.isEmpty,
                icon: "paperplane", iconPosition: .trailing,
                action: { showSubmitConfirm = true }
            )
            .padding(.horizontal, SalmaDesign.Spacing.md)
        }
        .padding(.vertical, SalmaDesign.Spacing.md)
        .padding(.horizontal, SalmaDesign.Spacing.md)
        .background(
            SalmaDesign.Colors.background
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: -4)
                .mask(Rectangle().padding(.top, -20))
        )
    }

    @ViewBuilder
    private func summaryItem(icon: String, count: Int, total: Int, label: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon).font(.system(size: 14))
                .foregroundColor(count == total ? SalmaDesign.Colors.success : SalmaDesign.Colors.warning)
            Text("\(count)/\(total)").font(SalmaDesign.Typography.captionMedium)
                .foregroundColor(SalmaDesign.Colors.textPrimary)
            Text(label).font(SalmaDesign.Typography.caption)
                .foregroundColor(SalmaDesign.Colors.textSecondary)
        }
    }

    // MARK: - Actions

    private func runValidation() {
        guard let journey = flowState.journey else { return }
        validationErrors = PageValidator.validateAllPages(
            journey: journey, fieldValues: flowState.fieldValues,
            capturedImages: flowState.capturedImages, language: languageManager.currentLanguage
        )
    }

    private func navigateToFirstError() {
        guard let journey = flowState.journey else { return }
        if let pageIndex = PageValidator.firstPageWithErrors(
            journey: journey, fieldValues: flowState.fieldValues,
            capturedImages: flowState.capturedImages, language: languageManager.currentLanguage
        ) {
            router.popToRoot()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                router.push(.formPage(pageIndex: pageIndex))
            }
        }
    }

    private func submitData() {
        runValidation()
        guard validationErrors.isEmpty else { navigateToFirstError(); return }
        router.push(.submitting)
    }

    private func formatDate(_ dateString: String) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        guard let date = fmt.date(from: dateString) else { return dateString }
        let display = DateFormatter()
        display.locale = languageManager.currentLanguage.locale
        display.dateStyle = .long
        return display.string(from: date)
    }

    private func countFilledFields() -> Int {
        guard let journey = flowState.journey else { return 0 }
        return journey.pages.flatMap(\.fields)
            .filter { FieldType(rawValue: $0.type).map { !$0.isMediaField } ?? true }
            .filter { !flowState.getValue(for: $0.id).isEmpty }
            .count
    }

    private func countTotalFields() -> Int {
        guard let journey = flowState.journey else { return 0 }
        return journey.pages.flatMap(\.fields)
            .filter { FieldType(rawValue: $0.type).map { !$0.isMediaField } ?? true }
            .count
    }

    private func countMediaFields() -> Int {
        guard let journey = flowState.journey else { return 0 }
        return journey.pages.flatMap(\.fields)
            .filter { FieldType(rawValue: $0.type)?.isMediaField == true }
            .count
    }
}
