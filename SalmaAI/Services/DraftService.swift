import Foundation

actor DraftService {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func startDraft(journeyId: String?, journeyCode: String?, deviceId: String?) async throws -> DraftStatusResponse {
        let language = await MainActor.run { LanguageManager.shared.currentLanguage.rawValue }
        let request = StartDraftRequest(
            journeyId: journeyId,
            journeyCode: journeyCode,
            deviceId: deviceId,
            language: language
        )
        return try await apiClient.post(.startDraft, body: request)
    }

    func savePage(
        draftId: String,
        pageIndex: Int,
        fieldValues: [String: String],
        files: [MultipartFile]
    ) async throws -> SavePageResponse {
        var fields: [String: String] = [
            "draftId": draftId,
            "pageIndex": String(pageIndex)
        ]
        for (key, value) in fieldValues {
            fields["fieldValues[\(key)]"] = value
        }

        #if DEBUG
        print("[DraftService] savePage — draftId: \(draftId), pageIndex: \(pageIndex)")
        print("[DraftService] fieldValues (\(fieldValues.count) entries):")
        for (key, value) in fieldValues {
            print("  • \(key) = \(value.prefix(80))")
        }
        print("[DraftService] files: \(files.count)")
        #endif

        return try await apiClient.upload(.saveDraftPage, fields: fields, files: files)
    }

    func submitDraft(draftId: String) async throws -> SubmissionResult {
        return try await apiClient.post(.submitDraft(draftId: draftId))
    }

    func getDraftStatus(draftId: String) async throws -> DraftStatusResponse {
        return try await apiClient.get(.getDraftStatus(draftId: draftId))
    }

    func getActiveDraft(journeyId: String, deviceId: String?) async throws -> DraftStatusResponse? {
        var params: [String: String] = ["journeyId": journeyId]
        if let deviceId = deviceId { params["deviceId"] = deviceId }
        do {
            let response: DraftStatusResponse = try await apiClient.get(.getActiveDraft, queryParams: params)
            return response
        } catch {
            return nil
        }
    }

    func findDraftByIdentifier(identifier: String, journeyId: String?, journeyCode: String?) async throws -> ResumeResponse {
        let request = ResumeRequest(
            identifier: identifier,
            journeyId: journeyId,
            journeyCode: journeyCode
        )
        return try await apiClient.post(.resumeDraft, body: request)
    }

    func sendOtp(identifier: String, identifierType: String) async throws -> OtpSendResponse {
        let request = OtpSendRequest(identifier: identifier, identifierType: identifierType)
        return try await apiClient.post(.sendResumeOtp, body: request)
    }

    func verifyOtpAndResume(identifier: String, otpCode: String, draftId: String) async throws -> OtpVerifyResponse {
        let request = OtpVerifyRequest(identifier: identifier, otpCode: otpCode, draftId: draftId)
        return try await apiClient.post(.verifyResumeOtp, body: request)
    }

    func getPublishedJourneys() async throws -> [PublishedJourney] {
        return try await apiClient.get(.getPublishedJourneys)
    }

    func deleteDraft(draftId: String) async throws {
        let _: EmptyResponse = try await apiClient.delete(.deleteDraft(draftId: draftId))
    }
}
