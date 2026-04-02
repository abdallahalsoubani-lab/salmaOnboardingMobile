import SwiftUI

struct FileUploadFieldView: View {
    let field: PageField
    let label: String
    @Binding var capturedImage: CapturedImage?
    let errorMessage: String?
    let onFilePick: () -> Void
    let onGallery: () -> Void
    let onPreview: () -> Void
    let onRemove: () -> Void

    @State private var pickedFileName: String?
    @State private var pickedFileSize: Int?

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

            // Accepted format tags
            if let formats = field.validationRules?.acceptedFormats, !formats.isEmpty {
                HStack(spacing: 4) {
                    ForEach(formats, id: \.self) { format in
                        Text(format.uppercased())
                            .font(SalmaDesign.Typography.small)
                            .foregroundColor(SalmaDesign.Colors.textTertiary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(SalmaDesign.Colors.backgroundSecondary)
                            .cornerRadius(4)
                    }

                    if let maxSize = field.validationRules?.maxFileSizeMB {
                        Text("max \(maxSize) MB")
                            .font(SalmaDesign.Typography.small)
                            .foregroundColor(SalmaDesign.Colors.textTertiary)
                    }
                }
            }

            MediaFieldButton(
                label: label,
                fieldType: .fileUpload,
                capturedImage: nil,
                capturedFileName: pickedFileName,
                capturedFileSize: pickedFileSize,
                errorMessage: errorMessage,
                isRequired: field.isRequired,
                sourceType: .galleryOnly,
                onGallery: onGallery,
                onFilePick: onFilePick,
                onPreview: onPreview,
                onRemove: {
                    pickedFileName = nil
                    pickedFileSize = nil
                    capturedImage = nil
                    onRemove()
                }
            )
        }
        .onChange(of: capturedImage?.fieldId) { _ in
            // Sync state when capturedImage is set externally
            if capturedImage == nil {
                pickedFileName = nil
                pickedFileSize = nil
            }
        }
    }

    func setPickedDocument(_ doc: PickedDocument) {
        pickedFileName = doc.fileName
        pickedFileSize = doc.fileSize
        capturedImage = CapturedImage(
            fieldId: field.id,
            imageData: doc.data,
            type: .document
        )
    }
}
