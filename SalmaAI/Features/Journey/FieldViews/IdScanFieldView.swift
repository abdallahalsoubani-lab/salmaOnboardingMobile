import SwiftUI

struct IdScanFieldView: View {
    let field: PageField
    let label: String
    @Binding var capturedImage: CapturedImage?
    let errorMessage: String?
    let onCapture: () -> Void
    let onGallery: () -> Void
    let onPreview: () -> Void
    let onRemove: () -> Void

    @EnvironmentObject var flowState: VerificationFlowState
    @EnvironmentObject var languageManager: LanguageManager

    private var backImage: CapturedImage? {
        flowState.getCapturedImage(for: field.id + "_back")
    }
    private var hasFront: Bool { capturedImage != nil }
    private var hasBack: Bool { backImage != nil }
    private var hasBoth: Bool { hasFront && hasBack }

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

            if hasBoth {
                bothCapturedView
            } else if hasFront {
                frontOnlyView
            } else {
                emptyCaptureView
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
    private var bothCapturedView: some View {
        HStack(spacing: SalmaDesign.Spacing.sm) {
            idThumbnail(image: capturedImage, sideLabel: L("front_side"), onTap: onPreview)
            idThumbnail(image: backImage, sideLabel: L("back_side"), onTap: {})
        }

        HStack(spacing: SalmaDesign.Spacing.sm) {
            SalmaButton(title: L("change"), style: .ghost, size: .small,
                        icon: "arrow.counterclockwise") {
                onRemove()
                flowState.removeCapturedImage(for: field.id + "_back")
                onCapture()
            }
            SalmaButton(title: L("remove"), style: .ghost, size: .small,
                        icon: "trash") {
                onRemove()
                flowState.removeCapturedImage(for: field.id + "_back")
            }
        }
    }

    @ViewBuilder
    private var frontOnlyView: some View {
        idThumbnail(
            image: capturedImage,
            sideLabel: L("front_side") + " \u{2713}",
            onTap: onPreview
        )

        Button { onCapture() } label: {
            HStack(spacing: SalmaDesign.Spacing.sm) {
                Image(systemName: "creditcard")
                    .font(.system(size: 20))
                    .foregroundColor(SalmaDesign.Colors.primary)
                VStack(alignment: .leading, spacing: 2) {
                    Text(L("id_capture_back"))
                        .font(SalmaDesign.Typography.callout)
                        .foregroundColor(SalmaDesign.Colors.textPrimary)
                    Text(L("back_side"))
                        .font(SalmaDesign.Typography.caption)
                        .foregroundColor(SalmaDesign.Colors.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.forward")
                    .font(.system(size: 14))
                    .foregroundColor(SalmaDesign.Colors.textTertiary)
            }
            .padding(SalmaDesign.Spacing.md)
            .background(SalmaDesign.Colors.backgroundSecondary)
            .cornerRadius(SalmaDesign.Radius.md)
        }
    }

    @ViewBuilder
    private var emptyCaptureView: some View {
        let sourceType = FieldType.idScan.captureSource(sourceType: field.validationRules?.sourceType)
        MediaFieldButton(
            label: label, fieldType: .idScan,
            capturedImage: nil, errorMessage: nil,
            isRequired: field.isRequired, sourceType: sourceType,
            onCapture: onCapture, onGallery: onGallery,
            onPreview: {}, onRemove: {}
        )
    }

    @ViewBuilder
    private func idThumbnail(image: CapturedImage?, sideLabel: String, onTap: @escaping () -> Void) -> some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                if let data = image?.imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 90)
                        .clipped()
                        .cornerRadius(SalmaDesign.Radius.sm)
                } else {
                    RoundedRectangle(cornerRadius: SalmaDesign.Radius.sm)
                        .fill(SalmaDesign.Colors.backgroundSecondary)
                        .frame(height: 90)
                }
                Text(sideLabel)
                    .font(SalmaDesign.Typography.caption)
                    .foregroundColor(SalmaDesign.Colors.textSecondary)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}
