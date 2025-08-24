import Foundation
import RealmSwift

class ParagraphModel: Object, Identifiable {
    @Persisted(primaryKey: true) var uuid: String = UUID().uuidString
    @Persisted var text: String = ""
    @Persisted var createTime: Date = Date()
    @Persisted var updateTime: Date = Date()
    @Persisted var order: Int = 0 // 用于排序
    
    // 一个段落可以有多个语音（例如不同音色、语速的生成）
    @Persisted var voices = RealmSwift.List<VoiceModel>() // 关联生成的语音
    
    convenience init(uuid: String = UUID().uuidString, text: String, order: Int = 0) {
        self.init()
        self.uuid = uuid
        self.text = text
        self.order = order
    }
}
