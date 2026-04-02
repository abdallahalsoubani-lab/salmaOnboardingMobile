import SwiftUI

struct PhotoFieldView: View {
    let field: PageField
    let label: String
    @Binding var capturedImage: CapturedImage?
    let errorMessage: String?
    let onCapture: () -> Void
    let onGallery: () -> Void
    let onPreview: () -> Void
    let onRemove: () -> Void

    var body: some View {
        let sourceType = FieldType.photo.captureSource(sourceType: field.validationRules?.sourceType)
        let uiImage: UIImage? = capturedImage.flatMap { UIImage(data: $0.imageData) }

        MediaFieldButton(
            label: label,
            fieldType: .photo,
            capturedImage: uiImage,
            errorMessage: errorMessage,
            isRequired: field.isRequired,
            sourceType: sourceType,
            onCapture: onCapture,
            onGallery: onGallery,
            onPreview: onPreview,
            onRemove: onRemove
        )
    }
}
