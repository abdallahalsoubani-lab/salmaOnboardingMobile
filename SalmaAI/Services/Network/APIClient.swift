import Foundation
import UIKit

actor APIClient: NetworkServiceProtocol {
    private let baseURL: String
    private let tokenManager: TokenManager
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    private var isRefreshing = false
    private var refreshContinuations: [CheckedContinuation<String, Error>] = []

    init(baseURL: String, tokenManager: TokenManager = .shared) {
        self.baseURL = baseURL
        self.tokenManager = tokenManager

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 120
        config.waitsForConnectivity = true
        self.session = URLSession(configuration: config)

        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()
    }

    // MARK: - Public API

    func get<T: Codable>(_ endpoint: APIEndpoint, queryParams: [String: String]? = nil) async throws -> T {
        let request = try await buildRequest(endpoint: endpoint, queryParams: queryParams)
        return try await execute(request)
    }

    func post<T: Codable, B: Codable>(_ endpoint: APIEndpoint, body: B) async throws -> T {
        var request = try await buildRequest(endpoint: endpoint)
        request.httpBody = try encoder.encode(body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return try await execute(request)
    }

    func upload<T: Codable>(
        _ endpoint: APIEndpoint,
        fields: [String: String],
        files: [MultipartFile]
    ) async throws -> T {
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = try await buildRequest(endpoint: endpoint)
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = buildMultipartBody(fields: fields, files: files, boundary: boundary)
        request.timeoutInterval = 120
        return try await execute(request)
    }

    func submitVerification(
        journeyId: String,
        fields: [String: String],
        files: [MultipartFile]
    ) async throws -> SubmissionResult {
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = try await buildRequest(endpoint: .createSubmission)
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 180

        var formFields: [String: String] = ["journeyId": journeyId]
        if let fieldsJSON = try? JSONSerialization.data(withJSONObject: fields),
           let fieldsString = String(data: fieldsJSON, encoding: .utf8) {
            formFields["fields"] = fieldsString
        }

        request.httpBody = buildMultipartBody(fields: formFields, files: files, boundary: boundary)
        return try await execute(request)
    }

    // MARK: - Request Building

    private func buildRequest(
        endpoint: APIEndpoint,
        queryParams: [String: String]? = nil
    ) async throws -> URLRequest {
        guard var urlComponents = URLComponents(string: baseURL + endpoint.path) else {
            throw APIError.invalidURL
        }

        if let queryParams = queryParams, !queryParams.isEmpty {
            urlComponents.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
        }

        guard let url = urlComponents.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let token = await tokenManager.getAccessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let language = await MainActor.run { LanguageManager.shared.currentLanguage.rawValue }
        request.setValue(language, forHTTPHeaderField: "Accept-Language")

        return request
    }

    // MARK: - Request Execution

    private func execute<T: Codable>(_ request: URLRequest) async throws -> T {
        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: request)
        } catch let urlError as URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                throw APIError.noInternet
            case .timedOut:
                throw APIError.timeout
            default:
                throw APIError.unknown(urlError)
            }
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknown(NSError(domain: "APIClient", code: -1))
        }

        #if DEBUG
        print("[\(request.httpMethod ?? "?")] \(request.url?.path ?? "") → \(httpResponse.statusCode)")
        if let bodyString = String(data: data, encoding: .utf8) {
            print("Response: \(bodyString.prefix(500))")
        }
        #endif

        switch httpResponse.statusCode {
        case 200...201:
            return try decodeResponse(data: data)

        case 401:
            return try await handleUnauthorized(originalRequest: request)

        case 403:
            throw APIError.forbidden

        case 404:
            let apiResponse = try? decoder.decode(ApiResponse<EmptyResponse>.self, from: data)
            throw APIError.notFound(apiResponse?.message ?? "Resource not found")

        case 400:
            let apiResponse = try? decoder.decode(ApiResponse<EmptyResponse>.self, from: data)
            let errors = apiResponse?.errors ?? [apiResponse?.message ?? "Validation error"]
            throw APIError.validationError(errors)

        case 422:
            let apiResponse = try? decoder.decode(ApiResponse<EmptyResponse>.self, from: data)
            throw APIError.businessRuleError(apiResponse?.message ?? "Business rule error")

        case 429:
            let retryAfter = httpResponse.value(forHTTPHeaderField: "Retry-After").flatMap(Int.init)
            throw APIError.rateLimited(retryAfter: retryAfter)

        case 500...599:
            let apiResponse = try? decoder.decode(ApiResponse<EmptyResponse>.self, from: data)
            throw APIError.serverError(
                statusCode: httpResponse.statusCode,
                message: apiResponse?.message ?? L("server_error_generic")
            )

        default:
            throw APIError.serverError(statusCode: httpResponse.statusCode, message: "Unexpected error")
        }
    }

    // MARK: - Response Decoding

    private func decodeResponse<T: Codable>(data: Data) throws -> T {
        do {
            let apiResponse = try decoder.decode(ApiResponse<T>.self, from: data)
            guard apiResponse.success, let responseData = apiResponse.data else {
                let errors = apiResponse.errors ?? [apiResponse.message ?? "Unknown error"]
                throw APIError.validationError(errors)
            }
            return responseData
        } catch let error as APIError {
            throw error
        } catch {
            // Fallback: try direct decoding without ApiResponse wrapper
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw APIError.decodingError(error)
            }
        }
    }

    // MARK: - Token Refresh + Retry

    private func handleUnauthorized<T: Codable>(originalRequest: URLRequest) async throws -> T {
        guard await tokenManager.hasRefreshToken() else {
            await tokenManager.clearTokens()
            throw APIError.tokenRefreshFailed
        }

        if isRefreshing {
            let newToken: String = try await withCheckedThrowingContinuation { continuation in
                refreshContinuations.append(continuation)
            }
            var retryRequest = originalRequest
            retryRequest.setValue("Bearer \(newToken)", forHTTPHeaderField: "Authorization")
            return try await execute(retryRequest)
        }

        isRefreshing = true

        do {
            guard let refreshTokenValue = await tokenManager.getRefreshToken() else {
                throw APIError.tokenRefreshFailed
            }

            let body = RefreshTokenRequest(refreshToken: refreshTokenValue)
            let bodyData = try encoder.encode(body)

            guard let url = URL(string: baseURL + APIEndpoint.refreshToken.path) else {
                throw APIError.invalidURL
            }

            var refreshRequest = URLRequest(url: url)
            refreshRequest.httpMethod = "POST"
            refreshRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            refreshRequest.httpBody = bodyData

            let (data, response) = try await session.data(for: refreshRequest)

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw APIError.tokenRefreshFailed
            }

            let apiResponse = try decoder.decode(ApiResponse<AuthResponse>.self, from: data)
            guard let authData = apiResponse.data else {
                throw APIError.tokenRefreshFailed
            }

            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            let expiryDate = formatter.date(from: authData.expiresAt) ?? Date().addingTimeInterval(3600)

            await tokenManager.saveTokens(
                accessToken: authData.accessToken,
                refreshToken: authData.refreshToken,
                expiresAt: expiryDate
            )

            let newToken = authData.accessToken
            for continuation in refreshContinuations {
                continuation.resume(returning: newToken)
            }
            refreshContinuations.removeAll()
            isRefreshing = false

            var retryRequest = originalRequest
            retryRequest.setValue("Bearer \(newToken)", forHTTPHeaderField: "Authorization")
            return try await execute(retryRequest)

        } catch {
            await tokenManager.clearTokens()
            isRefreshing = false

            for continuation in refreshContinuations {
                continuation.resume(throwing: APIError.tokenRefreshFailed)
            }
            refreshContinuations.removeAll()

            throw APIError.tokenRefreshFailed
        }
    }

    // MARK: - Multipart Form Data

    private func buildMultipartBody(
        fields: [String: String],
        files: [MultipartFile],
        boundary: String
    ) -> Data {
        var body = Data()

        for (key, value) in fields {
            body.appendString("--\(boundary)\r\n")
            body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendString("\(value)\r\n")
        }

        for file in files {
            body.appendString("--\(boundary)\r\n")
            body.appendString("Content-Disposition: form-data; name=\"\(file.fieldName)\"; filename=\"\(file.fileName)\"\r\n")
            body.appendString("Content-Type: \(file.mimeType)\r\n\r\n")
            body.append(file.data)
            body.appendString("\r\n")
        }

        body.appendString("--\(boundary)--\r\n")
        return body
    }
}

// MARK: - Helper Types

struct MultipartFile {
    let fieldName: String
    let fileName: String
    let mimeType: String
    let data: Data
}

struct EmptyResponse: Codable {}

extension Data {
    mutating func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
