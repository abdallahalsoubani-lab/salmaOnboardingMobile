import SwiftUI

struct SalmaCheckbox: View {
    @Binding var isChecked: Bool
    var consentText: String = ""
    var errorMessage: String?
    var isRequired: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: SalmaDesign.Spacing.xs) {
            Button {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
                    isChecked.toggle()
                }
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
            } label: {
                HStack(alignment: .top, spacing: SalmaDesign.Spacing.sm) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(isChecked ? Color.clear : SalmaDesign.Colors.border, lineWidth: 2)
                            .frame(width: 24, height: 24)

                        RoundedRectangle(cornerRadius: 6)
                            .fill(isChecked ? SalmaDesign.Colors.primary : .clear)
                            .frame(width: 24, height: 24)

                        if isChecked {
                            Image(systemName: "checkmark")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .animation(.spring(response: 0.25, dampingFraction: 0.6), value: isChecked)

                    Text(consentText)
                        .font(SalmaDesign.Typography.callout)
                        .foregroundColor(SalmaDesign.Colors.textPrimary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(consentText)
            .accessibilityValue(isChecked ? L("checked") : L("unchecked"))
            .accessibilityAddTraits(.isButton)
            .accessibilityHint(L("double_tap_to_toggle"))

            if let error = errorMessage {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle")
                        .font(.system(size: 12))
                    Text(error)
                        .font(SalmaDesign.Typography.caption)
                }
                .foregroundColor(SalmaDesign.Colors.danger)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(AppAnimations.fadeIn, value: errorMessage)
    }
}
