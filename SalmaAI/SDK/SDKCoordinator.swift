import SwiftUI
import UIKit

class SDKCoordinator {
    let config: SalmaConfig
    let completion: (SalmaResult) -> Void
    private var hostingController: UIHostingController<AnyView>?

    init(config: SalmaConfig, completion: @escaping (SalmaResult) -> Void) {
        self.config = config
        self.completion = completion
    }

    func present(from viewController: UIViewController) {
        SDKConfigManager.shared.apply(config)

        let sdkView = SDKContainerView(config: config) { [weak self] result in
            self?.hostingController?.dismiss(animated: true) {
                self?.completion(result)
            }
        }

        let hosting = UIHostingController(rootView: AnyView(sdkView))
        hosting.modalPresentationStyle = .fullScreen
        hosting.modalTransitionStyle = .coverVertical
        self.hostingController = hosting
        viewController.present(hosting, animated: true)
    }
}
