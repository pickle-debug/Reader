//
//  MiniWhisperPlayerView.swift
//  read
//
//  Created by 何纪栋 on 2025/8/24.
//

import SwiftUI

struct MiniWhisperPlayerView: View {
    var body: some View {
        HStack (spacing: 15) {
            WhisperInfo(size: .init(width: 30, height: 30))
            Spacer(minLength: 0)
                       
            Button {
                
            } label: {
                Image(systemName: "play.fill")
                    .contentShape(.rect)
                
            }
            .padding(.trailing, 10)
            Button {
                
            } label: {
                Image(systemName: "forward.fill")
                    .contentShape(.rect)
                
            }
        }
        .padding(.horizontal, 15)
    }
}
