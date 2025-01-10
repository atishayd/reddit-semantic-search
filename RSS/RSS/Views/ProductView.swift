import SwiftUI
import Charts

struct CommentView: View {
    let comment: String
    let sentiment: Double
    @State private var isExpanded = false
    
    private var displayText: String {
        if isExpanded {
            return comment  // Show full comment when expanded
        } else {
            // Only truncate for display, not data
            return comment.count > 150 ? String(comment.prefix(150)) + "..." : comment
        }
    }
    
    private var sentimentLabel: String {
        if sentiment > 0.05 {
            return "Positive"
        } else if sentiment < -0.05 {
            return "Negative"
        } else {
            return "Neutral"
        }
    }
    
    private var sentimentColor: Color {
        if sentiment > 0.05 {
            return .green
        } else if sentiment < -0.05 {
            return .red
        } else {
            return .yellow
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Sentiment Label
            Text(sentimentLabel)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(sentimentColor.opacity(0.2))
                .foregroundColor(sentimentColor)
                .cornerRadius(4)
            
            // Comment Text
            Text(displayText)
                .font(.body)
                .lineLimit(isExpanded ? nil : 3)
                .animation(.easeInOut, value: isExpanded)
            
            // Only show Read More/Less if comment is longer than 150 characters
            if comment.count > 150 {
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation {
                            isExpanded.toggle()
                        }
                    }) {
                        Text(isExpanded ? "Read Less" : "Read More")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemBackground))
                .shadow(radius: 2)
        )
        // Animate the container size change
        .animation(.easeInOut, value: isExpanded)
    }
}

struct ProductView: View {
    let product: Product
    @State private var imageLoadError = false
    @State private var isLoading = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Product Image
                if let imageURL = product.imageURL {
                    AsyncImage(url: URL(string: imageURL)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(height: 200)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        case .failure(_):
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundStyle(.secondary)
                                .frame(height: 200)
                        @unknown def