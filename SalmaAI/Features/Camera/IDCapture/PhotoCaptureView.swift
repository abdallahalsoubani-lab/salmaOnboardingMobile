import SwiftUI

// Will be fully implemented alongside IDCapture
struct PhotoCaptureView: View {
    let fieldId: String

    @EnvironmentObject var flowState: VerificationFlowState
    @EnvironmentObject var router: NavigationRouter

    var body: some View {
        VStack(spacing: SalmaDesign.Spacing.lg) {
            Spacer()

            Image(systemName: "camera.fill")
                .font(.system(size: 64))
                .foregroundColor(SalmaDesign.Colors.primary)

            Text("Photo Capture")
                .font(SalmaDesign.Typography.title2)
                .foregroundColor(SalmaDesign.Colors.textPrimary)

            SalmaButton(title: "Simulate Capture") {
                let renderer = UIGraphicsImageRenderer(size: CGSize(width: 400, height: 300))
                let data = renderer.jpegData(withCompressionQuality: 0.8) { ctx in
                    UIColor.systemGray5.setFill()
                    ctx.fill(CGRect(x: 0, y: 0, width: 400, height: 300))
                }
                let image = CapturedImage(fieldId: fieldId, imageData: data, type: .photo)
                flowState.setCapturedImage(image, for: fieldId)
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
}
