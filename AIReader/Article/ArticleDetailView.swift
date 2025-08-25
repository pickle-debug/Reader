import SwiftUI
import Foundation

struct ArticleDetailView: View {
    @StateObject private var detailViewModel: ArticleDetailViewModel
    @Environment(\.presentationMode) var presentationMode
    
    init(article: ArticleModel) {
        self._detailViewModel = StateObject(wrappedValue: ArticleDetailViewModel(article: article))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                GradientBackground()
                GeometryReader { geo in
                    VStack(spacing: 0) {
                        HStack {
                            Spacer()
                            Capsule()
                                .fill(.secondary)
                                .frame(width: 40, height: 5)
                                .opacity(0.6)
                            Spacer()
                        }
                        .padding(.top, 12)
                        .padding(.horizontal, 16)
                        
                        // 文章信息头部
                        VStack(spacing: 12) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(detailViewModel.article.name)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                }
                                
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                        }
                        .frame(height: 80)
                        .background(Color.clear)
                        
                        List {
                            ForEach(detailViewModel.paragraphs) { p in
                                ParagraphCardView(text: p.paragraph.text)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                            }
                        }
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .listStyle(.plain)
                        
                        // 语音设置组件
                        VoiceSettingsView(viewModel: VoiceViewModel(article: detailViewModel.article))
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}
