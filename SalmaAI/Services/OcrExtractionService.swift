import Foundation
import UIKit

actor OcrExtractionService {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func extractFromImage(imageData: Data, side: String = "front") async throws -> OcrExtractionResult {
        var jpegData = imageData
        if let uiImage = UIImage(data: imageData),
           let compressed = uiImage.jpegData(compressionQuality: 0.85) {
            jpegData = compressed
        }

        let file = MultipartFile(
            fieldName: "file",
            fileName: "id_\(side).jpg",
            mimeType: "image/jpeg",
            data: jpegData
        )

        let response: OcrExtractionResult = try await apiClient.upload(
            .extractOcr,
            fields: ["side": side],
            files: [file]
        )
        return response
    }
}
