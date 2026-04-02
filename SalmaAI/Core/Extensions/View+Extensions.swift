import SwiftUI

extension View {
    func salmaCard() -> some View {
        modifier(CardModifier())
    }

    func dismissKeyboardOnTap() -> some View {
        modifier(KeyboardDismissModifier())
    }

    func shake(trigger: Bool) -> some View {
        modifier(ShakeModifier(shakes: trigger ? 2 : 0))
    }

    func staggeredAppear(index: Int) -> some View {
        modifier(StaggeredAppearModifier(index: index))
    }

    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }

    func pressAnimation() -> some View {
        modifier(ButtonPressModifier())
    }

    func cameraFlash(trigger: Binding<Bool>) -> some View {
        modifier(CameraFlashModifier(trigger: trigger))
    }

    func pageTransition(direction: PageTransitionModifier.TransitionDirection) -> some View {
        modifier(PageTransitionModifier(direction: direction))
    }
}
