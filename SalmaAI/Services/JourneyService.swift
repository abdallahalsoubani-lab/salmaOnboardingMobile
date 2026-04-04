import Foundation

actor JourneyService: JourneyServiceProtocol {
    private let apiClient: APIClient
    private var cachedJourney: JourneyDetail?
    private var cacheTimestamp: Date?
    private let cacheDuration: TimeInterval = 300

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func getActiveJourney(code: String? = nil, journeyId: String? = nil, forceRefresh: Bool = false) async throws -> JourneyDetail {
        if !forceRefresh,
           let cached = cachedJourney,
           let timestamp = cacheTimestamp,
           Date().timeIntervalSince(timestamp) < cacheDuration {
            return cached
        }

        var params: [String: String] = [:]
        if let code = code {
            params["code"] = code
        }
        if let journeyId = journeyId {
            params["journeyId"] = journeyId
        }

        let journey: JourneyDetail = try await apiClient.get(
            .getActiveJourney,
            queryParams: params.isEmpty ? nil : params
        )

        cachedJourney = journey
        cacheTimestamp = Date()

        return journey
    }

    func getPublishedJourneys() async throws -> [PublishedJourney] {
        return try await apiClient.get(.getPublishedJourneys)
    }

    func clearCache() {
        cachedJourney = nil
        cacheTimestamp = nil
    }
}
