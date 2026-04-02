import SwiftUI

// Will be implemented in Prompt 4
struct SalmaCheckbox: View {
    let label: String
    @Binding var isChecked: Bool
    var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: SalmaDesign.Spacing.xs) {
            Button {
                isChecked.toggle()
            } label: {
                HStack(alignment: .top, spacing: SalmaDesign.Spacing.sm) {
                    Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                        .font(.system(size: 22))
                        .foregroundColor(isChecked ? SalmaDesign.Colors.primary : SalmaDesign.Colors.textTertiary)

                    Text(label)
                        .font(SalmaDesign.Typography.callout)
                        .foregroundColor(SalmaDesign.Colors.textPrimary)
                        .multilineTextAlignment(.leading)
                }
            }
            .buttonStyle(.plain)

            if let error = errorMessage {
                Text(error)
                    .font(SalmaDesign.Typography.caption)
                    .foregroundColor(SalmaDesign.Colors.danger)
            }
        }
    }
}
