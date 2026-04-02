import Foundation

actor JourneyService: JourneyServiceProtocol {
    private let apiClient: APIClient
    private var cachedJourney: JourneyDetail?
    private var cacheTimestamp: Date?
    private let cacheDuration: TimeInterval = 300 // 5 minutes

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func getActiveJourney(forceRefresh: Bool = false) async throws -> JourneyDetail {
        if !forceRefresh,
           let cached = cachedJourney,
           let timestamp = cacheTimestamp,
           Date().timeIntervalSince(timestamp) < cacheDuration {
            return cached
        }

        let journey: JourneyDetail = try await apiClient.get(.getActiveJourney)

        cachedJourney = journey
        cacheTimestamp = Date()

        return journey
    }

    func clearCache() {
        cachedJourney = nil
        cacheTimestamp = nil
    }
}
