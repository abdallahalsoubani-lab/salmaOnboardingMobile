import Foundation

protocol JourneyServiceProtocol {
    func fetchActiveJourney() async throws -> JourneyDetail
}
