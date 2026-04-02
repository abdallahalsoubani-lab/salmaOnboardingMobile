import SwiftUI

struct DateFieldView: View {
    let field: PageField
    let label: String
    @Binding var value: String
    let errorMessage: String?

    @State private var selectedDate: Date?
    @EnvironmentObject var languageManager: LanguageManager

    var body: some View {
        SalmaDatePicker(
            label: label,
            selectedDate: Binding(
                get: { selectedDate },
                set: { date in
                    selectedDate = date
                    if let d = date {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd"
                        value = formatter.string(from: d)
                    } else {
                        value = ""
                    }
                }
            ),
            placeholder: languageManager.currentLanguage == .arabic ? "اختر التاريخ" : "Select date",
            errorMessage: errorMessage,
            isRequired: field.isRequired,
            mustBePast: field.validationRules?.mustBePast ?? false,
            mustBeFuture: field.validationRules?.mustBeFuture ?? false,
            minDate: parseDate(field.validationRules?.minDate),
            maxDate: parseDate(field.validationRules?.maxDate)
        )
        .onAppear {
            if !value.isEmpty, selectedDate == nil {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                selectedDate = formatter.date(from: value)
            }
        }
    }

    private func parseDate(_ string: String?) -> Date? {
        guard let s = string else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: s)
    }
}
