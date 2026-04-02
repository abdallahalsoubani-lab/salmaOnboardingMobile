import SwiftUI

struct LanguageSelectionView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @State private var selectedLanguage: AppLanguage = .arabic

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Logo
            VStack(spacing: SalmaDesign.Spacing.sm) {
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 56))
                    .foregroundColor(SalmaDesign.Colors.primary)

                Text("Salma AI")
                    .font(SalmaDesign.Typography.largeTitle)
                    .foregroundColor(SalmaDesign.Colors.primary)

                Text("Identity Verification")
                    .font(SalmaDesign.Typography.callout)
                    .foregroundColor(SalmaDesign.Colors.textSecondary)
            }
            .padding(.bottom, SalmaDesign.Spacing.xxl)

            // Subtitle
            VStack(spacing: SalmaDesign.Spacing.xs) {
                Text("اختر اللغة")
                    .font(SalmaDesign.Typography.title2)
                    .foregroundColor(SalmaDesign.Colors.textPrimary)

                Text("Choose Language")
                    .font(SalmaDesign.Typography.callout)
                    .foregroundColor(SalmaDesign.Colors.textSecondary)
            }
            .padding(.bottom, SalmaDesign.Spacing.lg)

            // Language cards
            HStack(spacing: SalmaDesign.Spacing.md) {
                LanguageCard(
                    title: "العربية",
                    subtitle: "Arabic",
                    isSelected: selectedLanguage == .arabic
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedLanguage = .arabic
                    }
                }

                LanguageCard(
                    title: "English",
                    subtitle: "الإنجليزية",
                    isSelected: selectedLanguage == .english
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedLanguage = .english
                    }
                }
            }
            .padding(.horizontal, SalmaDesign.Spacing.lg)

            Spacer()

            // Start button
            Button {
                languageManager.setLanguage(selectedLanguage)
            } label: {
                Text(selectedLanguage == .arabic ? "ابدأ" : "Start")
                    .font(SalmaDesign.Typography.title3)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(SalmaDesign.Colors.primary)
                    .cornerRadius(SalmaDesign.Radius.lg)
                    .shadow(
                        color: SalmaDesign.Shadows.button.color,
                        radius: SalmaDesign.Shadows.button.radius,
                        x: SalmaDesign.Shadows.button.x,
                        y: SalmaDesign.Shadows.button.y
                    )
            }
            .padding(.horizontal, SalmaDesign.Spacing.lg)
            .padding(.bottom, SalmaDesign.Spacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(SalmaDesign.Colors.background.ignoresSafeArea())
    }
}

struct LanguageCard: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: SalmaDesign.Spacing.sm) {
                Spacer()

                Text(title)
                    .font(SalmaDesign.Typography.title1)
                    .foregroundColor(isSelected ? SalmaDesign.Colors.primary : SalmaDesign.Colors.textPrimary)

                Text(subtitle)
                    .font(SalmaDesign.Typography.caption)
                    .foregroundColor(SalmaDesign.Colors.textSecondary)

                Spacer()
            }
            .frame(maxWidth: .infinity)
            .frame(height: 180)
            .background(SalmaDesign.Colors.surface)
            .cornerRadius(SalmaDesign.Radius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: SalmaDesign.Radius.lg)
                    .stroke(
                        isSelected ? SalmaDesign.Colors.primary : SalmaDesign.Colors.border,
                        lineWidth: isSelected ? 3 : 1
                    )
            )
            .overlay(alignment: .topTrailing) {
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(SalmaDesign.Colors.primary)
                        .padding(SalmaDesign.Spacing.sm)
                }
            }
            .shadow(
                color: SalmaDesign.Shadows.card.color,
                radius: SalmaDesign.Shadows.card.radius,
                x: SalmaDesign.Shadows.card.x,
                y: SalmaDesign.Shadows.card.y
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(.plain)
    }
}
