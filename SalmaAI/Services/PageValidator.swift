import Foundation

struct PageValidator {

    static func validatePage(
        page: JourneyPage,
        fieldValues: [String: String],
        capturedImages: [String: CapturedImage],
        allFieldValues: [String: String],
        language: AppLanguage
    ) -> [String: String] {
        var errors: [String: String] = [:]

        for field in page.fields.sorted(by: { $0.order < $1.order }) {
            if !isFieldVisible(field, allFieldValues: allFieldValues) {
                continue
            }

            let value = fieldValues[field.id] ?? ""
            let captured = capturedImages[field.id]

            if let error = FieldValidator.validate(
                field: field, value: value, capturedImage: captured, language: language
            ) {
                errors[field.id] = error
            }
        }

        return errors
    }

    static func isFieldVisible(_ field: PageField, allFieldValues: [String: String]) -> Bool {
        guard let condition = field.validationRules?.condition else { return true }
        let watchedValue = allFieldValues[condition.field] ?? ""

        switch condition.operator {
        case "equals":     return watchedValue == (condition.value ?? "")
        case "not_equals": return watchedValue != (condition.value ?? "")
        case "contains":   return watchedValue.localizedCaseInsensitiveContains(condition.value ?? "")
        case "not_empty":  return !watchedValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        default:           return true
        }
    }

    static func validateAllPages(
        journey: JourneyDetail,
        fieldValues: [String: String],
        capturedImages: [String: CapturedImage],
        language: AppLanguage
    ) -> [String: String] {
        var allErrors: [String: String] = [:]
        for page in journey.pages.sorted(by: { $0.order < $1.order }) {
            let pageErrors = validatePage(
                page: page, fieldValues: fieldValues,
                capturedImages: capturedImages, allFieldValues: fieldValues,
                language: language
            )
            allErrors.merge(pageErrors) { _, new in new }
        }
        return allErrors
    }

    static func firstPageWithErrors(
        journey: JourneyDetail,
        fieldValues: [String: String],
        capturedImages: [String: CapturedImage],
        language: AppLanguage
    ) -> Int? {
        for (index, page) in journey.pages.sorted(by: { $0.order < $1.order }).enumerated() {
            let errors = validatePage(
                page: page, fieldValues: fieldValues,
                capturedImages: capturedImages, allFieldValues: fieldValues,
                language: language
            )
            if !errors.isEmpty { return index }
        }
        return nil
    }
}
