import Foundation

enum APIError: LocalizedError {
    case noInternet
    case timeout
    case serverError(statusCode: Int, message: String)
    case unauthorized
    case forbidden
    case notFound(String)
    case validationError([String])
    case businessRuleError(String)
    case rateLimited(retryAfter: Int?)
    case decodingError(Error)
    case encodingError
    case invalidURL
    case tokenRefreshFailed
    case noData
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .noInternet:
            return String(localized: "no_internet_error")
        case .timeout:
            return String(localized: "timeout_error")
        case .serverError(_, let message):
            return message
        case .unauthorized:
            return String(localized: "session_expired_error")
        case .forbidden:
            return String(localized: "forbidden_error")
        case .notFound(let message):
            return message
        case .validationError(let errors):
            return errors.joined(separator: "\n")
        case .businessRuleError(let message):
            return message
        case .rateLimited:
            return String(localized: "rate_limited_error")
        case .decodingError:
            return String(localized: "parsing_error")
        case .encodingError:
            return String(localized: "encoding_error")
        case .invalidURL:
            return String(localized: "invalid_url_error")
        case .tokenRefreshFailed:
            return String(localized: "token_refresh_failed_error")
        case .noData:
            return String(localized: "no_data_error")
        case .unknown(let error):
            return error.localizedDescription
        }
    }

    var isAuthError: Bool {
        switch self {
        case .unauthorized, .tokenRefreshFailed: return true
        default: return false
        }
    }
}
