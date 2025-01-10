import SwiftUI

struct ModernSearchBar: View {
    @Binding var text: String
    var onSubmit: () -> Void
    @FocusState private var isFocused: Bool
    @State private var isEditing = false
    
    var body: some View {
        HStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .font(.system(size: 17, weight: .medium))
                    .frame(width: 44, height: 44) // Apple's minimum touch target
                
                TextField("Search for a product...", text: $text)
                    .textFieldStyle(.plain)
                    .focused($isFocused)
                    .submitLabel(.search)
                    .onSubmit(onSubmit)
                    .onChange(of: text) { oldValue, newValue in
                        isEditing = true
                    }
                
                if !text.isEmpty {
                    Button(action: {
                        text = ""
                        isEditing = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .frame(width: 44, height: 44) // Apple's minimum touch target
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isFocused ? Color.blue : Color.clear, lineWidth: 1.5)
            )
            
            if isEditing {
                Button("Cancel") {
                    text = ""
                    isEditing = false
                    isFocused = false
                }
                .foregroundColor(.blue)
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .padding(.horizontal)
        .animation(.easeInOut(duration: 0.2), value: isEditing)
        .animation(.easeInOut(duration: 0.2), valu