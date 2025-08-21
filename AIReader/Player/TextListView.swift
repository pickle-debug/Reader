import SwiftUI

struct TextListView: View {
    @ObservedObject var viewModel: ArticleViewModel
    @State private var showingEditSheet = false
    @State private var editingIndex: Int?
    @State private var editingText = ""
    
    var body: some View {
        ScrollView {
            if viewModel.texts.isEmpty {
                EmptyStateView(icon: "", title: "aaa", subtitle: "bbbb")
            } else {
                LazyVStack(spacing: 16) {
                    LazyVStack(spacing: 12) {
                        ForEach(Array(viewModel.texts.enumerated()), id: \.offset) { index, text in
                            TextCellView(
                                text: text,
                                index: index,
                                isSelected: viewModel.selectedParagraphs.contains(index),
                                onToggle: {
                                    viewModel.toggleSelection(index)
                                },
                                onEdit: {
                                    editingIndex = index
                                    editingText = text
                                    showingEditSheet = true
                                },
                                onDelete: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        // 这里需要实现删除功能
                                        print("Delete paragraph at index: \(index)")
                                    }
                                }
                            )
                            .transition(.asymmetric(
                                insertion: .scale.combined(with: .opacity),
                                removal: .scale.combined(with: .opacity)
                            ))
                        }
                        .onMove { from, to in
                            withAnimation(.easeInOut(duration: 0.3)) {
                                // 这里需要实现移动功能
                                print("Move from \(from) to \(to)")
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100) // Space for bottom controls
                }
            }
        }
        .background(Color.clear)
        .sheet(isPresented: $showingEditSheet) {
            TextEditView(
                text: $editingText,
                onSave: {
                    if let index = editingIndex {
                        // 这里需要实现更新功能
                        print("Update text at index: \(index) with: \(editingText)")
                    }
                    showingEditSheet = false
                },
                onCancel: {
                    showingEditSheet = false
                }
            )
        }
    }
}

struct TextCellView: View {
    let text: String
    let index: Int
    let isSelected: Bool
    let onToggle: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    @State private var isPressed = false
    @State private var dragOffset: CGSize = .zero
    @State private var showingDeleteButton = false
    
    var body: some View {
        VStack {
            HStack {
                Button(action: onToggle) {
                    ZStack {
                        if isSelected {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 1.0, green: 0.925, blue: 0.824),
                                            Color(red: 0.988, green: 0.714, blue: 0.624)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: 24, height: 24)
                                .blur(radius: 0.3)
                        } else {
                            Circle()
                                .fill(Color.white.opacity(0.3))
                                .frame(width: 24, height: 24)
                        }
                        
                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                            .font(.title3)
                            .foregroundColor(isSelected ? .white : .gray)
                            .scaleEffect(isSelected ? 1.2 : 1.0)
                            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isSelected)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                // Text Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(text)
                        .font(.body)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)
                }
                
                Spacer()
            }
            .padding(16)
        }
        .frame(height: 80) // 固定高度
        .background(
            ZStack {
                // 高斯模糊背景
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.8))
                    .blur(radius: 0.3)
                
                // 选中状态的渐变背景
                if isSelected {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 1.0, green: 0.925, blue: 0.824),
                                    Color(red: 0.988, green: 0.714, blue: 0.624)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .opacity(0.8)
                        .blur(radius: 0.5)
                }
                
                // 边框
                if isSelected {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 1.0, green: 0.925, blue: 0.824),
                                    Color(red: 0.988, green: 0.714, blue: 0.624)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 2
                        )
                } else {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                }
            }
        )
        .shadow(
            color: isSelected ? 
                Color(red: 0.988, green: 0.714, blue: 0.624).opacity(0.3) : 
                Color.black.opacity(0.1),
            radius: isSelected ? 12 : 8,
            x: 0,
            y: isSelected ? 6 : 4
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .offset(x: dragOffset.width)
        .animation(Animation.easeInOut(duration: 0.3), value: isPressed)
        .animation(Animation.easeInOut(duration: 0.4), value: dragOffset)
        .animation(Animation.easeInOut(duration: 0.3), value: isSelected)
        .gesture(
            // Long Press Gesture
            LongPressGesture(minimumDuration: 0.5)
                .onEnded { _ in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        onEdit()
                    }
                }
        )
        .simultaneousGesture(
            // Drag Gesture for Swipe to Delete
            DragGesture()
                .onChanged { value in
                    if value.translation.width < 0 {
                        dragOffset = value.translation
                        if abs(value.translation.width) > 50 {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showingDeleteButton = true
                            }
                        }
                    }
                }
                .onEnded { value in
                    if value.translation.width < -100 {
                        // Delete the item
                        withAnimation(.easeInOut(duration: 0.3)) {
                            onDelete()
                        }
                    } else {
                        // Reset position
                        withAnimation(.easeInOut(duration: 0.3)) {
                            dragOffset = .zero
                            showingDeleteButton = false
                        }
                    }
                }
        )
        .overlay(
            // Delete Button Overlay
            HStack {
                Spacer()
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        onDelete()
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.red.opacity(0.2))
                            .frame(width: 40, height: 40)
                            .blur(radius: 0.5)
                        
                        Image(systemName: "trash.circle.fill")
                            .font(.title2)
                            .foregroundColor(.red)
                    }
                }
                .padding(.trailing, 16)
                .opacity(showingDeleteButton ? 1 : 0)
                .scaleEffect(showingDeleteButton ? 1 : 0.8)
                .animation(.easeInOut(duration: 0.2), value: showingDeleteButton)
            }
        )
    }
}

struct TextEditView: View {
    @Binding var text: String
    let onSave: () -> Void
    let onCancel: () -> Void
    
    @Environment(\.presentationMode) var presentationMode
    @FocusState private var isTextFieldFocused: Bool
    @State private var editedText: String
    
    init(text: Binding<String>, onSave: @escaping () -> Void, onCancel: @escaping () -> Void) {
        self._text = text
        self.onSave = onSave
        self.onCancel = onCancel
        self._editedText = State(initialValue: text.wrappedValue)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("编辑文本")
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
                    
                    Button("保存") {
                        text = editedText
                        isTextFieldFocused = false
                        onSave()
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(editedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.blue)
                    .cornerRadius(20)
                    .disabled(editedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                
                Spacer()
            }
            .padding(20)
            .navigationTitle("编辑文本")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        isTextFieldFocused = false
                        onCancel()
                    }
                }
            }
            .onTapGesture {
                isTextFieldFocused = false
            }
        }
        .onAppear {
            isTextFieldFocused = true
        }
    }
}

#Preview {
    TextListView(viewModel: ArticleViewModel())
}
