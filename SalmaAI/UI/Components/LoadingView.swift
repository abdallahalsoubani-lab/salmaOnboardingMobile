import SwiftUI

struct LoadingView: View {
    var message: String?
    var size: LoadingSize = .medium

    var body: some View {
        VStack(spacing: SalmaDesign.Spacing.md) {
            PulsingDots(size: size)

            if let msg = message, !msg.isEmpty {
                Text(msg)
                    .font(SalmaDesign.Typography.callout)
                    .foregroundColor(SalmaDesign.Colors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(SalmaDesign.Colors.background)
    }
}

enum LoadingSize {
    case small, medium, large

    var dotSize: CGFloat {
        switch self {
        case .small: return 6
        case .medium: return 10
        case .large: return 14
        }
    }

    var spacing: CGFloat {
        switch self {
        case .small: return 4
        case .medium: return 6
        case .large: return 8
        }
    }
}

private struct PulsingDots: View {
    let size: LoadingSize
    @State private var scales: [CGFloat] = [0.6, 0.6, 0.6]

    var body: some View {
        HStack(spacing: size.spacing) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(SalmaDesign.Colors.primary)
                    .frame(width: size.dotSize, height: size.dotSize)
                    .scaleEffect(scales[index])
            }
        }
        .onAppear {
            for i in 0..<3 {
                withAnimation(
                    .easeInOut(duration: 0.6)
                    .repeatForever(autoreverses: true)
                    .delay(Double(i) * 0.15)
                ) {
                    scales[i] = 1.0
                }
            }
        }
    }
}
