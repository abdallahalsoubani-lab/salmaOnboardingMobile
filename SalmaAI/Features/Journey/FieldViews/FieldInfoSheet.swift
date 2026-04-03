import SwiftUI

struct FieldInfoSheet: View {
    let fieldId: String
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: SalmaDesign.Spacing.md) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(SalmaDesign.Colors.info)
                    .padding(.top, SalmaDesign.Spacing.lg)

                Text("Field information for: \(fieldId)")
                    .font(SalmaDesign.Typography.body)
                    .foregroundColor(SalmaDesign.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, SalmaDesign.Spacing.lg)

                Spacer()
            }
            .navigationTitle("Info")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(L("done")) {
                        dismiss()
                    }
                    .foregroundColor(SalmaDesign.Colors.primary)
                }
            }
        }
    }
}
