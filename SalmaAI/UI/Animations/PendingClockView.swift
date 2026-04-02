import SwiftUI

struct PendingClockView: View {
    @State private var handRotation: Double = 0
    @State private var opacity: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let size: CGFloat
    let color: Color

    init(size: CGFloat = 120, color: Color = SalmaDesign.Colors.warning) {
        self.size = size
        self.color = color
    }

    var body: some View {
        ZStack {
            // Pulse ring
            Circle()
                .fill(color.opacity(0.08))
                .frame(width: size * 1.3, height: size * 1.3)
                .scaleEffect(pulseScale)

            Circle()
                .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .frame(width: size, height: size)

            Circle()
                .fill(color.opacity(0.1))
                .frame(width: size, height: size)

            // Clock hand
            VStack(spacing: 0) {
                Rectangle()
                    .fill(color)
                    .frame(width: 3, height: size * 0.25)
            }
            .rotationEffect(.degrees(handRotation))

            // Center dot
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
        }
        .opacity(opacity)
        .onAppear {
            if reduceMotion {
                opacity = 1
                return
            }
            withAnimation(.easeOut(duration: 0.3)) { opacity = 1 }
            withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
                handRotation = 360
            }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                pulseScale = 1.08
            }
        }
    }
}
