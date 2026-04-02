import SwiftUI

struct Configuration {
    static let apiBaseURL: String = {
        Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String ?? "http://localhost:5000/api/v1"
    }()
}

@MainActor
class DependencyContainer: ObservableObject {
    let languageManager: LanguageManager
    let networkService: NetworkServiceProtocol
    let journeyService: JourneyServiceProtocol
    let submissionService: SubmissionServiceProtocol
    let storageService: StorageServiceProtocol

    init() {
        self.languageManager = LanguageManager.shared

        let tokenManager = TokenManager()
        let apiClient = APIClient(baseURL: Configuration.apiBaseURL, tokenManager: tokenManager)

        self.networkService = apiClient
        self.journeyService = JourneyService(apiClient: apiClient)
        self.submissionService = SubmissionService(apiClient: apiClient)
        self.storageService = StorageService()
    }
}
