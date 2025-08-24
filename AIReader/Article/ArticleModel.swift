import Foundation
import RealmSwift

class ArticleModel: Object, Identifiable {
    @Persisted(primaryKey: true) var uuid: String = UUID().uuidString
    @Persisted var name: String = ""
    @Persisted var createTime: Date = Date()
    @Persisted var updateTime: Date = Date()
    
    // 文章的全局默认语音设置
    @Persisted var voiceValue: String = ""
    @Persisted var speedValue: String = "1.0"
    @Persisted var pitchValue: String = "0"
    @Persisted var styleValue: String = "general"
    
    // 一篇文章可以包含多个段落的UUID，用于维护顺序和关联
    @Persisted var paragraphUUIDs: RealmSwift.List<String>
    
    convenience init(name: String, paragraphUUIDs: [String] = [],
                     voiceValue: String = "zh-CN-XiaoxiaoNeural",
                     speedValue: String = "1.0",
                     pitchValue: String = "0",
                     styleValue: String = "general") {
        self.init()
        self.name = name
        self.paragraphUUIDs.append(objectsIn: paragraphUUIDs)
        self.voiceValue = voiceValue
        self.speedValue = speedValue
        self.pitchValue = pitchValue
        self.styleValue = styleValue
    }
}
