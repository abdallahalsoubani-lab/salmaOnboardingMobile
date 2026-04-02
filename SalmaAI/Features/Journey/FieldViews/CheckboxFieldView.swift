import SwiftUI

struct CheckboxFieldView: View {
    let field: PageField
    let label: String
    @Binding var value: String
    let errorMessage: String?

    @EnvironmentObject var languageManager: LanguageManager

    private var isChecked: Binding<Bool> {
        Binding(
            get: { value == "true" },
            set: { value = $0 ? "true" : "false" }
        )
    }

    var body: some View {
        let consentText = languageManager.localizedConsentText(for: field.validationRules) ?? label

        SalmaCheckbox(
            isChecked: isChecked,
            consentText: consentText,
            errorMessage: errorMessage,
            isRequired: field.isRequired
        )
    }
}
