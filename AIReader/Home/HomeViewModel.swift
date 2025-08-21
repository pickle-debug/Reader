import Foundation
import RealmSwift
import Combine

class HomeViewModel: ObservableObject {
    @Published var articles: [ArticleModel] = []
    @Published var selectedArticle: ArticleModel?
    
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
            
            // 监听文章变化
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
        self.articles = Array(articles)
    }
    
    func createArticle(name: String) {
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
    
    func selectArticle(_ article: ArticleModel) {
        selectedArticle = article
    }
    
    func deleteArticle(_ article: ArticleModel) {
        guard let realm = realm else { return }
        
        do {
            try realm.write {
                // 删除相关的段落和音色
                for paragraph in article.paragraphs {
                    realm.delete(paragraph.voices)
                }
                realm.delete(article.paragraphs)
                realm.delete(article)
            }
        } catch {
            print("Failed to delete article: \(error)")
        }
    }
}
