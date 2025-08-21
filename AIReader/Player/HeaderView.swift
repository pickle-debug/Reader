import SwiftUI

struct HeaderView: View {
    @ObservedObject var viewModel: ArticleViewModel
    let onAddText: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("AI配音生成器")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    if viewModel.selectedParagraphs.count > 0 {
                        Text("已选择\(viewModel.selectedParagraphs.count)段")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Button(action: onAddText) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            if viewModel.selectedParagraphs.count > 0 {
                HStack {
                    Text("\(viewModel.selectedParagraphs.count)段文本")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button("清除选择") {
                        viewModel.clearSelection()
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
                .padding(.horizontal, 20)
            }
        }
        .frame(height: 80) // 固定高度
        .background(Color.clear)
    }
}

#Preview {
    HeaderView(viewModel: ArticleViewModel(), onAddText: {})
}
