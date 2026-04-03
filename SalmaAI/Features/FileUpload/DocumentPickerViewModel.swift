import SwiftUI
import UniformTypeIdentifiers

// Document picker is now handled via DocumentPickerView (UIViewControllerRepresentable)
// This file provides helper utilities for file validation

struct FileValidator {
    static func validate(
        document: PickedDocument,
        maxSizeMB: Int? = nil,
        acceptedFormats: [String]? = nil
    ) -> String? {
        // Check file size
        if let maxMB = maxSizeMB {
            let maxBytes = maxMB * 1_048_576
            if document.fileSize > maxBytes {
                return L("file_too_large")
            }
        }

        // Check format
        if let formats = acceptedFormats, !formats.isEmpty {
            if !formats.contains(document.fileExtension.lowercased()) {
                return L("unsupported_format")
            }
        }

        return nil
    }

    static func allowedUTTypes(from formats: [String]?) -> [UTType] {
        guard let formats = formats, !formats.isEmpty else {
            return SalmaDesign.FileUpload.allAllowedFormats.compactMap { $0.utType }
        }
        return formats.compactMap { $0.utType }
    }
}
