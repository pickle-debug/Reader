//
//  ParagraphManager.swift
//  read
//
//  Created by gidon on 2025/8/22.
//

import RealmSwift
import Foundation
import SwiftUI

class ParagraphManager: ObservableObject {
    @Published var paragraphs: [ParagraphViewData] = []
    
    static let shared = ParagraphManager()
    
    private var realm: Realm?
    private var notificationToken: NotificationToken?
    private var isDeleting = false // 添加删除状态标志
    
    init() {
        setupRealm()
        reload()
    }
    deinit {
        notificationToken?.invalidate()
    }
    
    private func setupRealm() {
        do {
            realm = try Realm()

            notificationToken = realm?.objects(ParagraphModel.self).observe { [weak self] changes in
                // 确保在主线程处理通知
                DispatchQueue.main.async {
                    // 如果正在删除，不重新加载
                    if self?.isDeleting == false {
                        self?.reload()
                    }
                }
            }
        } catch {
            print("Failed to initialize Realm: \(error)")
        }
    }
    
    private func reload() {
          guard let realm else { return }
          let results = realm.objects(ParagraphModel.self)
            .sorted(by: [
                    SortDescriptor(keyPath: "order", ascending: true),
                    SortDescriptor(keyPath: "updateTime", ascending: false)
                ])

          self.paragraphs = results.map {
              ParagraphViewData(
                  id: $0.uuid,
                  text: $0.text,
                  createTime: $0.createTime,
                  voiceCount: $0.voices.count
              )
          }
      }
    
    func addParagraph(content: String) {
        guard let realm = realm else { return }
        
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedContent.isEmpty else {
            print("Paragraph content cannot be empty.")
            return
        }
        
        do {
            try realm.write {
                let newParagraph = ParagraphModel(uuid: UUID().uuidString, text: trimmedContent)
                realm.add(newParagraph)
            }
        } catch {
            print("Failed to create paragraph: \(error)")
        }
    }
    
    func delete(uuid: String) {
        guard let realm else { return }
        do {
            try realm.write {
                guard let p = realm.object(ofType: ParagraphModel.self, forPrimaryKey: uuid) else { return }
                // 清理引用
                let refs = realm.objects(ArticleModel.self).filter("ANY paragraphUUIDs == %@", uuid)
                for a in refs {
                    if let idx = a.paragraphUUIDs.firstIndex(of: uuid) {
                        a.paragraphUUIDs.remove(at: idx)
                        a.updateTime = Date()
                    }
                }
                realm.delete(p.voices)
                realm.delete(p)
            }
        } catch { print("delete failed:", error) }
    }
    
    func updateOrder(by orderedIDs: [String]) {
        DispatchQueue.global(qos: .userInitiated).async {
            autoreleasepool {
                do {
                    let realm = try Realm()
                    try realm.write {
                        for (i, id) in orderedIDs.enumerated() {
                            if let p = realm.object(ofType: ParagraphModel.self, forPrimaryKey: id) {
                                p.order = i
                                p.updateTime = Date()
                            }
                        }
                    }
                } catch {
                    print("Failed to update order:", error)
                }
            }
        }
    }


}
