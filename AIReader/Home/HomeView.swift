import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showingCreateArticle = false
    @State private var newArticleName = ""
    
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
                                Text("AI配音生成器")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                
                                Text("管理你的文章和配音")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                showingCreateArticle = true
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    }
                    .frame(height: 80)
                    .background(Color.clear)
                    
                    // 文章列表
                    if viewModel.articles.isEmpty {
                        // 空状态
                        VStack(spacing: 20) {
                            Image(systemName: "doc.text")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            
                            Text("还没有文章")
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            Text("点击右上角的 + 按钮创建你的第一篇文章")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Button(action: {
                                showingCreateArticle = true
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "plus")
                                    Text("创建文章")
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
                    } else {
                        // 文章列表
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(viewModel.articles, id: \.uuid) { article in
                                    ArticleCardView(article: article) {
                                        viewModel.selectArticle(article)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 100)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
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

struct ArticleCardView: View {
    let article: ArticleModel
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
                        Text("\(article.paragraphCount) 段")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                        
                        Text("\(article.voiceCount) 音色")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // 进度条（如果有段落）
                if article.paragraphCount > 0 {
                    ProgressView(value: Double(article.voiceCount), total: Double(article.paragraphCount))
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
