import Foundation

enum Route: Hashable {
    // Stage 1
    case languageSelection

    // Stage 2
    case journeyLoading

    // Stage 3
    case formPage(pageIndex: Int)

    // Stage 4
    case review
    case submitting

    // Stage 5
    case result
}

enum IDSide: String, Hashable, Codable {
    case front
    case back

    var displayNameAr: String {
        switch self {
        case .front: return "الوجه الأمامي"
        case .back: return "الوجه الخلفي"
        }
    }

    var displayNameEn: String {
        switch self {
        case .front: return "Front Side"
        case .back: return "Back Side"
        }
    }
}

// Sheet routes (presented as sheets)
enum SheetRoute: Identifiable, Hashable {
    case languageSwitch
    case fieldInfo(field: String)

    var id: String {
        switch self {
        case .languageSwitch: return "languageSwitch"
        case .fieldInfo(let field): return "fieldInfo_\(field)"
        }
    }
}

// Full screen routes (camera, signature, preview)
enum FullScreenRoute: Identifiable {
    case idCapture(fieldId: String, side: IDSide)
    case selfieCapture(fieldId: String)
    case livenessCheck(fieldId: String)
    case photoCapture(fieldId: String)
    case signaturePad(fieldId: String)
    case imagePreview(fieldId: String, imageData: Data)

    var id: String {
        switch self {
        case .idCapture(let id, let side): return "idCapture_\(id)_\(side.rawValue)"
        case .selfieCapture(let id): return "selfie_\(id)"
        case .livenessCheck(let id): return "liveness_\(id)"
        case .photoCapture(let id): return "photo_\(id)"
        case .signaturePad(let id): return "signature_\(id)"
        case .imagePreview(let id, _): return "preview_\(id)"
        }
    }
}

extension FullScreenRoute: Equatable {
    static func == (lhs: FullScreenRoute, rhs: FullScreenRoute) -> Bool {
        lhs.id == rhs.id
    }
}

extension FullScreenRoute: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
