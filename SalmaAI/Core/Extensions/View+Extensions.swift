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
}
