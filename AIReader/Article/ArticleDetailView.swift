import SwiftUI
import Foundation


struct ArticleDetailView: View {
    let article: ArticleModel
    @StateObject private var detailViewModel: ArticleDetailViewModel
    @StateObject private var articleViewModel = ArticleViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var showingAddParagraph = false
    @State private var newParagraphText = ""
    
   init(article: ArticleModel) {
    self.article = article
    self._detailViewModel = StateObject(wrappedValue: ArticleDetailViewModel(article: article))
}

    var body: some View {
        NavigationView {
            ZStack {
                GradientBackground()
                
                VStack(spacing: 0) {
                    // 文章信息头部
                    VStack(spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(article.name)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                
                                Text("\(article.paragraphCount) 段落 · \(article.voiceCount) 音色")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                showingAddParagraph = true
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
                    
                    // 段落列表
                    if detailViewModel.paragraphs.isEmpty {
                        // 空状态
                        VStack(spacing: 20) {
                            Image(systemName: "text.quote")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            
                            Text("还没有段落")
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            Text("点击右上角的 + 按钮添加第一个段落")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Button(action: {
                                showingAddParagraph = true
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "plus")
                                    Text("添加段落")
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
                        // 段落列表
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(Array(detailViewModel.paragraphs.enumerated()), id: \.element.uuid) { index, paragraph in
                                    ParagraphCardView(
                                        paragraph: paragraph,
                                        index: index,
                                        onEdit: {
                                            detailViewModel.editParagraph(at: index)
                                        },
                                        onDelete: {
                                            detailViewModel.deleteParagraph(at: index)
                                        },
                                        onGenerateVoice: {
                                            detailViewModel.generateVoice(for: paragraph)
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 100)
                        }
                    }
                    
                    // 音乐播放器
                    MusicPlayerView(viewModel: articleViewModel)
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
        // 在视图出现时连接两个ViewModel
        detailViewModel.onParagraphsUpdated = { paragraphs in
            articleViewModel.setParagraphs(paragraphs)
        }
    }
        .sheet(isPresented: $showingAddParagraph) {
            AddParagraphView(
                paragraphText: $newParagraphText,
                onSave: {
                    if !newParagraphText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        detailViewModel.addParagraph(text: newParagraphText)
                        newParagraphText = ""
                        showingAddParagraph = false
                    }
                },
                onCancel: {
                    newParagraphText = ""
                    showingAddParagraph = false
                }
            )
        }
        .sheet(item: $detailViewModel.editingParagraph) { paragraph in
            EditParagraphView(
                paragraph: paragraph,
                onSave: { newText in
                    detailViewModel.updateParagraph(text: newText)
                },
                onCancel: {
                    detailViewModel.cancelEdit()
                }
            )
        }
        .overlay(
            // 返回按钮
            VStack {
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("返回")
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(12)
                    }
                    .padding(.leading, 20)
                    .padding(.top, 10)
                    
                    Spacer()
                }
                Spacer()
            }
        )
    }
}

struct ParagraphCardView: View {
    let paragraph: ParagraphModel
    let index: Int
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onGenerateVoice: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("段落 \(index + 1)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                
                Spacer()
                
                HStack(spacing: 8) {
                    Button(action: onEdit) {
                        Image(systemName: "pencil")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
            
            Text(paragraph.text)
                .font(.body)
                .foregroundColor(.primary)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
            
            HStack {
                Text("\(paragraph.voices.count) 个音色")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: onGenerateVoice) {
                    HStack(spacing: 4) {
                        Image(systemName: "waveform")
                            .font(.caption)
                        Text("生成音色")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue)
                    .cornerRadius(12)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.8))
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}

struct AddParagraphView: View {
    @Binding var paragraphText: String
    let onSave: () -> Void
    let onCancel: () -> Void
    
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("段落内容")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    TextEditor(text: $paragraphText)
                        .frame(minHeight: 120)
                        .padding(12)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .focused($isTextFieldFocused)
                }
                
                HStack {
                    Text("\(paragraphText.count)个字符")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
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
                    
                    Button("添加", action: onSave)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(paragraphText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(20)
                        .disabled(paragraphText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .padding(20)
            .navigationTitle("添加段落")
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

struct EditParagraphView: View {
    let paragraph: ParagraphModel
    let onSave: (String) -> Void
    let onCancel: () -> Void
    
    @State private var editedText: String
    @FocusState private var isTextFieldFocused: Bool
    
    init(paragraph: ParagraphModel, onSave: @escaping (String) -> Void, onCancel: @escaping () -> Void) {
        self.paragraph = paragraph
        self.onSave = onSave
        self.onCancel = onCancel
        self._editedText = State(initialValue: paragraph.text)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("编辑段落")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    TextEditor(text: $editedText)
                        .frame(minHeight: 120)
                        .padding(12)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .focused($isTextFieldFocused)
                }
                
                HStack {
                    Text("\(editedText.count)个字符")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
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
                    
                    Button("保存", action: { onSave(editedText) })
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(editedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(20)
                        .disabled(editedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .padding(20)
            .navigationTitle("编辑段落")
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
    ArticleDetailView(article: ArticleModel(uuid: "test", name: "测试文章"))
}
