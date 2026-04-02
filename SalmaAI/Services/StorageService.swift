import Foundation

class StorageService: StorageServiceProtocol {
    private let defaults = UserDefaults.standard

    var selectedLanguage: AppLanguage? {
        get {
            guard let raw = defaults.string(forKey: "selected_language") else { return nil }
            return AppLanguage(rawValue: raw)
        }
        set {
            defaults.set(newValue?.rawValue, forKey: "selected_language")
        }
    }

    var hasCompletedOnboarding: Bool {
        get { defaults.bool(forKey: "completed_onboarding") }
        set { defaults.set(newValue, forKey: "completed_onboarding") }
    }

    var lastSubmissionId: String? {
        get { defaults.string(forKey: "last_submission_id") }
        set { defaults.set(newValue, forKey: "last_submission_id") }
    }

    var apiBaseURL: String {
        get { defaults.string(forKey: "api_base_url") ?? Configuration.apiBaseURL }
        set { defaults.set(newValue, forKey: "api_base_url") }
    }

    func clearAll() {
        if let domain = Bundle.main.bundleIdentifier {
            defaults.removePersistentDomain(forName: domain)
        }
    }
}
