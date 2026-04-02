import Foundation

protocol StorageServiceProtocol {
    var selectedLanguage: AppLanguage? { get set }
    var hasCompletedOnboarding: Bool { get set }
    var lastSubmissionId: String? { get set }
    var apiBaseURL: String { get set }
    func clearAll()
}
