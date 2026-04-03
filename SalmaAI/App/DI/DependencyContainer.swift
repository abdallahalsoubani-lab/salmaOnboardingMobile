import SwiftUI

struct Configuration {
    static let apiBaseURL: String = {
        Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String ?? "http://34.41.105.171/api/v1"
    }()
}

@MainActor
class DependencyContainer: ObservableObject {
    let languageManager: LanguageManager
    let tokenManager: TokenManager
    let apiClient: APIClient
    let journeyService: JourneyService
    let submissionService: SubmissionService
    let storageService: StorageService
    let ocrExtractionService: OcrExtractionService

    init(baseURL: String? = nil) {
        self.languageManager = LanguageManager.shared
        self.tokenManager = TokenManager.shared
        self.storageService = StorageService()

        let url = baseURL ?? storageService.apiBaseURL
        self.apiClient = APIClient(baseURL: url, tokenManager: TokenManager.shared)
        self.journeyService = JourneyService(apiClient: apiClient)
        self.submissionService = SubmissionService(apiClient: apiClient)
        self.ocrExtractionService = OcrExtractionService(apiClient: apiClient)
    }
}
