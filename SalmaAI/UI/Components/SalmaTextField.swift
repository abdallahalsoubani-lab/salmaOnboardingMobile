import SwiftUI

struct SalmaTextField: View {
    let label: String
    @Binding var text: String
    var placeholder: String = ""
    var errorMessage: String?
    var isRequired: Bool = false
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false
    var isDisabled: Bool = false
    var maxLength: Int?
    var prefix: String?
    var trailingIcon: String?
    var onSubmit: (() -> Void)?

    @FocusState private var isFocused: Bool
    @State private var shakeError = false

    var body: some View {
        VStack(alignment: .leading, spacing: SalmaDesign.Spacing.xs) {
            // Label row
            HStack {
                HStack(spacing: 2) {
                    Text(label)
                        .font(SalmaDesign.Typography.callout)
                        .foregroundColor(SalmaDesign.Colors.textSecondary)
                    if isRequired {
                        Text("*")
                            .font(SalmaDesign.Typography.callout)
                            .foregroundColor(SalmaDesign.Colors.danger)
                    }
                }

                Spacer()

                if let max = maxLength {
                    Text("\(text.count)/\(max)")
                        .font(SalmaDesign.Typography.caption)
                        .foregroundColor(text.count > max ? SalmaDesign.Colors.danger : SalmaDesign.Colors.textTertiary)
                }
            }

            // Input field
            HStack(spacing: 0) {
                if let icon = trailingIcon {
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(SalmaDesign.Colors.textTertiary)
                        .padding(.leading, SalmaDesign.Spacing.md)
                }

                if let pfx = prefix {
                    Text(pfx)
                        .font(SalmaDesign.Typography.body)
                        .foregroundColor(SalmaDesign.Colors.textSecondary)
                        .padding(.leading, trailingIcon == nil ? SalmaDesign.Spacing.md : SalmaDesign.Spacing.sm)

                    Rectangle()
                        .fill(SalmaDesign.Colors.border)
                        .frame(width: 1, height: 24)
                        .padding(.horizontal, SalmaDesign.Spacing.sm)
                }

                Group {
                    if isSecure {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text)
                    }
                }
                .font(SalmaDesign.Typography.body)
                .foregroundColor(SalmaDesign.Colors.textPrimary)
                .keyboardType(keyboardType)
                .focused($isFocused)
                .disabled(isDisabled)
                .padding(.horizontal, prefix != nil || trailingIcon != nil ? SalmaDesign.Spacing.sm : SalmaDesign.Spacing.md)
                .onSubmit { onSubmit?() }
                .onChange(of: text) { newValue in
                    if let max = maxLength, newValue.count > max {
                        text = String(newValue.prefix(max))
                    }
                }
            }
            .frame(height: 52)
            .background(SalmaDesign.Colors.backgroundSecondary)
            .cornerRadius(SalmaDesign.Radius.md)
            .overlay(
                RoundedRectangle(cornerRadius: SalmaDesign.Radius.md)
                    .stroke(borderColor, lineWidth: 1.5)
            )
            .opacity(isDisabled ? 0.6 : 1.0)
            .shake(trigger: shakeError)
            .animation(.easeInOut(duration: 0.2), value: isFocused)

            // Error message
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
        .accessibilityElement(children: .combine)
        .accessibilityLabel(errorMessage != nil ? "\(label), \(errorMessage!)" : label)
        .accessibilityValue(text)
        .animation(AppAnimations.fadeIn, value: errorMessage)
        .onChange(of: errorMessage) { newValue in
            if newValue != nil {
                shakeError.toggle()
            }
        }
    }

    private var borderColor: Color {
        if errorMessage != nil { return SalmaDesign.Colors.danger }
        if isFocused { return SalmaDesign.Colors.primary }
        return SalmaDesign.Colors.border
    }
}
