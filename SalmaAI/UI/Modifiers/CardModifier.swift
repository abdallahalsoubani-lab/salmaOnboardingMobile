import SwiftUI

struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(SalmaDesign.Colors.surface)
            .cornerRadius(SalmaDesign.Radius.md)
            .shadow(
                color: SalmaDesign.Shadows.card.color,
                radius: SalmaDesign.Shadows.card.radius,
                x: SalmaDesign.Shadows.card.x,
                y: SalmaDesign.Shadows.card.y
            )
    }
}
