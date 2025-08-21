import SwiftUI

struct EmptyStateView: View {
    let onAddText: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "text.quote")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("还没有文本")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            Text("点击右上角的 + 按钮添加你的第一段文本")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: onAddText) {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                    Text("添加文本")
                }
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.blue)
                .cornerRadius(20)
            }
        }
        .padding(.top, 100)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    EmptyStateView(onAddText: {})
}
