import SwiftUI

struct TextFieldView: View {
    let field: PageField
    let label: String
    let placeholder: String
    @Binding var value: String
    let errorMessage: String?

    var body: some View {
        SalmaTextField(
            label: label,
            text: $value,
            placeholder: placeholder,
            errorMessage: errorMessage,
            isRequired: field.isRequired,
            keyboardType: .default,
            maxLength: field.validationRules?.maxLength
        )
    }
}
