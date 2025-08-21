import Foundation
import Alamofire
import AVFoundation

class AudioService: ObservableObject {
    static let shared = AudioService()
    
    private let ttsURL = "https://tts-voice-magic.1941109171.workers.dev/v1/audio/speech"
    private let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    private init() {}
    
    // 获取音频文件路径
    func getAudioFilePath(for uuid: String) -> URL {
        return documentsPath.appendingPathComponent("\(uuid).mp3")
    }
    
    // 检查音频文件是否存在
    func audioFileExists(for uuid: String) -> Bool {
        let filePath = getAudioFilePath(for: uuid)
        return FileManager.default.fileExists(atPath: filePath.path)
    }
    
    // 生成单个音频文件
    func generateAudio(for text: String, uuid: String, completion: @escaping (Bool) -> Void) {
        let parameters: [String: Any] = [
            "input": text,
            "voice": "en-US-JennyNeural",
            "speed": 1.0,
            "pitch": "0",
            "style": "general"
        ]
        
        let filePath = getAudioFilePath(for: uuid)
        
        AF.request(ttsURL, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseData { response in
                DispatchQueue.main.async {
                    switch response.result {
                    case .success(let data):
                        do {
                            try data.write(to: filePath)
                            print("Audio saved successfully: \(filePath.path)")
                            completion(true)
                        } catch {
                            print("Failed to save audio file: \(error)")
                            completion(false)
                        }
                    case .failure(let error):
                        print("TTS API request failed: \(error)")
                        completion(false)
                    }
                }
            }
    }
    
    // 批量生成音频文件（段落）
    func generateAudioForParagraphs(_ paragraphs: [ParagraphModel], completion: @escaping (Int) -> Void) {
        let paragraphsWithoutAudio = paragraphs.filter { !audioFileExists(for: $0.uuid) }
        var completedCount = 0
        
        guard !paragraphsWithoutAudio.isEmpty else {
            completion(0)
            return
        }
        
        for paragraphModel in paragraphsWithoutAudio {
            generateAudio(for: paragraphModel.text, uuid: paragraphModel.uuid) { success in
                completedCount += 1
                if completedCount == paragraphsWithoutAudio.count {
                    completion(completedCount)
                }
            }
        }
    }
    
    // 为特定音色生成音频
    func generateAudioForVoice(_ voice: VoiceModel, paragraph: ParagraphModel, completion: @escaping (Bool) -> Void) {
        let parameters: [String: Any] = [
            "input": paragraph.text,
            "voice": voice.voiceType,
            "speed": 1.0,
            "pitch": voice.pitch,
            "style": voice.style
        ]
        
        // 使用voice的uuid作为文件名
        let audioURL = getAudioFilePath(for: voice.uuid)
        
        AF.request(ttsURL, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseData { response in
                DispatchQueue.main.async {
                    switch response.result {
                    case .success(let data):
                        do {
                            try data.write(to: audioURL)
                            print("Voice audio saved successfully: \(audioURL.path)")
                            completion(true)
                        } catch {
                            print("Failed to save voice audio file: \(error)")
                            completion(false)
                        }
                    case .failure(let error):
                        print("Voice TTS API request failed: \(error)")
                        completion(false)
                    }
                }
            }
    }
    
    // 创建AVAudioPlayer
    func createAudioPlayer(for uuid: String) -> AVAudioPlayer? {
        let filePath = getAudioFilePath(for: uuid)
        
        do {
            let audioPlayer = try AVAudioPlayer(contentsOf: filePath)
            return audioPlayer
        } catch {
            print("Failed to create audio player: \(error)")
            return nil
        }
    }
}
