//
//  WhisperPlayerView.swift
//  read
//
//  Created by 何纪栋 on 2025/8/24.
//

import SwiftUI

struct WhisperPlayerView: View {
    var mainsize: CGSize
    var body: some View {
        
        GeometryReader {
            let size = $0.size
            let spacing = size.height * 0.04
            
            // Sizing it for more compact look
            VStack(spacing: spacing) {
                VStack(spacing: spacing) {
                    HStack(alignment: .center, spacing: 15) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Look What You Made Me do")
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Text("Taylor Swift")
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Button {
                            
                        } label: {
                            Image(systemName: "ellipsis")
                                .foregroundColor(.white)
                                .padding (12)
                                .background {
                                    Circle()
                                        .fill(.ultraThinMaterial)
                                        .environment(\.colorScheme, .light)
                                }
                        }
                    }
                    
                    // Timing Indicator
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .environment(\.colorScheme, .light)
                        .frame(height: 5)
                        .padding(.top, spacing)
                    
                    // Timing Label View
                    HStack {
                        Text("0:00")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Spacer(minLength: 0)
                        
                        Text("3:33")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                // Moving it to Top
                .frame(height: size.height / 2.5, alignment: .top)
                
                HStack {
                    // 左侧按钮
                    Button {
                        
                    } label: {
                        Image(systemName: "quote.bubble")
                            .font(.title3)  // 更小的字体
                    }
                    .padding(.leading, 20)  // 距离边缘更近
                    
                    Spacer()
                    
                    // 中间主要播放控制区域
                    HStack(spacing: size.width * 0.12) {  // 减小间距
                        Button {
                            
                        } label: {
                            Image(systemName: "backward.fill")
                                .font(size.height < 300 ? .title3 : .title)
                        }
                        
                        // Making Play/Pause Little Bigger
                        Button {
                            
                        } label: {
                            Image(systemName: "pause.fill")
                                .font(size.height < 300 ? .largeTitle : .system(size: 50))
                        }
                        
                        Button {
                            
                        } label: {
                            Image(systemName: "forward.fill")
                                .font(size.height < 300 ? .title3 : .title)
                        }
                    }
                    
                    Spacer()
                    
                    // 右侧按钮
                    Button {
                        
                    } label: {
                        Image(systemName: "quote.bubble")
                            .font(.title3)  // 更小的字体
                    }
                    .padding(.trailing, 20)  // 距离边缘更近
                }
                .foregroundColor(.white)
                .frame(maxHeight: .infinity)
            }
        }
    }
}
