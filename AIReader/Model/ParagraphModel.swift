import Foundation
import RealmSwift

class ParagraphModel: Object, Identifiable {
    @Persisted(primaryKey: true) var uuid: String
    @Persisted var text: String
    @Persisted var mp3file: String
    @Persisted var createTime: Date
    @Persisted var updateTime: Date
    
    // 反向关系：指向Article
    @Persisted(originProperty: "paragraphs") var article: LinkingObjects<ArticleModel>
    
    @Persisted var voices: List<VoiceModel> = List<VoiceModel>()
    
    convenience init(uuid: String, text: String, mp3file: String) {
        self.init()
        self.uuid = uuid
        self.text = text
        self.mp3file = mp3file
        self.createTime = Date()
        self.updateTime = Date()
    }
    
    override static func primaryKey() -> String? {
        return "uuid"
    }
}
