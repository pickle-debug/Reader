//
//  ArticlesContentView.swift
//  read
//
//  Created by 何纪栋 on 2025/8/21.
//
import SwiftUI

struct ArticleCardView: View {
    let article: ArticleModel
    @ObservedObject var viewModel: HomeViewModel
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(article.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        Text("创建于 \(article.createTime.formatted(date: .abbreviated, time: .shortened))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        let stats = viewModel.getArticleStats(for: article)
                        Text("\(stats.paragraphCount) 段")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                        
                        Text("\(stats.voiceCount) 音色")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // 进度条（如果有段落）
                let stats = viewModel.getArticleStats(for: article)
                if stats.paragraphCount > 0 {
                    ProgressView(value: Double(stats.voiceCount), total: Double(stats.paragraphCount))
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        .scaleEffect(y: 0.8)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.8))
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}



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

