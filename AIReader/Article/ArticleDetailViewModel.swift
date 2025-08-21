import Foundation
import RealmSwift
import Combine

class ArticleDetailViewModel: ObservableObject {
    @Published var paragraphs: [ParagraphModel] = []
    @Published var editingParagraph: ParagraphModel?
    
    private let article: ArticleModel
    private var realm: Realm?
    private var notificationToken: NotificationToken?
    var onParagraphsUpdated: (([ParagraphModel]) -> Void)?
    
    init(article: ArticleModel) {
        self.article = article
        setupRealm()
        loadParagraphs()
    }
    
    deinit {
        notificationToken?.invalidate()
    }
    
    private func setupRealm() {
        do {
            realm = try Realm()
            
            // 监听段落变化
            notificationToken = realm?.objects(ParagraphModel.self).observe { [weak self] changes in
                DispatchQueue.main.async {
                    self?.loadParagraphs()
                }
            }
        } catch {
            print("Failed to initialize Realm: \(error)")
        }
    }
    
    private func loadParagraphs() {
        guard let realm = realm else { return }
        
        // 获取当前文章的段落
        let articleInRealm = realm.object(ofType: ArticleModel.self, forPrimaryKey: article.uuid)
        if let articleInRealm = articleInRealm {
            self.paragraphs = Array(articleInRealm.paragraphs.sorted(byKeyPath: "createTime", ascending: true))
            onParagraphsUpdated?(self.paragraphs)
        }
    }
    
    func addParagraph(text: String) {
        guard let realm = realm else { return }
        
        do {
            try realm.write {
                let paragraph = ParagraphModel(uuid: UUID().uuidString, text: text, mp3file: "")
                realm.add(paragraph)
                
                // 添加到文章的段落列表
                let articleInRealm = realm.object(ofType: ArticleModel.self, forPrimaryKey: article.uuid)
                articleInRealm?.paragraphs.append(paragraph)
                articleInRealm?.updateTime = Date()
            }
        } catch {
            print("Failed to add paragraph: \(error)")
        }
    }
    
    func editParagraph(at index: Int) {
        guard index < paragraphs.count else { return }
        editingParagraph = paragraphs[index]
    }
    
    func updateParagraph(text: String) {
        guard let editingParagraph = editingParagraph,
              let realm = realm else { return }
        
        do {
            try realm.write {
                editingParagraph.text = text
                editingParagraph.updateTime = Date()
                
                // 更新文章的更新时间
                let articleInRealm = realm.object(ofType: ArticleModel.self, forPrimaryKey: article.uuid)
                articleInRealm?.updateTime = Date()
            }
            self.editingParagraph = nil
        } catch {
            print("Failed to update paragraph: \(error)")
        }
    }
    
    func deleteParagraph(at index: Int) {
        guard index < paragraphs.count,
              let realm = realm else { return }
        
        let paragraph = paragraphs[index]
        
        do {
            try realm.write {
                // 删除相关的音色
                realm.delete(paragraph.voices)
                
                // 从文章的段落列表中移除
                let articleInRealm = realm.object(ofType: ArticleModel.self, forPrimaryKey: article.uuid)
                if let paragraphIndex = articleInRealm?.paragraphs.index(of: paragraph) {
                    articleInRealm?.paragraphs.remove(at: paragraphIndex)
                }
                
                // 删除段落
                realm.delete(paragraph)
                
                // 更新文章的更新时间
                articleInRealm?.updateTime = Date()
            }
        } catch {
            print("Failed to delete paragraph: \(error)")
        }
    }
    
    func generateVoice(for paragraph: ParagraphModel) {
        // 这里可以调用AudioService来生成音色
        // 暂时创建一个默认的音色
        guard let realm = realm else { return }
        
        do {
            try realm.write {
                let voice = VoiceModel(
                    uuid: UUID().uuidString,
                    voiceType: "en-US-JennyNeural",
                    pitch: "0",
                    style: "general",
                    md5: "default"
                )
                realm.add(voice)
                
                // 这里需要建立段落和音色的关系
                // 由于Realm的限制，我们可能需要重新设计关系
            }
        } catch {
            print("Failed to generate voice: \(error)")
        }
    }
    
    func cancelEdit() {
        editingParagraph = nil
    }
}
