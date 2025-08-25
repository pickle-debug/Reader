//
//  ParagraphPickerView.swift
//  read
//
//  Created by gidon on 2025/8/22.
//


import SwiftUI

struct ParagraphPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: HomeViewModel

    @State private var articleName: String = ""
    @State private var selectedIDs: [String] = []
    @State private var editMode: EditMode = .inactive

    var body: some View {
        NavigationView {
            List {
                selectedSection
                allParagraphsSection
            }
            .listStyle(.insetGrouped)
            .environment(\.editMode, $editMode)
            .navigationTitle("选择段落")
            .toolbar {
                toolbarContent
            }
        }
    }
    
    // ✅ 提取已选择区域
    private var selectedSection: some View {
        Section(header: Text("已选顺序 (\(selectedIDs.count))")) {
            if selectedIDs.isEmpty {
                emptyStateView
            } else {
                selectedItemsList
            }
        }
    }
    
    // 提取空状态视图
    private var emptyStateView: some View {
        Text("点下面的段落以添加到这里；支持重复添加。\n在此区可拖动排序，左滑删除。")
            .font(.footnote)
            .foregroundColor(.secondary)
    }
    
    // 提取已选择列表
    private var selectedItemsList: some View {
        ForEach(selectedIDs.indices, id: \.self) { index in
            selectedItemRow(at: index)
        }
        .onMove(perform: moveItems)
        .onDelete(perform: deleteItems)
    }
    
    // 提取单行视图
    private func selectedItemRow(at index: Int) -> some View {
        let id = selectedIDs[index]
        return HStack {
            Text(titleFor(id: id))
                .lineLimit(1)
            Spacer()
            Text("#\(index + 1)")
                .foregroundColor(.secondary)
        }
    }
    
    // ✅ 提取所有段落区域
    private var allParagraphsSection: some View {
        Section(header: Text("所有段落")) {
            ForEach(viewModel.paragraphs) { paragraph in
                paragraphRow(for: paragraph)
            }
        }
    }
    
    // 提取段落行
    private func paragraphRow(for paragraph: ParagraphData) -> some View {
        ParagraphRowView(
            paragraph: paragraph,
            selectedCount: countFor(paragraphId: paragraph.paragraph.uuid),
            onTap: { selectedIDs.append(paragraph.paragraph.uuid) }
        )
        .swipeActions(edge: .trailing) {
            Button("添加一次") {
                selectedIDs.append(paragraph.paragraph.uuid)
            }
        }
    }
    
    // 辅助方法
    private func moveItems(from indices: IndexSet, to newOffset: Int) {
        selectedIDs.move(fromOffsets: indices, toOffset: newOffset)
    }
    
    private func deleteItems(at indices: IndexSet) {
        selectedIDs.remove(atOffsets: indices)
    }
    
    private func countFor(paragraphId: String) -> Int {
        selectedIDs.filter { $0 == paragraphId }.count
    }
    
    private func titleFor(id: String) -> String {
        viewModel.paragraphs.first(where: { $0.paragraph.uuid == id })?.paragraph.text ?? "（已删除）"
    }
    
    private func createArticle() {
        let name = articleName.trimmingCharacters(in: .whitespacesAndNewlines)
        viewModel.createArticle(
            with: name.isEmpty ? "未命名文章" : name,
            paragraphIDs: selectedIDs
        )
        dismiss()
    }
}
extension ParagraphPickerView {
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("关闭") {
                dismiss()
            }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(editMode.isEditing ? "完成排序" : "排序") {
                withAnimation {
                    editMode = editMode.isEditing ? .inactive : .active
                }
            }
            .disabled(selectedIDs.count < 2)
        }
        
        // ✅ 修复：将ToolbarItemGroup分解为单独的工具栏项
        ToolbarItem(placement: .bottomBar) {
            articleNameField
        }
        
        ToolbarItem(placement: .bottomBar) {
            Spacer()
        }
        
        ToolbarItem(placement: .bottomBar) {
            bottomButtonsGroup
        }
    }
    
    // 提取文章名称输入框
    private var articleNameField: some View {
        TextField("文章名称", text: $articleName)
            .textFieldStyle(.roundedBorder)
    }
    
    // 提取底部按钮组
    private var bottomButtonsGroup: some View {
        HStack {
            Button("清空") {
                selectedIDs.removeAll()
            }
            .disabled(selectedIDs.isEmpty)
            
            Button("创建") {
                createArticle()
            }
            .disabled(selectedIDs.isEmpty)
        }
    }
}

struct ParagraphRowView: View {
    let paragraph: ParagraphData
    let selectedCount: Int
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(paragraph.paragraph.text)
                    .lineLimit(2)
                Spacer()
                if selectedCount > 0 {
                    CountBadge(count: selectedCount)
                }
            }
        }
    }
}
struct CountBadge: View {
    let count: Int
    var body: some View {
        Text("\(count)")
            .font(.caption2).bold()
            .padding(.horizontal, 6).padding(.vertical, 2)
            .background(Capsule().fill(Color.blue.opacity(0.15)))
            .foregroundColor(.blue)
    }
}
