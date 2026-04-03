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
            return L("no_internet_error")
        case .timeout:
            return L("timeout_error")
        case .serverError(_, let message):
            return message
        case .unauthorized:
            return L("session_expired_error")
        case .forbidden:
            return L("forbidden_error")
        case .notFound(let message):
            return message
        case .validationError(let errors):
            return errors.joined(separator: "\n")
        case .businessRuleError(let message):
            return message
        case .rateLimited:
            return L("rate_limited_error")
        case .decodingError:
            return L("parsing_error")
        case .encodingError:
            return L("encoding_error")
        case .invalidURL:
            return L("invalid_url_error")
        case .tokenRefreshFailed:
            return L("token_refresh_failed_error")
        case .noData:
            return L("no_data_error")
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
