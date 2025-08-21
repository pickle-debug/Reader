import SwiftUI

struct LoadingView: View {
    let message: String
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(Color.blue.opacity(0.3), lineWidth: 4)
                    .frame(width: 60, height: 60)
                
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(Color.blue, lineWidth: 4)
                    .frame(width: 60, height: 60)
                    .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                    .animation(
                        Animation.linear(duration: 1)
                            .repeatForever(autoreverses: false),
                        value: isAnimating
                    )
            }
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(30)
        .background(Color.white.opacity(0.95))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.15), radius: 15, x: 0, y: 8)
        .onAppear {
            isAnimating = true
        }
    }
}

struct LoadingOverlay: View {
    let isShowing: Bool
    let message: String
    
    var body: some View {
        if isShowing {
            ZStack {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                
                LoadingView(message: message)
            }
        }
    }
}

#Preview {
    LoadingView(message: "正在生成AI配音...")
}
