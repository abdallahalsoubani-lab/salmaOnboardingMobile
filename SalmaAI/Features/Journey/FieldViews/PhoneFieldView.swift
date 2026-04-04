import SwiftUI

struct PhoneFieldView: View {
    let field: PageField
    let label: String
    let placeholder: String
    @Binding var value: String
    let errorMessage: String?

    @FocusState private var isFocused: Bool
    @State private var shakeError = false

    private var countryCode: String {
        field.validationRules?.countryCode ?? "+962"
    }

    private var effectivePlaceholder: String {
        placeholder.isEmpty ? phonePlaceholder(for: countryCode) : placeholder
    }

    var body: some View {
        VStack(alignment: .leading, spacing: SalmaDesign.Spacing.xs) {
            // Label — follows natural language direction (RTL for Arabic)
            HStack {
                HStack(spacing: 2) {
                    Text(label)
                        .font(SalmaDesign.Typography.callout)
                        .foregroundColor(SalmaDesign.Colors.textSecondary)
                    if field.isRequired {
                        Text("*")
                            .font(SalmaDesign.Typography.callout)
                            .foregroundColor(SalmaDesign.Colors.danger)
                    }
                }

                Spacer()

                if let max = field.validationRules?.maxLength {
                    Text("\(value.count)/\(max)")
                        .font(SalmaDesign.Typography.caption)
                        .foregroundColor(value.count > max ? SalmaDesign.Colors.danger : SalmaDesign.Colors.textTertiary)
                }
            }

            // Input box — ALWAYS left-to-right
            PhoneInputRow(
                countryCode: countryCode,
                placeholder: effectivePlaceholder,
                text: $value,
                isFocused: $isFocused,
                maxLength: field.validationRules?.maxLength,
                borderColor: borderColor
            )
            .shake(trigger: shakeError)
            .animation(.easeInOut(duration: 0.2), value: isFocused)

            // Error — follows natural language direction
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
        .accessibilityValue(value)
        .animation(AppAnimations.fadeIn, value: errorMessage)
        .onChange(of: errorMessage) { newValue in
            if newValue != nil { shakeError.toggle() }
        }
    }

    private var borderColor: Color {
        if errorMessage != nil { return SalmaDesign.Colors.danger }
        if isFocused { return ThemedColors.primary }
        return SalmaDesign.Colors.border
    }

    private func phonePlaceholder(for code: String) -> String {
        switch code {
        case "+962": return "07XXXXXXXX"
        case "+966": return "05XXXXXXXX"
        case "+971": return "05XXXXXXXX"
        case "+20": return "01XXXXXXXXX"
        default: return ""
        }
    }
}

// MARK: - LTR Phone Input (UIKit-backed for reliable left-to-right text)

private struct PhoneInputRow: View {
    let countryCode: String
    let placeholder: String
    @Binding var text: String
    var isFocused: FocusState<Bool>.Binding
    let maxLength: Int?
    let borderColor: Color

    var body: some View {
        HStack(spacing: 0) {
            Text(countryCode)
                .font(SalmaDesign.Typography.body)
                .foregroundColor(SalmaDesign.Colors.textSecondary)
                .padding(.leading, SalmaDesign.Spacing.md)

            Rectangle()
                .fill(SalmaDesign.Colors.border)
                .frame(width: 1, height: 24)
                .padding(.horizontal, SalmaDesign.Spacing.sm)

            LTRTextField(
                text: $text,
                placeholder: placeholder,
                maxLength: maxLength,
                isFocused: isFocused
            )
            .padding(.trailing, SalmaDesign.Spacing.sm)
        }
        .frame(height: 52)
        .background(SalmaDesign.Colors.backgroundSecondary)
        .cornerRadius(SalmaDesign.Radius.md)
        .overlay(
            RoundedRectangle(cornerRadius: SalmaDesign.Radius.md)
                .stroke(borderColor, lineWidth: 1.5)
        )
        .environment(\.layoutDirection, .leftToRight)
    }
}

// MARK: - UIKit TextField wrapper — guarantees LTR text alignment

private struct LTRTextField: UIViewRepresentable {
    @Binding var text: String
    let placeholder: String
    let maxLength: Int?
    var isFocused: FocusState<Bool>.Binding

    func makeUIView(context: Context) -> UITextField {
        let tf = UITextField()
        tf.textAlignment = .left
        tf.semanticContentAttribute = .forceLeftToRight
        tf.keyboardType = .phonePad
        tf.placeholder = placeholder
        tf.font = .systemFont(ofSize: 17)
        tf.textColor = UIColor.label
        tf.delegate = context.coordinator
        tf.setContentHuggingPriority(.defaultLow, for: .horizontal)
        tf.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        tf.addTarget(context.coordinator, action: #selector(Coordinator.textChanged(_:)), for: .editingChanged)
        tf.addTarget(context.coordinator, action: #selector(Coordinator.editingDidBegin(_:)), for: .editingDidBegin)
        tf.addTarget(context.coordinator, action: #selector(Coordinator.editingDidEnd(_:)), for: .editingDidEnd)
        tf.inputAccessoryView = makeDoneToolbar(target: context.coordinator)
        return tf
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
        if uiView.placeholder != placeholder {
            uiView.placeholder = placeholder
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    private func makeDoneToolbar(target: Coordinator) -> UIToolbar {
        let bar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        bar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: L("done"), style: .done, target: target, action: #selector(Coordinator.doneTapped))
        ]
        bar.sizeToFit()
        return bar
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: LTRTextField

        init(_ parent: LTRTextField) {
            self.parent = parent
        }

        @objc func doneTapped() {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }

        @objc func textChanged(_ textField: UITextField) {
            let newText = textField.text ?? ""
            if let max = parent.maxLength, newText.count > max {
                textField.text = String(newText.prefix(max))
            }
            parent.text = textField.text ?? ""
        }

        @objc func editingDidBegin(_ textField: UITextField) {
            parent.isFocused.wrappedValue = true
        }

        @objc func editingDidEnd(_ textField: UITextField) {
            parent.isFocused.wrappedValue = false
        }

        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            let allowed = CharacterSet.decimalDigits
            return string.unicodeScalars.allSatisfy { allowed.contains($0) }
        }
    }
}
