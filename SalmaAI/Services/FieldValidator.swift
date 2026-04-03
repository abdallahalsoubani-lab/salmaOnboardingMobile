import Foundation

struct FieldValidator {

    static func validate(
        field: PageField,
        value: String,
        capturedImage: CapturedImage?,
        language: AppLanguage
    ) -> String? {
        let fieldType = FieldType(rawValue: field.type) ?? .text
        let rules = field.validationRules
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)

        // Required check
        if field.isRequired {
            if fieldType.isMediaField {
                if capturedImage == nil {
                    return loc("field_required", language)
                }
            } else if fieldType == .checkbox {
                if value != "true" {
                    return loc("checkbox_required", language)
                }
            } else {
                if trimmed.isEmpty {
                    return loc("field_required", language)
                }
            }
        }

        // Skip further validation if empty and not required
        if trimmed.isEmpty && !field.isRequired { return nil }

        switch fieldType {
        case .text:      return validateText(trimmed, rules: rules, language: language)
        case .phone:     return validatePhone(trimmed, rules: rules, language: language)
        case .email:     return validateEmail(trimmed, language: language)
        case .date:      return validateDate(trimmed, rules: rules, language: language)
        case .dropdown:  return validateDropdown(trimmed, options: field.options, language: language)
        case .photo, .idScan, .selfie:
            return validateImage(capturedImage, rules: rules, language: language)
        case .fileUpload:
            return validateFileUpload(capturedImage, rules: rules, language: language)
        case .signature, .checkbox:
            return nil
        }
    }

    // MARK: - Text

    private static func validateText(_ value: String, rules: ValidationRules?, language: AppLanguage) -> String? {
        guard let rules = rules else { return nil }

        if let min = rules.minLength, min > 0, value.count < min {
            let tpl = language == .arabic ? "الحد الأدنى %d حرف" : "Minimum %d characters"
            return String(format: tpl, min)
        }

        if let max = rules.maxLength, max > 0, value.count > max {
            let tpl = language == .arabic ? "الحد الأقصى %d حرف" : "Maximum %d characters"
            return String(format: tpl, max)
        }

        if let pattern = rules.regex, !pattern.isEmpty {
            return validateRegex(value, pattern: pattern, rules: rules, language: language)
        }

        return nil
    }

    // MARK: - Phone

    private static func validatePhone(_ value: String, rules: ValidationRules?, language: AppLanguage) -> String? {
        let cleaned = value.replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
        guard !cleaned.isEmpty else { return nil }

        if !cleaned.allSatisfy({ $0.isNumber }) {
            return loc("phone_digits_only", language)
        }

        if let rules = rules, let pattern = rules.regex, !pattern.isEmpty {
            return validateRegex(cleaned, pattern: pattern, rules: rules, language: language)
        }

        if cleaned.count < 7 {
            return loc("phone_too_short", language)
        }

        return nil
    }

    // MARK: - Email

    private static func validateEmail(_ value: String, language: AppLanguage) -> String? {
        guard !value.isEmpty else { return nil }
        let pattern = "^[\\w.-]+@[\\w.-]+\\.[a-zA-Z]{2,}$"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else { return nil }
        let range = NSRange(value.startIndex..., in: value)
        if regex.firstMatch(in: value, options: [], range: range) == nil {
            return loc("invalid_email", language)
        }
        return nil
    }

    // MARK: - Date

    private static func validateDate(_ value: String, rules: ValidationRules?, language: AppLanguage) -> String? {
        guard !value.isEmpty else { return nil }
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        guard let date = fmt.date(from: value) else {
            return loc("invalid_date", language)
        }

        let today = Calendar.current.startOfDay(for: Date())
        let selected = Calendar.current.startOfDay(for: date)

        if rules?.mustBePast == true && selected >= today {
            return loc("date_must_be_past", language)
        }
        if rules?.mustBeFuture == true && selected <= today {
            return loc("date_must_be_future", language)
        }

        if let minStr = rules?.minDate, let minDate = fmt.date(from: minStr), date < minDate {
            let formatted = formatDate(minDate, language: language)
            let tpl = language == .arabic ? "التاريخ يجب أن يكون بعد %@" : "Date must be after %@"
            return String(format: tpl, formatted)
        }
        if let maxStr = rules?.maxDate, let maxDate = fmt.date(from: maxStr), date > maxDate {
            let formatted = formatDate(maxDate, language: language)
            let tpl = language == .arabic ? "التاريخ يجب أن يكون قبل %@" : "Date must be before %@"
            return String(format: tpl, formatted)
        }

        return nil
    }

    // MARK: - Dropdown

    private static func validateDropdown(_ value: String, options: [String]?, language: AppLanguage) -> String? {
        guard !value.isEmpty else { return nil }
        if let options = options, !options.contains(value) {
            return loc("invalid_selection", language)
        }
        return nil
    }

    // MARK: - Image

    private static func validateImage(_ captured: CapturedImage?, rules: ValidationRules?, language: AppLanguage) -> String? {
        guard let captured = captured else { return nil }
        if let maxMB = rules?.maxFileSizeMB {
            let sizeMB = Double(captured.imageData.count) / (1024.0 * 1024.0)
            if sizeMB > Double(maxMB) {
                let tpl = language == .arabic ? "حجم الملف يتجاوز الحد الأقصى (%d ميجابايت)" : "File size exceeds limit (%d MB)"
                return String(format: tpl, maxMB)
            }
        }
        return nil
    }

    // MARK: - FileUpload

    private static func validateFileUpload(_ captured: CapturedImage?, rules: ValidationRules?, language: AppLanguage) -> String? {
        guard let captured = captured else { return nil }
        let maxMB = rules?.maxFileSizeMB ?? SalmaDesign.FileUpload.defaultMaxSizeMB
        let sizeMB = Double(captured.imageData.count) / (1024.0 * 1024.0)
        if sizeMB > Double(maxMB) {
            let tpl = language == .arabic ? "حجم الملف يتجاوز الحد الأقصى (%d ميجابايت)" : "File size exceeds limit (%d MB)"
            return String(format: tpl, maxMB)
        }
        return nil
    }

    // MARK: - Regex

    private static func validateRegex(_ value: String, pattern: String, rules: ValidationRules?, language: AppLanguage) -> String? {
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let range = NSRange(value.startIndex..., in: value)
            if regex.firstMatch(in: value, options: [], range: range) == nil {
                if language == .arabic {
                    return rules?.regexErrorAr ?? loc("invalid_format", language)
                } else {
                    return rules?.regexError ?? loc("invalid_format", language)
                }
            }
        } catch {
            return nil // Invalid regex pattern — don't block user
        }
        return nil
    }

    // MARK: - Helpers

    private static func loc(_ key: String, _ language: AppLanguage) -> String {
        NSLocalizedString(key, bundle: .localized, comment: "")
    }

    private static func formatDate(_ date: Date, language: AppLanguage) -> String {
        let fmt = DateFormatter()
        fmt.locale = language.locale
        fmt.dateStyle = .medium
        return fmt.string(from: date)
    }
}
