import SwiftUI

@MainActor
class LanguageManager: ObservableObject {
    static let shared = LanguageManager()

    @Published var currentLanguage: AppLanguage
    @Published var layoutDirection: LayoutDirection

    private let storageKey = "selected_language"

    init() {
        if let saved = UserDefaults.standard.string(forKey: storageKey),
           let lang = AppLanguage(rawValue: saved) {
            self.currentLanguage = lang
            self.layoutDirection = lang.layoutDirection
        } else {
            self.currentLanguage = .arabic
            self.layoutDirection = .rightToLeft
        }
        UserDefaults.standard.set([currentLanguage.rawValue], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }

    var isLanguageSelected: Bool {
        UserDefaults.standard.string(forKey: storageKey) != nil
    }

    func setLanguage(_ language: AppLanguage) {
        currentLanguage = language
        layoutDirection = language.layoutDirection
        UserDefaults.standard.set(language.rawValue, forKey: storageKey)
        UserDefaults.standard.set([language.rawValue], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        Bundle.resetLocalizedBundle()
    }

    func localizedLabel(for field: PageField) -> String {
        currentLanguage == .arabic ? field.labelAr : field.label
    }

    func localizedPlaceholder(for field: PageField) -> String {
        let ph = currentLanguage == .arabic ? field.placeholderAr : field.placeholder
        return ph ?? ""
    }

    func localizedTitle(for page: JourneyPage) -> String {
        currentLanguage == .arabic ? page.titleAr : page.title
    }

    func localizedError(for rules: ValidationRules?) -> String? {
        guard let rules = rules else { return nil }
        return currentLanguage == .arabic ? rules.regexErrorAr : rules.regexError
    }

    func localizedRuleMessage(for action: RuleAction) -> String? {
        currentLanguage == .arabic ? action.messageAr : action.message
    }

    func localizedConsentText(for rules: ValidationRules?) -> String? {
        guard let rules = rules else { return nil }
        return currentLanguage == .arabic ? rules.consentTextAr : rules.consentTextEn
    }
}
