import SwiftUI

struct CaptureSourceSheet: ViewModifier {
    @Binding var isPresented: Bool
    let fieldType: FieldType
    let sourceType: CaptureSource
    var onCamera: () -> Void = {}
    var onGallery: () -> Void = {}
    var onFilePicker: () -> Void = {}

    func body(content: Content) -> some View {
        content
            .confirmationDialog(
                L("choose_source"),
                isPresented: $isPresented,
                titleVisibility: .visible
            ) {
                if sourceType == .cameraOnly || sourceType == .cameraAndGallery {
                    Button(L("take_photo")) { onCamera() }
                }

                if sourceType == .galleryOnly || sourceType == .cameraAndGallery {
                    if fieldType == .fileUpload {
                        Button(L("choose_file")) { onFilePicker() }
                    } else {
                        Button(L("choose_from_gallery")) { onGallery() }
                    }
                }

                Button(L("cancel"), role: .cancel) {}
            }
    }
}

extension View {
    func captureSourceSheet(
        isPresented: Binding<Bool>,
        fieldType: FieldType,
        sourceType: CaptureSource,
        onCamera: @escaping () -> Void = {},
        onGallery: @escaping () -> Void = {},
        onFilePicker: @escaping () -> Void = {}
    ) -> some View {
        modifier(CaptureSourceSheet(
            isPresented: isPresented,
            fieldType: fieldType,
            sourceType: sourceType,
            onCamera: onCamera,
            onGallery: onGallery,
            onFilePicker: onFilePicker
        ))
    }
}
