import SwiftUI

struct RejectedXMarkView: View {
    @State private var circleProgress: CGFloat = 0
    @State private var xProgress: CGFloat = 0
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let size: CGFloat
    let color: Color

    init(size: CGFloat = 120, color: Color = SalmaDesign.Colors.danger) {
        self.size = size
        self.color = color
    }

    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: circleProgress)
                .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))

            Circle()
                .fill(color.opacity(0.1))
                .frame(width: size, height: size)
                .opacity(circleProgress >= 1 ? 1 : 0)

            XMarkShape()
                .trim(from: 0, to: xProgress)
                .stroke(color, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .frame(width: size * 0.35, height: size * 0.35)
        }
        .scaleEffect(scale)
        .opacity(opacity)
        .onAppear {
            if reduceMotion {
                opacity = 1; scale = 1.0; circleProgress = 1.0; xProgress = 1.0
                return
            }
            withAnimation(.easeOut(duration: 0.3)) { opacity = 1; scale = 1.0 }
            withAnimation(.easeInOut(duration: 0.5).delay(0.2)) { circleProgress = 1.0 }
            withAnimation(.easeOut(duration: 0.3).delay(0.6)) { xProgress = 1.0 }
            withAnimation(.linear(duration: 0.05).delay(0.9)) { scale = 1.03 }
            withAnimation(.linear(duration: 0.05).delay(0.95)) { scale = 0.97 }
            withAnimation(.easeOut(duration: 0.1).delay(1.0)) { scale = 1.0 }
        }
    }
}

struct XMarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        return path
    }
}
