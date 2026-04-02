import SwiftUI

struct LoadingView: View {
    var message: String = ""

    var body: some View {
        VStack(spacing: SalmaDesign.Spacing.md) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(SalmaDesign.Colors.primary)

            if !message.isEmpty {
                Text(message)
                    .font(SalmaDesign.Typography.callout)
                    .foregroundColor(SalmaDesign.Colors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(SalmaDesign.Colors.background)
    }
}
