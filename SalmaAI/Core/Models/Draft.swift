import Foundation

struct StartDraftRequest: Codable {
    let journeyId: String?
    let journeyCode: String?
    let deviceId: String?
    let language: String?
}

struct SavePageRequest: Codable {
    let draftId: String
    let pageIndex: Int
    let fieldValues: [String: String]
}

struct SavePageResponse: Codable {
    let draftId: String
    let currentPageIndex: Int
    let nextPageIndex: Int?
    let nextPage: JourneyPage?
    let isLastPage: Bool
    let totalPages: Int
    let savedFieldsCount: Int
    let validationErrors: [String: String]?
    let message: String?
}

struct DraftStatusResponse: Codable {
    let draftId: String
    let journeyId: String
    let journeyName: String?
    let currentPageIndex: Int
    let totalPages: Int
    let status: String
    let fieldValues: [String: String]?
    let uploadedFiles: [String]?
    let createdAt: String
    let updatedAt: String
    let expiresAt: String
}

struct ResumeRequest: Codable {
    let identifier: String
    let journeyId: String?
    let journeyCode: String?
}

struct ResumeResponse: Codable {
    let found: Bool
    let draftId: String?
    let maskedName: String?
    let currentPageIndex: Int?
    let totalPages: Int?
    let status: String?
    let requiresOtp: Bool?
}

struct OtpSendRequest: Codable {
    let identifier: String
    let identifierType: String
}

struct OtpSendResponse: Codable {
    let sent: Bool
    let expiresInSeconds: Int?
}

struct OtpVerifyRequest: Codable {
    let identifier: String
    let otpCode: String
    let draftId: String
}

struct OtpVerifyResponse: Codable {
    let verified: Bool
    let draftId: String?
    let fieldValues: [String: String]?
    let uploadedFiles: [String]?
    let currentPageIndex: Int?
    let totalPages: Int?
    let message: String?
}

struct PublishedJourney: Codable, Identifiable {
    let id: String
    let name: String
    let description: String?
    let version: Int?
    let status: String?
    let pageCount: Int
    let fieldCount: Int?
    let createdAt: String?
    let updatedAt: String?
    let publishedAt: String?
    let createdByName: String?
}
