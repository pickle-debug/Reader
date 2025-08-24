import SwiftUI

struct GradientBackground: View {
    var body: some View {
        GradientBackground.gradient
            .ignoresSafeArea()
    }
    
    // 添加一个计算属性来返回 LinearGradient
    static var gradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.992, green: 0.988, blue: 0.984), // #fdfcfb
                Color(red: 0.886, green: 0.820, blue: 0.765)  // #e2d1c3
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
// 扩展Color以支持十六进制颜色
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// 使用十六进制颜色的渐变背景
struct HexGradientBackground: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(hex: "#fdfcfb"),
                Color(hex: "#e2d1c3")
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

#Preview {
    VStack {
        Text("渐变背景预览")
            .font(.title)
            .foregroundColor(.primary)
        Spacer()
    }
    .background(GradientBackground())
}
