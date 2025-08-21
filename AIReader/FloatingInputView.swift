//
//  FloatInputView.swift
//  read
//
//  Created by gidon on 2025/8/21.
//

import SwiftUI

struct FloatingInputView: View {
    @Binding var inputText: String
    var onSend: () -> Void
    var placeholder: String = "输入新段落..."
    
    // 计算文本行数相关的常量
    private let lineHeight: CGFloat = 24 // 单行文本高度
    private let maxLines: Int = 5
    private let textFieldVerticalPadding: CGFloat = 8
    private let hstackVerticalPadding: CGFloat = 4
    
    // 计算最小和最大容器高度
    private var minContainerHeight: CGFloat {
        return lineHeight + (textFieldVerticalPadding * 2) + (hstackVerticalPadding * 2)
    }
    
    private var maxContainerHeight: CGFloat {
        return CGFloat(maxLines) * lineHeight + (textFieldVerticalPadding * 2) + (hstackVerticalPadding * 2)
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            TextField(placeholder, text: $inputText, axis: .vertical)
                .font(.body)
                .lineLimit(1...maxLines) // 限制行数范围
                .padding(.horizontal, 10)
                .padding(.vertical, textFieldVerticalPadding)
                .background(Color.clear)
                .fixedSize(horizontal: false, vertical: true) // 允许垂直方向根据内容调整
            
            Button(action: {
                onSend()
            }) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(inputText.isEmpty ? .gray.opacity(0.6) : .blue)
            }
            .disabled(inputText.isEmpty)
            .padding(.trailing, 8)
        }
        .padding(.vertical, hstackVerticalPadding)
        .frame(minHeight: minContainerHeight) // 设置最小高度
        .background {
            RoundedRectangle(cornerRadius: 25)
                .fill(.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 10)
    }
}
