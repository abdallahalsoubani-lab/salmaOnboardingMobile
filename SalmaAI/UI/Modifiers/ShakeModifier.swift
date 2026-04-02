import SwiftUI

struct ShakeModifier: GeometryEffect {
    var amount: CGFloat = 6
    var shakes: CGFloat

    var animatableData: CGFloat {
        get { shakes }
        set { shakes = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = amount * sin(shakes * .pi * 2)
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}

struct ShakeEffect: ViewModifier {
    var trigger: Bool
    @State private var shakeOffset: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .offset(x: shakeOffset)
            .onChange(of: trigger) { newValue in
                if newValue { shakeSequence() }
            }
    }

    private func shakeSequence() {
        let d = 0.07
        withAnimation(.linear(duration: d)) { shakeOffset = -10 }
        DispatchQueue.main.asyncAfter(deadline: .now() + d) {
            withAnimation(.linear(duration: d)) { shakeOffset = 10 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + d * 2) {
            withAnimation(.linear(duration: d)) { shakeOffset = -6 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + d * 3) {
            withAnimation(.linear(duration: d)) { shakeOffset = 6 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + d * 4) {
            withAnimation(.linear(duration: d)) { shakeOffset = 0 }
        }
    }
}
