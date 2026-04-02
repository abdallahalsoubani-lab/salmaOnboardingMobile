import Foundation
import Security

actor TokenManager {
    static let shared = TokenManager()

    private let accessTokenKey = "com.salmaai.accessToken"
    private let refreshTokenKey = "com.salmaai.refreshToken"
    private let tokenExpiryKey = "com.salmaai.tokenExpiry"

    // MARK: - Save Tokens

    func saveTokens(accessToken: String, refreshToken: String, expiresAt: Date) {
        saveToKeychain(key: accessTokenKey, value: accessToken)
        saveToKeychain(key: refreshTokenKey, value: refreshToken)
        UserDefaults.standard.set(expiresAt.timeIntervalSince1970, forKey: tokenExpiryKey)
    }

    // MARK: - Read Tokens

    func getAccessToken() -> String? {
        readFromKeychain(key: accessTokenKey)
    }

    func getRefreshToken() -> String? {
        readFromKeychain(key: refreshTokenKey)
    }

    // MARK: - Token Validity

    func isAccessTokenValid() -> Bool {
        guard getAccessToken() != nil else { return false }
        let expiry = UserDefaults.standard.double(forKey: tokenExpiryKey)
        guard expiry > 0 else { return false }
        let expiryDate = Date(timeIntervalSince1970: expiry)
        // Buffer: consider expired 60s early
        return expiryDate.addingTimeInterval(-60) > Date()
    }

    func hasRefreshToken() -> Bool {
        getRefreshToken() != nil
    }

    // MARK: - Clear (Logout)

    func clearTokens() {
        deleteFromKeychain(key: accessTokenKey)
        deleteFromKeychain(key: refreshTokenKey)
        UserDefaults.standard.removeObject(forKey: tokenExpiryKey)
    }

    // MARK: - Keychain Operations

    private func saveToKeychain(key: String, value: String) {
        guard let data = value.data(using: .utf8) else { return }

        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(deleteQuery as CFDictionary)

        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]
        SecItemAdd(addQuery as CFDictionary, nil)
    }

    private func readFromKeychain(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private func deleteFromKeychain(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}
