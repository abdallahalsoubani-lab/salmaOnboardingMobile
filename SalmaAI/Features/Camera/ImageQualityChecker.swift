import CoreImage
import UIKit

struct ImageQualityChecker {

    struct QualityResult {
        let isAcceptable: Bool
        let brightness: Double
        let sharpness: Double
        let issues: [QualityIssue]
    }

    enum QualityIssue {
        case tooDark
        case tooBright
        case blurry

        var messageKey: String {
            switch self {
            case .tooDark: return "image_too_dark"
            case .tooBright: return "image_too_bright"
            case .blurry: return "image_blurry"
            }
        }
    }

    static func check(_ image: UIImage) -> QualityResult {
        guard let ciImage = CIImage(image: image) else {
            return QualityResult(isAcceptable: true, brightness: 0.5, sharpness: 0.5, issues: [])
        }

        var issues: [QualityIssue] = []

        let brightness = calculateBrightness(ciImage)
        if brightness < 0.15 { issues.append(.tooDark) }
        if brightness > 0.9 { issues.append(.tooBright) }

        let sharpness = calculateSharpness(ciImage)
        if sharpness < 0.02 { issues.append(.blurry) }

        return QualityResult(
            isAcceptable: issues.isEmpty,
            brightness: brightness,
            sharpness: sharpness,
            issues: issues
        )
    }

    private static func calculateBrightness(_ image: CIImage) -> Double {
        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [
            kCIInputImageKey: image,
            kCIInputExtentKey: CIVector(cgRect: image.extent)
        ]), let output = filter.outputImage else { return 0.5 }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext()
        context.render(
            output, toBitmap: &bitmap, rowBytes: 4,
            bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
            format: .RGBA8, colorSpace: CGColorSpaceCreateDeviceRGB()
        )

        let r = Double(bitmap[0]) / 255.0
        let g = Double(bitmap[1]) / 255.0
        let b = Double(bitmap[2]) / 255.0
        return (r + g + b) / 3.0
    }

    private static func calculateSharpness(_ image: CIImage) -> Double {
        guard let edgeFilter = CIFilter(name: "CIEdges") else { return 0.5 }
        edgeFilter.setValue(image, forKey: kCIInputImageKey)
        edgeFilter.setValue(5.0, forKey: kCIInputIntensityKey)

        guard let edgeImage = edgeFilter.outputImage,
              let avgFilter = CIFilter(name: "CIAreaAverage", parameters: [
                  kCIInputImageKey: edgeImage,
                  kCIInputExtentKey: CIVector(cgRect: edgeImage.extent)
              ]),
              let output = avgFilter.outputImage else { return 0.5 }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext()
        context.render(
            output, toBitmap: &bitmap, rowBytes: 4,
            bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
            format: .RGBA8, colorSpace: CGColorSpaceCreateDeviceRGB()
        )

        return Double(bitmap[0]) / 255.0
    }
}
