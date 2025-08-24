//
//  ArticleManager.swift
//  read
//
//  Created by gidon on 2025/8/22.
//

import RealmSwift
import Foundation
import SwiftUI
import Combine
struct ArticleGlobalVoiceOptions: Hashable, Identifiable {
    var id: String { UUID().uuidString }
    var voiceValue: String
    var speedValue: String
    var pitchValue: String
    var styleValue: String
}

struct ArticleDisplayData: Identifiable {
    let id: String
    let name: String
    let createTime: Date
    let updateTime: Date
    var globalVoiceOptions: ArticleGlobalVoiceOptions // 包含全局语音设置
}
// 辅助结构体：用于 ViewModel 发布段落及其语音信息，纯 Swift 类型
struct ArticleParagraphDisplayData: Identifiable {
    var id: String { paragraph.uuid } // 使用段落的UUID作为ID
    let paragraph: ParagraphModel // 注意：这里为了简化直接使用 Realm Managed Object。更严格应为 ParagraphDisplayData 纯 struct
    let articleMatchedVoice: VoiceModel? // 与文章全局设置匹配的语音 (Realm Managed Object)
    let allVoicesForParagraph: [VoiceModel] // 该段落生成的所有语音 (Realm Managed Objects)
}
class ArticleManager: ObservableObject {
    @Published var articles: [ArticleModel] = []
    
    static let shared = ArticleManager()
    
    private var realm: Realm? = try? Realm()
    private var token: NotificationToken?
    private var articleDetailSubjects: [String: PassthroughSubject<(ArticleDisplayData, [ArticleParagraphDisplayData]), Never>] = [:]
    
    private var articleDetailNotificationTokens: [String: Set<NotificationToken>] = [:] // 存储每个文章详情的NotificationToken
    
    private var commonCancellables = Set<AnyCancellable>()
    
    init() {
        do {
            realm = try Realm()
            token = realm?.objects(ArticleModel.self).observe { [weak self] _ in
                DispatchQueue.main.async { self?.reload() }
            }
            reload()
        } catch {
            print("Failed to initialize ArticleManager Realm: \(error)")
        }
    }
    
    deinit {
        token?.invalidate()
        articleDetailSubjects.removeAll()
        for (_, tokens) in articleDetailNotificationTokens {
            tokens.forEach { $0.invalidate() }
        }
        articleDetailNotificationTokens.removeAll()
        commonCancellables.forEach { $0.cancel() }
    }
    
    private func reload() {
        guard let realm else { return }
        let results = realm.objects(ArticleModel.self)
            .sorted(byKeyPath: "updateTime", ascending: false)
        articles = Array(results)
    }
    
    
    func addArticle(name: String, text: String = "", paragraphIDs: [String] = [],
                    voiceValue: String = "zh-CN-XiaoxiaoNeural",
                    speedValue: String = "1.0",
                    pitchValue: String = "0",
                    styleValue: String = "general") -> String? {
        guard let realm else { return nil }
        let newUUID = UUID().uuidString
        do {
            try realm.write {
                let article = ArticleModel(name: name,
                                           voiceValue: voiceValue,
                                           speedValue: speedValue,
                                           pitchValue: pitchValue,
                                           styleValue: styleValue)
                article.uuid = newUUID
                paragraphIDs.forEach { article.paragraphUUIDs.append($0) }
                realm.add(article, update: .modified)
            }
            return newUUID
        } catch {
            print("Failed to add article:", error)
            return nil
        }
    }
    
    func getArticleDetailPublisher(for articleUUID: String) -> AnyPublisher<(ArticleDisplayData, [ArticleParagraphDisplayData]), Never> {
        if articleDetailSubjects[articleUUID] == nil {
            articleDetailSubjects[articleUUID] = PassthroughSubject()
            // 首次获取时，立即加载数据并发布
            self.loadAndPublishArticleDetailData(for: articleUUID)
            // 订阅Realm通知，以便在数据变化时重新加载并发布
            setupArticleDetailObserver(for: articleUUID)
        }
        return articleDetailSubjects[articleUUID]!.eraseToAnyPublisher()
    }
    
    // 设置针对特定文章的Realm观察者
    private func setupArticleDetailObserver(for articleUUID: String) {
        guard let realm = realm else { return }
        
        // 确保清除旧的tokens，防止重复观察
        if let oldTokens = articleDetailNotificationTokens[articleUUID] {
            oldTokens.forEach { $0.invalidate() }
        }
        articleDetailNotificationTokens[articleUUID] = Set<NotificationToken>() // 初始化新的Set
        
        if let article = realm.object(ofType: ArticleModel.self, forPrimaryKey: articleUUID) {
            // 观察文章本身的变化 (全局语音设置、paragraphUUIDs)
            let articleToken = article.observe(keyPaths: ["name", "text", "updateTime", "voiceValue", "speedValue", "pitchValue", "styleValue", "paragraphUUIDs"]) { [weak self] change in
                if let self = self {
                    DispatchQueue.main.async {
                        self.loadAndPublishArticleDetailData(for: articleUUID)
                    }
                }
            }
            // ⚠️ 修正：将 NotificationToken 直接添加到 Set 中
            articleDetailNotificationTokens[articleUUID]?.insert(articleToken)
        }
        
        // 观察与此文章相关的 ParagraphModel 和 VoiceModel 的变化
        // 这里可以进行更细致的过滤，例如只观察 article.paragraphUUIDs 包含的 ParagraphModel
        // 但为了简化，这里暂时观察所有相关的，实际应用中建议优化
        let paragraphToken = realm.objects(ParagraphModel.self)
            .filter("uuid IN %@", realm.object(ofType: ArticleModel.self, forPrimaryKey: articleUUID)?.paragraphUUIDs ?? []) // 优化：只观察与文章相关的段落
            .observe { [weak self] _ in
                DispatchQueue.main.async { self?.loadAndPublishArticleDetailData(for: articleUUID) }
            }
        // ⚠️ 修正：将 NotificationToken 直接添加到 Set 中
        articleDetailNotificationTokens[articleUUID]?.insert(paragraphToken)
        
        let voiceToken = realm.objects(VoiceModel.self)
            .filter("paragraphUUID IN %@", realm.object(ofType: ArticleModel.self, forPrimaryKey: articleUUID)?.paragraphUUIDs ?? []) // 优化：只观察与文章相关的语音
            .observe { [weak self] _ in
                DispatchQueue.main.async { self?.loadAndPublishArticleDetailData(for: articleUUID) }
            }
        // ⚠️ 修正：将 NotificationToken 直接添加到 Set 中
        articleDetailNotificationTokens[articleUUID]?.insert(voiceToken)
    }
    // 加载并发布文章详细数据
    private func loadAndPublishArticleDetailData(for articleUUID: String) {
        guard let realm = realm,
              let articleInRealm = realm.object(ofType: ArticleModel.self, forPrimaryKey: articleUUID),
              let subject = articleDetailSubjects[articleUUID] else { return }
        
        let articleDisplayData = ArticleDisplayData(
            id: articleInRealm.uuid,
            name: articleInRealm.name,
            createTime: articleInRealm.createTime,
            updateTime: articleInRealm.updateTime,
            globalVoiceOptions: ArticleGlobalVoiceOptions(
                voiceValue: articleInRealm.voiceValue,
                speedValue: articleInRealm.speedValue,
                pitchValue: articleInRealm.pitchValue,
                styleValue: articleInRealm.styleValue
            )
        )
        
        var paragraphsDisplayData: [ArticleParagraphDisplayData] = []
        for paragraphUUID in articleInRealm.paragraphUUIDs {
            if let paragraph = realm.object(ofType: ParagraphModel.self, forPrimaryKey: paragraphUUID) {
                let allVoicesForParagraph = Array(paragraph.voices)
                let matchedVoice = allVoicesForParagraph.first { voice in
                    voice.voiceValue == articleInRealm.voiceValue &&
                    voice.speedValue == articleInRealm.speedValue &&
                    voice.pitchValue == articleInRealm.pitchValue &&
                    voice.styleValue == articleInRealm.styleValue
                }
                paragraphsDisplayData.append(ArticleParagraphDisplayData(
                    paragraph: paragraph.thaw() ?? paragraph, // 使用thaw()获取可管理对象，或直接传递Realm对象
                    articleMatchedVoice: matchedVoice?.thaw() ?? matchedVoice,
                    allVoicesForParagraph: allVoicesForParagraph.compactMap { $0.thaw() ?? $0 }
                ))
            }
        }
        
        subject.send((articleDisplayData, paragraphsDisplayData))
    }
    
    /// 更新文章的全局语音设置
    func updateArticleGlobalVoiceOptions(articleUUID: String, newOptions: ArticleGlobalVoiceOptions) {
        guard let realm = realm else { return }
        do {
            try realm.write {
                if let articleInRealm = realm.object(ofType: ArticleModel.self, forPrimaryKey: articleUUID) {
                    articleInRealm.voiceValue = newOptions.voiceValue
                    articleInRealm.speedValue = newOptions.speedValue
                    articleInRealm.pitchValue = newOptions.pitchValue
                    articleInRealm.styleValue = newOptions.styleValue
                    articleInRealm.updateTime = Date()
                }
            }
        } catch {
            print("Failed to update article global voice options in ArticleManager: \(error)")
        }
    }
    func updateParagraphOrder(for articleUUID: String, orderedIDs: [String]) {
        guard let realm = realm else { return }
        DispatchQueue.global(qos: .userInitiated).async { // 可以在后台线程进行写操作
            autoreleasepool {
                do {
                    let realm = try Realm() // 获取新的Realm实例
                    try realm.write {
                        if let article = realm.object(ofType: ArticleModel.self, forPrimaryKey: articleUUID) {
                            article.paragraphUUIDs.removeAll()
                            article.paragraphUUIDs.append(objectsIn: orderedIDs)
                            article.updateTime = Date()
                        }
                        // 如果ParagraphModel本身有order属性，也需要更新
                        for (i, id) in orderedIDs.enumerated() {
                            if let p = realm.object(ofType: ParagraphModel.self, forPrimaryKey: id) {
                                p.order = i
                                p.updateTime = Date()
                            }
                        }
                    }
                } catch {
                    print("Failed to update paragraph order in ArticleManager:", error)
                }
            }
        }
    }
    func getParagraphViewData(for article: ArticleModel) -> [ParagraphViewData] {
        guard let realm = realm else { return [] }
        
        // 安全检查，确保文章对象有效
        if article.isInvalidated {
            return []
        }
        
        return article.paragraphUUIDs.compactMap { uuid in
            guard let paragraph = realm.object(ofType: ParagraphModel.self, forPrimaryKey: uuid),
                  !paragraph.isInvalidated else {
                return nil
            }
            
            return ParagraphViewData(
                id: paragraph.uuid,
                text: paragraph.text,
                createTime: paragraph.createTime,
                voiceCount: paragraph.voices.count
            )
        }
    }
}

