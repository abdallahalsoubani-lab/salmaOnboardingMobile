import SwiftUI

struct LanguageSelectionView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @State private var selectedLanguage: AppLanguage = .arabic
    @State private var logoAppeared = false
    @State private var arabicCardAppeared = false
    @State private var englishCardAppeared = false
    @State private var buttonAppeared = false

    var body: some View {
        ZStack {
            // Premium gradient background
            LinearGradient(
                colors: [SalmaDesign.Colors.primaryDark, SalmaDesign.Colors.primary],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Logo with glow
                VStack(spacing: SalmaDesign.Spacing.sm) {
                    Image(systemName: "shield.checkered")
                        .font(.system(size: 56, weight: .medium))
                        .foregroundColor(.white)
                        .shadow(color: .white.opacity(0.4), radius: 20, y: 5)

                    Text("Salma AI")
                        .font(.system(size: 28, weight: .bold))
                        .tracking(2)
                        .foregroundColor(.white)

                    Text("Identity Verification")
                        .font(SalmaDesign.Typography.callout)
                        .foregroundColor(.white.opacity(0.7))
                }
                .opacity(logoAppeared ? 1 : 0)
                .scaleEffect(logoAppeared ? 1.0 : 0.8)
                .padding(.bottom, SalmaDesign.Spacing.xxl)

                // Subtitle
                VStack(spacing: SalmaDesign.Spacing.xs) {
                    Text("اختر اللغة")
                        .font(SalmaDesign.Typography.title2)
                        .foregroundColor(.white)

                    Text("Choose Language")
                        .font(SalmaDesign.Typography.callout)
                        .foregroundColor(.white.opacity(0.7))
                }
                .opacity(logoAppeared ? 1 : 0)
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
                    .opacity(arabicCardAppeared ? 1 : 0)
                    .offset(x: arabicCardAppeared ? 0 : 40)

                    LanguageCard(
                        title: "English",
                        subtitle: "الإنجليزية",
                        isSelected: selectedLanguage == .english
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedLanguage = .english
                        }
                    }
                    .opacity(englishCardAppeared ? 1 : 0)
                    .offset(x: englishCardAppeared ? 0 : -40)
                }
                .padding(.horizontal, SalmaDesign.Spacing.lg)

                Spacer()

                // Start button with shimmer
                Button {
                    languageManager.setLanguage(selectedLanguage)
                } label: {
                    Text(selectedLanguage == .arabic ? "ابدأ" : "Start")
                        .font(SalmaDesign.Typography.title3)
                        .foregroundColor(SalmaDesign.Colors.primary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(.white)
                        .cornerRadius(SalmaDesign.Radius.lg)
                        .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
                        .shimmer()
                }
                .pressAnimation()
                .opacity(buttonAppeared ? 1 : 0)
                .offset(y: buttonAppeared ? 0 : 20)
                .padding(.horizontal, SalmaDesign.Spacing.lg)
                .padding(.bottom, SalmaDesign.Spacing.xl)
            }
        }
        .onAppear { animateIn() }
    }

    private func animateIn() {
        withAnimation(.easeOut(duration: 0.5)) {
            logoAppeared = true
        }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.3)) {
            arabicCardAppeared = true
        }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.45)) {
            englishCardAppeared = true
        }
        withAnimation(.easeOut(duration: 0.4).delay(0.6)) {
            buttonAppeared = true
        }
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
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .shadow(
                color: isSelected
                    ? SalmaDesign.Colors.primary.opacity(0.3)
                    : .black.opacity(0.06),
                radius: isSelected ? 16 : 8,
                x: 0,
                y: isSelected ? 8 : 2
            )
            .offset(y: isSelected ? -2 : 0)
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(.plain)
        .pressAnimation()
    }
}
