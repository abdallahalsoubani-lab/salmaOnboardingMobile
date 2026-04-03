import SwiftUI

struct CameraBottomBar: View {
    let onCapture: () -> Void
    var onTorchToggle: (() -> Void)?
    let onClose: () -> Void
    var isTorchOn: Bool = false
    var isCapturing: Bool = false

    var body: some View {
        HStack {
            // Close button
            Button(action: onClose) {
                Circle()
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    )
            }
            .accessibilityLabel(L("close_camera"))

            Spacer()

            // Capture button
            Button(action: {
                guard !isCapturing else { return }
                onCapture()
            }) {
                ZStack {
                    Circle()
                        .stroke(Color.white, lineWidth: 4)
                        .frame(width: 72, height: 72)

                    if isCapturing {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(1.2)
                    } else {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 60, height: 60)
                    }
                }
            }
            .pressAnimation()
            .accessibilityLabel(L("capture"))

            Spacer()

            // Torch button (or spacer)
            if let torchToggle = onTorchToggle {
                Button(action: torchToggle) {
                    Circle()
                        .fill(isTorchOn ? Color.white : Color.clear)
                        .frame(width: 44, height: 44)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                        .overlay(
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 16))
                                .foregroundColor(isTorchOn ? .yellow : .white)
                        )
                }
                .accessibilityLabel(isTorchOn ? L("torch_on") : L("torch_off"))
            } else {
                Color.clear.frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal, SalmaDesign.Spacing.xl)
        .padding(.vertical, SalmaDesign.Spacing.lg)
        .padding(.bottom, SalmaDesign.Spacing.md)
        .background(
            LinearGradient(
                colors: [.clear, .black.opacity(0.8)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}
