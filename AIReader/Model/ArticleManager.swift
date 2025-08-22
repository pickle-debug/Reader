//
//  ArticleManager.swift
//  read
//
//  Created by gidon on 2025/8/22.
//

import RealmSwift
import Foundation
import SwiftUI

class ArticleManager: ObservableObject {
    @Published var articles: [ArticleModel] = []
    
    static let shared = ArticleManager()
    
    private var realm: Realm? = try? Realm()
    private var token: NotificationToken?

    init() {
        token = realm?.objects(ArticleModel.self).observe { [weak self] _ in
            DispatchQueue.main.async { self?.reload() }
        }
        reload()
    }
    deinit {
        token?.invalidate()
    }
  
    private func reload() {
        guard let realm else { return }
        let results = realm.objects(ArticleModel.self)
            .sorted(byKeyPath: "updateTime", ascending: false)
        articles = Array(results)
    }

    
    func addArticle(name: String, paragraphIDs: [String]) {
        guard let realm else { return }
        do {
            try realm.write {
                let article = ArticleModel(uuid: UUID().uuidString, name: name)
                article.paragraphUUIDs.removeAll()
                // 保留顺序&重复
                paragraphIDs.forEach { article.paragraphUUIDs.append($0) }
                realm.add(article, update: .modified)
            }
        } catch {
            print("Failed to add article:", error)
        }
    }

    // 获取文章的段落
    func getParagraphs(for article: ArticleModel) -> [ParagraphModel] {
        guard let realm = realm else { return [] }
        
        // 安全检查，确保文章对象有效
        if article.isInvalidated {
            return []
        }
        
        return article.paragraphUUIDs.compactMap { uuid in
            let paragraph = realm.object(ofType: ParagraphModel.self, forPrimaryKey: uuid)
            // 只返回有效的段落对象
            return paragraph?.isInvalidated == false ? paragraph : nil
        }
    }
}
