import SwiftUI

struct CheckboxFieldView: View {
    let field: PageField
    let label: String
    @Binding var value: String
    let errorMessage: String?

    @EnvironmentObject var languageManager: LanguageManager

    @State private var showTermsSheet = false
    @State private var hasViewedTerms = false

    private var isChecked: Binding<Bool> {
        Binding(
            get: { value == "true" },
            set: { value = $0 ? "true" : "false" }
        )
    }

    private var termsConfig: TermsConfig? {
        field.validationRules?.terms
    }

    private var isTermsField: Bool {
        termsConfig?.isTermsField == true
    }

    var body: some View {
        let consentText = languageManager.localizedConsentText(for: field.validationRules) ?? label

        VStack(alignment: .leading, spacing: SalmaDesign.Spacing.xs) {
            SalmaCheckbox(
                isChecked: Binding(
                    get: { isChecked.wrappedValue },
                    set: { newValue in
                        if isTermsField && !hasViewedTerms && newValue {
                            showTermsSheet = true
                            return
                        }
                        isChecked.wrappedValue = newValue
                    }
                ),
                consentText: consentText,
                errorMessage: errorMessage,
                isRequired: field.isRequired
            )

            if isTermsField {
                Button { showTermsSheet = true } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 14))
                        Text(termsLinkText)
                            .font(SalmaDesign.Typography.callout)
                            .underline()
                    }
                    .foregroundColor(SalmaDesign.Colors.primary)
                }
                .buttonStyle(.plain)

                if !hasViewedTerms && !isChecked.wrappedValue {
                    Text(L("terms_must_view_first"))
                        .font(SalmaDesign.Typography.caption)
                        .foregroundColor(SalmaDesign.Colors.warning)
                }
            }
        }
        .sheet(isPresented: $showTermsSheet) {
            if let terms = termsConfig {
                TermsSheetView(
                    terms: terms,
                    onAccept: {
                        hasViewedTerms = true
                        value = "true"
                        showTermsSheet = false
                    },
                    onDismiss: {
                        hasViewedTerms = true
                        showTermsSheet = false
                    }
                )
                .environmentObject(languageManager)
            }
        }
    }

    private var termsLinkText: String {
        if languageManager.currentLanguage == .arabic {
            return termsConfig?.linkTextAr ?? "عرض الشروط والأحكام"
        } else {
            return termsConfig?.linkTextEn ?? "View Terms & Conditions"
        }
    }
}
