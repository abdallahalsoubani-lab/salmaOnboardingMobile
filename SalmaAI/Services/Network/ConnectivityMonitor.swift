import Network
import SwiftUI

@MainActor
class ConnectivityMonitor: ObservableObject {
    static let shared = ConnectivityMonitor()

    @Published var isConnected: Bool = true
    @Published var connectionType: NWInterface.InterfaceType?

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.salmaai.connectivity")

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.isConnected = path.status == .satisfied
                if path.usesInterfaceType(.wifi) {
                    self?.connectionType = .wifi
                } else if path.usesInterfaceType(.cellular) {
                    self?.connectionType = .cellular
                } else {
                    self?.connectionType = nil
                }
            }
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }

    var isWifi: Bool { connectionType == .wifi }
    var isCellular: Bool { connectionType == .cellular }
}
