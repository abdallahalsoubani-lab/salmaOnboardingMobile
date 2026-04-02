import Foundation

final class APIClient: NetworkServiceProtocol {
    private let baseURL: String
    private let tokenManager: TokenManager
    private let session: URLSession
    private let decoder: JSONDecoder

    init(baseURL: String, tokenManager: TokenManager, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.tokenManager = tokenManager
        self.session = session
        self.decoder = JSONDecoder()
    }

    func request<T: Codable>(_ endpoint: APIEndpoint) async throws -> T {
        guard let url = URL(string: baseURL + endpoint.path) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = tokenManager.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await performRequest(request)
        try validateResponse(response)

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }

    func upload(
        data: Data,
        to endpoint: APIEndpoint,
        fieldName: String,
        fileName: String,
        mimeType: String
    ) async throws -> ApiResponse<String> {
        guard let url = URL(string: baseURL + endpoint.path) else {
            throw APIError.invalidURL
        }

        let boundary = UUID().uuidString
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        if let token = tokenManager.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        let (responseData, response) = try await performRequest(request)
        try validateResponse(response)

        do {
            return try decoder.decode(ApiResponse<String>.self, from: responseData)
        } catch {
            throw APIError.decodingError(error)
        }
    }

    // MARK: - Private

    private func performRequest(_ request: URLRequest) async throws -> (Data, URLResponse) {
        do {
            return try await session.data(for: request)
        } catch {
            throw APIError.networkError(error)
        }
    }

    private func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknown
        }
        switch httpResponse.statusCode {
        case 200...299:
            return
        case 401:
            throw APIError.unauthorized
        case 403:
            throw APIError.forbidden
        case 404:
            throw APIError.notFound
        default:
            throw APIError.serverError(statusCode: httpResponse.statusCode, message: nil)
        }
    }
}
