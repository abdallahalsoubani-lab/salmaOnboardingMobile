import SwiftUI

@MainActor
struct FieldFactory {

    @ViewBuilder
    static func makeField(
        for field: PageField,
        value: Binding<String>,
        capturedImage: Binding<CapturedImage?>,
        errorMessage: String?,
        languageManager: LanguageManager,
        onCameraCapture: @escaping (PageField) -> Void,
        onGalleryPick: @escaping (PageField) -> Void,
        onFilePick: @escaping (PageField) -> Void,
        onImagePreview: @escaping (PageField) -> Void,
        onImageRemove: @escaping (PageField) -> Void
    ) -> some View {
        let fieldType = FieldType(rawValue: field.type) ?? .text
        let label = languageManager.localizedLabel(for: field)
        let placeholder = languageManager.localizedPlaceholder(for: field)

        switch fieldType {
        case .text:
            TextFieldView(field: field, label: label, placeholder: placeholder,
                          value: value, errorMessage: errorMessage)

        case .phone:
            PhoneFieldView(field: field, label: label, placeholder: placeholder,
                           value: value, errorMessage: errorMessage)

        case .email:
            EmailFieldView(field: field, label: label, placeholder: placeholder,
                           value: value, errorMessage: errorMessage)

        case .date:
            DateFieldView(field: field, label: label, value: value,
                          errorMessage: errorMessage)

        case .dropdown:
            DropdownFieldView(field: field, label: label, value: value,
                              errorMessage: errorMessage)

        case .photo:
            PhotoFieldView(field: field, label: label, capturedImage: capturedImage,
                           errorMessage: errorMessage,
                           onCapture: { onCameraCapture(field) },
                           onGallery: { onGalleryPick(field) },
                           onPreview: { onImagePreview(field) },
                           onRemove: { onImageRemove(field) })

        case .idScan:
            IdScanFieldView(field: field, label: label, capturedImage: capturedImage,
                            errorMessage: errorMessage,
                            onCapture: { onCameraCapture(field) },
                            onGallery: { onGalleryPick(field) },
                            onPreview: { onImagePreview(field) },
                            onRemove: { onImageRemove(field) })

        case .selfie:
            SelfieFieldView(field: field, label: label, capturedImage: capturedImage,
                            errorMessage: errorMessage,
                            onCapture: { onCameraCapture(field) },
                            onGallery: { onGalleryPick(field) },
                            onPreview: { onImagePreview(field) },
                            onRemove: { onImageRemove(field) })

        case .signature:
            SignatureFieldView(field: field, label: label, capturedImage: capturedImage,
                               errorMessage: errorMessage)

        case .checkbox:
            CheckboxFieldView(field: field, label: label, value: value,
                              errorMessage: errorMessage)

        case .fileUpload:
            FileUploadFieldView(field: field, label: label, capturedImage: capturedImage,
                                errorMessage: errorMessage,
                                onFilePick: { onFilePick(field) },
                                onGallery: { onGalleryPick(field) },
                                onPreview: { onImagePreview(field) },
                                onRemove: { onImageRemove(field) })
        }
    }
}
