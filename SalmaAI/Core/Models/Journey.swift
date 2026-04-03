import Foundation

struct JourneyDetail: Codable, Identifiable {
    let id: String
    let name: String
    let description: String?
    let version: Int
    let status: String
    let pages: [JourneyPage]
    let businessRules: [BusinessRule]
}

struct JourneyPage: Codable, Identifiable {
    let id: String
    let title: String
    let titleAr: String
    let order: Int
    let fields: [PageField]
}

struct PageField: Codable, Identifiable {
    let id: String
    let type: String
    let label: String
    let labelAr: String
    let placeholder: String?
    let placeholderAr: String?
    let isRequired: Bool
    let order: Int
    let validationRules: ValidationRules?
    let options: [String]?
}

struct ValidationRules: Codable {
    // Text fields
    let minLength: Int?
    let maxLength: Int?
    let regex: String?
    let regexError: String?
    let regexErrorAr: String?

    // Date fields
    let mustBePast: Bool?
    let mustBeFuture: Bool?
    let minDate: String?
    let maxDate: String?

    // Phone fields
    let countryCode: String?

    // Image/File fields (Photo, IdScan, Selfie, FileUpload)
    let maxFileSizeMB: Int?
    let acceptedFormats: [String]?
    let sourceType: String?

    // FileUpload specific
    let allowMultiple: Bool?

    // Checkbox fields
    let consentTextAr: String?
    let consentTextEn: String?

    // Terms & Conditions
    let terms: TermsConfig?

    // Conditional display
    let condition: FieldCondition?
}

struct TermsConfig: Codable {
    let isTermsField: Bool?
    let contentType: String?
    let contentAr: String?
    let contentEn: String?
    let url: String?
    let mustScrollToBottom: Bool?
    let linkTextAr: String?
    let linkTextEn: String?
}

struct FieldCondition: Codable {
    let field: String
    let `operator`: String
    let value: String?
}

struct BusinessRule: Codable, Identifiable {
    let id: String
    let ruleName: String
    let ruleType: String
    let condition: RuleCondition
    let action: RuleAction
    let isActive: Bool
}

struct RuleCondition: Codable {
    let field: String
    let `operator`: String
    let value: AnyCodableValue?
}

struct RuleAction: Codable {
    let message: String?
    let messageAr: String?
}

enum AnyCodableValue: Codable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intVal = try? container.decode(Int.self) {
            self = .int(intVal)
            return
        }
        if let doubleVal = try? container.decode(Double.self) {
            self = .double(doubleVal)
            return
        }
        if let boolVal = try? container.decode(Bool.self) {
            self = .bool(boolVal)
            return
        }
        if let stringVal = try? container.decode(String.self) {
            self = .string(stringVal)
            return
        }
        throw DecodingError.typeMismatch(
            AnyCodableValue.self,
            .init(codingPath: decoder.codingPath, debugDescription: "Unsupported type")
        )
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let v): try container.encode(v)
        case .int(let v): try container.encode(v)
        case .double(let v): try container.encode(v)
        case .bool(let v): try container.encode(v)
        }
    }

    var intValue: Int? {
        if case .int(let v) = self { return v }
        return nil
    }

    var stringValue: String? {
        if case .string(let v) = self { return v }
        return nil
    }

    var doubleValue: Double? {
        if case .double(let v) = self { return v }
        return nil
    }

    var boolValue: Bool? {
        if case .bool(let v) = self { return v }
        return nil
    }
}
