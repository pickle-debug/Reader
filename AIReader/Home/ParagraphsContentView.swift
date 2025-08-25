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
            List {
                ForEach(viewModel.paragraphs) { p in
                    ParagraphCardView(text: p.paragraph.text)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)

                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            viewModel.deleteParagraph(uuid: p.paragraph.uuid)
                        } label: {
                            Label("删除", systemImage: "trash")
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .listStyle(.plain)
        }
    }
}
// 段落卡片视图
struct ParagraphCardView: View {
    let text: String
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(text)
                .font(.body)
                .foregroundColor(.primary)
                .lineLimit(3)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 4)
        }

        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.8))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}
