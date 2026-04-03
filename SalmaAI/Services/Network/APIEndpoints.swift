import Foundation

enum APIEndpoint {
    // Journey
    case getActiveJourney

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
        case .getActiveJourney:            return "/journey/active"
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
        case .getActiveJourney, .getSubmissionStatus, .livenessStatus:
            return .get
        case .createSubmission, .uploadFile, .login, .register, .refreshToken,
             .createLivenessSession, .verifyLiveness, .extractOcr:
            return .post
        }
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}
