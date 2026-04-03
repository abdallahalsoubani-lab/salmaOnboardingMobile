import SwiftUI

struct ImagePreviewView: View {
    let fieldId: String
    let imageData: Data

    @EnvironmentObject var flowState: VerificationFlowState
    @EnvironmentObject var router: NavigationRouter

    var body: some View {
        VStack(spacing: 0) {
            // Close button
            HStack {
                Spacer()
                Button {
                    router.dismissFullScreen()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(SalmaDesign.Colors.textSecondary)
                }
                .padding(SalmaDesign.Spacing.md)
            }

            Spacer()

            // Image preview
            if let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(SalmaDesign.Radius.md)
                    .padding(.horizontal, SalmaDesign.Spacing.lg)
            }

            Spacer()

            // Action buttons
            HStack(spacing: SalmaDesign.Spacing.md) {
                SalmaButton(
                    title: L("retake"),
                    style: .secondary
                ) {
                    flowState.removeCapturedImage(for: fieldId)
                    router.dismissFullScreen()
                }

                SalmaButton(
                    title: L("use_photo")
                ) {
                    router.dismissFullScreen()
                }
            }
            .padding(.horizontal, SalmaDesign.Spacing.md)
            .padding(.bottom, SalmaDesign.Spacing.xl)
        }
        .background(SalmaDesign.Colors.background.ignoresSafeArea())
    }
}
