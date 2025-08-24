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
            return "列表"
        case .random:
            return "随机"
        case .singleLoop:
            return "单曲"
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

class ArticleViewModel: ObservableObject {
    @Published var selectedParagraphs: Set<Int> = []
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var playMode: PlayMode = .listLoop
    @Published var currentTrackIndex = 0
    @Published var isGenerating = false
    
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    private let audioService = AudioService.shared
    
    // 当前文章的段落
    private var paragraphs: [ParagraphModel] = []
    
    // 计算属性：获取文本数组
    var texts: [String] {
        return paragraphs.map { $0.text }
    }
    
    // 设置当前文章的段落
    func setParagraphs(_ paragraphs: [ParagraphModel]) {
        self.paragraphs = paragraphs
        selectedParagraphs.removeAll()
        currentTrackIndex = 0
        stopPlayback()
    }
    
    // MARK: - Selection Management
    
    func toggleSelection(_ index: Int) {
        if selectedParagraphs.contains(index) {
            selectedParagraphs.remove(index)
        } else {
            selectedParagraphs.insert(index)
        }
    }
    
    func clearSelection() {
        selectedParagraphs.removeAll()
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
        guard !selectedParagraphs.isEmpty else { return }
        
        let selectedArray = Array(selectedParagraphs).sorted()
        if currentTrackIndex == 0 && !selectedArray.isEmpty {
            currentTrackIndex = selectedArray[0]
        }
        
        guard currentTrackIndex < paragraphs.count else { return }
        
        let currentParagraph = paragraphs[currentTrackIndex]
        
//        // 检查音频文件是否存在
//        if audioService.audioFileExists(for: currentParagraph.uuid) {
//            // 音频文件存在，直接播放
//            if let player = audioService.createAudioPlayer(for: currentParagraph.uuid) {
//                audioPlayer = player
//                audioPlayer?.play()
//                isPlaying = true
//                startTimer()
//            }
//        } else {
//            // 音频文件不存在，先生成音频
//            isGenerating = true
//            audioService.generateAudio(for: currentParagraph.text, uuid: currentParagraph.uuid) { [weak self] success in
//                DispatchQueue.main.async {
//                    self?.isGenerating = false
//                    if success {
//                        self?.startPlayback() // 重新开始播放
//                    }
//                }
//            }
//        }
    }
    
    func pausePlayback() {
        audioPlayer?.pause()
        isPlaying = false
        stopTimer()
    }
    
    func nextTrack() {
        guard !selectedParagraphs.isEmpty else { return }
        
        let selectedArray = Array(selectedParagraphs).sorted()
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
        guard !selectedParagraphs.isEmpty else { return }
        
        let selectedArray = Array(selectedParagraphs).sorted()
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
        guard !selectedParagraphs.isEmpty else { return }
        
        let selectedParagraphModels = Array(selectedParagraphs).sorted().compactMap { index in
            index < paragraphs.count ? paragraphs[index] : nil
        }
        
        isGenerating = true
        
//        audioService.generateAudioForParagraphs(selectedParagraphModels) { [weak self] (completedCount: Int) in
//            DispatchQueue.main.async {
//                self?.isGenerating = false
//                print("Generated \(completedCount) audio files")
//                
//                // 自动开始播放第一个选中的文本
//                if let selectedParagraphs = self?.selectedParagraphs, !selectedParagraphs.isEmpty {
//                    self?.currentTrackIndex = Array(self?.selectedParagraphs ?? []).sorted()[0]
//                    self?.startPlayback()
//                }
//            }
//        }
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
    
    private func stopPlayback() {
        audioPlayer?.stop()
        isPlaying = false
        stopTimer()
        currentTime = 0
        duration = 0
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
        guard currentTrackIndex < paragraphs.count else { return "" }
        return paragraphs[currentTrackIndex].text
    }
}
