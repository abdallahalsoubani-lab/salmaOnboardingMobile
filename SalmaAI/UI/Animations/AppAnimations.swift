import SwiftUI

struct AppAnimations {
    // Standard transitions
    static let defaultDuration: Double = 0.3
    static let fastDuration: Double = 0.15
    static let slowDuration: Double = 0.5

    // Spring animations (for interactive elements)
    static let buttonPress = Animation.spring(response: 0.3, dampingFraction: 0.6)
    static let cardAppear = Animation.spring(response: 0.5, dampingFraction: 0.8)
    static let sheetPresent = Animation.spring(response: 0.4, dampingFraction: 0.85)

    // Ease animations (for state changes)
    static let stateChange = Animation.easeInOut(duration: 0.3)
    static let fadeIn = Animation.easeOut(duration: 0.25)
    static let fadeOut = Animation.easeIn(duration: 0.2)

    // Page transitions
    static let pageForward = Animation.easeInOut(duration: 0.35)
    static let pageBackward = Animation.easeInOut(duration: 0.3)

    // Success/Error
    static let successPop = Animation.spring(response: 0.4, dampingFraction: 0.5)
    static let errorShake = Animation.linear(duration: 0.07)

    // Loading
    static let pulse = Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true)
    static let spin = Animation.linear(duration: 1.0).repeatForever(autoreverses: false)
}
