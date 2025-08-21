import SwiftUI

struct NowPlayingView: View {
    let text: String
    let isPlaying: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            // Album Art Placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient(
                        colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "waveform")
                    .font(.title)
                    .foregroundColor(.white)
            }
            
            // Text Info
            VStack(spacing: 4) {
                Text("当前播放")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(text)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            
            // Playing Indicator
            if isPlaying {
                HStack(spacing: 4) {
                    ForEach(0..<3) { index in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.blue)
                            .frame(width: 3, height: 20)
                            .scaleEffect(y: 0.3 + Double(index) * 0.2, anchor: .bottom)
                            .animation(
                                Animation.easeInOut(duration: 0.6)
                                    .repeatForever()
                                    .delay(Double(index) * 0.1),
                                value: isPlaying
                            )
                    }
                }
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.9))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    NowPlayingView(
        text: "Hello, this is a sample text for AI voice generation.",
        isPlaying: true
    )
}
