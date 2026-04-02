import SwiftUI

// Will be fully implemented in Prompt 10
struct ReviewView: View {
    @EnvironmentObject var flowState: VerificationFlowState
    @EnvironmentObject var router: NavigationRouter
    @EnvironmentObject var languageManager: LanguageManager

    var body: some View {
        VStack(spacing: SalmaDesign.Spacing.lg) {
            Spacer()

            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(SalmaDesign.Colors.primary)

            Text(languageManager.currentLanguage == .arabic
                 ? "مراجعة البيانات"
                 : "Review Data")
                .font(SalmaDesign.Typography.title1)
                .foregroundColor(SalmaDesign.Colors.textPrimary)

            Text("Placeholder — will be built in Prompt 10")
                .font(SalmaDesign.Typography.callout)
                .foregroundColor(SalmaDesign.Colors.textSecondary)

            Spacer()

            SalmaButton(title: String(localized: "submit")) {
                router.push(.submitting)
            }
            .padding(.horizontal, SalmaDesign.Spacing.lg)
            .padding(.bottom, SalmaDesign.Spacing.xl)
        }
        .background(SalmaDesign.Colors.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
    }
}
