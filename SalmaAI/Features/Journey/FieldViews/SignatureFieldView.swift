import SwiftUI

struct SignatureFieldView: View {
    let field: PageField
    let label: String
    @Binding var capturedImage: CapturedImage?
    let errorMessage: String?

    @State private var showSignaturePad = false
    @State private var signatureUIImage: UIImage?

    var body: some View {
        VStack(alignment: .leading, spacing: SalmaDesign.Spacing.xs) {
            HStack(spacing: 2) {
                Text(label)
                    .font(SalmaDesign.Typography.callout)
                    .foregroundColor(SalmaDesign.Colors.textSecondary)
                if field.isRequired {
                    Text("*").font(SalmaDesign.Typography.callout)
                        .foregroundColor(SalmaDesign.Colors.danger)
                }
            }

            if let img = signatureUIImage {
                VStack(spacing: SalmaDesign.Spacing.sm) {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 120)
                        .background(SalmaDesign.Colors.backgroundSecondary)
                        .cornerRadius(SalmaDesign.Radius.md)
                        .overlay(
                            RoundedRectangle(cornerRadius: SalmaDesign.Radius.md)
                                .stroke(SalmaDesign.Colors.border, lineWidth: 1)
                        )

                    HStack {
                        SalmaButton(title: L("change"), style: .ghost, size: .small) {
                            showSignaturePad = true
                        }
                        SalmaButton(title: L("remove"), style: .ghost, size: .small) {
                            signatureUIImage = nil
                            capturedImage = nil
                        }
                    }
                }
            } else {
                Button { showSignaturePad = true } label: {
                    VStack(spacing: SalmaDesign.Spacing.sm) {
                        Image(systemName: "pencil.tip")
                            .font(.system(size: 28))
                            .foregroundColor(SalmaDesign.Colors.textTertiary)
                        Text(L("sign_here"))
                            .font(SalmaDesign.Typography.callout)
                            .foregroundColor(SalmaDesign.Colors.textTertiary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 120)
                    .background(
                        RoundedRectangle(cornerRadius: SalmaDesign.Radius.lg)
                            .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [8, 4]))
                            .foregroundColor(SalmaDesign.Colors.border)
                    )
                }
            }

            if let error = errorMessage {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle").font(.system(size: 12))
                    Text(error).font(SalmaDesign.Typography.caption)
                }
                .foregroundColor(SalmaDesign.Colors.danger)
            }
        }
        .fullScreenCover(isPresented: $showSignaturePad) {
            SignaturePadFullScreen(
                onSave: { image in
                    signatureUIImage = image
                    if let data = image.pngData() {
                        capturedImage = CapturedImage(fieldId: field.id, imageData: data, type: .signature)
                    }
                    showSignaturePad = false
                },
                onCancel: { showSignaturePad = false }
            )
        }
        .onAppear {
            if let existing = capturedImage, signatureUIImage == nil {
                signatureUIImage = UIImage(data: existing.imageData)
            }
        }
    }
}

struct SignaturePadFullScreen: View {
    let onSave: (UIImage) -> Void
    let onCancel: () -> Void
    @State private var signatureImage: UIImage?

    var body: some View {
        VStack(spacing: SalmaDesign.Spacing.lg) {
            Spacer()

            Text(L("sign_here"))
                .font(SalmaDesign.Typography.title2)
                .foregroundColor(SalmaDesign.Colors.textPrimary)

            SalmaSignaturePad(signatureImage: $signatureImage)
                .frame(height: 250)
                .padding(.horizontal, SalmaDesign.Spacing.md)

            HStack(spacing: SalmaDesign.Spacing.md) {
                SalmaButton(title: L("cancel"), style: .secondary, size: .medium, action: onCancel)
                SalmaButton(
                    title: L("done"),
                    size: .medium,
                    isDisabled: signatureImage == nil
                ) {
                    if let img = signatureImage { onSave(img) }
                }
            }
            .padding(.horizontal, SalmaDesign.Spacing.md)

            Spacer()
        }
        .background(SalmaDesign.Colors.background.ignoresSafeArea())
    }
}
