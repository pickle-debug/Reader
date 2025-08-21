import Foundation
import RealmSwift
import Combine

class HomeViewModel: ObservableObject {
    @Published var articles: [ArticleModel] = []
    @Published var paragraphs: [ParagraphModel] = []
    @Published var selectedArticle: ArticleModel?
    @Published var currentView: ContentType = .paragraphs // 默认显示段落
    
    enum ContentType: String, CaseIterable {
        case articles = "文章"
        case paragraphs = "段落"
    }
    
    private var realm: Realm?
    private var notificationToken: NotificationToken?
    private var paragraphNotificationToken: NotificationToken?
    
    init() {
        setupRealm()
        loadData()
    }
    
    deinit {
        notificationToken?.invalidate()
        paragraphNotificationToken?.invalidate()
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
            
            // 监听段落变化
            paragraphNotificationToken = realm?.objects(ParagraphModel.self).observe { [weak self] changes in
                DispatchQueue.main.async {
                    self?.loadParagraphs()
                }
            }
        } catch {
            print("Failed to initialize Realm: \(error)")
        }
    }
    
    private func loadData() {
        loadArticles()
        loadParagraphs()
    }
    
    private func loadArticles() {
        guard let realm = realm else { return }
        let articles = realm.objects(ArticleModel.self).sorted(byKeyPath: "updateTime", ascending: false)
        self.articles = Array(articles)
    }
    
    private func loadParagraphs() {
        guard let realm = realm else { return }
        let paragraphs = realm.objects(ParagraphModel.self).sorted(byKeyPath: "updateTime", ascending: false)
        self.paragraphs = Array(paragraphs)
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
    
    func createParagraph(content: String) {
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
    
    func selectArticle(_ article: ArticleModel) {
        selectedArticle = article
    }
    
    // 获取文章的段落
    func getParagraphs(for article: ArticleModel) -> [ParagraphModel] {
        guard let realm = realm else { return [] }
        return article.paragraphUUIDs.compactMap { uuid in
            realm.object(ofType: ParagraphModel.self, forPrimaryKey: uuid)
        }
    }
    
    // 计算文章的段落和音色数量
    func getArticleStats(for article: ArticleModel) -> (paragraphCount: Int, voiceCount: Int) {
        let paragraphs = getParagraphs(for: article)
        let voiceCount = paragraphs.reduce(0) { $0 + $1.voices.count }
        return (paragraphs.count, voiceCount)
    }
    
    func deleteParagraph(_ paragraph: ParagraphModel) {
        guard let realm = realm else { return }
        
        do {
            try realm.write {
                // 从所有引用此段落的文章中移除引用
                let referencingArticles = realm.objects(ArticleModel.self).filter("ANY paragraphUUIDs == %@", paragraph.uuid)
                for article in referencingArticles {
                    if let index = article.paragraphUUIDs.firstIndex(of: paragraph.uuid) {
                        article.paragraphUUIDs.remove(at: index)
                        article.updateTime = Date()
                    }
                }
                
                // 删除段落的音色
                realm.delete(paragraph.voices)
                // 删除段落
                realm.delete(paragraph)
            }
        } catch {
            print("Failed to delete paragraph: \(error)")
        }
    }
}
