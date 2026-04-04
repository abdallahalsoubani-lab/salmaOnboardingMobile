import SwiftUI

struct EmailFieldView: View {
    let field: PageField
    let label: String
    let placeholder: String
    @Binding var value: String
    let errorMessage: String?

    @FocusState private var isFocused: Bool
    @State private var shakeError = false

    private var effectivePlaceholder: String {
        placeholder.isEmpty ? "email@example.com" : placeholder
    }

    var body: some View {
        VStack(alignment: .leading, spacing: SalmaDesign.Spacing.xs) {
            // Label — follows natural language direction
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
            }

            // Input — ALWAYS left-to-right
            LTREmailField(
                text: $value,
                placeholder: effectivePlaceholder,
                isFocused: $isFocused
            )
            .frame(height: 52)
            .background(SalmaDesign.Colors.backgroundSecondary)
            .cornerRadius(SalmaDesign.Radius.md)
            .overlay(
                RoundedRectangle(cornerRadius: SalmaDesign.Radius.md)
                    .stroke(borderColor, lineWidth: 1.5)
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
}

// MARK: - UIKit TextField wrapper — guarantees LTR text alignment for email

private struct LTREmailField: UIViewRepresentable {
    @Binding var text: String
    let placeholder: String
    var isFocused: FocusState<Bool>.Binding

    func makeUIView(context: Context) -> UITextField {
        let tf = UITextField()
        tf.textAlignment = .left
        tf.semanticContentAttribute = .forceLeftToRight
        tf.keyboardType = .emailAddress
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.textContentType = .emailAddress
        tf.placeholder = placeholder
        tf.font = .systemFont(ofSize: 17)
        tf.textColor = UIColor.label
        tf.delegate = context.coordinator
        tf.setContentHuggingPriority(.defaultLow, for: .horizontal)
        tf.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let hPadding = SalmaDesign.Spacing.md
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: hPadding, height: 1))
        tf.leftViewMode = .always
        tf.rightView = UIView(frame: CGRect(x: 0, y: 0, width: hPadding, height: 1))
        tf.rightViewMode = .always

        tf.addTarget(context.coordinator, action: #selector(Coordinator.textChanged(_:)), for: .editingChanged)
        tf.addTarget(context.coordinator, action: #selector(Coordinator.editingDidBegin(_:)), for: .editingDidBegin)
        tf.addTarget(context.coordinator, action: #selector(Coordinator.editingDidEnd(_:)), for: .editingDidEnd)
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

    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: LTREmailField

        init(_ parent: LTREmailField) {
            self.parent = parent
        }

        @objc func textChanged(_ textField: UITextField) {
            parent.text = textField.text ?? ""
        }

        @objc func editingDidBegin(_ textField: UITextField) {
            parent.isFocused.wrappedValue = true
        }

        @objc func editingDidEnd(_ textField: UITextField) {
            parent.isFocused.wrappedValue = false
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
    }
}
