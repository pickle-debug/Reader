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
    
    private var realm: Realm?
    private var notificationToken: NotificationToken?
    
    init() {
        setupRealm()
        loadArticles()
    }
    deinit {
        notificationToken?.invalidate()
    }
    
    private func setupRealm() {
        do {
            realm = try Realm()
            
            notificationToken = realm?.objects(ArticleModel.self).observe { [weak self] changes in
                DispatchQueue.main.async {
                    self?.loadArticles()
                }
            }
        } catch {
            print("Failed to initialize Realm: \(error)")
        }
    }
    
    private func loadArticles() {
        guard let realm = realm else { return }
        let articles = realm.objects(ArticleModel.self).sorted(byKeyPath: "updateTime", ascending: false)
        self.articles = Array(articles).filter { !$0.isInvalidated }
    }
    
    func addArticle(name: String) {
        guard let realm = realm else { return }
        
        do {
            try realm.write {
                let article = ArticleModel(uuid: UUID().uuidString, name: name)
                realm.add(article)
            }
        } catch {
            print("Failed to create article: \(error)")
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
