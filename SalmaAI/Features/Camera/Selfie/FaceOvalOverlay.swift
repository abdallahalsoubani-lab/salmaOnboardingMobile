import SwiftUI

struct FaceOvalOverlay: View {
    var faceDetected: Bool = false
    var faceInstruction: FaceInstruction = .none

    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height

            let ovalWidth = screenWidth * SalmaDesign.Camera.faceOvalWidthRatio
            let ovalHeight = ovalWidth / SalmaDesign.Camera.faceOvalAspectRatio
            let ovalCenter = CGPoint(x: screenWidth / 2, y: screenHeight / 2 - 60)
            let ovalRect = CGRect(
                x: ovalCenter.x - ovalWidth / 2,
                y: ovalCenter.y - ovalHeight / 2,
                width: ovalWidth,
                height: ovalHeight
            )

            ZStack {
                // Dimmed overlay with oval cutout
                OvalCutoutShape(ovalRect: ovalRect)
                    .fill(Color.black.opacity(SalmaDesign.Camera.overlayOpacity), style: FillStyle(eoFill: true))
                    .ignoresSafeArea()

                // Oval border
                Ellipse()
                    .stroke(
                        faceDetected ? faceInstruction.color : Color.white,
                        lineWidth: faceDetected ? 4 : 2.5
                    )
                    .frame(width: ovalWidth, height: ovalHeight)
                    .position(ovalCenter)
                    .animation(.easeInOut(duration: 0.3), value: faceDetected)
                    .animation(.easeInOut(duration: 0.3), value: faceInstruction)

                // Pulsing ring when ready
                if faceInstruction == .centered || faceInstruction == .holdStill {
                    Ellipse()
                        .stroke(faceInstruction.color.opacity(0.4), lineWidth: 2)
                        .frame(width: ovalWidth + 16, height: ovalHeight + 16)
                        .position(ovalCenter)
                }

                // Instruction text above oval
                Text(NSLocalizedString(faceInstruction.messageKey, bundle: .localized, comment: ""))
                    .font(SalmaDesign.Typography.bodyMedium)
                    .foregroundColor(faceInstruction.color)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(SalmaDesign.Radius.sm)
                    .position(x: screenWidth / 2, y: ovalRect.minY - 40)
                    .animation(.easeInOut(duration: 0.2), value: faceInstruction)

                // Face silhouette hint
                if !faceDetected {
                    Image(systemName: "person.crop.circle")
                        .font(.system(size: 60))
                        .foregroundColor(.white.opacity(0.1))
                        .position(ovalCenter)
                }
            }
        }
    }
}

enum FaceInstruction: Equatable {
    case none
    case moveCloser
    case moveBack
    case holdStill
    case centered

    var messageKey: String {
        switch self {
        case .none: return "selfie_instruction"
        case .moveCloser: return "selfie_move_closer"
        case .moveBack: return "selfie_move_back"
        case .holdStill: return "selfie_hold_still"
        case .centered: return "selfie_ready"
        }
    }

    var color: Color {
        switch self {
        case .none: return .white
        case .moveCloser, .moveBack: return SalmaDesign.Colors.warning
        case .holdStill: return SalmaDesign.Colors.info
        case .centered: return SalmaDesign.Colors.success
        }
    }
}

private struct OvalCutoutShape: Shape {
    let ovalRect: CGRect

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addRect(rect)
        path.addEllipse(in: ovalRect)
        return path
    }
}
