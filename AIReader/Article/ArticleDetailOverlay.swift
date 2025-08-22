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
            ZStack(alignment: .top) {
                // 背景遮罩
                Color.black.opacity(0.25)
                    .ignoresSafeArea()
                    .onTapGesture { onClose() }

                // 内容容器：铺满屏幕
                VStack(spacing: 0) {
                    // 顶部抓手/关闭，考虑到安全区顶
                    HStack {
                        Capsule()
                            .fill(.secondary)
                            .frame(width: 40, height: 5)
                            .opacity(0.6)
                        Spacer()
                        Button { onClose() } label: {
                            Image(systemName: "xmark.circle.fill").imageScale(.large)
                        }
                    }
                    .padding(.top, max(8, geo.safeAreaInsets.top + 4))
                    .padding(.horizontal, 16)

                    // 详情内容：占满剩余空间
                    ArticleDetailView(article: article)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                }
                .background(
                    // 背景与列表卡片做几何匹配；全屏时圆角为 0
                    RoundedRectangle(cornerRadius: 0, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .matchedGeometryEffect(id: "bg-\(article.uuid)", in: ns)
                )
                .frame(width: geo.size.width, height: geo.size.height) // ★ 关键：强制铺满
                .offset(y: dragOffset) // 下拉退出
                .gesture(
                    DragGesture()
                        .updating($dragOffset) { v, st, _ in st = max(0, v.translation.height) }
                        .onEnded { v in if v.translation.height > 120 { onClose() } }
                )
            }
        }
        .ignoresSafeArea()                  // 覆盖全屏
        .statusBarHidden(true)              // 可选：沉浸式
    }
}
