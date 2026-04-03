import SwiftUI

@MainActor
class LivenessViewModel: ObservableObject {
    @Published var sessionId: String?
    @Published var isLoading = false
    @Published var isComplete = false
    @Published var result: LivenessCheckResult?
    @Published var error: String?

    private let apiClient: APIClient

    struct LivenessCheckResult {
        let isLive: Bool
        let confidence: Float
        let status: String
    }

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func createSession() async {
        isLoading = true
        error = nil

        do {
            let response: CreateSessionResponse = try await apiClient.post(
                .createLivenessSession,
                body: EmptyBody()
            )
            sessionId = response.sessionId
            isLoading = false
        } catch {
            self.error = error.localizedDescription
            isLoading = false
        }
    }

    func verifySession() async {
        guard let sessionId = sessionId else { return }
        isLoading = true

        do {
            let response: VerifyResponse = try await apiClient.post(
                .verifyLiveness,
                body: VerifyRequest(sessionId: sessionId)
            )

            result = LivenessCheckResult(
                isLive: response.isLive,
                confidence: response.confidence,
                status: response.status
            )
            isComplete = true
            isLoading = false

            if response.isLive {
                HapticManager.notification(.success)
            } else {
                HapticManager.notification(.error)
            }
        } catch {
            self.error = error.localizedDescription
            isLoading = false
        }
    }

    func resetForRetry() {
        isComplete = false
        sessionId = nil
        result = nil
        error = nil
    }
}

// MARK: - Request / Response Models

struct EmptyBody: Codable {}

struct CreateSessionResponse: Codable {
    let sessionId: String
    let region: String
}

struct VerifyRequest: Codable {
    let sessionId: String
}

struct VerifyResponse: Codable {
    let isLive: Bool
    let confidence: Float
    let status: String
    let message: String?
}

struct LivenessStatusResponse: Codable {
    let enabled: Bool
}
