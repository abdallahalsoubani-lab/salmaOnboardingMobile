import SwiftUI

struct IDCardOverlay: View {
    let side: IDSide

    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height

            let frameWidth = screenWidth * SalmaDesign.Camera.idCardFrameWidthRatio
            let frameHeight = frameWidth / SalmaDesign.Camera.idCardAspectRatio
            let frameX = (screenWidth - frameWidth) / 2
            let frameY = (screenHeight - frameHeight) / 2 - 40
            let frameRect = CGRect(x: frameX, y: frameY, width: frameWidth, height: frameHeight)

            ZStack {
                // Dimmed overlay with cutout
                IDCardCutoutShape(cutoutRect: frameRect, cornerRadius: 16)
                    .fill(Color.black.opacity(SalmaDesign.Camera.overlayOpacity), style: FillStyle(eoFill: true))
                    .ignoresSafeArea()

                // Frame border
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white, lineWidth: 3)
                    .frame(width: frameWidth, height: frameHeight)
                    .position(x: frameRect.midX, y: frameRect.midY)

                // Corner accents
                CornerAccents(rect: frameRect, lineLength: 30, lineWidth: 4, color: SalmaDesign.Colors.primary)

                // Instruction text above frame
                VStack(spacing: 8) {
                    Text(L("id_frame_instruction"))
                        .font(SalmaDesign.Typography.bodyMedium)
                        .foregroundColor(.white)

                    Text(side == .front
                         ? L("front_side")
                         : L("back_side"))
                        .font(SalmaDesign.Typography.title2)
                        .foregroundColor(SalmaDesign.Colors.primary)
                }
                .position(x: screenWidth / 2, y: frameY - 50)

                // Side indicator dots
                HStack(spacing: 8) {
                    Circle()
                        .fill(side == .front ? SalmaDesign.Colors.primary : Color.white.opacity(0.3))
                        .frame(width: 10, height: 10)
                    Circle()
                        .fill(side == .back ? SalmaDesign.Colors.primary : Color.white.opacity(0.3))
                        .frame(width: 10, height: 10)
                }
                .position(x: screenWidth / 2, y: frameRect.maxY + 30)

                // Scanning line
                ScanningLineView(frameHeight: frameHeight)
                    .frame(width: frameWidth - 8)
                    .position(x: frameRect.midX, y: frameRect.midY)
                    .clipped()

                // Subtle ID hint
                Image(systemName: "creditcard")
                    .font(.system(size: 40))
                    .foregroundColor(.white.opacity(0.12))
                    .position(x: frameRect.midX, y: frameRect.midY)
            }
        }
    }
}

// Full screen with rounded-rect cutout (even-odd fill for iOS 16 compat)
private struct IDCardCutoutShape: Shape {
    let cutoutRect: CGRect
    let cornerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addRect(rect)
        path.addRoundedRect(in: cutoutRect, cornerSize: CGSize(width: cornerRadius, height: cornerRadius))
        return path
    }
}

// L-shaped corner accents
struct CornerAccents: View {
    let rect: CGRect
    let lineLength: CGFloat
    let lineWidth: CGFloat
    let color: Color

    var body: some View {
        Canvas { context, _ in
            let corners: [(CGPoint, CGFloat, CGFloat)] = [
                (CGPoint(x: rect.minX, y: rect.minY), 1, 1),
                (CGPoint(x: rect.maxX, y: rect.minY), -1, 1),
                (CGPoint(x: rect.minX, y: rect.maxY), 1, -1),
                (CGPoint(x: rect.maxX, y: rect.maxY), -1, -1),
            ]

            for (point, hDir, vDir) in corners {
                var hPath = Path()
                hPath.move(to: point)
                hPath.addLine(to: CGPoint(x: point.x + lineLength * hDir, y: point.y))
                context.stroke(hPath, with: .color(color), lineWidth: lineWidth)

                var vPath = Path()
                vPath.move(to: point)
                vPath.addLine(to: CGPoint(x: point.x, y: point.y + lineLength * vDir))
                context.stroke(vPath, with: .color(color), lineWidth: lineWidth)
            }
        }
    }
}

struct ScanningLineView: View {
    let frameHeight: CGFloat
    @State private var offset: CGFloat = 0

    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [.clear, SalmaDesign.Colors.primary.opacity(0.4), .clear],
                    startPoint: .leading, endPoint: .trailing
                )
            )
            .frame(height: 2)
            .offset(y: offset - frameHeight / 2)
            .onAppear {
                withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: true)) {
                    offset = frameHeight
                }
            }
    }
}
