import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showingCreateArticle = false
    @State private var newArticleName = ""
    @State private var newParagraphContent: String = ""
    
    @State private var expandSheet: Bool = false
    @Namespace private var animation
    
    let openArticle: (ArticleModel) -> Void
    let matchedNS: Namespace.ID

    var body: some View {
        NavigationView {
            ZStack {
                // 背景渐变
                GradientBackground()
                
                VStack(spacing: 0) {
                    // 顶部标题栏
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("语料库")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                
                                Text("管理你的文章和段落")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if viewModel.currentView == .articles {
                                Button(action: {
                                    showingCreateArticle = true
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        
                        // 内容类型切换
                        Picker("内容类型", selection: $viewModel.currentView) {
                            ForEach(HomeViewModel.ContentType.allCases, id: \.self) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal, 20)
                    }
                    .frame(height: 120)
                    .background(Color.clear)
                    
                    // 内容区域
                    if viewModel.currentView == .articles {
                        ArticlesContentView(viewModel: viewModel, onSelect: openArticle, ns: matchedNS)
                    } else {
                        ParagraphsContentView(viewModel: viewModel)
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 8) {
                if viewModel.currentView == .paragraphs {
                    FloatingInputView(inputText: $newParagraphContent) {
                        if !newParagraphContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            viewModel.createParagraph(newParagraphContent)
                        }
                        newParagraphContent = ""
                    }
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 5)
                } else {
                    MiniWhisperPlayerView()
                        .frame(height: 48)  // 设置固定高度
                        .background(.ultraThinMaterial, in: .rect(cornerRadius: 15, style: .continuous))
                        .padding(.horizontal, 16)
                        .matchedGeometryEffect(id: "MINIPLAYER", in: animation)

                        .onTapGesture {
                            expandSheet.toggle()
                        }
                }
            }
        }
        .overlay {
            if expandSheet {
                WhisperBottomSheet(expandSheet: $expandSheet, animation: animation)
                // Transtion for more fluent Animation
                    .transition(.asymmetric(insertion: .identity, removal: .offset(y: -5)))
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingCreateArticle) {
            ParagraphPickerView(viewModel: viewModel)
        }
    }
}
