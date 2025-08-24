import Foundation
import SwiftUI
import RealmSwift
import Combine
struct ParagraphViewData: Identifiable, Equatable {
    let id: String
    let text: String
    let createTime: Date
    let voiceCount: Int
}
class HomeViewModel: ObservableObject {
    @Published var articles: [ArticleModel] = []
    @Published var paragraphs: [ParagraphViewData] = []
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
        // 关键：订阅 managers 的发布者
        paragraphManager.$paragraphs
            .receive(on: DispatchQueue.main)
            .assign(to: &$paragraphs)

        articleManager.$articles
            .receive(on: DispatchQueue.main)
            .assign(to: &$articles)
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
        paragraphManager.updateOrder(by: copy.map { $0.id })
    }

}
