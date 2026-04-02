import SwiftUI

// Will be implemented in Prompt 4
struct SalmaDatePicker: View {
    let label: String
    @Binding var date: Date
    var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: SalmaDesign.Spacing.xs) {
            Text(label)
                .font(SalmaDesign.Typography.captionMedium)
                .foregroundColor(SalmaDesign.Colors.textSecondary)

            DatePicker("", selection: $date, displayedComponents: .date)
                .labelsHidden()
                .datePickerStyle(.compact)

            if let error = errorMessage {
                Text(error)
                    .font(SalmaDesign.Typography.caption)
                    .foregroundColor(SalmaDesign.Colors.danger)
            }
        }
    }
}
