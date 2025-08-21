import Foundation
import RealmSwift

class TextModel: Object {
    @Persisted(primaryKey: true) var uuid: String
    @Persisted var text: String
    @Persisted var mp3file: String
    @Persisted var createTime: Date
    @Persisted var updateTime: Date
    
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
