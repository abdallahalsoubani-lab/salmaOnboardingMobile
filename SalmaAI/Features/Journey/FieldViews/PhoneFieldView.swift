import SwiftUI

// Will be implemented in Prompt 6
struct PhoneFieldView: View {
    let field: PageField
    @Binding var value: String
    var error: String?

    var body: some View {
        SalmaTextField(label: field.label, placeholder: field.placeholder ?? "", text: $value, errorMessage: error)
    }
}
