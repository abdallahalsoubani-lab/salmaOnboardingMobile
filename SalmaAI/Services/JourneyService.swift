import Foundation

final class JourneyService: JourneyServiceProtocol {
    private let apiClient: NetworkServiceProtocol

    init(apiClient: NetworkServiceProtocol) {
        self.apiClient = apiClient
    }

    func fetchActiveJourney() async throws -> JourneyDetail {
        let response: ApiResponse<JourneyDetail> = try await apiClient.request(.activeJourney)
        guard let journey = response.data else {
            throw APIError.noData
        }
        return journey
    }
}
