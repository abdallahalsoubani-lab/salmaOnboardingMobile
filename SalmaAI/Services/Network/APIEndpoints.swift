import Foundation

enum APIEndpoint {
    case activeJourney
    case submitData
    case submissionStatus(id: String)
    case uploadFile

    var path: String {
        switch self {
        case .activeJourney:
            return "/journey/active"
        case .submitData:
            return "/submissions"
        case .submissionStatus(let id):
            return "/submissions/\(id)/status"
        case .uploadFile:
            return "/files/upload"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .activeJourney, .submissionStatus:
            return .get
        case .submitData, .uploadFile:
            return .post
        }
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}
