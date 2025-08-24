//
//  VoiceManager.swift
//  read
//
//  Created by 何纪栋 on 2025/8/24.
//

import Foundation
import RealmSwift

class VoiceManager: ObservableObject {
    static let shared = VoiceManager()
    
    private var realm: Realm?
    private var notificationToken: NotificationToken?
    
    init() {
        setupRealm()
    }
    
    deinit {
        notificationToken?.invalidate()
    }
    
    private func setupRealm() {
        do {
            realm = try Realm()
        } catch {
            print("Failed to initialize VoiceManager Realm: \(error)")
        }
    }
    
    /// 添加一个VoiceModel到数据库
    func addVoice(voiceModel: VoiceModel, to paragraphUUID: String) {
        guard let realm = realm else { return }
        do {
            try realm.write {
                if let paragraph = realm.object(ofType: ParagraphModel.self, forPrimaryKey: paragraphUUID) {
                    paragraph.voices.append(voiceModel)
                    paragraph.updateTime = Date()
                } else {
                    print("Error: Paragraph with UUID \(paragraphUUID) not found for adding voice.")
                }
            }
        } catch {
            print("Failed to add voice to Realm: \(error)")
        }
    }
    
    /// 获取某个段落下的所有VoiceModel
    func getVoices(for paragraphUUID: String) -> Results<VoiceModel>? {
        guard let realm = realm else { return nil }
        if let paragraph = realm.object(ofType: ParagraphModel.self, forPrimaryKey: paragraphUUID) {
            return paragraph.voices.sorted(byKeyPath: "createTime", ascending: false)
        }
        return nil
    }
    
    /// 删除一个VoiceModel及其本地文件
    func deleteVoice(uuid: String) {
        guard let realm = realm else { return }
        do {
            try realm.write {
                if let voice = realm.object(ofType: VoiceModel.self, forPrimaryKey: uuid) {
                    let audioFilePath = AudioService.shared.getAudioFilePath(for: voice.uuid)
                    if FileManager.default.fileExists(atPath: audioFilePath.path) {
                        do {
                            try FileManager.default.removeItem(at: audioFilePath)
                            print("Deleted audio file: \(audioFilePath.path)")
                        } catch {
                            print("Error deleting audio file: \(error)")
                        }
                    }
                    realm.delete(voice)
                }
            }
        } catch {
            print("Failed to delete voice from Realm: \(error)")
        }
    }
    
    /// 检查指定参数组合的语音是否已存在于某个段落
    func voiceExists(for paragraphUUID: String, voiceValue: String, speedValue: String, pitchValue: String, styleValue: String) -> VoiceModel? {
        guard let realm = realm else { return nil }
        if let paragraph = realm.object(ofType: ParagraphModel.self, forPrimaryKey: paragraphUUID) {
            return paragraph.voices.first {
                $0.voiceValue == voiceValue &&
                $0.speedValue == speedValue &&
                $0.pitchValue == pitchValue &&
                $0.styleValue == styleValue
            }
        }
        return nil
    }
}
