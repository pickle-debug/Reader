import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TextViewModel()
    @State private var newText = ""
    @State private var showingTextInput = false
    
    var body: some View {
        ZStack {
            GradientBackground()
            
            VStack(spacing: 0) {
                // Header - 固定高度
                HeaderView(viewModel: viewModel) {
                    showingTextInput = true
                }
                
                // Text List - 可滚动区域
                TextListView(viewModel: viewModel)
                
                // Music Player - 动态高度
                MusicPlayerView(viewModel: viewModel)
//                
//                // Bottom Controls - 固定高度
//                BottomControlsView(viewModel: viewModel)
            }
            
            // Loading Overlay
            LoadingOverlay(
                isShowing: viewModel.isGenerating,
                message: "正在生成AI配音..."
            )
        }
        .sheet(isPresented: $showingTextInput) {
            TextInputView(viewModel: viewModel)
        }
    }
}

struct TextInputView: View {
    @ObservedObject var viewModel: TextViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var inputText = ""
    @FocusState private var isTextFieldFocused: Bool
    
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
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .focused($isTextFieldFocused)
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
                            isTextFieldFocused = false
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
                    isTextFieldFocused = false
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .onTapGesture {
                isTextFieldFocused = false
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    ContentView()
}
