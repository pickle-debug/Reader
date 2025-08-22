//
//  Whisper.swift
//  read
//
//  Created by gidon on 2025/8/21.
//

import SwiftUI

struct RootView: View {
    @Environment(\.scenePhase) private var scenePhase

    // 路由状态 & 动画命名空间
    @State private var selectedArticle: ArticleModel?
    @Namespace private var articleNS

    var body: some View {
        ZStack {
            // 主界面
            HomeView(
                openArticle: { article in
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                        selectedArticle = article
                    }
                },
                matchedNS: articleNS
            )
            // 详情 Overlay：放在 Root，盖住 Home 顶部栏
            if let article = selectedArticle {
                ArticleDetailOverlay(
                    article: article,
                    ns: articleNS,
                    onClose: {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                            selectedArticle = nil
                        }
                    }
                )
                .ignoresSafeArea() // ★ 关键：覆盖整个屏幕
                .transition(.opacity.combined(with: .scale(scale: 0.98)))
                .zIndex(1)
            }
        }
        .statusBarHidden(selectedArticle != nil) // 需要时沉浸式
        // 你已有的键盘预热
        .onChange(of: scenePhase) { if $0 == .active { KeyboardPreloader.shared.preload() } }
        .onAppear { KeyboardPreloader.shared.preload() }
    }
}
