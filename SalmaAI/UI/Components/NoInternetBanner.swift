import SwiftUI

struct NoInternetBanner: View {
    @EnvironmentObject var connectivity: ConnectivityMonitor

    var body: some View {
        if !connectivity.isConnected {
            HStack(spacing: 8) {
                Image(systemName: "wifi.slash")
                    .font(.system(size: 14))
                Text(L("no_internet_error"))
                    .font(SalmaDesign.Typography.caption)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(SalmaDesign.Colors.danger)
            .transition(.move(edge: .top).combined(with: .opacity))
            .animation(AppAnimations.stateChange, value: connectivity.isConnected)
        }
    }
}
