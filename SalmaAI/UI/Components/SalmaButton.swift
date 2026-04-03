import SwiftUI

struct SalmaButton: View {
    let title: String
    var style: ButtonVariant = .primary
    var size: ButtonSize = .large
    var isLoading: Bool = false
    var isDisabled: Bool = false
    var icon: String?
    var iconPosition: IconPosition = .trailing
    var fullWidth: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: {
            guard !isLoading && !isDisabled else { return }
            action()
        }) {
            HStack(spacing: SalmaDesign.Spacing.sm) {
                if isLoading {
                    ProgressView()
                        .tint(spinnerColor)
                        .scaleEffect(0.85)
                } else {
                    if let icon = icon, iconPosition == .leading {
                        Image(systemName: icon)
                            .font(.system(size: 14, weight: .semibold))
                    }

                    Text(title)
                        .font(size.font)

                    if let icon = icon, iconPosition == .trailing {
                        Image(systemName: icon)
                            .font(.system(size: 14, weight: .semibold))
                    }
                }
            }
            .foregroundColor(style.foregroundColor)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .frame(height: size.height)
            .padding(.horizontal, fullWidth ? 0 : size.horizontalPadding)
            .background(style.backgroundColor)
            .cornerRadius(size.radius)
            .overlay(
                Group {
                    if style == .outline {
                        RoundedRectangle(cornerRadius: size.radius)
                            .stroke(SalmaDesign.Colors.primary, lineWidth: 1.5)
                    }
                }
            )
        }
        .disabled(isDisabled || isLoading)
        .opacity(isDisabled ? 0.5 : 1.0)
        .pressAnimation()
        .accessibilityLabel(isLoading ? "\(title), \(L("loading"))" : title)
        .accessibilityAddTraits(.isButton)
    }

    private var spinnerColor: Color {
        switch style {
        case .primary, .danger: return .white
        default: return SalmaDesign.Colors.primary
        }
    }
}

enum ButtonVariant {
    case primary, secondary, danger, ghost, outline

    var backgroundColor: Color {
        switch self {
        case .primary: return SalmaDesign.Colors.primary
        case .secondary: return SalmaDesign.Colors.backgroundSecondary
        case .danger: return SalmaDesign.Colors.danger
        case .ghost: return .clear
        case .outline: return .clear
        }
    }

    var foregroundColor: Color {
        switch self {
        case .primary: return .white
        case .secondary: return SalmaDesign.Colors.textPrimary
        case .danger: return .white
        case .ghost: return SalmaDesign.Colors.primary
        case .outline: return SalmaDesign.Colors.primary
        }
    }
}

enum ButtonSize {
    case small, medium, large

    var height: CGFloat {
        switch self {
        case .small: return 40
        case .medium: return 48
        case .large: return 56
        }
    }

    var font: Font {
        switch self {
        case .small: return SalmaDesign.Typography.callout
        case .medium, .large: return SalmaDesign.Typography.bodyMedium
        }
    }

    var horizontalPadding: CGFloat {
        switch self {
        case .small: return 16
        case .medium: return 20
        case .large: return 24
        }
    }

    var radius: CGFloat {
        switch self {
        case .small: return SalmaDesign.Radius.sm
        case .medium: return SalmaDesign.Radius.md
        case .large: return SalmaDesign.Radius.lg
        }
    }
}

enum IconPosition {
    case leading, trailing
}
