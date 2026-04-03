import Foundation

extension Bundle {

    private static var _localizedBundle: Bundle?
    private static var _cachedLanguage: String?

    static var localized: Bundle {
        let lang = UserDefaults.standard.string(forKey: "selected_language") ?? "ar"
        if let cached = _localizedBundle, _cachedLanguage == lang { return cached }
        if let path = Bundle.main.path(forResource: lang, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            _localizedBundle = bundle
            _cachedLanguage = lang
            return bundle
        }
        return Bundle.main
    }

    static func resetLocalizedBundle() {
        _localizedBundle = nil
        _cachedLanguage = nil
    }
}

func L(_ key: String) -> String {
    NSLocalizedString(key, bundle: .localized, comment: "")
}
