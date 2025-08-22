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
                
                // 浮动输入框（只在段落视图显示）
                if viewModel.currentView == .paragraphs {
                    VStack {
                        Spacer()
                        FloatingInputView(inputText: $newParagraphContent) {
                            if !newParagraphContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                viewModel.createParagraph(content: newParagraphContent)
                            }
                            newParagraphContent = ""
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingCreateArticle) {
            CreateArticleView(
                articleName: $newArticleName,
                onSave: {
                    if !newArticleName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        viewModel.createArticle(name: newArticleName)
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

// 段落卡片视图
struct ParagraphCardView: View {
    let paragraph: ParagraphModel
    @ObservedObject var viewModel: HomeViewModel
    @State private var showingDeleteAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(paragraph.text)
                        .font(.body)
                        .foregroundColor(.primary)
                        .lineLimit(3)
                    
                    Text("创建于 \(paragraph.createTime.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(paragraph.voices.count) 音色")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                    
                    Menu {
                        Button("删除", role: .destructive) {
                            showingDeleteAlert = true
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title3)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.8))
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .alert("删除段落", isPresented: $showingDeleteAlert) {
            Button("取消", role: .cancel) { }
            Button("删除", role: .destructive) {
                viewModel.deleteParagraph(paragraph)
            }
        } message: {
            Text("确定要删除这个段落吗？这个操作不可撤销。")
        }
    }
}


// 修改ArticleCardView以适应新的数据结构
struct ArticleCardView: View {
    let article: ArticleModel
    @ObservedObject var viewModel: HomeViewModel
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(article.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        Text("创建于 \(article.createTime.formatted(date: .abbreviated, time: .shortened))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        let stats = viewModel.getArticleStats(for: article)
                        Text("\(stats.paragraphCount) 段")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                        
                        Text("\(stats.voiceCount) 音色")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // 进度条（如果有段落）
                let stats = viewModel.getArticleStats(for: article)
                if stats.paragraphCount > 0 {
                    ProgressView(value: Double(stats.voiceCount), total: Double(stats.paragraphCount))
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        .scaleEffect(y: 0.8)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.8))
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
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
