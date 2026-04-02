import SwiftUI

struct SplashView: View {
    @State private var logoOpacity: Double = 0
    @State private var logoScale: CGFloat = 0.8
    @State private var taglineOpacity: Double = 0
    @State private var taglineOffset: CGFloat = 10

    var body: some View {
        ZStack {
            SalmaDesign.Colors.primary
                .ignoresSafeArea()

            VStack(spacing: SalmaDesign.Spacing.md) {
                // Logo
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

                // Tagline
                Text(deviceLanguageIsArabic
                     ? "تحقق من هويتك بسهولة"
                     : "Verify your identity with ease")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white.opacity(0.6))
                    .opacity(taglineOpacity)
                    .offset(y: taglineOffset)
            }
        }
        .onAppear {
            startAnimations()
        }
    }

    private var deviceLanguageIsArabic: Bool {
        Locale.current.language.languageCode?.identifier == "ar"
    }

    private func startAnimations() {
        // Phase 1: Logo appears (0 - 0.6s)
        withAnimation(.easeOut(duration: 0.6)) {
            logoOpacity = 1
            logoScale = 1.0
        }

        // Phase 2: Tagline appears (0.6 - 1.0s)
        withAnimation(.easeOut(duration: 0.4).delay(0.6)) {
            taglineOpacity = 1
            taglineOffset = 0
        }
    }
}
