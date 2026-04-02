import SwiftUI

enum FieldType: String, Codable, CaseIterable {
    case text = "Text"
    case phone = "Phone"
    case email = "Email"
    case date = "Date"
    case dropdown = "Dropdown"
    case photo = "Photo"
    case idScan = "IdScan"
    case selfie = "Selfie"
    case signature = "Signature"
    case checkbox = "Checkbox"
    case fileUpload = "FileUpload"

    var isMediaField: Bool {
        switch self {
        case .photo, .idScan, .selfie, .signature, .fileUpload:
            return true
        default:
            return false
        }
    }

    var isCameraCapable: Bool {
        switch self {
        case .photo, .idScan, .selfie:
            return true
        default:
            return false
        }
    }

    var isFilePicker: Bool {
        self == .fileUpload
    }

    var isCamera: Bool {
        switch self {
        case .photo, .idScan, .selfie:
            return true
        default:
            return false
        }
    }

    func captureSource(sourceType: String?) -> CaptureSource {
        switch self {
        case .fileUpload:
            return .galleryOnly
        case .photo, .idScan, .selfie:
            switch sourceType {
            case "camera": return .cameraOnly
            case "gallery": return .galleryOnly
            default: return .cameraAndGallery
            }
        default:
            return .none
        }
    }

    var displayNameAr: String {
        switch self {
        case .text: return "نص"
        case .phone: return "هاتف"
        case .email: return "بريد إلكتروني"
        case .date: return "تاريخ"
        case .dropdown: return "قائمة"
        case .photo: return "صورة"
        case .idScan: return "هوية"
        case .selfie: return "سيلفي"
        case .signature: return "توقيع"
        case .checkbox: return "موافقة"
        case .fileUpload: return "رفع ملف"
        }
    }

    var displayNameEn: String {
        switch self {
        case .text: return "Text"
        case .phone: return "Phone"
        case .email: return "Email"
        case .date: return "Date"
        case .dropdown: return "Dropdown"
        case .photo: return "Photo"
        case .idScan: return "ID Scan"
        case .selfie: return "Selfie"
        case .signature: return "Signature"
        case .checkbox: return "Consent"
        case .fileUpload: return "File Upload"
        }
    }

    var iconName: String {
        switch self {
        case .text: return "textformat"
        case .phone: return "phone"
        case .email: return "envelope"
        case .date: return "calendar"
        case .dropdown: return "chevron.down.circle"
        case .photo: return "camera"
        case .idScan: return "creditcard"
        case .selfie: return "person.crop.circle"
        case .signature: return "pencil.tip"
        case .checkbox: return "checkmark.square"
        case .fileUpload: return "paperclip"
        }
    }
}

enum CaptureSource: Equatable {
    case cameraOnly
    case galleryOnly
    case cameraAndGallery
    case none
}

enum AppLanguage: String, Codable {
    case arabic = "ar"
    case english = "en"

    var layoutDirection: LayoutDirection {
        self == .arabic ? .rightToLeft : .leftToRight
    }

    var locale: Locale {
        Locale(identifier: rawValue)
    }
}
