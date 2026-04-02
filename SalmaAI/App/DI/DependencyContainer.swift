import SwiftUI

struct Configuration {
    static let apiBaseURL: String = {
        Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String ?? "http://localhost:5000/api/v1"
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

    init() {
        self.languageManager = LanguageManager.shared
        self.tokenManager = TokenManager.shared
        self.storageService = StorageService()

        let baseURL = storageService.apiBaseURL
        self.apiClient = APIClient(baseURL: baseURL, tokenManager: TokenManager.shared)
        self.journeyService = JourneyService(apiClient: apiClient)
        self.submissionService = SubmissionService(apiClient: apiClient)
    }
}
