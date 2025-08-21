import Foundation
import AVFoundation
import SwiftUI
import RealmSwift

enum PlayMode: CaseIterable {
    case listLoop
    case random
    case singleLoop
    
    var description: String {
        switch self {
        case .listLoop:
            return "列表循环"
        case .random:
            return "随机播放"
        case .singleLoop:
            return "单曲循环"
        }
    }
    
    var icon: String {
        switch self {
        case .listLoop:
            return "repeat"
        case .random:
            return "shuffle"
        case .singleLoop:
            return "repeat.1"
        }
    }
}

class TextViewModel: ObservableObject {
    @Published var textModels: [TextModel] = []
    @Published var selectedTexts: Set<Int> = []
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var playMode: PlayMode = .listLoop
    @Published var currentTrackIndex = 0
    @Published var isGenerating = false
    
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    private var realm: Realm?
    private let audioService = AudioService.shared
    
    // 计算属性：获取文本数组
    var texts: [String] {
        return textModels.map { $0.text }
    }
    
    init() {
        setupRealm()
        loadTextsFromRealm()
        
        // 如果没有数据，添加一些示例文本
        if textModels.isEmpty {
            addSampleTexts()
        }
    }
    
    // MARK: - Realm Setup and Management
    
    private func setupRealm() {
        do {
            realm = try Realm()
        } catch {
            print("Failed to initialize Realm: \(error)")
        }
    }
    
    private func loadTextsFromRealm() {
        guard let realm = realm else { return }
        
        let results = realm.objects(TextModel.self).sorted(byKeyPath: "createTime", ascending: true)
        textModels = Array(results)
    }
    
    private func addSampleTexts() {
        let sampleTexts = [
            "Hello, this is a sample text for AI voice generation.",
            "The quick brown fox jumps over the lazy dog.",
            "Welcome to our AI voice generation app.",
            "This text will be converted to speech using artificial intelligence."
        ]
        
        for text in sampleTexts {
            addText(text)
        }
    }
    
    // MARK: - Text Management
    
    func addText(_ text: String) {
        let uuid = UUID().uuidString
        let textModel = TextModel(uuid: uuid, text: text, mp3file: "\(uuid).mp3")
        
        guard let realm = realm else { return }
        
        do {
            try realm.write {
                realm.add(textModel)
            }
            textModels.append(textModel)
        } catch {
            print("Failed to add text to Realm: \(error)")
        }
    }
    
    func toggleSelection(_ index: Int) {
        if selectedTexts.contains(index) {
            selectedTexts.remove(index)
        } else {
            selectedTexts.insert(index)
        }
    }
    
    func clearSelection() {
        selectedTexts.removeAll()
    }
    
    // MARK: - Playback Control
    
    func togglePlayback() {
        if isPlaying {
            pausePlayback()
        } else {
            startPlayback()
        }
    }
    
    func startPlayback() {
        guard !selectedTexts.isEmpty else { return }
        
        let selectedArray = Array(selectedTexts).sorted()
        if currentTrackIndex == 0 && !selectedArray.isEmpty {
            currentTrackIndex = selectedArray[0]
        }
        
        guard currentTrackIndex < textModels.count else { return }
        
        let currentTextModel = textModels[currentTrackIndex]
        
        // 检查音频文件是否存在
        if audioService.audioFileExists(for: currentTextModel.uuid) {
            // 音频文件存在，直接播放
            if let player = audioService.createAudioPlayer(for: currentTextModel.uuid) {
                audioPlayer = player
                audioPlayer?.play()
                isPlaying = true
                startTimer()
            }
        } else {
            // 音频文件不存在，先生成音频
            isGenerating = true
            audioService.generateAudio(for: currentTextModel.text, uuid: currentTextModel.uuid) { [weak self] success in
                DispatchQueue.main.async {
                    self?.isGenerating = false
                    if success {
                        self?.startPlayback() // 重新开始播放
                    }
                }
            }
        }
    }
    
    func pausePlayback() {
        audioPlayer?.pause()
        isPlaying = false
        stopTimer()
    }
    
    func nextTrack() {
        guard !selectedTexts.isEmpty else { return }
        
        let selectedArray = Array(selectedTexts).sorted()
        let currentIndex = selectedArray.firstIndex(of: currentTrackIndex) ?? -1
        
        switch playMode {
        case .listLoop:
            let nextIndex = (currentIndex + 1) % selectedArray.count
            currentTrackIndex = selectedArray[nextIndex]
        case .random:
            currentTrackIndex = selectedArray.randomElement() ?? selectedArray[0]
        case .singleLoop:
            // 单曲循环，不改变当前曲目
            break
        }
        
        // 重新开始播放当前曲目
        if isPlaying {
            startPlayback()
        }
    }
    
    func previousTrack() {
        guard !selectedTexts.isEmpty else { return }
        
        let selectedArray = Array(selectedTexts).sorted()
        let currentIndex = selectedArray.firstIndex(of: currentTrackIndex) ?? -1
        
        switch playMode {
        case .listLoop:
            let prevIndex = currentIndex > 0 ? currentIndex - 1 : selectedArray.count - 1
            currentTrackIndex = selectedArray[prevIndex]
        case .random:
            currentTrackIndex = selectedArray.randomElement() ?? selectedArray[0]
        case .singleLoop:
            // 单曲循环，不改变当前曲目
            break
        }
        
        // 重新开始播放当前曲目
        if isPlaying {
            startPlayback()
        }
    }
    
    func cyclePlayMode() {
        let currentIndex = PlayMode.allCases.firstIndex(of: playMode) ?? 0
        let nextIndex = (currentIndex + 1) % PlayMode.allCases.count
        playMode = PlayMode.allCases[nextIndex]
    }
    
    // MARK: - AI Voice Generation
    
    func generateAIVoice() {
        guard !selectedTexts.isEmpty else { return }
        
        let selectedTextModels = Array(selectedTexts).sorted().compactMap { index in
            index < textModels.count ? textModels[index] : nil
        }
        
        isGenerating = true
        
        audioService.generateAudioForTexts(selectedTextModels) { [weak self] completedCount in
            DispatchQueue.main.async {
                self?.isGenerating = false
                print("Generated \(completedCount) audio files")
                
                // 自动开始播放第一个选中的文本
                if let selectedTexts = self?.selectedTexts, !selectedTexts.isEmpty {
                    self?.currentTrackIndex = Array(self?.selectedTexts ?? []).sorted()[0]
                    self?.startPlayback()
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func startTimer() {
        guard let audioPlayer = audioPlayer else { return }
        
        duration = audioPlayer.duration
        currentTime = 0
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if self.audioPlayer?.isPlaying == true {
                self.currentTime = self.audioPlayer?.currentTime ?? 0
            } else if self.currentTime >= self.duration {
                self.nextTrack()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Computed Properties
    
    var progress: Double {
        guard duration > 0 else { return 0 }
        return currentTime / duration
    }
    
    var currentTimeString: String {
        let minutes = Int(currentTime) / 60
        let seconds = Int(currentTime) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var remainingTimeString: String {
        let remaining = duration - currentTime
        let minutes = Int(remaining) / 60
        let seconds = Int(remaining) % 60
        return String(format: "-%d:%02d", minutes, seconds)
    }
    
    var currentText: String {
        guard currentTrackIndex < textModels.count else { return "" }
        return textModels[currentTrackIndex].text
    }
}
