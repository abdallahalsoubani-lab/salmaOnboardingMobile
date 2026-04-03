import Foundation
import UIKit

actor SubmissionService: SubmissionServiceProtocol {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func submitVerification(
        journeyId: String,
        fields: [String: String],
        images: [CapturedImage]
    ) async throws -> SubmissionResult {
        let files = images.compactMap { image -> MultipartFile? in
            if image.type == .document {
                let fileName = image.fileName ?? "\(image.fieldId).bin"
                let mimeType = image.mimeType ?? "application/octet-stream"
                return MultipartFile(
                    fieldName: image.fieldId,
                    fileName: fileName,
                    mimeType: mimeType,
                    data: image.imageData
                )
            }

            guard let jpegData = compressImage(image.imageData, maxSizeKB: 1024) else { return nil }
            return MultipartFile(
                fieldName: image.fieldId,
                fileName: "\(image.fieldId).jpg",
                mimeType: "image/jpeg",
                data: jpegData
            )
        }

        return try await apiClient.submitVerification(
            journeyId: journeyId,
            fields: fields,
            files: files
        )
    }

    func getSubmissionStatus(id: String) async throws -> SubmissionStatus {
        try await apiClient.get(.getSubmissionStatus(id: id))
    }

    private func compressImage(_ imageData: Data, maxSizeKB: Int) -> Data? {
        guard let uiImage = UIImage(data: imageData) else { return nil }

        var compression: CGFloat = 0.9
        var data = uiImage.jpegData(compressionQuality: compression)

        while let d = data, d.count > maxSizeKB * 1024, compression > 0.1 {
            compression -= 0.1
            data = uiImage.jpegData(compressionQuality: compression)
        }

        return data
    }
}

struct CapturedImage {
    let fieldId: String
    let imageData: Data
    let type: CaptureType
    var fileName: String?
    var mimeType: String?
    var fileSize: Int?

    enum CaptureType {
        case idFront
        case idBack
        case selfie
        case photo
        case signature
        case document
    }
}
