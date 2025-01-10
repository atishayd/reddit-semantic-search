import SwiftUI

struct PulsingView: ViewModifier {
    @State private var isAnimating = false
    
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.gray.opacity(0.0),
                        Color.gray.opacity(0.1),
                        Color.gray.opacity(0.0)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: isAnimating ? 200 : -200)
            )
            .mask(content)
            .onAppear {
                withAnimation(
                    .linear(duration: 1.5)
                    .repeatForever(autoreverses: false)
                ) {
                    isAnimating = true
                }
            }
    }
}

extension View {
    func pulsingAnimation() -> some View {
        modifier(PulsingView())
    }
} 