import SwiftUI
import UIKit

struct SalmaSignaturePad: View {
    @Binding var signatureImage: UIImage?
    var lineColor: Color = SalmaDesign.Colors.textPrimary
    var lineWidth: CGFloat = 3.0
    var backgroundColor: Color = SalmaDesign.Colors.backgroundSecondary

    @State private var canvasView = SignatureCanvasView()

    var body: some View {
        VStack(spacing: SalmaDesign.Spacing.sm) {
            // Canvas
            SignatureCanvasRepresentable(
                canvasView: canvasView,
                lineColor: UIColor(lineColor),
                lineWidth: lineWidth,
                bgColor: UIColor(backgroundColor)
            )
            .frame(height: 200)
            .cornerRadius(SalmaDesign.Radius.md)
            .overlay(
                RoundedRectangle(cornerRadius: SalmaDesign.Radius.md)
                    .stroke(SalmaDesign.Colors.border, lineWidth: 1)
            )
            .overlay(alignment: .center) {
                if canvasView.isEmpty {
                    Text(L("sign_here"))
                        .font(SalmaDesign.Typography.callout)
                        .foregroundColor(SalmaDesign.Colors.textTertiary)
                        .allowsHitTesting(false)
                }
            }

            // Buttons
            HStack(spacing: SalmaDesign.Spacing.md) {
                SalmaButton(
                    title: L("clear_signature"),
                    style: .ghost,
                    size: .small
                ) {
                    canvasView.clear()
                }

                SalmaButton(
                    title: L("done"),
                    size: .small
                ) {
                    signatureImage = canvasView.exportImage()
                }
            }
        }
    }
}

// MARK: - UIKit Canvas

class SignatureCanvasView: UIView {
    private var paths: [(UIBezierPath, UIColor, CGFloat)] = []
    private var currentPath: UIBezierPath?
    private var strokeColor: UIColor = .black
    private var strokeWidth: CGFloat = 3.0
    private var lastPoint: CGPoint?

    var isEmpty: Bool { paths.isEmpty && currentPath == nil }

    override func draw(_ rect: CGRect) {
        for (path, color, _) in paths {
            color.setStroke()
            path.stroke()
        }
        if let current = currentPath {
            strokeColor.setStroke()
            current.stroke()
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }
        let path = UIBezierPath()
        path.lineWidth = strokeWidth
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        path.move(to: point)
        currentPath = path
        lastPoint = point
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self),
              let last = lastPoint,
              let current = currentPath else { return }
        let mid = CGPoint(x: (last.x + point.x) / 2, y: (last.y + point.y) / 2)
        current.addQuadCurve(to: mid, controlPoint: last)
        lastPoint = point
        setNeedsDisplay()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let current = currentPath {
            paths.append((current, strokeColor, strokeWidth))
        }
        currentPath = nil
        lastPoint = nil
        setNeedsDisplay()
    }

    func configure(color: UIColor, width: CGFloat, bg: UIColor) {
        strokeColor = color
        strokeWidth = width
        backgroundColor = bg
    }

    func clear() {
        paths.removeAll()
        currentPath = nil
        lastPoint = nil
        setNeedsDisplay()
    }

    func exportImage() -> UIImage? {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { ctx in
            layer.render(in: ctx.cgContext)
        }
    }
}

struct SignatureCanvasRepresentable: UIViewRepresentable {
    let canvasView: SignatureCanvasView
    let lineColor: UIColor
    let lineWidth: CGFloat
    let bgColor: UIColor

    func makeUIView(context: Context) -> SignatureCanvasView {
        canvasView.configure(color: lineColor, width: lineWidth, bg: bgColor)
        return canvasView
    }

    func updateUIView(_ uiView: SignatureCanvasView, context: Context) {}
}
