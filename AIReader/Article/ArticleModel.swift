import Foundation
import RealmSwift

class ArticleModel: Object, Identifiable {
    @Persisted(primaryKey: true) var uuid: String
    @Persisted var createTime: Date
    @Persisted var name: String
    @Persisted var updateTime: Date
    
    // 一对多关系：一个文章包含多个段落
    @Persisted var paragraphs = List<ParagraphModel>()
    
    // 计算属性：获取所有音色
    var allVoices: [VoiceModel] {
        return Array(paragraphs.flatMap { $0.voices })
    }
    
    // 计算属性：获取段落数量
    var paragraphCount: Int {
        return paragraphs.count
    }
    
    // 计算属性：获取音色数量
    var voiceCount: Int {
        return allVoices.count
    }
    
    convenience init(uuid: String, name: String) {
        self.init()
        self.uuid = uuid
        self.name = name
        self.createTime = Date()
        self.updateTime = Date()
    }
    
    override static func primaryKey() -> String? {
        return "uuid"
    }
}
