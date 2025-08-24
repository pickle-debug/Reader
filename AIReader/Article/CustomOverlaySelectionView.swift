//
//  CustomOverlaySelectionView.swift
//  read
//
//  Created by 何纪栋 on 2025/8/24.
//
import SwiftUI
//
//struct CustomOverlaySelectionView: View {
//    @Binding var isPresented: Bool
//    let title: String
//    @Binding var selectedOption: VoiceOption
//    let options: [VoiceOption]
//    let sourceRect: CGRect // 用于动画的起始位置
//
//    @State private var contentScale: CGFloat = 0.001 // 初始极小
//    @State private var contentOpacity: Double = 0.0 // 初始透明度
//    @State private var blurOpacity: Double = 0.0 // 模糊背景初始透明度
//    @State private var contentOffset: CGSize = .zero // 内容偏移量
//
//    var body: some View {
//        ZStack {
//            // 模糊背景
//            Rectangle()
//                .fill(.ultraThinMaterial) // 使用 ultraThinMaterial 模拟 Messages 虚化效果
//                .opacity(blurOpacity)
//                .background(.clear)
//                .onTapGesture {
//                    dismissView()
//                }
//
//            // 选项内容
//            OptionSelectionContent(
//                title: title,
//                selectedOption: $selectedOption,
//                options: options,
//                onDismiss: dismissView
//            )
//            .frame(width: 300, height: 350) // 设定一个合适的大小
//            .background(
//                RoundedRectangle(cornerRadius: 12)
//                    .fill(Color(.systemBackground))
//            )
//            .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
//            .scaleEffect(contentScale)
//            .opacity(contentOpacity)
//            .offset(contentOffset) // 应用偏移
//        }
//        .ignoresSafeArea()
//        .onAppear(perform: setupInitialStateAndAnimateIn)
//        .transition(.identity)
//    }
//    
//    private func setupInitialStateAndAnimateIn() {
//        // 计算初始位置，使其位于 sourceRect 的中心
//        let initialX = sourceRect.midX - (300 / 2) // content width is 300
//        let initialY = sourceRect.midY - (350 / 2) // content height is 350
//        contentOffset = CGSize(width: initialX - UIScreen.main.bounds.midX + 150, // 调整到屏幕中央的偏移
//                               height: initialY - UIScreen.main.bounds.midY + 175)
//
//        // 立即开始动画
//        DispatchQueue.main.async { // 确保在视图完全加载后进行动画
//            withAnimation(.spring(response: 0.35, dampingFraction: 0.75, blendDuration: 0.2)) {
//                contentScale = 1.0
//                contentOpacity = 1.0
//                blurOpacity = 1.0
//                contentOffset = .zero // 动画到中心
//            }
//        }
//    }
//
//    private func dismissView() {
//        withAnimation(.spring(response: 0.25, dampingFraction: 0.8, blendDuration: 0.2)) {
//            contentScale = 0.001 // 缩小回极小
//            contentOpacity = 0.0
//            blurOpacity = 0.0
//            // 动画回到源位置
//            let finalX = sourceRect.midX - (300 / 2)
//            let finalY = sourceRect.midY - (350 / 2)
//            contentOffset = CGSize(width: finalX - UIScreen.main.bounds.midX + 150,
//                                   height: finalY - UIScreen.main.bounds.midY + 175)
//        } completion: {
//            isPresented = false
//        }
//    }
//}
