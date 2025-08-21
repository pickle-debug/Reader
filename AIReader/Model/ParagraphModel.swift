import Foundation
import RealmSwift

class ParagraphModel: Object, Identifiable {
    @Persisted(primaryKey: true) var uuid: String
    @Persisted var text: String
    @Persisted var createTime: Date
    @Persisted var updateTime: Date
    
    @Persisted var voices: List<VoiceModel> = List<VoiceModel>()
    @Persisted var defaultVoice: String? // 默认音色的UUID
    
    convenience init(uuid: String, text: String) {
        self.init()
        self.uuid = uuid
        self.text = text
        self.createTime = Date()
        self.updateTime = Date()
    }
    
    override static func primaryKey() -> String? {
        return "uuid"
    }
    
    // 获取当前默认音色
    var currentDefaultVoice: VoiceModel? {
        guard let defaultVoiceUUID = defaultVoice else { return nil }
        return voices.first(where: { $0.uuid == defaultVoiceUUID })
    }
    
    // 更新默认音色的逻辑
    func updateDefaultVoice(realm: Realm) {
        try! realm.write {
            if voices.isEmpty {
                // 如果没有音色，设置为 nil
                defaultVoice = nil
            } else if voices.count == 1 {
                // 如果只有一个音色，自动设置为默认
                defaultVoice = voices.first?.uuid
            } else if let currentDefault = defaultVoice,
                      !voices.contains(where: { $0.uuid == currentDefault }) {
                // 如果当前默认音色已被删除，重置为第一个音色
                defaultVoice = voices.first?.uuid
            }
            // 如果有多个音色且当前默认音色仍存在，则保持不变
            
            updateTime = Date()
        }
    }
    
    // 设置指定音色为默认音色
    func setDefaultVoice(_ voiceUUID: String, realm: Realm) {
        guard voices.contains(where: { $0.uuid == voiceUUID }) else { return }
        
        try! realm.write {
            defaultVoice = voiceUUID
            updateTime = Date()
        }
    }
}

