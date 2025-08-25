import Foundation
import SwiftUI
import RealmSwift
import Combine
class HomeViewModel: ObservableObject {
    @Published var articles: [ArticleModel] = []
    @Published var paragraphs: [ParagraphData] = []
    @Published var selectedArticle: ArticleModel?
    @Published var currentView: ContentType = .paragraphs

    @ObservedObject var paragraphManager = ParagraphManager.shared
    @ObservedObject var articleManager = ArticleManager.shared

    enum ContentType: String, CaseIterable {
        case articles = "文章"
        case paragraphs = "段落"
    }
    
    private var cancellables = Set<AnyCancellable>()
    init() {
        paragraphManager.$paragraphs
            .receive(on: DispatchQueue.main)
            .assign(to: &$paragraphs)
        // 订阅文章列表
        articleManager.$articles
            .receive(on: DispatchQueue.main)
            .assign(to: &$articles)
        
        $selectedArticle
            .compactMap { $0?.uuid } // 获取文章UUID
            .flatMap { [weak self] articleUUID in
                // 订阅该文章的详细数据流
                self?.articleManager.getArticleDetailPublisher(for: articleUUID) ?? Empty().eraseToAnyPublisher()
            }
            .map { _, paragraphsData in paragraphsData } // 只取段落数据部分
            .receive(on: DispatchQueue.main)
            .assign(to: &$paragraphs)
    }

    func selectArticle(_ article: ArticleModel) {
        selectedArticle = article
    }

    func createArticle(with name: String, paragraphIDs: [String]) {
        articleManager.addArticle(name: name, paragraphIDs: paragraphIDs)
    }
    
    func createParagraph(_ content:String) {
        paragraphManager.addParagraph(content: content)
    }

    func deleteParagraph(uuid: String) {
        paragraphManager.delete(uuid: uuid)
    }
    
    func reorder(from source: IndexSet, to destination: Int) {
        var copy = paragraphs
        copy.move(fromOffsets: source, toOffset: destination)
        paragraphs = copy
        paragraphManager.updateOrder(by: copy.map { $0.paragraph.uuid })
    }

}
