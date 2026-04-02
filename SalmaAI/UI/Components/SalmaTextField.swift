import SwiftUI

// Will be implemented in Prompt 4
struct SalmaTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: SalmaDesign.Spacing.xs) {
            Text(label)
                .font(SalmaDesign.Typography.captionMedium)
                .foregroundColor(SalmaDesign.Colors.textSecondary)

            TextField(placeholder, text: $text)
                .font(SalmaDesign.Typography.body)
                .padding(SalmaDesign.Spacing.md)
                .background(SalmaDesign.Colors.backgroundSecondary)
                .cornerRadius(SalmaDesign.Radius.sm)
                .overlay(
                    RoundedRectangle(cornerRadius: SalmaDesign.Radius.sm)
                        .stroke(
                            errorMessage != nil ? SalmaDesign.Colors.danger : SalmaDesign.Colors.border,
                            lineWidth: 1
                        )
                )

            if let error = errorMessage {
                Text(error)
                    .font(SalmaDesign.Typography.caption)
                    .foregroundColor(SalmaDesign.Colors.danger)
            }
        }
    }
}
