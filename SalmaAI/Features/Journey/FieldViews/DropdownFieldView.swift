import SwiftUI

struct DropdownFieldView: View {
    let field: PageField
    let label: String
    @Binding var value: String
    let errorMessage: String?

    @EnvironmentObject var languageManager: LanguageManager

    var body: some View {
        SalmaDropdown(
            label: label,
            options: field.options ?? [],
            selection: $value,
            placeholder: languageManager.currentLanguage == .arabic ? "اختر..." : "Select...",
            errorMessage: errorMessage,
            isRequired: field.isRequired
        )
    }
}
