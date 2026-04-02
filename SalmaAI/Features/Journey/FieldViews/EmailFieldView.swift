import SwiftUI

struct EmailFieldView: View {
    let field: PageField
    let label: String
    let placeholder: String
    @Binding var value: String
    let errorMessage: String?

    var body: some View {
        SalmaTextField(
            label: label,
            text: $value,
            placeholder: placeholder.isEmpty ? "email@example.com" : placeholder,
            errorMessage: errorMessage,
            isRequired: field.isRequired,
            keyboardType: .emailAddress
        )
        .environment(\.layoutDirection, .leftToRight)
    }
}
