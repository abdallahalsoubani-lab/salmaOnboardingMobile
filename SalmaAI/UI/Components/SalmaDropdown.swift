import SwiftUI

// Will be implemented in Prompt 4
struct SalmaDropdown: View {
    let label: String
    let options: [String]
    @Binding var selection: String
    var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: SalmaDesign.Spacing.xs) {
            Text(label)
                .font(SalmaDesign.Typography.captionMedium)
                .foregroundColor(SalmaDesign.Colors.textSecondary)

            Menu {
                ForEach(options, id: \.self) { option in
                    Button(option) {
                        selection = option
                    }
                }
            } label: {
                HStack {
                    Text(selection.isEmpty ? label : selection)
                        .font(SalmaDesign.Typography.body)
                        .foregroundColor(selection.isEmpty ? SalmaDesign.Colors.textTertiary : SalmaDesign.Colors.textPrimary)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(SalmaDesign.Colors.textSecondary)
                }
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
            }

            if let error = errorMessage {
                Text(error)
                    .font(SalmaDesign.Typography.caption)
                    .foregroundColor(SalmaDesign.Colors.danger)
            }
        }
    }
}
