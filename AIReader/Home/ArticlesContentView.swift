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
    let onSelect: (ArticleModel) -> Void
    let ns: Namespace.ID
    
    var body: some View {
        ZStack {
            // 列表
            List {
                ForEach(viewModel.articles, id: \.uuid) { article in
                    ArticleCardView(article: article, viewModel: viewModel) {
                        onSelect(article)
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.white.opacity(0.8))
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                            .matchedGeometryEffect(id: "bg-\(article.uuid)", in: ns)
                    )
                }
            }
            .scrollContentBackground(.hidden)
            .listStyle(.plain)
        }
    }
}
