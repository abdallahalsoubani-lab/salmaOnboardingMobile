import SwiftUI

struct SelfieFieldView: View {
    let field: PageField
    let label: String
    @Binding var capturedImage: CapturedImage?
    let errorMessage: String?
    let onCapture: () -> Void
    let onGallery: () -> Void
    let onPreview: () -> Void
    let onRemove: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: SalmaDesign.Spacing.sm) {
            HStack(spacing: 2) {
                Text(label)
                    .font(SalmaDesign.Typography.callout)
                    .foregroundColor(SalmaDesign.Colors.textSecondary)
                if field.isRequired {
                    Text("*").font(SalmaDesign.Typography.callout)
                        .foregroundColor(SalmaDesign.Colors.danger)
                }
            }

            if let captured = capturedImage, let uiImage = UIImage(data: captured.imageData) {
                capturedSelfieView(image: uiImage)
            } else {
                emptyStateView
            }

            if let error = errorMessage {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle").font(.system(size: 12))
                    Text(error).font(SalmaDesign.Typography.caption)
                }
                .foregroundColor(SalmaDesign.Colors.danger)
            }
        }
    }

    @ViewBuilder
    private func capturedSelfieView(image: UIImage) -> some View {
        VStack(spacing: SalmaDesign.Spacing.md) {
            ZStack(alignment: .bottomTrailing) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(SalmaDesign.Colors.success, lineWidth: 3))

                ZStack {
                    Circle().fill(SalmaDesign.Colors.success).frame(width: 28, height: 28)
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
                .offset(x: -4, y: -4)
            }
            .frame(maxWidth: .infinity)
            .onTapGesture { onPreview() }

            Text(L("selfie_captured"))
                .font(SalmaDesign.Typography.captionMedium)
                .foregroundColor(SalmaDesign.Colors.success)

            HStack(spacing: SalmaDesign.Spacing.sm) {
                SalmaButton(title: L("change"), style: .ghost, size: .small,
                            icon: "arrow.counterclockwise", action: onCapture)
                SalmaButton(title: L("remove"), style: .ghost, size: .small,
                            icon: "trash", action: onRemove)
            }
        }
        .padding(SalmaDesign.Spacing.md)
        .background(SalmaDesign.Colors.backgroundSecondary)
        .cornerRadius(SalmaDesign.Radius.lg)
    }

    @ViewBuilder
    private var emptyStateView: some View {
        let sourceType = FieldType.selfie.captureSource(sourceType: field.validationRules?.sourceType)
        MediaFieldButton(
            label: label, fieldType: .selfie,
            capturedImage: nil, errorMessage: nil,
            isRequired: field.isRequired, sourceType: sourceType,
            onCapture: onCapture, onGallery: onGallery,
            onPreview: {}, onRemove: {}
        )
    }
}
