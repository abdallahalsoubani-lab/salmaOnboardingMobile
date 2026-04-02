import SwiftUI

struct FormPageView: View {
    let pageIndex: Int

    @EnvironmentObject var flowState: VerificationFlowState
    @EnvironmentObject var router: NavigationRouter
    @EnvironmentObject var languageManager: LanguageManager

    var body: some View {
        let pages = flowState.sortedPages
        let page = pages.indices.contains(pageIndex) ? pages[pageIndex] : nil
        let isLast = pageIndex == pages.count - 1

        VStack(spacing: 0) {
            // Progress bar
            ProgressStepBar(
                currentStep: pageIndex + 1,
                totalSteps: pages.count
            )
            .padding(.horizontal, SalmaDesign.Spacing.md)
            .padding(.top, SalmaDesign.Spacing.sm)

            // Page title
            if let page = page {
                Text(languageManager.localizedTitle(for: page))
                    .font(SalmaDesign.Typography.title2)
                    .foregroundColor(SalmaDesign.Colors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, SalmaDesign.Spacing.md)
                    .padding(.top, SalmaDesign.Spacing.lg)
                    .padding(.bottom, SalmaDesign.Spacing.md)
            }

            // Scrollable fields
            ScrollView {
                VStack(spacing: SalmaDesign.Spacing.md) {
                    if let page = page {
                        ForEach(Array(page.fields.sorted(by: { $0.order < $1.order }).enumerated()), id: \.element.id) { index, field in
                            fieldPlaceholder(for: field)
                                .staggeredAppear(index: index)
                        }
                    }
                }
                .padding(.horizontal, SalmaDesign.Spacing.md)
                .padding(.bottom, 100)
            }

            Spacer(minLength: 0)

            // Bottom buttons
            bottomButtons(isLast: isLast)
        }
        .background(SalmaDesign.Colors.background)
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
        .dismissKeyboardOnTap()
        .onAppear {
            flowState.currentPageIndex = pageIndex
        }
    }

    // MARK: - Bottom Buttons

    @ViewBuilder
    private func bottomButtons(isLast: Bool) -> some View {
        HStack(spacing: SalmaDesign.Spacing.md) {
            if pageIndex > 0 {
                Button {
                    router.pop()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: languageManager.currentLanguage == .arabic ? "chevron.right" : "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                        Text(String(localized: "previous"))
                    }
                    .font(SalmaDesign.Typography.bodyMedium)
                    .foregroundColor(SalmaDesign.Colors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(SalmaDesign.Colors.backgroundSecondary)
                    .cornerRadius(SalmaDesign.Radius.lg)
                }
                .pressAnimation()
            }

            Button {
                if isLast {
                    router.push(.review)
                } else {
                    router.push(.formPage(pageIndex: pageIndex + 1))
                }
            } label: {
                HStack(spacing: 6) {
                    Text(isLast
                         ? String(localized: "review_and_submit")
                         : String(localized: "next"))
                    Image(systemName: languageManager.currentLanguage == .arabic ? "chevron.left" : "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                }
                .font(SalmaDesign.Typography.bodyMedium)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(SalmaDesign.Colors.primary)
                .cornerRadius(SalmaDesign.Radius.lg)
            }
            .pressAnimation()
        }
        .padding(.horizontal, SalmaDesign.Spacing.md)
        .padding(.bottom, SalmaDesign.Spacing.lg)
        .background(
            SalmaDesign.Colors.background
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: -4)
                .mask(Rectangle().padding(.top, -20))
        )
    }

    // MARK: - Field Placeholder

    @ViewBuilder
    private func fieldPlaceholder(for field: PageField) -> some View {
        let fieldType = FieldType(rawValue: field.type)

        VStack(alignment: .leading, spacing: SalmaDesign.Spacing.xs) {
            Text(languageManager.localizedLabel(for: field))
                .font(SalmaDesign.Typography.callout)
                .foregroundColor(SalmaDesign.Colors.textSecondary)

            RoundedRectangle(cornerRadius: SalmaDesign.Radius.sm)
                .fill(SalmaDesign.Colors.backgroundSecondary)
                .frame(height: fieldType?.isMediaField == true ? 120 : 48)
                .overlay(
                    HStack(spacing: SalmaDesign.Spacing.sm) {
                        if let icon = fieldType?.iconName {
                            Image(systemName: icon)
                                .foregroundColor(SalmaDesign.Colors.textTertiary)
                        }
                        Text(fieldType?.displayNameEn ?? field.type)
                            .font(SalmaDesign.Typography.caption)
                            .foregroundColor(SalmaDesign.Colors.textTertiary)
                    }
                )
        }
    }
}
