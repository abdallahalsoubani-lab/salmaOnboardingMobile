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

    var path: String {
        switch self {
        case .getActiveJourney:            return "/journey/active"
        case .createSubmission:            return "/submissions"
        case .getSubmissionStatus(let id): return "/submissions/\(id)/status"
        case .uploadFile:                  return "/files/upload"
        case .login:                       return "/auth/login"
        case .register:                    return "/auth/register"
        case .refreshToken:                return "/auth/refresh-token"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .getActiveJourney, .getSubmissionStatus:
            return .get
        case .createSubmission, .uploadFile, .login, .register, .refreshToken:
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
