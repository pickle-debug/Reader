//
//  OptionSelectionContent.swift
//  read
//
//  Created by 何纪栋 on 2025/8/24.
//

import SwiftUI

struct OptionSelectionContent: View {
    let title: String
    @Binding var selectedOption: VoiceOption
    let options: [VoiceOption]
    var onDismiss: () -> Void // 添加一个关闭回调
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部导航栏，我们自定义它
            HStack {
                Text(title)
                    .font(.headline) // 使用headline或title，看原Messages应用风格
                    .fontWeight(.semibold)
                Spacer()
                Button("完成") {
                    onDismiss()
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(.systemBackground).opacity(0.9)) // 轻微的背景，避免选项和标题混淆
            
            // 选项列表
            ScrollView { // 使用ScrollView以防内容过多
                LazyVStack(spacing: 0) {
                    ForEach(options) { option in
                        Button(action: {
                            selectedOption = option
                            onDismiss() // 选中后也关闭
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
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                selectedOption.id == option.id ?
                                    Color.blue.opacity(0.1) :
                                    Color.clear
                            )
                            .contentShape(Rectangle()) // 使整个HStack可点击
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        if option.id != options.last?.id {
                            Divider()
                                .padding(.leading, 72)
                        }
                    }
                }
            }
        }
        .background(Color(.systemBackground)) // 列表内容的背景
        .cornerRadius(12)
        .padding(.horizontal, 16)
        .padding(.vertical, 8) // 微调垂直内边距
    }
    
    // 颜色辅助函数 (从OptionsSelectionView移动过来)
    func iconBackgroundColor(for option: VoiceOption) -> Color {
        if option.icon?.contains("person") == true {
            return Color.blue.opacity(0.2)
        } else if option.icon?.contains("bolt") == true {
            return Color.orange.opacity(0.2)
        } else if option.icon?.contains("music") == true || option.icon?.contains("arrow") == true {
            return Color.purple.opacity(0.2)
        } else if option.icon?.contains("theatermasks") == true {
            return Color.pink.opacity(0.2)
        } else {
            return Color(.systemGray5)
        }
    }
    
    func iconForegroundColor(for option: VoiceOption) -> Color {
        if option.icon?.contains("person") == true {
            return .blue
        } else if option.icon?.contains("bolt") == true {
            return .orange
        } else if option.icon?.contains("music") == true || option.icon?.contains("arrow") == true {
            return .purple
        } else if option.icon?.contains("theatermasks") == true {
            return .pink
        } else {
            return .primary
        }
    }
}
