import SwiftUI

@MainActor
class FormPageViewModel: ObservableObject {
    @Published var fieldErrors: [String: String] = [:]
    @Published var hasAttemptedNext: Bool = false
    @Published var shakeFieldId: String?

    let pageIndex: Int

    init(pageIndex: Int) {
        self.pageIndex = pageIndex
    }

    func validateBeforeNext(
        page: JourneyPage,
        fieldValues: [String: String],
        capturedImages: [String: CapturedImage],
        language: AppLanguage
    ) -> Bool {
        hasAttemptedNext = true

        let errors = PageValidator.validatePage(
            page: page,
            fieldValues: fieldValues,
            capturedImages: capturedImages,
            allFieldValues: fieldValues,
            language: language
        )

        fieldErrors = errors

        if let firstErrorFieldId = page.fields
            .sorted(by: { $0.order < $1.order })
            .first(where: { errors[$0.id] != nil })?.id {
            shakeFieldId = firstErrorFieldId
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.shakeFieldId = nil
            }
        }

        return errors.isEmpty
    }

    func validateField(
        field: PageField,
        value: String,
        capturedImage: CapturedImage?,
        language: AppLanguage
    ) {
        guard hasAttemptedNext else { return }

        let error = FieldValidator.validate(
            field: field, value: value,
            capturedImage: capturedImage, language: language
        )

        if let error = error {
            fieldErrors[field.id] = error
        } else {
            fieldErrors.removeValue(forKey: field.id)
        }
    }

    func clearErrors() {
        fieldErrors.removeAll()
        hasAttemptedNext = false
        shakeFieldId = nil
    }

    func error(for fieldId: String) -> String? {
        fieldErrors[fieldId]
    }
}
