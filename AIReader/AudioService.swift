import Foundation
import Alamofire
import AVFoundation

class AudioService: ObservableObject {
    static let shared = AudioService()
    
    private let ttsURL = "https://tts-voice-magic.1941109171.workers.dev/v1/audio/speech"
    private let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    private init() {}
    
    func getAudioFilePath(for uuid: String) -> URL {
        return documentsPath.appendingPathComponent("\(uuid).mp3")
    }
    
    func audioFileExists(for uuid: String) -> Bool {
        let filePath = getAudioFilePath(for: uuid)
        return FileManager.default.fileExists(atPath: filePath.path)
    }
    
    /// 生成单个音频文件并保存，同时将元数据记录到Realm
    /// - Parameters:
    ///   - text: 需要合成的文本
    ///   - paragraphUUID: 关联的段落UUID
    ///   - voiceSelection: 选中的语音选项
    ///   - speedSelection: 选中的语速选项
    ///   - pitchSelection: 选中的音调选项
    ///   - styleSelection: 选中的风格选项
    ///   - completion: (成功标志, 生成的VoiceModel) -> Void
    func generateAndSaveAudio(
        for text: String,
        paragraphUUID: String,
        voiceSelection: VoiceOption,
        speedSelection: VoiceOption,
        pitchSelection: VoiceOption,
        styleSelection: VoiceOption,
        completion: @escaping (Bool, VoiceModel?) -> Void
    ) {
        // 先检查是否已经存在相同参数的语音，避免重复生成
        if let existingVoice = VoiceManager.shared.voiceExists(for: paragraphUUID,
                                                               voiceValue: voiceSelection.value,
                                                               speedValue: speedSelection.value,
                                                               pitchValue: pitchSelection.value,
                                                               styleValue: styleSelection.value) {
            if audioFileExists(for: existingVoice.uuid) {
                print("Voice already exists and file is present for paragraph \(paragraphUUID) with these settings. Skipping generation.")
                completion(true, existingVoice)
                return
            } else {
                print("Voice record exists but file is missing. Regenerating for \(paragraphUUID).")
                VoiceManager.shared.deleteVoice(uuid: existingVoice.uuid) // 删除旧记录，重新生成
            }
        }
        
        let newVoiceUUID = UUID().uuidString
        let filePath = getAudioFilePath(for: newVoiceUUID)
        
        let parameters: [String: Any] = [
            "input": text,
            "voice": voiceSelection.value,
            "speed": Double(speedSelection.value) ?? 1.0,
            "pitch": pitchSelection.value,
            "style": styleSelection.value
        ]
        
        AF.request(ttsURL, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseData { response in
                DispatchQueue.main.async {
                    switch response.result {
                    case .success(let data):
                        do {
                            try data.write(to: filePath)
                            print("Audio saved successfully: \(filePath.path)")
                            
                            let newVoice = VoiceModel(
                                uuid: newVoiceUUID,
                                voiceURL: filePath.lastPathComponent,
                                paragraphUUID: paragraphUUID,
                                voiceValue: voiceSelection.value,
                                speedValue: speedSelection.value,
                                pitchValue: pitchSelection.value,
                                styleValue: styleSelection.value
                            )
                            VoiceManager.shared.addVoice(voiceModel: newVoice, to: paragraphUUID)
                            
                            completion(true, newVoice)
                            
                        } catch {
                            print("Failed to save audio file or VoiceModel: \(error)")
                            completion(false, nil)
                        }
                    case .failure(let error):
                        print("TTS API request failed for \(paragraphUUID): \(error)")
                        completion(false, nil)
                    }
                }
            }
    }
    
    func createAudioPlayer(for voiceModel: VoiceModel) -> AVAudioPlayer? {
        let filePath = getAudioFilePath(for: voiceModel.uuid)
        guard FileManager.default.fileExists(atPath: filePath.path) else {
            print("Audio file not found at path: \(filePath.path)")
            return nil
        }
        do {
            let audioPlayer = try AVAudioPlayer(contentsOf: filePath)
            return audioPlayer
        } catch {
            print("Failed to create audio player for \(voiceModel.uuid): \(error)")
            return nil
        }
    }
}
