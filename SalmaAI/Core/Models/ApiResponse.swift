import Foundation

struct ApiResponse<T: Codable>: Codable {
    let success: Bool
    let data: T?
    let errors: [String]?
    let message: String?
    let statusCode: Int?
}

struct PaginatedResponse<T: Codable>: Codable {
    let items: [T]
    let totalCount: Int
    let page: Int
    let pageSize: Int
    let totalPages: Int
}
