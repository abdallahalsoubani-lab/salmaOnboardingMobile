import SwiftUI

struct CameraFlashModifier: ViewModifier {
    @Binding var trigger: Bool
    @State private var flashOpacity: Double = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                Color.white
                    .opacity(flashOpacity)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            )
            .onChange(of: trigger) { newValue in
                if newValue {
                    withAnimation(.easeIn(duration: 0.05)) {
                        flashOpacity = 0.8
                    }
                    withAnimation(.easeOut(duration: 0.15).delay(0.05)) {
                        flashOpacity = 0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        trigger = false
                    }
                }
            }
    }
}

extension View {
    func cameraFlash(trigger: Binding<Bool>) -> some View {
        modifier(CameraFlashModifier(trigger: trigger))
    }
}
