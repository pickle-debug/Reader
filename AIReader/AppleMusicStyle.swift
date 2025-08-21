import SwiftUI

// Apple Music风格的样式管理
struct AppleMusicStyle {
    // 渐变颜色
    static let gradientStart = Color(red: 1.0, green: 0.925, blue: 0.824) // #ffecd2
    static let gradientEnd = Color(red: 0.988, green: 0.714, blue: 0.624) // #fcb69f
    
    // 创建渐变
    static func createGradient() -> LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [gradientStart, gradientEnd]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    // 背景颜色
    static let backgroundColor = Color.white.opacity(0.8)
    static let selectedBackgroundColor = Color.white.opacity(0.9)
    
    // 阴影颜色
    static let normalShadowColor = Color.black.opacity(0.1)
    static let selectedShadowColor = Color(red: 0.988, green: 0.714, blue: 0.624).opacity(0.3)
    
    // 模糊效果
    static let lightBlur: CGFloat = 0.3
    static let mediumBlur: CGFloat = 0.5
    static let heavyBlur: CGFloat = 1.0
}

// 扩展View以支持Apple Music样式
extension View {
    func appleMusicShadow(isSelected: Bool) -> some View {
        if isSelected {
            return self.shadow(
                color: AppleMusicStyle.selectedShadowColor,
                radius: 12,
                x: 0,
                y: 6
            )
        } else {
            return self.shadow(
                color: AppleMusicStyle.normalShadowColor,
                radius: 8,
                x: 0,
                y: 4
            )
        }
    }
}
