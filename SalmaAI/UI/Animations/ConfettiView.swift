import SwiftUI

struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .position(x: particle.x, y: particle.y)
                        .opacity(particle.opacity)
                }
            }
            .onAppear {
                guard !reduceMotion else { return }
                generateAndAnimate(in: geometry.size)
            }
        }
        .allowsHitTesting(false)
    }

    private func generateAndAnimate(in size: CGSize) {
        let center = CGPoint(x: size.width / 2, y: size.height / 2 - 60)
        let colors: [Color] = [
            SalmaDesign.Colors.primary,
            SalmaDesign.Colors.success,
            SalmaDesign.Colors.primary.opacity(0.6),
            SalmaDesign.Colors.success.opacity(0.6)
        ]

        var newParticles: [ConfettiParticle] = []
        for i in 0..<10 {
            let angle = Double(i) / 10.0 * 2.0 * .pi
            let distance = CGFloat.random(in: 60...140)
            let particle = ConfettiParticle(
                x: center.x,
                y: center.y,
                targetX: center.x + cos(angle) * distance,
                targetY: center.y + sin(angle) * distance,
                color: colors[i % colors.count],
                size: CGFloat.random(in: 6...12),
                opacity: 1.0
            )
            newParticles.append(particle)
        }
        particles = newParticles

        withAnimation(.easeOut(duration: 0.8)) {
            for i in particles.indices {
                particles[i].x = particles[i].targetX
                particles[i].y = particles[i].targetY
                particles[i].opacity = 0
                particles[i].size = 2
            }
        }
    }
}

struct ConfettiParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var targetX: CGFloat
    var targetY: CGFloat
    var color: Color
    var size: CGFloat
    var opacity: Double
}
