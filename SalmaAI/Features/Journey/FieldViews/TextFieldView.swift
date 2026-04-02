import SwiftUI

// Will be implemented in Prompt 6
struct TextFieldView: View {
    let field: PageField
    @Binding var value: String
    var error: String?

    var body: some View {
        SalmaTextField(label: field.label, placeholder: field.placeholder ?? "", text: $value, errorMessage: error)
    }
}
