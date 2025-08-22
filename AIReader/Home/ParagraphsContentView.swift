//
//  ParagraphsContentView.swift
//  read
//
//  Created by 何纪栋 on 2025/8/21.
//

import SwiftUI

// 段落内容视图
struct ParagraphsContentView: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        if viewModel.paragraphs.isEmpty {
            EmptyStateView(
                icon: "text.alignleft",
                title: "还没有段落",
                subtitle: "使用下方的输入框创建你的第一个段落"
            )
        } else {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.paragraphs, id: \.uuid) { paragraph in
                        ParagraphCardView(paragraph: paragraph, viewModel: viewModel)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
        }
    }
}
