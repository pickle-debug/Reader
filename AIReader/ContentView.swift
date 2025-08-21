import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TextViewModel()
    @State private var newText = ""
    @State private var showingTextInput = false
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    // Header
                    headerView
                    
                    // Text List
                    textListView
                    
                    // Bottom Controls
                    bottomControlsView
                }
                .background(Color(.systemGray6))
                .navigationBarHidden(true)
                
                // Loading Overlay
                LoadingOverlay(
                    isShowing: viewModel.isGenerating,
                    message: "正在生成AI配音..."
                )
            }
        }
        .sheet(isPresented: $showingTextInput) {
            TextInputView(viewModel: viewModel)
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("AI配音生成器")
                                            .font(.title2)
                    .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    if viewModel.selectedTexts.count > 0 {
                        Text("已选择\(viewModel.selectedTexts.count)段")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Button(action: {
                    showingTextInput = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            if viewModel.selectedTexts.count > 0 {
                HStack {
                    Text("\(viewModel.selectedTexts.count)段文本")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button("清除选择") {
                        viewModel.clearSelection()
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.bottom, 16)
        .background(Color(.systemBackground))
    }
    
    private var textListView: some View {
        ScrollView {
            if viewModel.texts.isEmpty {
                EmptyStateView {
                    showingTextInput = true
                }
                .padding(.top, 60)
            } else {
                LazyVStack(spacing: 16) {
                    // Now Playing Section
                    if viewModel.isPlaying && !viewModel.currentText.isEmpty {
                        NowPlayingView(
                            text: viewModel.currentText,
                            isPlaying: viewModel.isPlaying
                        )
                        .padding(.horizontal, 20)
                    }
                    
                    // Text List
                    LazyVStack(spacing: 12) {
                        ForEach(Array(viewModel.texts.enumerated()), id: \.offset) { index, text in
                            TextItemView(
                                text: text,
                                isSelected: viewModel.selectedTexts.contains(index),
                                onToggle: {
                                    viewModel.toggleSelection(index)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100) // Space for bottom controls
                }
            }
        }
    }
    
    private var bottomControlsView: some View {
        VStack(spacing: 0) {
            // Progress Bar
            if viewModel.isPlaying {
                VStack(spacing: 8) {
                    HStack {
                        Text(viewModel.currentTimeString)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(viewModel.remainingTimeString)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    ProgressView(value: viewModel.progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
            
            // Playback Controls
            HStack(spacing: 30) {
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
            }
            .padding(.bottom, 20)
            
            // Play Mode and Generate Button
            HStack(spacing: 20) {
                // Play Mode Button
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
                    .background(Color(.systemGray5))
                    .cornerRadius(15)
                }
                
                Spacer()
                
                // Generate AI Voice Button
                Button(action: viewModel.generateAIVoice) {
                    HStack(spacing: 8) {
                        Image(systemName: "waveform")
                            .font(.caption)
                        Text("生成AI配音")
                                                    .font(.subheadline)
                        .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(viewModel.selectedTexts.isEmpty ? Color.gray : Color.blue)
                    .cornerRadius(20)
                }
                .disabled(viewModel.selectedTexts.isEmpty)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .background(Color(.systemBackground))
    }
}

struct TextItemView: View {
    let text: String
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(text)
                        .font(.body)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)
                    
                    Text("\(text.count)个字符")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(isSelected ? .blue : .gray)
            }
            .padding(16)
            .background(isSelected ? Color.blue.opacity(0.1) : Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TextInputView: View {
    @ObservedObject var viewModel: TextViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var inputText = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("输入文本")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    TextEditor(text: $inputText)
                        .frame(minHeight: 120)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                }
                
                HStack {
                    Text("\(inputText.count)个字符")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button("添加文本") {
                        if !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            viewModel.addText(inputText.trimmingCharacters(in: .whitespacesAndNewlines))
                            inputText = ""
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.blue)
                    .cornerRadius(20)
                    .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                
                Spacer()
            }
            .padding(20)
            .navigationTitle("添加新文本")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("取消") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

#Preview {
    ContentView()
}
