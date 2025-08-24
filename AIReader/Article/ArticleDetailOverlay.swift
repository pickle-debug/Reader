//
//  ArticleDetailOverlay.swift
//  read
//
//  Created by gidon on 2025/8/22.
//
import SwiftUI

struct ArticleDetailOverlay: View {
    let article: ArticleModel
    let ns: Namespace.ID
    let onClose: () -> Void
    @GestureState private var dragOffset: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            ArticleDetailView(article: article)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .background(
                    RoundedRectangle(cornerRadius: 0, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .matchedGeometryEffect(id: "bg-\(article.uuid)", in: ns)
                )
                .frame(width: geo.size.width, height: geo.size.height) 
                .offset(y: dragOffset) // 下拉退出
                .gesture(
                    DragGesture()
                        .updating($dragOffset) { v, st, _ in st = max(0, v.translation.height) }
                        .onEnded { v in if v.translation.height > 120 { onClose() } }
                )
        }
        .ignoresSafeArea()                  // 覆盖全屏
        .statusBarHidden(true)              // 可选：沉浸式
    }
}
