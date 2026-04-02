import Foundation

protocol JourneyServiceProtocol: Actor {
    func getActiveJourney(forceRefresh: Bool) async throws -> JourneyDetail
    func clearCache()
}
