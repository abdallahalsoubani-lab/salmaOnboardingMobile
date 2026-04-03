import SwiftUI

struct LanguageSwitchSheet: View {
    @EnvironmentObject var languageManager: LanguageManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: SalmaDesign.Spacing.md) {
                Text(L("language_will_change"))
                    .font(SalmaDesign.Typography.callout)
                    .foregroundColor(SalmaDesign.Colors.textSecondary)
                    .padding(.top, SalmaDesign.Spacing.sm)

                VStack(spacing: 0) {
                    languageRow(
                        title: "العربية",
                        subtitle: "Arabic",
                        language: .arabic
                    )

                    Divider()
                        .padding(.leading, SalmaDesign.Spacing.xxl)

                    languageRow(
                        title: "English",
                        subtitle: "الإنجليزية",
                        language: .english
                    )
                }
                .background(SalmaDesign.Colors.surface)
                .cornerRadius(SalmaDesign.Radius.md)
                .padding(.horizontal, SalmaDesign.Spacing.md)

                Spacer()
            }
            .navigationTitle(L("change_language"))
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

    @ViewBuilder
    private func languageRow(title: String, subtitle: String, language: AppLanguage) -> some View {
        let isSelected = languageManager.currentLanguage == language

        Button {
            languageManager.setLanguage(language)
            dismiss()
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(SalmaDesign.Typography.bodyMedium)
                        .foregroundColor(SalmaDesign.Colors.textPrimary)
                    Text(subtitle)
                        .font(SalmaDesign.Typography.caption)
                        .foregroundColor(SalmaDesign.Colors.textSecondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(SalmaDesign.Colors.primary)
                }
            }
            .padding(.horizontal, SalmaDesign.Spacing.md)
            .padding(.vertical, SalmaDesign.Spacing.md)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
