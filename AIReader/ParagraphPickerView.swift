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
    @State private var selectedIDs: [String] = []        // 顺序数组，可重复
    @State private var editMode: EditMode = .inactive    // 控制“已选顺序”是否可拖动

    var body: some View {
        NavigationView {
            List {
                // 已选顺序区
                Section(header: Text("已选顺序 (\(selectedIDs.count))")) {
                    if selectedIDs.isEmpty {
                        Text("点下面的段落以添加到这里；支持重复添加。\n在此区可拖动排序，左滑删除。")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(Array(selectedIDs.enumerated()), id: \.offset) { idx, id in
                            HStack {
                                Text(titleFor(id: id))
                                    .lineLimit(1)
                                Spacer()
                                Text("#\(idx+1)")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .onMove { idx, newOffset in
                            selectedIDs.move(fromOffsets: idx, toOffset: newOffset)
                        }
                        .onDelete { idx in
                            selectedIDs.remove(atOffsets: idx)
                        }
                    }
                }

                // 所有段落列表
                Section(header: Text("所有段落")) {
                    ForEach(viewModel.paragraphs) { p in
                        Button {
                            selectedIDs.append(p.id)       // ★ 一次点按=追加一次
                        } label: {
                            HStack {
                                Text(p.text).lineLimit(2)
                                Spacer()
                                let count = selectedIDs.filter { $0 == p.id }.count
                                if count > 0 { CountBadge(count: count) }
                            }
                        }
                        .swipeActions(edge: .trailing) {
                            Button {
                                selectedIDs.append(p.id)   // 右滑也可“再添加一次”
                            } label: { Label("添加一次", systemImage: "plus.circle") }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .environment(\.editMode, $editMode)
            .navigationTitle("选择段落")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("关闭") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(editMode.isEditing ? "完成排序" : "排序") {
                        withAnimation { editMode = editMode.isEditing ? .inactive : .active }
                    }
                    .disabled(selectedIDs.count < 2)
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    TextField("文章名称", text: $articleName)
                        .textFieldStyle(.roundedBorder)
                    Spacer()
                    Button("清空") { selectedIDs.removeAll() }
                        .disabled(selectedIDs.isEmpty)
                    Button("创建") {
                        let name = articleName.trimmingCharacters(in: .whitespacesAndNewlines)
                        viewModel.createArticle(with: name.isEmpty ? "未命名文章" : name,
                                                paragraphIDs: selectedIDs)
                        dismiss()
                    }
                    .disabled(selectedIDs.isEmpty)
                }
            }
        }
    }

    private func titleFor(id: String) -> String {
        viewModel.paragraphs.first(where: { $0.id == id })?.text ?? "（已删除）"
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
