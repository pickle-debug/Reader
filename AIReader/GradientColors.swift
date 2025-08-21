import SwiftUI

// 渐变颜色管理
struct GradientColors {
    // Apple Music风格的渐变颜色
    static let appleMusicGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 1.0, green: 0.925, blue: 0.824), // #ffecd2
            Color(red: 0.988, green: 0.714, blue: 0.624)  // #fcb69f
        ]),
        startPoint: .leading,
        endPoint: .trailing
    )
    
    // 颜色常量
    static let primaryGradientStart = Color(red: 1.0, green: 0.925, blue: 0.824) // #ffecd2
    static let primaryGradientEnd = Color(red: 0.988, green: 0.714, blue: 0.624) // #fcb69f
    
    // 阴影颜色
    static let selectedShadowColor = Color(red: 0.988, green: 0.714, blue: 0.624).opacity(0.3)
    static let normalShadowColor = Color.black.opacity(0.1)
    
    // 背景材质 - 使用SwiftUI原生颜色
    static let ultraThinMaterial = Color.white.opacity(0.8)
    static let thinMaterial = Color.white.opacity(0.9)
    static let regularMaterial = Color.white
    static let thickMaterial = Color.white
    static let ultraThickMaterial = Color.white
}

// 扩展Color以支持Apple Music风格的颜色
extension Color {
    static let appleMusicPrimary = Color(red: 1.0, green: 0.925, blue: 0.824)
    static let appleMusicSecondary = Color(red: 0.988, green: 0.714, blue: 0.624)
    
    // 创建Apple Music风格的渐变
    static func appleMusicGradient(startPoint: UnitPoint = .leading, endPoint: UnitPoint = .trailing) -> LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [appleMusicPrimary, appleMusicSecondary]),
            startPoint: startPoint,
            endPoint: endPoint
        )
    }
}

// 高斯模糊效果管理
struct BlurEffects {
    static let light = 0.3
    static let medium = 0.5
    static let heavy = 1.0
    static let extraHeavy = 2.0
}

// 阴影效果管理
struct ShadowEffects {
    static let light = Shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    static let medium = Shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    static let heavy = Shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 6)
    static let selected = Shadow(color: GradientColors.selectedShadowColor, radius: 12, x: 0, y: 6)
}

// 阴影结构
struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// 扩展View以支持自定义阴影
extension View {
    func customShadow(_ shadow: Shadow) -> some View {
        self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
    
    func appleMusicStyle(isSelected: Bool) -> some View {
        if isSelected {
            return self.shadow(
                color: GradientColors.selectedShadowColor,
                radius: 12,
                x: 0,
                y: 6
            )
        } else {
            return self.shadow(
                color: Color.black.opacity(0.1),
                radius: 8,
                x: 0,
                y: 4
            )
        }
    }
}
