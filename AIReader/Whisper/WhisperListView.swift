//
//  WhisperListView.swift
//  read
//
//  Created by 何纪栋 on 2025/8/24.
//

import SwiftUI
struct WhisperListView: View {

    var body: some View {
        
        VStack {
            HStack {

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
            
            VStack {
                Text("继续播放")
                Text("正在自动播放")
            }
            
            List{
                
            }
        }
    }
}
