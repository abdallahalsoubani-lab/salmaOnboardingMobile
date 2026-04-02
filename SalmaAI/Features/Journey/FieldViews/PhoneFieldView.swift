import SwiftUI

struct PhoneFieldView: View {
    let field: PageField
    let label: String
    let placeholder: String
    @Binding var value: String
    let errorMessage: String?

    var body: some View {
        let countryCode = field.validationRules?.countryCode ?? "+962"

        SalmaTextField(
            label: label,
            text: $value,
            placeholder: placeholder.isEmpty ? phonePlaceholder(for: countryCode) : placeholder,
            errorMessage: errorMessage,
            isRequired: field.isRequired,
            keyboardType: .phonePad,
            maxLength: field.validationRules?.maxLength,
            prefix: countryCode
        )
    }

    private func phonePlaceholder(for code: String) -> String {
        switch code {
        case "+962": return "07XXXXXXXX"
        case "+966": return "05XXXXXXXX"
        case "+971": return "05XXXXXXXX"
        case "+20": return "01XXXXXXXXX"
        default: return ""
        }
    }
}
