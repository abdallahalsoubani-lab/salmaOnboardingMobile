import SwiftUI

// Will be fully implemented in Prompt 5
struct SignaturePadView: View {
    let fieldId: String

    @EnvironmentObject var flowState: VerificationFlowState
    @EnvironmentObject var router: NavigationRouter

    var body: some View {
        VStack(spacing: SalmaDesign.Spacing.lg) {
            Spacer()

            Image(systemName: "pencil.tip")
                .font(.system(size: 64))
                .foregroundColor(SalmaDesign.Colors.primary)

            Text("Signature Pad")
                .font(SalmaDesign.Typography.title2)
                .foregroundColor(SalmaDesign.Colors.textPrimary)

            Text("Coming in Prompt 5")
                .font(SalmaDesign.Typography.callout)
                .foregroundColor(SalmaDesign.Colors.textSecondary)

            SalmaButton(title: "Simulate Signature") {
                let renderer = UIGraphicsImageRenderer(size: CGSize(width: 400, height: 200))
                let data = renderer.pngData { ctx in
                    UIColor.white.setFill()
                    ctx.fill(CGRect(x: 0, y: 0, width: 400, height: 200))
                }
                let image = CapturedImage(fieldId: fieldId, imageData: data, type: .signature)
                flowState.setCapturedImage(image, for: fieldId)
                router.dismissFullScreen()
            }
            .padding(.horizontal, SalmaDesign.Spacing.xl)

            SalmaButton(title: L("cancel"), style: .secondary) {
                router.dismissFullScreen()
            }
            .padding(.horizontal, SalmaDesign.Spacing.xl)

            Spacer()
        }
        .background(SalmaDesign.Colors.background.ignoresSafeArea())
    }
}
