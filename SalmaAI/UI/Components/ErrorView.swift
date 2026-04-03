import SwiftUI

struct ErrorView: View {
    var title: String = L("error")
    let message: String
    var icon: String = "exclamationmark.triangle.fill"
    var retryAction: (() -> Void)?

    var body: some View {
        VStack(spacing: SalmaDesign.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(SalmaDesign.Colors.danger)

            Text(title)
                .font(SalmaDesign.Typography.title2)
                .foregroundColor(SalmaDesign.Colors.textPrimary)

            Text(message)
                .font(SalmaDesign.Typography.body)
                .foregroundColor(SalmaDesign.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 280)

            if let retry = retryAction {
                SalmaButton(
                    title: L("retry"),
                    style: .secondary,
                    size: .medium,
                    action: retry
                )
                .padding(.horizontal, SalmaDesign.Spacing.xxl)
                .padding(.top, SalmaDesign.Spacing.sm)
            }
        }
        .padding(SalmaDesign.Spacing.lg)
    }
}
