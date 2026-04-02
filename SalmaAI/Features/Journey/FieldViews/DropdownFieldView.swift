import SwiftUI

// Will be implemented in Prompt 6
struct DropdownFieldView: View {
    let field: PageField
    @Binding var value: String
    var error: String?

    var body: some View {
        SalmaDropdown(label: field.label, options: field.options ?? [], selection: $value, errorMessage: error)
    }
}
