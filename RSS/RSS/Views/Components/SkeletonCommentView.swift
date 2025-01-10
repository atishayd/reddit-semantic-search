import SwiftUI

struct SkeletonCommentView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Skeleton Sentiment Label
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 80, height: 24)
            
            // Skeleton Comment Lines
            VStack(alignment: .leading, spacing: 8) {
                ForEach(0..<3) { index in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 16)
                        .frame(width: index == 2 ? 200 : nil) // Last line shorter
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemBackground))
                .shadow(radius: 2)
        )
        .opacity(isAnimating ? 0.6 : 1.0)
        .animation(
            Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true),
            value: isAnimating
        )
        .onAppear {
            isAnimating = true
        }
    }
} 