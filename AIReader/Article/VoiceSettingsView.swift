import SwiftUI

// 语音选项数据模型
struct VoiceOption: Identifiable, Hashable {
    let id = UUID() // 确保每个选项实例都有一个唯一的ID
    let name: String
    let description: String
    let icon: String? // SF Symbols name
    let value: String // 新增的属性，用于存储实际的后端/API值
    
    // Hashable 实现：基于 id 进行哈希
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Equatable 实现：基于 id 进行比较
    static func == (lhs: VoiceOption, rhs: VoiceOption) -> Bool {
        lhs.id == rhs.id
    }
}

// 自定义选择器按钮
struct CustomPickerButton: View {
    let title: String
    @Binding var selectedOption: VoiceOption
    let options: [VoiceOption]
    @State private var showingOptions = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Button(action: {
                showingOptions = true
            }) {
                HStack {
                    if let icon = selectedOption.icon {
                        Image(systemName: icon)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(selectedOption.name)
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .sheet(isPresented: $showingOptions) {
            OptionsSelectionView(
                title: title,
                selectedOption: $selectedOption,
                options: options
            )
        }
    }
}

// 选项选择页面
struct OptionsSelectionView: View {
    let title: String
    @Binding var selectedOption: VoiceOption
    let options: [VoiceOption]
    @Environment(\.dismiss) private var dismiss
    
    // Helper functions for icon colors (保持不变，以提供更好的视觉区分)
    private func iconBackgroundColor(for option: VoiceOption) -> Color {
        selectedOption.id == option.id ? Color.blue.opacity(0.1) : Color(.systemGray5)
    }
    
    private func iconForegroundColor(for option: VoiceOption) -> Color {
        selectedOption.id == option.id ? .blue : .primary
    }
    
    var body: some View {
        NavigationView { // 确保有导航栏来显示标题和“完成”按钮
            // 使用 List 来显示选项，它会自动处理滚动和视觉样式
            List {
                ForEach(options) { option in
                    Button(action: {
                        selectedOption = option // 更新选中项
                        dismiss() // 关闭 sheet
                    }) {
                        HStack(spacing: 16) {
                            // 图标容器
                            ZStack {
                                Circle()
                                    .fill(iconBackgroundColor(for: option))
                                    .frame(width: 40, height: 40)
                                
                                Image(systemName: option.icon ?? "circle")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(iconForegroundColor(for: option))
                            }
                            
                            // 文本内容
                            VStack(alignment: .leading, spacing: 2) {
                                Text(option.name)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                
                                Text(option.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            // 选中状态指示
                            if selectedOption.id == option.id {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.vertical, 4) // 适当调整垂直内边距
                    }
                    .buttonStyle(PlainButtonStyle()) // 确保按钮点击区域透明
                }
            }
            .navigationTitle(title) // 标题显示在List上方
            .navigationBarTitleDisplayMode(.large) // large标题，留出更多空间
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss() // 点击完成关闭 sheet
                    }
                }
            }
        }
        .presentationDetents([.medium, .large]) // 允许sheet有中等和大型两种高度
        .presentationDragIndicator(.visible) // 显示拖动指示器
    }
}
// 生成按钮
struct GenerateButton: View {
    let isGenerating: Bool
    let onGenerate: () -> Void
    
    @State private var animationPhase: CGFloat = 0
    
    var body: some View {
        Button(action: {
            if !isGenerating {
                onGenerate()
            }
        }) {
            HStack(spacing: 8) {
                if isGenerating {
                    // 旋转的加载动画
                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(
                            LinearGradient(
                                colors: [.blue, .purple, .pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 16, height: 16)
                        .rotationEffect(.degrees(animationPhase))
                        .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: animationPhase)
                        .onAppear {
                            animationPhase = 360
                        }
                    
                    Text("生成中...")
                        .font(.body)
                        .fontWeight(.medium)
                } else {
                    Image(systemName: "wand.and.stars")
                        .font(.body)
                    
                    Text("生成语音")
                        .font(.body)
                        .fontWeight(.medium)
                }
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    colors: isGenerating ? 
                        [Color.gray.opacity(0.6), Color.gray.opacity(0.4)] :
                        [Color.blue, Color.purple, Color.pink],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(25)
            .scaleEffect(isGenerating ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isGenerating)
        }
        .disabled(isGenerating)
        .buttonStyle(PlainButtonStyle())
    }
}

// 主语音设置视图
struct VoiceSettingsView: View {
    @StateObject var viewModel: VoiceViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            // 第一行：语音选择、语速调节、音调高低
            HStack(spacing: 12) {
                CustomPickerButton(
                    title: "语音选择",
                    selectedOption: $viewModel.selectedVoice,
                    options: viewModel.voiceOptions
                )
                
                CustomPickerButton(
                    title: "语速调节",
                    selectedOption: $viewModel.selectedSpeed,
                    options: viewModel.speedOptions
                )
                
                CustomPickerButton(
                    title: "音调高低",
                    selectedOption: $viewModel.selectedPitch,
                    options: viewModel.pitchOptions
                )
            }
            
            // 第二行：语音风格
            HStack {
                CustomPickerButton(
                    title: "语音风格",
                    selectedOption: $viewModel.selectedStyle,
                    options: viewModel.styleOptions
                )
                
                Spacer()
            }
            
            // 生成按钮
            HStack {
                Spacer()
                GenerateButton(
                    isGenerating: viewModel.isGenerating,
                    onGenerate: viewModel.generateVoiceForAllParagraphs
                )
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 5)
    }
}


