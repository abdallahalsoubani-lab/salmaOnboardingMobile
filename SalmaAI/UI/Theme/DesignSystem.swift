import SwiftUI

struct SalmaDesign {

    // MARK: - Colors
    struct Colors {
        static let primary = Color("Primary")
        static let primaryDark = Color("PrimaryDark")
        static let primaryLight = Color("PrimaryLight")

        static let background = Color("Background")
        static let backgroundSecondary = Color("BackgroundSecondary")
        static let surface = Color("Surface")

        static let textPrimary = Color("TextPrimary")
        static let textSecondary = Color("TextSecondary")
        static let textTertiary = Color("TextTertiary")

        static let success = Color("Success")
        static let danger = Color("Danger")
        static let warning = Color("Warning")
        static let info = Color("Info")

        static let border = Color("Border")
        static let divider = Color("Divider")

        static let cameraOverlay = Color.black.opacity(0.6)
    }

    // MARK: - Typography
    struct Typography {
        static let largeTitle = Font.system(size: 28, weight: .bold)
        static let title1 = Font.system(size: 22, weight: .bold)
        static let title2 = Font.system(size: 18, weight: .semibold)
        static let title3 = Font.system(size: 16, weight: .semibold)
        static let body = Font.system(size: 16, weight: .regular)
        static let bodyMedium = Font.system(size: 16, weight: .medium)
        static let callout = Font.system(size: 14, weight: .regular)
        static let caption = Font.system(size: 12, weight: .regular)
        static let captionMedium = Font.system(size: 12, weight: .medium)
        static let small = Font.system(size: 10, weight: .regular)
    }

    // MARK: - Spacing
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }

    // MARK: - Radius
    struct Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let full: CGFloat = 9999
    }

    // MARK: - Shadows
    struct Shadows {
        static let card = ShadowStyle(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
        static let button = ShadowStyle(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }

    // MARK: - Camera
    struct Camera {
        static let idCardAspectRatio: CGFloat = 85.6 / 54.0
        static let idCardFrameWidthRatio: CGFloat = 0.85
        static let faceOvalWidthRatio: CGFloat = 0.6
        static let faceOvalAspectRatio: CGFloat = 3.0 / 4.0
        static let overlayOpacity: Double = 0.6
    }

    // MARK: - File Upload
    struct FileUpload {
        static let defaultMaxSizeMB: Int = 20
        static let imageMaxSizeMB: Int = 10
        static let allowedImageFormats = ["jpg", "jpeg", "png", "webp"]
        static let allowedDocFormats = ["pdf", "doc", "docx"]
        static let allAllowedFormats = ["jpg", "jpeg", "png", "webp", "pdf", "doc", "docx"]
    }
}

struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}
