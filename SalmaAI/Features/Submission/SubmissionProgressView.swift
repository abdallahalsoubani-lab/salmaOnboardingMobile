import SwiftUI

// Will be fully implemented in Prompt 10
struct SubmissionProgressView: View {
    @EnvironmentObject var flowState: VerificationFlowState
    @EnvironmentObject var router: NavigationRouter
    @State private var spinAngle: Double = 0

    var body: some View {
        VStack(spacing: SalmaDesign.Spacing.lg) {
            Spacer()

            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(SalmaDesign.Colors.primary, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .frame(width: 48, height: 48)
                .rotationEffect(.degrees(spinAngle))
                .onAppear {
                    withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                        spinAngle = 360
                    }
                }

            Text(String(localized: "submitting"))
                .font(SalmaDesign.Typography.title3)
                .foregroundColor(SalmaDesign.Colors.textPrimary)

            // Progress bar placeholder
            ProgressView(value: flowState.uploadProgress)
                .tint(SalmaDesign.Colors.primary)
                .padding(.horizontal, SalmaDesign.Spacing.xxl)

            Spacer()

            // Auto-navigate to result after delay (simulated)
            Color.clear.onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    router.push(.result)
                }
            }
        }
        .background(SalmaDesign.Colors.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }
}
