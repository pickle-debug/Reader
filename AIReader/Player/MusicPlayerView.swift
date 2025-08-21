import SwiftUI

struct MusicPlayerView: View {
    @ObservedObject var viewModel: ArticleViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // 进度条区域 - 始终显示
            VStack(spacing: 8) {
                HStack {
                    Text(viewModel.isPlaying ? viewModel.currentTimeString : "0:00")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(viewModel.isPlaying ? viewModel.remainingTimeString : "0:00")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                ProgressView(value: viewModel.isPlaying ? viewModel.progress : 0.0)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            // 控制按钮区域
            HStack(spacing: 30) {
                Button(action: viewModel.cyclePlayMode) {
                    HStack(spacing: 6) {
                        Image(systemName: viewModel.playMode.icon)
                            .font(.caption)
                        Text(viewModel.playMode.description)
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(15)
                }
                
                Button(action: viewModel.previousTrack) {
                    Image(systemName: "backward.fill")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
                
                Button(action: viewModel.togglePlayback) {
                    Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                        .font(.largeTitle)
                        .foregroundColor(.primary)
                }
                
                Button(action: viewModel.nextTrack) {
                    Image(systemName: "forward.fill")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
                
                Button(action: viewModel.generateAIVoice) {
                    HStack(spacing: 8) {
                        Text("配音")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                                    .background(viewModel.selectedParagraphs.isEmpty ? Color.gray : Color.blue)
                .cornerRadius(20)
            }
            .disabled(viewModel.selectedParagraphs.isEmpty)
            }
            .padding(.bottom, 20)
        }
        .frame(height: 120) // 固定高度
        .background(
            // 毛玻璃效果背景
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial) // 或使用 .thinMaterial, .regularMaterial 等
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
        .padding(.horizontal, 16) // 左右边距
        .padding(.bottom, 8) // 底部边距
    }
}

#Preview {
    MusicPlayerView(viewModel: ArticleViewModel())
}
