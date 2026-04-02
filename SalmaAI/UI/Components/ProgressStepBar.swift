import SwiftUI

struct ProgressStepBar: View {
    let currentStep: Int
    let totalSteps: Int

    var body: some View {
        HStack(spacing: SalmaDesign.Spacing.xs) {
            ForEach(1...totalSteps, id: \.self) { step in
                Capsule()
                    .fill(step <= currentStep ? SalmaDesign.Colors.primary : SalmaDesign.Colors.border)
                    .frame(height: 4)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: currentStep)
    }
}
