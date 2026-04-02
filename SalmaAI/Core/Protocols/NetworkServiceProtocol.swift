import Foundation

protocol NetworkServiceProtocol: Actor {
    func get<T: Codable>(_ endpoint: APIEndpoint, queryParams: [String: String]?) async throws -> T
    func post<T: Codable, B: Codable>(_ endpoint: APIEndpoint, body: B) async throws -> T
    func upload<T: Codable>(_ endpoint: APIEndpoint, fields: [String: String], files: [MultipartFile]) async throws -> T
    func submitVerification(journeyId: String, fields: [String: String], files: [MultipartFile]) async throws -> SubmissionResult
}
