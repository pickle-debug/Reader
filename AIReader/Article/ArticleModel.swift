import Foundation
import RealmSwift

class ArticleModel: Object, Identifiable {
    @Persisted(primaryKey: true) var uuid: String
    @Persisted var createTime: Date
    @Persisted var name: String
    @Persisted var updateTime: Date
    
    // 改为存储段落UUID的引用，而不是直接包含段落
    @Persisted var paragraphUUIDs = List<String>()
    
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
