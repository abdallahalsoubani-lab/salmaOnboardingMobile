import Foundation
import Security

final class TokenManager {
    private let tokenKey = "com.salmaai.onboarding.jwt"
    private let refreshTokenKey = "com.salmaai.onboarding.refreshToken"

    var token: String? {
        get { readKeychain(key: tokenKey) }
        set {
            if let value = newValue {
                saveKeychain(key: tokenKey, value: value)
            } else {
                deleteKeychain(key: tokenKey)
            }
        }
    }

    var refreshToken: String? {
        get { readKeychain(key: refreshTokenKey) }
        set {
            if let value = newValue {
                saveKeychain(key: refreshTokenKey, value: value)
            } else {
                deleteKeychain(key: refreshTokenKey)
            }
        }
    }

    var hasToken: Bool {
        token != nil
    }

    func clearAll() {
        token = nil
        refreshToken = nil
    }

    // MARK: - Keychain Helpers

    private func saveKeychain(key: String, value: String) {
        guard let data = value.data(using: .utf8) else { return }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    private func readKeychain(key: String) -> String? {
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

    private func deleteKeychain(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}
