//
//  Whisper.swift
//  read
//
//  Created by gidon on 2025/8/21.
//

import SwiftUI

struct RootView: View {
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        HomeView()
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active {
                    KeyboardPreloader.shared.preload()
                }
            }
            .onAppear {
                // 有些冷启动路径 .onChange 触发得稍晚，这里兜底
                KeyboardPreloader.shared.preload()
            }
    }
}
