import SwiftUI

struct ErrorView: View {
    let message: String
    var retryAction: (() -> Void)?

    var body: some View {
        VStack(spacing: SalmaDesign.Spacing.md) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(SalmaDesign.Colors.danger)

            Text(message)
                .font(SalmaDesign.Typography.body)
                .foregroundColor(SalmaDesign.Colors.textPrimary)
                .multilineTextAlignment(.center)

            if let retry = retryAction {
                SalmaButton(title: NSLocalizedString("retry", comment: ""), action: retry)
                    .padding(.horizontal, SalmaDesign.Spacing.xxl)
            }
        }
        .padding(SalmaDesign.Spacing.lg)
    }
}
