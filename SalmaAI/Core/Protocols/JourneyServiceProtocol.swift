import Foundation

protocol JourneyServiceProtocol: Actor {
    func getActiveJourney(code: String?, journeyId: String?, forceRefresh: Bool) async throws -> JourneyDetail
    func clearCache()
}
