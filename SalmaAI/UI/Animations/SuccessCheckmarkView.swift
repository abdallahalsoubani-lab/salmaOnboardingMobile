import SwiftUI

struct SuccessCheckmarkView: View {
    @State private var circleProgress: CGFloat = 0
    @State private var checkmarkProgress: CGFloat = 0
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let size: CGFloat
    let color: Color

    init(size: CGFloat = 120, color: Color = SalmaDesign.Colors.success) {
        self.size = size
        self.color = color
    }

    var body: some View {
        ZStack {
            // Background circle (animated draw)
            Circle()
                .trim(from: 0, to: circleProgress)
                .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))

            // Filled circle (fade in after stroke)
            Circle()
                .fill(color.opacity(0.1))
                .frame(width: size, height: size)
                .opacity(circleProgress >= 1 ? 1 : 0)

            // Checkmark path (animated draw)
            CheckmarkShape()
                .trim(from: 0, to: checkmarkProgress)
                .stroke(color, style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                .frame(width: size * 0.45, height: size * 0.35)
        }
        .scaleEffect(scale)
        .opacity(opacity)
        .onAppear {
            if reduceMotion {
                opacity = 1; scale = 1.0; circleProgress = 1.0; checkmarkProgress = 1.0
                return
            }
            withAnimation(.easeOut(duration: 0.3)) {
                opacity = 1; scale = 1.0
            }
            withAnimation(.easeInOut(duration: 0.5).delay(0.2)) {
                circleProgress = 1.0
            }
            withAnimation(.easeOut(duration: 0.3).delay(0.6)) {
                checkmarkProgress = 1.0
            }
            withAnimation(AppAnimations.successPop.delay(0.9)) {
                scale = 1.05
            }
            withAnimation(.easeInOut(duration: 0.15).delay(1.1)) {
                scale = 1.0
            }
        }
    }
}

struct CheckmarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.width * 0.05, y: rect.height * 0.55))
        path.addLine(to: CGPoint(x: rect.width * 0.35, y: rect.height * 0.95))
        path.addLine(to: CGPoint(x: rect.width * 0.95, y: rect.height * 0.1))
        return path
    }
}
