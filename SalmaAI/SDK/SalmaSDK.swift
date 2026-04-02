import SwiftUI
import UIKit

// MARK: - Main SDK Entry Point

public final class SalmaSDK {
    public static let version = "1.0.0"

    public static func startVerification(
        from viewController: UIViewController,
        config: SalmaConfig,
        completion: @escaping (SalmaResult) -> Void
    ) {
        let coordinator = SDKCoordinator(config: config, completion: completion)
        coordinator.present(from: viewController)
    }

    public static func verificationView(
        config: SalmaConfig,
        completion: @escaping (SalmaResult) -> Void
    ) -> some View {
        SDKContainerView(config: config, completion: completion)
    }

    public static func validate(config: SalmaConfig) -> SalmaConfigValidation {
        var issues: [String] = []
        if config.apiBaseURL.isEmpty { issues.append("apiBaseURL is required") }
        if !config.apiBaseURL.hasPrefix("http") { issues.append("apiBaseURL must start with http:// or https://") }
        if config.apiKey.isEmpty { issues.append("apiKey is required") }
        return SalmaConfigValidation(isValid: issues.isEmpty, issues: issues)
    }

    public static func prefetch(config: SalmaConfig) async throws {
        let apiClient = APIClient(baseURL: config.apiBaseURL, tokenManager: TokenManager.shared)
        let journeyService = JourneyService(apiClient: apiClient)
        _ = try await journeyService.getActiveJourney(forceRefresh: true)
    }
}

// MARK: - Configuration

public struct SalmaConfig {
    public let apiBaseURL: String
    public let apiKey: String
    public let defaultLanguage: SalmaLanguage
    public let allowLanguageSwitch: Bool
    public let followDeviceLanguage: Bool
    public let theme: SalmaTheme
    public let metadata: [String: String]
    public let requestTimeout: TimeInterval
    public let debugMode: Bool

    public init(
        apiBaseURL: String,
        apiKey: String,
        defaultLanguage: SalmaLanguage = .arabic,
        allowLanguageSwitch: Bool = true,
        followDeviceLanguage: Bool = false,
        theme: SalmaTheme = .default,
        metadata: [String: String] = [:],
        requestTimeout: TimeInterval = 30,
        debugMode: Bool = false
    ) {
        self.apiBaseURL = apiBaseURL
        self.apiKey = apiKey
        self.defaultLanguage = defaultLanguage
        self.allowLanguageSwitch = allowLanguageSwitch
        self.followDeviceLanguage = followDeviceLanguage
        self.theme = theme
        self.metadata = metadata
        self.requestTimeout = requestTimeout
        self.debugMode = debugMode
    }
}

// MARK: - Language

public enum SalmaLanguage: String, Codable {
    case arabic = "ar"
    case english = "en"
}

// MARK: - Theme

public struct SalmaTheme {
    public let primaryColor: UIColor
    public let backgroundColor: UIColor
    public let cornerRadius: CGFloat
    public let fontFamily: String?
    public let showBranding: Bool

    public init(
        primaryColor: UIColor = UIColor(red: 22/255, green: 160/255, blue: 133/255, alpha: 1),
        backgroundColor: UIColor = .systemBackground,
        cornerRadius: CGFloat = 12,
        fontFamily: String? = nil,
        showBranding: Bool = true
    ) {
        self.primaryColor = primaryColor
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.fontFamily = fontFamily
        self.showBranding = showBranding
    }

    public static let `default` = SalmaTheme()

    public static let dark = SalmaTheme(
        primaryColor: UIColor(red: 26/255, green: 188/255, blue: 156/255, alpha: 1),
        backgroundColor: UIColor(red: 26/255, green: 26/255, blue: 46/255, alpha: 1)
    )

    public static let banking = SalmaTheme(
        primaryColor: UIColor(red: 25/255, green: 95/255, blue: 165/255, alpha: 1),
        showBranding: false
    )
}

// MARK: - Result

public enum SalmaResult {
    case approved(SalmaVerificationData)
    case rejected(SalmaRejectionData)
    case pending(SalmaPendingData)
    case cancelled
    case error(SalmaError)
}

public struct SalmaVerificationData {
    public let submissionId: String
    public let fullName: String?
    public let nationalId: String?
    public let dateOfBirth: String?
    public let gender: String?
    public let ocrConfidence: Double?
    public let rawResponse: [String: Any]?
}

public struct SalmaRejectionData {
    public let submissionId: String
    public let reason: String
    public let rawResponse: [String: Any]?
}

public struct SalmaPendingData {
    public let submissionId: String
    public let message: String
    public let estimatedWaitTime: String?
}

public struct SalmaConfigValidation {
    public let isValid: Bool
    public let issues: [String]
}

// MARK: - Errors

public enum SalmaError: LocalizedError {
    case configurationInvalid(String)
    case networkError(Error)
    case serverError(statusCode: Int, message: String)
    case noJourneyAvailable
    case cameraPermissionDenied
    case timeout
    case unknown(Error)

    public var errorDescription: String? {
        switch self {
        case .configurationInvalid(let msg): return "Configuration error: \(msg)"
        case .networkError(let err): return "Network error: \(err.localizedDescription)"
        case .serverError(_, let msg): return msg
        case .noJourneyAvailable: return "No verification journey is currently available"
        case .cameraPermissionDenied: return "Camera permission is required for identity verification"
        case .timeout: return "Request timed out"
        case .unknown(let err): return err.localizedDescription
        }
    }
}
