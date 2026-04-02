import SwiftUI

struct SalmaToggle: View {
    let label: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            Text(label)
                .font(SalmaDesign.Typography.body)
                .foregroundColor(SalmaDesign.Colors.textPrimary)
        }
        .tint(SalmaDesign.Colors.primary)
    }
}
