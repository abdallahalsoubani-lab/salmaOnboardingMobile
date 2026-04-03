import SwiftUI

struct ProgressStepBar: View {
    let currentStep: Int
    let totalSteps: Int
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(spacing: SalmaDesign.Spacing.sm) {
            ForEach(1...totalSteps, id: \.self) { step in
                HStack(spacing: 0) {
                    // Step dot
                    StepDot(
                        step: step,
                        currentStep: currentStep,
                        reduceMotion: reduceMotion
                    )

                    // Connecting line (except after last step)
                    if step < totalSteps {
                        StepLine(
                            isCompleted: step < currentStep,
                            reduceMotion: reduceMotion
                        )
                    }
                }
            }
        }
        .accessibilityLabel(L("step_progress"))
        .accessibilityValue("\(currentStep) / \(totalSteps)")
        .animation(AppAnimations.stateChange, value: currentStep)
    }
}

private struct StepDot: View {
    let step: Int
    let currentStep: Int
    let reduceMotion: Bool

    @State private var pulseScale: CGFloat = 1.0
    @State private var completedScale: CGFloat = 1.0

    private var isCompleted: Bool { step < currentStep }
    private var isCurrent: Bool { step == currentStep }

    var body: some View {
        ZStack {
            Circle()
                .fill(dotColor)
                .frame(width: 28, height: 28)
                .scaleEffect(isCurrent ? pulseScale : completedScale)

            if isCompleted {
                // Mini checkmark
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .transition(.scale.combined(with: .opacity))
            } else {
                Text("\(step)")
                    .font(SalmaDesign.Typography.captionMedium)
                    .foregroundColor(isCurrent ? .white : SalmaDesign.Colors.textTertiary)
            }
        }
        .onAppear {
            guard !reduceMotion else { return }
            if isCurrent {
                withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                    pulseScale = 1.05
                }
            }
        }
        .onChange(of: currentStep) { _ in
            guard !reduceMotion else { return }
            if isCompleted {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    completedScale = 1.3
                }
                withAnimation(.easeOut(duration: 0.2).delay(0.2)) {
                    completedScale = 1.0
                }
            }
        }
    }

    private var dotColor: Color {
        if isCompleted { return SalmaDesign.Colors.primary }
        if isCurrent { return SalmaDesign.Colors.primary }
        return SalmaDesign.Colors.border
    }
}

private struct StepLine: View {
    let isCompleted: Bool
    let reduceMotion: Bool

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background line
                Capsule()
                    .fill(SalmaDesign.Colors.border)
                    .frame(height: 3)

                // Filled line
                Capsule()
                    .fill(SalmaDesign.Colors.primary)
                    .frame(width: isCompleted ? geometry.size.width : 0, height: 3)
                    .animation(
                        reduceMotion ? .none : .easeInOut(duration: 0.3),
                        value: isCompleted
                    )
            }
        }
        .frame(height: 3)
    }
}
