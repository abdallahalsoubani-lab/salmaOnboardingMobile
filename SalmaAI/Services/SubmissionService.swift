import Foundation

final class SubmissionService: SubmissionServiceProtocol {
    private let apiClient: NetworkServiceProtocol

    init(apiClient: NetworkServiceProtocol) {
        self.apiClient = apiClient
    }

    func submitData(_ fields: [String: Any], images: [String: Data]) async throws -> SubmissionResult {
        // Will be fully implemented in Prompt 10 (Submission flow)
        let response: ApiResponse<SubmissionResult> = try await apiClient.request(.submitData)
        guard let result = response.data else {
            throw APIError.noData
        }
        return result
    }

    func checkStatus(submissionId: String) async throws -> SubmissionStatus {
        let response: ApiResponse<SubmissionStatus> = try await apiClient.request(.submissionStatus(id: submissionId))
        guard let status = response.data else {
            throw APIError.noData
        }
        return status
    }
}
