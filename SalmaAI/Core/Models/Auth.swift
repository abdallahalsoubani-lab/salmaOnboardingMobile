import Foundation

struct AuthRequest: Codable {
    let username: String
    let password: String
}

struct AuthResponse: Codable {
    let token: String
    let refreshToken: String?
    let expiresIn: Int?
}

struct RefreshTokenRequest: Codable {
    let refreshToken: String
}
