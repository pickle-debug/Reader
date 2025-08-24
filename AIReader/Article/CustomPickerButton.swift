//
//  CustomPickerButton.swift
//  read
//
//  Created by 何纪栋 on 2025/8/24.
//


import SwiftUI
//
//struct CustomPickerButton: View {
//    let title: String
//    @Binding var selectedOption: VoiceOption
//    let options: [VoiceOption]
//    
//    @State private var showingCustomOverlay = false
//    @State private var buttonFrame: CGRect = .zero // 存储按钮的几何信息
//    
//    // 为每个CustomPickerButton生成唯一的matchedGeometryID
//    private let matchedGeometryID = UUID().uuidString 
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text(title)
//                .font(.caption)
//                .fontWeight(.semibold)
//                .foregroundColor(.primary)
//            
//            Button(action: {
//                showingCustomOverlay = true
//            }) {
//                HStack {
//                    if let icon = selectedOption.icon {
//                        Image(systemName: icon)
//                            .font(.caption)
//                            .foregroundColor(.secondary)
//                    }
//                    
//                    Text(selectedOption.name)
//                        .font(.body)
//                        .foregroundColor(.primary)
//                    
//                    Spacer()
//                    
//                    Image(systemName: "chevron.down")
//                        .font(.caption)
//                        .foregroundColor(.secondary)
//                }
//                .padding(.horizontal, 12)
//                .padding(.vertical, 10)
//                .background(Color(.systemGray6))
//                .cornerRadius(12)
//            }
//            .buttonStyle(PlainButtonStyle())
//            // 获取按钮的frame
//            .background(
//                GeometryReader { proxy in
//                    Color.clear.onAppear {
//                        buttonFrame = proxy.frame(in: .global)
//                    }
//                    .onChange(of: proxy.frame(in: .global)) { newFrame in
//                        buttonFrame = newFrame // 确保 frame 更新
//                    }
//                }
//            )
//        }
//        // 当 showingCustomOverlay 为 true 时，在最顶层显示我们的自定义视图
//        .fullScreenCover(isPresented: $showingCustomOverlay) { // 或者使用 .overlay(isPresented: $showingCustomOverlay)
//            CustomOverlaySelectionView(
//                isPresented: $showingCustomOverlay,
//                title: title,
//                selectedOption: $selectedOption,
//                options: options,
//                sourceRect: buttonFrame, // 传递按钮的位置
//            )
//        }
//    }
//}
