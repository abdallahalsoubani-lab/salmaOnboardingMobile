import SwiftUI

struct PageTransitionModifier: ViewModifier {
    let direction: TransitionDirection

    enum TransitionDirection {
        case forward
        case backward
    }

    func body(content: Content) -> some View {
        content
            .transition(
                .asymmetric(
                    insertion: direction == .forward
                        ? .move(edge: .leading).combined(with: .opacity)
                        : .move(edge: .trailing).combined(with: .opacity),
                    removal: direction == .forward
                        ? .move(edge: .trailing).combined(with: .opacity)
                        : .move(edge: .leading).combined(with: .opacity)
                )
            )
    }
}

extension View {
    func pageTransition(direction: PageTransitionModifier.TransitionDirection) -> some View {
        modifier(PageTransitionModifier(direction: direction))
    }
}
