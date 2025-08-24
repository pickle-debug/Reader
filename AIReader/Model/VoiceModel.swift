import Foundation
import RealmSwift

class VoiceModel: Object, Identifiable {
    @Persisted(primaryKey: true) var uuid: String = UUID().uuidString // 语音文件的UUID
    @Persisted var voiceURL: String = "" // 本地文件路径
    @Persisted var paragraphUUID: String = "" // 关联的段落UUID
    @Persisted var voiceValue: String = "" // 语音选项的value
    @Persisted var speedValue: String = "" // 语速选项的value
    @Persisted var pitchValue: String = "" // 音调选项的value
    @Persisted var styleValue: String = "" // 风格选项的value
    @Persisted var createTime: Date = Date()
    
    @Persisted(originProperty: "voices") var paragraph: LinkingObjects<ParagraphModel>
    
    convenience init(uuid: String, voiceURL: String, paragraphUUID: String, voiceValue: String, speedValue: String, pitchValue: String, styleValue: String) {
        self.init()
        self.uuid = uuid
        self.voiceURL = voiceURL
        self.paragraphUUID = paragraphUUID
        self.voiceValue = voiceValue
        self.speedValue = speedValue
        self.pitchValue = pitchValue
        self.styleValue = styleValue
        self.createTime = Date()
    }
}
