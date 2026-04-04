import Foundation

enum APIEndpoint {
    // Theme
    case getTheme

    // Journey
    case getActiveJourney
    case getPublishedJourneys

    // Drafts
    case startDraft
    case saveDraftPage
    case submitDraft(draftId: String)
    case getDraftStatus(draftId: String)
    case getActiveDraft
    case deleteDraft(draftId: String)

    // Resume
    case resumeDraft
    case sendResumeOtp
    case verifyResumeOtp

    // Submissions
    case createSubmission
    case getSubmissionStatus(id: String)

    // Files
    case uploadFile

    // Auth
    case login
    case register
    case refreshToken

    // Liveness
    case createLivenessSession
    case verifyLiveness
    case livenessStatus

    // OCR
    case extractOcr

    var path: String {
        switch self {
        case .getTheme:                    return "/theme"
        case .getActiveJourney:            return "/journey/active"
        case .getPublishedJourneys:        return "/journeys/published"
        case .startDraft:                  return "/drafts/start"
        case .saveDraftPage:               return "/drafts/page"
        case .submitDraft(let id):         return "/drafts/\(id)/submit"
        case .getDraftStatus(let id):      return "/drafts/\(id)"
        case .getActiveDraft:              return "/drafts/active"
        case .deleteDraft(let id):         return "/drafts/\(id)"
        case .resumeDraft:                 return "/drafts/resume"
        case .sendResumeOtp:               return "/drafts/resume/send-otp"
        case .verifyResumeOtp:             return "/drafts/resume/verify"
        case .createSubmission:            return "/submissions"
        case .getSubmissionStatus(let id): return "/submissions/\(id)/status"
        case .uploadFile:                  return "/files/upload"
        case .login:                       return "/auth/login"
        case .register:                    return "/auth/register"
        case .refreshToken:                return "/auth/refresh-token"
        case .createLivenessSession:       return "/liveness/session"
        case .verifyLiveness:              return "/liveness/verify"
        case .livenessStatus:              return "/liveness/status"
        case .extractOcr:                  return "/ocr/extract"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .getTheme, .getActiveJourney, .getPublishedJourneys, .getSubmissionStatus, .getDraftStatus, .getActiveDraft, .livenessStatus:
            return .get
        case .startDraft, .saveDraftPage, .submitDraft, .resumeDraft, .sendResumeOtp, .verifyResumeOtp,
             .createSubmission, .uploadFile, .login, .register, .refreshToken,
             .createLivenessSession, .verifyLiveness, .extractOcr:
            return .post
        case .deleteDraft:
            return .delete
        }
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}
