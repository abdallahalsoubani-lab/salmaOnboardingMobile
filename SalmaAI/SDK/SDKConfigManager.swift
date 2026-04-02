import Foundation

class SDKConfigManager {
    static let shared = SDKConfigManager()
    private(set) var currentConfig: SalmaConfig?

    func apply(_ config: SalmaConfig) {
        currentConfig = config

        if config.debugMode {
            print("[SalmaSDK] Version \(SalmaSDK.version)")
            print("[SalmaSDK] API: \(config.apiBaseURL)")
            print("[SalmaSDK] Language: \(config.defaultLanguage.rawValue)")
            print("[SalmaSDK] Language switch: \(config.allowLanguageSwitch)")
        }

        UserDefaults.standard.set(config.theme.showBranding, forKey: "salma_sdk_show_branding")
        UserDefaults.standard.set(config.theme.cornerRadius, forKey: "salma_sdk_corner_radius")
    }
}
