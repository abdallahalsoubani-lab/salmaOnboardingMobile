import SwiftUI

// Will be fully styled in Prompt 4
struct SalmaButton: View {
    let title: String
    var style: ButtonStyle = .primary
    var isLoading: Bool = false
    var isDisabled: Bool = false
    let action: () -> Void

    enum ButtonStyle {
        case primary
        case secondary
        case danger
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: SalmaDesign.Spacing.sm) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                }
                Text(title)
                    .font(SalmaDesign.Typography.title3)
            }
            .foregroundColor(foregroundColor)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(backgroundColor)
            .cornerRadius(SalmaDesign.Radius.lg)
            .shadow(
                color: SalmaDesign.Shadows.button.color,
                radius: SalmaDesign.Shadows.button.radius,
                x: SalmaDesign.Shadows.button.x,
                y: SalmaDesign.Shadows.button.y
            )
        }
        .disabled(isDisabled || isLoading)
        .opacity(isDisabled ? 0.6 : 1.0)
    }

    private var backgroundColor: Color {
        switch style {
        case .primary: return SalmaDesign.Colors.primary
        case .secondary: return SalmaDesign.Colors.backgroundSecondary
        case .danger: return SalmaDesign.Colors.danger
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary: return .white
        case .secondary: return SalmaDesign.Colors.textPrimary
        case .danger: return .white
        }
    }
}
