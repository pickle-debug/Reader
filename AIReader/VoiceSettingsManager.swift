//
//  VoiceSettingsManager.swift
//  read
//
//  Created by gidon on 2025/8/25.
//


import Foundation
import Combine

struct VoiceOptions: Hashable, Identifiable, Codable {
    var id: String { UUID().uuidString }
    var voiceValue: String
    var speedValue: String
    var pitchValue: String
    var styleValue: String
    
    // 默认设置
    static let `default` = VoiceOptions(
        voiceValue: "zh-CN-XiaoxiaoNeural",
        speedValue: "1.0",
        pitchValue: "0",
        styleValue: "general"
    )
}

// UserDefaults扩展，用于存储和读取语音设置
extension UserDefaults {
    private enum Keys {
        static let voiceOptions = "VoiceOptions"
    }
    
    var voiceOptions: VoiceOptions {
        get {
            guard let data = data(forKey: Keys.voiceOptions),
                  let options = try? JSONDecoder().decode(VoiceOptions.self, from: data) else {
                return .default
            }
            return options
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else { return }
            set(data, forKey: Keys.voiceOptions)
        }
    }
}

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()
    
    @Published var voiceOptions: VoiceOptions {
        didSet {
            // 自动保存到UserDefaults
            UserDefaults.standard.voiceOptions = voiceOptions
        }
    }
    
    private init() {
        // 从UserDefaults读取设置
        self.voiceOptions = UserDefaults.standard.voiceOptions
    }
    
    // 更新语音设置
    func updateVoice(_ value: String) {
        voiceOptions.voiceValue = value
    }
    
    func updateSpeed(_ value: String) {
        voiceOptions.speedValue = value
    }
    
    func updatePitch(_ value: String) {
        voiceOptions.pitchValue = value
    }
    
    func updateStyle(_ value: String) {
        voiceOptions.styleValue = value
    }
    
    // 重置为默认设置
    func resetToDefault() {
        voiceOptions = .default
    }
}
