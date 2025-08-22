//
//  ArticlesContentView.swift
//  read
//
//  Created by 何纪栋 on 2025/8/21.
//
import SwiftUI

// 文章内容视图
struct ArticlesContentView: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        if viewModel.articles.isEmpty {
            EmptyStateView(
                icon: "doc.text",
                title: "还没有文章",
                subtitle: "点击右上角的 + 按钮创建你的第一篇文章"
            ) {
                // 可以添加创建文章的快捷按钮
            }
        } else {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.articles, id: \.uuid) { article in
                        ArticleCardView(article: article, viewModel: viewModel) {
                            viewModel.selectArticle(article)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
        }
    }
}

