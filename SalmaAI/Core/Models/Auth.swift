import Foundation

struct AuthRequest: Codable {
    let username: String
    let password: String
}

struct AuthResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresAt: String
    let user: UserInfo?
}

struct UserInfo: Codable {
    let id: String
    let email: String?
    let fullName: String?
    let phoneNumber: String?
    let role: String?
}

struct RefreshTokenRequest: Codable {
    let refreshToken: String
}
