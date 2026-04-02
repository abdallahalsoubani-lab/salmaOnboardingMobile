import Foundation

protocol SubmissionServiceProtocol {
    func submitData(_ fields: [String: Any], images: [String: Data]) async throws -> SubmissionResult
    func checkStatus(submissionId: String) async throws -> SubmissionStatus
}
