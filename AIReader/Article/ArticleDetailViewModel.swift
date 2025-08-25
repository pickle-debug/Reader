import Foundation
import RealmSwift
import Combine
import SwiftUI

class ArticleDetailViewModel: ObservableObject {
    @Published var article: ArticleModel
    @Published var paragraphs: [ParagraphData] = []
    @ObservedObject var articleManager = ArticleManager.shared
    @ObservedObject var paragraphManager = ParagraphManager.shared
    
    private var cancellables = Set<AnyCancellable>()
    
    init(article: ArticleModel) {
        self.article = article
        setupObservers()
        loadParagraphs()
    }
    
    private func setupObservers() {
        paragraphManager.$paragraphs
            .sink { [weak self] _ in
                self?.loadParagraphs()
            }
            .store(in: &cancellables)
        
        // 监听当前文章的变化，重新加载段落
        $article
            .sink { [weak self] _ in
                self?.loadParagraphs()
            }
            .store(in: &cancellables)
    }
    
    private func loadParagraphs() {
        let articleParagraphUUIDs = Array(article.paragraphUUIDs)
        
        paragraphs = articleParagraphUUIDs.compactMap { uuid in
            paragraphManager.paragraphs.first { $0.paragraph.uuid == uuid }
        }
    }
    
    func switchToArticle(_ newArticle: ArticleModel) {
        self.article = newArticle
    }
    
    func genWhisper() {
        // 实现方法
    }
}
