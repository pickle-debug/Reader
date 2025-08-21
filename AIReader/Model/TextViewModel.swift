import Foundation
import AVFoundation
import SwiftUI
import RealmSwift

class TextViewModel: ObservableObject {
    @Published var textModels: [ParagraphModel] = []
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
        
        let results = realm.objects(ParagraphModel.self).sorted(byKeyPath: "createTime", ascending: true)
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
        let paragraph = ParagraphModel(uuid: uuid, text: text)
        
        guard let realm = realm else { return }
        
        do {
            try realm.write {
                realm.add(paragraph)
            }
            textModels.append(paragraph)
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
        
        let selectedParagraphModels = Array(selectedTexts).sorted().compactMap { index in
            index < textModels.count ? textModels[index] : nil
        }
        
        isGenerating = true
        
        audioService.generateAudioForParagraphs(selectedParagraphModels) { [weak self] (completedCount: Int) in
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
    
    // MARK: - Text Management Methods
    
    func deleteText(at index: Int) {
        guard index < textModels.count else { return }
        
        let textModel = textModels[index]
        
        // 删除音频文件
        let audioService = AudioService.shared
        let filePath = audioService.getAudioFilePath(for: textModel.uuid)
        try? FileManager.default.removeItem(at: filePath)
        
        // 从Realm中删除
        guard let realm = realm else { return }
        
        do {
            try realm.write {
                realm.delete(textModel)
            }
            
            // 从数组中删除
            textModels.remove(at: index)
            
            // 更新选中的索引
            var newSelectedTexts: Set<Int> = []
            for selectedIndex in selectedTexts {
                if selectedIndex < index {
                    newSelectedTexts.insert(selectedIndex)
                } else if selectedIndex > index {
                    newSelectedTexts.insert(selectedIndex - 1)
                }
            }
            selectedTexts = newSelectedTexts
            
            // 更新当前播放索引
            if currentTrackIndex == index {
                currentTrackIndex = 0
            } else if currentTrackIndex > index {
                currentTrackIndex -= 1
            }
            
        } catch {
            print("Failed to delete text from Realm: \(error)")
        }
    }
    
    func updateText(at index: Int, newText: String) {
        guard index < textModels.count else { return }
        
        let textModel = textModels[index]
        
        guard let realm = realm else { return }
        
        do {
            try realm.write {
                textModel.text = newText
                textModel.updateTime = Date()
            }
            
            // 更新数组
            textModels[index] = textModel
            
        } catch {
            print("Failed to update text in Realm: \(error)")
        }
    }
    
    func moveText(from sourceIndex: IndexSet, to destination: Int) {
        guard let fromIndex = sourceIndex.first else { return }
        
        // 更新数组顺序
        let movedText = textModels.remove(at: fromIndex)
        textModels.insert(movedText, at: destination)
        
        // 更新Realm中的顺序（通过重新创建）
        guard let realm = realm else { return }
        
        do {
            try realm.write {
                // 删除所有现有对象
                realm.deleteAll()
                
                // 重新添加按新顺序排列的对象
                for textModel in textModels {
                    realm.add(textModel)
                }
            }
        } catch {
            print("Failed to reorder texts in Realm: \(error)")
        }
        
        // 更新选中的索引
        var newSelectedTexts: Set<Int> = []
        for selectedIndex in selectedTexts {
            if selectedIndex == fromIndex {
                newSelectedTexts.insert(destination)
            } else if selectedIndex < fromIndex && selectedIndex >= destination {
                newSelectedTexts.insert(selectedIndex + 1)
            } else if selectedIndex > fromIndex && selectedIndex <= destination {
                newSelectedTexts.insert(selectedIndex - 1)
            } else {
                newSelectedTexts.insert(selectedIndex)
            }
        }
        selectedTexts = newSelectedTexts
        
        // 更新当前播放索引
        if currentTrackIndex == fromIndex {
            currentTrackIndex = destination
        } else if currentTrackIndex < fromIndex && currentTrackIndex >= destination {
            currentTrackIndex += 1
        } else if currentTrackIndex > fromIndex && currentTrackIndex <= destination {
            currentTrackIndex -= 1
        }
    }
}
