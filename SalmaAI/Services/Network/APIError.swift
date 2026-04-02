import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case serverError(statusCode: Int, message: String?)
    case networkError(Error)
    case unauthorized
    case forbidden
    case notFound
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .serverError(let code, let message):
            return message ?? "Server error (\(code))"
        case .networkError(let error):
            return error.localizedDescription
        case .unauthorized:
            return "Unauthorized — please try again"
        case .forbidden:
            return "Access denied"
        case .notFound:
            return "Resource not found"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}
