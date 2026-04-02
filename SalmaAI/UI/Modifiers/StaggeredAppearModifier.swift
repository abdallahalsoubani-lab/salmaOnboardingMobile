import SwiftUI

struct StaggeredAppearModifier: ViewModifier {
    let index: Int
    @State private var appeared = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            .onAppear {
                if reduceMotion {
                    appeared = true
                    return
                }
                let delay = min(Double(index) * 0.08, 0.5)
                withAnimation(AppAnimations.cardAppear.delay(delay)) {
                    appeared = true
                }
            }
    }
}

extension View {
    func staggeredAppear(index: Int) -> some View {
        modifier(StaggeredAppearModifier(index: index))
    }
}
