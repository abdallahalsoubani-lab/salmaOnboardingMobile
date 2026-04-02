import Foundation

struct ValidationSummary {

    struct PageSummary {
        let pageIndex: Int
        let pageTitle: String
        let isValid: Bool
        let errorCount: Int
        let errors: [FieldError]
    }

    struct FieldError {
        let fieldId: String
        let fieldLabel: String
        let errorMessage: String
    }

    static func generate(
        journey: JourneyDetail,
        fieldValues: [String: String],
        capturedImages: [String: CapturedImage],
        language: AppLanguage
    ) -> [PageSummary] {
        journey.pages.sorted(by: { $0.order < $1.order }).enumerated().map { index, page in
            let errors = PageValidator.validatePage(
                page: page, fieldValues: fieldValues,
                capturedImages: capturedImages, allFieldValues: fieldValues,
                language: language
            )

            let fieldErrors = errors.map { fieldId, message -> FieldError in
                let field = page.fields.first { $0.id == fieldId }
                let label = language == .arabic ? (field?.labelAr ?? fieldId) : (field?.label ?? fieldId)
                return FieldError(fieldId: fieldId, fieldLabel: label, errorMessage: message)
            }

            let title = language == .arabic ? page.titleAr : page.title

            return PageSummary(
                pageIndex: index,
                pageTitle: title,
                isValid: errors.isEmpty,
                errorCount: errors.count,
                errors: fieldErrors
            )
        }
    }

    static func isValid(summary: [PageSummary]) -> Bool {
        summary.allSatisfy { $0.isValid }
    }
}
