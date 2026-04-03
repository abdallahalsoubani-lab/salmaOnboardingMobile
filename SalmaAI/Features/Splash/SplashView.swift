import SwiftUI

struct SplashView: View {
    @State private var logoOpacity: Double = 0
    @State private var logoScale: CGFloat = 0.8
    @State private var taglineOpacity: Double = 0
    @State private var taglineOffset: CGFloat = 10

    private var hasClientLogo: Bool {
        ThemeManager.shared.logoUrl != nil
    }

    var body: some View {
        ZStack {
            ThemedColors.primary
                .ignoresSafeArea()

            VStack(spacing: SalmaDesign.Spacing.md) {
                Spacer()

                if let logoUrlString = ThemeManager.shared.logoUrl,
                   let url = URL(string: logoUrlString) {
                    clientLogoSection(url: url)
                } else {
                    defaultLogoSection
                }

                Text(deviceLanguageIsArabic
                     ? "تحقق من هويتك بسهولة"
                     : "Verify your identity with ease")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white.opacity(0.6))
                    .opacity(taglineOpacity)
                    .offset(y: taglineOffset)

                Spacer()

                if ThemeManager.shared.showPoweredBy {
                    Text("Powered by Salma AI")
                        .font(SalmaDesign.Typography.caption)
                        .foregroundColor(.white.opacity(0.5))
                        .padding(.bottom, SalmaDesign.Spacing.lg)
                        .opacity(taglineOpacity)
                }
            }
        }
        .onAppear {
            startAnimations()
        }
    }

    // MARK: - Client Logo (from theme)

    private func clientLogoSection(url: URL) -> some View {
        VStack(spacing: SalmaDesign.Spacing.sm) {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(height: 60)
            } placeholder: {
                ProgressView()
                    .tint(.white)
            }
        }
        .opacity(logoOpacity)
        .scaleEffect(logoScale)
    }

    // MARK: - Default Salma Logo

    private var defaultLogoSection: some View {
        VStack(spacing: SalmaDesign.Spacing.sm) {
            Image(systemName: "shield.checkered")
                .font(.system(size: 60, weight: .medium))
                .foregroundColor(.white)
                .shadow(color: .white.opacity(0.3), radius: 20, y: 5)

            Text("Salma AI")
                .font(.system(size: 28, weight: .bold))
                .tracking(2)
                .foregroundColor(.white)

            Text("Onboarding")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.white.opacity(0.7))
        }
        .opacity(logoOpacity)
        .scaleEffect(logoScale)
    }

    private var deviceLanguageIsArabic: Bool {
        Locale.current.language.languageCode?.identifier == "ar"
    }

    private func startAnimations() {
        withAnimation(.easeOut(duration: 0.6)) {
            logoOpacity = 1
            logoScale = 1.0
        }
        withAnimation(.easeOut(duration: 0.4).delay(0.6)) {
            taglineOpacity = 1
            taglineOffset = 0
        }
    }
}
