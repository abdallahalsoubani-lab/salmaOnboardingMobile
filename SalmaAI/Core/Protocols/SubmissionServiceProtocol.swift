import Foundation

protocol SubmissionServiceProtocol: Actor {
    func submitVerification(journeyId: String, fields: [String: String], images: [CapturedImage]) async throws -> SubmissionResult
    func getSubmissionStatus(id: String) async throws -> SubmissionStatus
}
