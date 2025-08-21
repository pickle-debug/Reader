import Foundation
import RealmSwift

class VoiceModel: Object, Identifiable {
    @Persisted(primaryKey: true) var uuid: String
    @Persisted var voiceType: String // 音色类型，如 "en-US-JennyNeural"
    @Persisted var pitch: String // 音调
    @Persisted var style: String // 风格
    @Persisted var createTime: Date
    @Persisted var updateTime: Date
    @Persisted var md5: String // 用于缓存标识
    
    // 反向关系：指向Paragraph
    @Persisted(originProperty: "voices") var paragraph: LinkingObjects<ParagraphModel>
    
    convenience init(uuid: String, voiceType: String, pitch: String, style: String, md5: String) {
        self.init()
        self.uuid = uuid
        self.voiceType = voiceType
        self.pitch = pitch
        self.style = style
        self.md5 = md5
        self.createTime = Date()
        self.updateTime = Date()
    }
    
    override static func primaryKey() -> String? {
        return "uuid"
    }
}
