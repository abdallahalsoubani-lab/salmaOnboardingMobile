import SwiftUI

// Will be fully implemented in Prompt 8
struct IDCaptureView: View {
    let fieldId: String
    let side: IDSide

    @EnvironmentObject var flowState: VerificationFlowState
    @EnvironmentObject var router: NavigationRouter

    var body: some View {
        VStack(spacing: SalmaDesign.Spacing.lg) {
            Spacer()

            Image(systemName: "creditcard.viewfinder")
                .font(.system(size: 64))
                .foregroundColor(SalmaDesign.Colors.primary)

            Text("ID Capture — \(side.displayNameEn)")
                .font(SalmaDesign.Typography.title2)
                .foregroundColor(SalmaDesign.Colors.textPrimary)

            Text("Coming in Prompt 8")
                .font(SalmaDesign.Typography.callout)
                .foregroundColor(SalmaDesign.Colors.textSecondary)

            // Simulate capture
            SalmaButton(title: "Simulate Capture") {
                let placeholder = createPlaceholderImage()
                flowState.setCapturedImage(placeholder, for: fieldId)
                router.dismissFullScreen()
            }
            .padding(.horizontal, SalmaDesign.Spacing.xl)

            SalmaButton(title: String(localized: "cancel"), style: .secondary) {
                router.dismissFullScreen()
            }
            .padding(.horizontal, SalmaDesign.Spacing.xl)

            Spacer()
        }
        .background(SalmaDesign.Colors.background.ignoresSafeArea())
    }

    private func createPlaceholderImage() -> CapturedImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 400, height: 260))
        let data = renderer.jpegData(withCompressionQuality: 0.8) { ctx in
            UIColor.systemGray5.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 400, height: 260))
        }
        return CapturedImage(
            fieldId: fieldId,
            imageData: data,
            type: side == .front ? .idFront : .idBack
        )
    }
}
