import SwiftUI
import UniformTypeIdentifiers

struct DocumentPickerView: UIViewControllerRepresentable {
    var allowedTypes: [UTType]
    var allowMultiple: Bool = false
    var onDocumentsPicked: (([PickedDocument]) -> Void)
    var onCancel: (() -> Void)?

    @Environment(\.dismiss) var dismiss

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: allowedTypes)
        picker.allowsMultipleSelection = allowMultiple
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPickerView

        init(_ parent: DocumentPickerView) { self.parent = parent }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            let documents = urls.compactMap { url -> PickedDocument? in
                guard url.startAccessingSecurityScopedResource() else { return nil }
                defer { url.stopAccessingSecurityScopedResource() }

                guard let data = try? Data(contentsOf: url) else { return nil }

                let fileName = url.lastPathComponent
                let fileExtension = url.pathExtension.lowercased()
                let mimeType = UTType(filenameExtension: fileExtension)?.preferredMIMEType ?? "application/octet-stream"

                return PickedDocument(
                    fileName: fileName,
                    fileExtension: fileExtension,
                    mimeType: mimeType,
                    fileSize: data.count,
                    data: data
                )
            }

            parent.onDocumentsPicked(documents)
            parent.dismiss()
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.onCancel?()
            parent.dismiss()
        }
    }
}

struct PickedDocument {
    let fileName: String
    let fileExtension: String
    let mimeType: String
    let fileSize: Int
    let data: Data

    var fileSizeFormatted: String {
        let kb = Double(fileSize) / 1024.0
        if kb > 1024 {
            return String(format: "%.1f MB", kb / 1024.0)
        }
        return String(format: "%.0f KB", kb)
    }

    var fileIcon: String {
        switch fileExtension {
        case "pdf": return "doc.text.fill"
        case "doc", "docx": return "doc.fill"
        case "jpg", "jpeg", "png", "webp": return "photo.fill"
        default: return "doc.fill"
        }
    }

    var fileIconColor: Color {
        switch fileExtension {
        case "pdf": return .red
        case "doc", "docx": return .blue
        case "jpg", "jpeg", "png", "webp": return .green
        default: return .gray
        }
    }
}

extension String {
    var utType: UTType? {
        switch self.lowercased() {
        case "pdf": return .pdf
        case "jpg", "jpeg": return .jpeg
        case "png": return .png
        case "webp": return .webP
        case "doc": return UTType("com.microsoft.word.doc")
        case "docx": return UTType("org.openxmlformats.wordprocessingml.document")
        default: return nil
        }
    }
}
