import SwiftUI

struct TermsSheetView: View {
    let terms: TermsConfig
    let onAccept: () -> Void
    let onDismiss: () -> Void

    @EnvironmentObject var languageManager: LanguageManager
    @State private var hasScrolledToBottom = false
    @State private var canAccept = false

    private var requiresScroll: Bool {
        terms.mustScrollToBottom == true
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: SalmaDesign.Spacing.md) {
                        termsContent

                        Color.clear
                            .frame(height: 1)
                            .id("bottom")
                            .onAppear {
                                hasScrolledToBottom = true
                                updateCanAccept()
                            }
                    }
                    .padding(SalmaDesign.Spacing.lg)
                }

                Divider()

                VStack(spacing: SalmaDesign.Spacing.sm) {
                    if requiresScroll && !hasScrolledToBottom {
                        Text(L("terms_scroll_to_accept"))
                            .font(SalmaDesign.Typography.caption)
                            .foregroundColor(SalmaDesign.Colors.textTertiary)
                    }

                    SalmaButton(
                        title: L("terms_accept"),
                        style: .primary,
                        size: .large,
                        isDisabled: !canAccept
                    ) {
                        HapticManager.notification(.success)
                        onAccept()
                    }
                }
                .padding(SalmaDesign.Spacing.lg)
            }
            .navigationTitle(L("terms_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(L("close")) {
                        onDismiss()
                    }
                }
            }
            .environment(\.layoutDirection,
                          languageManager.currentLanguage == .arabic ? .rightToLeft : .leftToRight)
        }
        .onAppear { updateCanAccept() }
    }

    @ViewBuilder
    private var termsContent: some View {
        let content = languageManager.currentLanguage == .arabic
            ? (terms.contentAr ?? terms.contentEn ?? "")
            : (terms.contentEn ?? terms.contentAr ?? "")

        switch terms.contentType {
        case "html":
            HTMLTermsView(html: content)
                .frame(minHeight: 400)

        case "url":
            if let urlString = terms.url, let url = URL(string: urlString) {
                WebTermsView(url: url)
                    .frame(minHeight: 400)
            } else {
                Text(L("terms_url_error"))
                    .foregroundColor(SalmaDesign.Colors.danger)
            }

        default:
            Text(content)
                .font(SalmaDesign.Typography.body)
                .foregroundColor(SalmaDesign.Colors.textPrimary)
                .multilineTextAlignment(
                    languageManager.currentLanguage == .arabic ? .trailing : .leading
                )
        }
    }

    private func updateCanAccept() {
        canAccept = requiresScroll ? hasScrolledToBottom : true
    }
}
