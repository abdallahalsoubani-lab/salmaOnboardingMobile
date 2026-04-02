import SwiftUI

// Will be implemented in Prompt 12
public final class SalmaSDK {
    public static let shared = SalmaSDK()

    private init() {}

    public func startVerification(
        from viewController: UIViewController,
        completion: @escaping (Result<SubmissionResult, Error>) -> Void
    ) {
        // Will be implemented in Prompt 12
    }
}
