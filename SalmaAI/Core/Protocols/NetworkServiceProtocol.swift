import Foundation

protocol NetworkServiceProtocol {
    func request<T: Codable>(_ endpoint: APIEndpoint) async throws -> T
    func upload(data: Data, to endpoint: APIEndpoint, fieldName: String, fileName: String, mimeType: String) async throws -> ApiResponse<String>
}
