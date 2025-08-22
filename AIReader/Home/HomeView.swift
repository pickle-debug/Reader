import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showingCreateArticle = false
    @State private var newArticleName = ""
    @State private var newParagraphContent: String = ""

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
                        ArticlesContentView(viewModel: viewModel)
                    } else {
                        ParagraphsContentView(viewModel: viewModel)
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
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
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingCreateArticle) {
            CreateArticleView(
                articleName: $newArticleName,
                onSave: {
                    if !newArticleName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        viewModel.createArticle(newArticleName)
                        newArticleName = ""
                        showingCreateArticle = false
                    }
                },
                onCancel: {
                    newArticleName = ""
                    showingCreateArticle = false
                }
            )
        }
        .sheet(item: $viewModel.selectedArticle) { article in
            ArticleDetailView(article: article)
        }
    }
}

struct CreateArticleView: View {
    @Binding var articleName: String
    let onSave: () -> Void
    let onCancel: () -> Void
    
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("文章名称")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    TextField("输入文章名称", text: $articleName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .focused($isTextFieldFocused)
                }
                
                Spacer()
                
                HStack(spacing: 16) {
                    Button("取消", action: onCancel)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(20)
                    
                    Button("创建", action: onSave)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(articleName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(20)
                        .disabled(articleName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .padding(20)
            .navigationTitle("创建新文章")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消", action: onCancel)
                }
            }
        }
        .onAppear {
            isTextFieldFocused = true
        }
    }
}
#Preview {
    HomeView()
}
