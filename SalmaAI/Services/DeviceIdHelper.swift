import Foundation

struct DeviceIdHelper {
    private static let key = "com.salmaai.deviceId"

    static var deviceId: String {
        if let existing = UserDefaults.standard.string(forKey: key) {
            return existing
        }
        let newId = UUID().uuidString
        UserDefaults.standard.set(newId, forKey: key)
        return newId
    }
}
