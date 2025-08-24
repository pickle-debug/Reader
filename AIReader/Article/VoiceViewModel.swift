//
//  VoiceSettingsViewModel.swift
//  read
//
//  Created by 何纪栋 on 2025/8/24.
//

import SwiftUI
import Alamofire
import Realm
import Combine

class VoiceViewModel: ObservableObject {
    @Published var selectedVoice: VoiceOption
    @Published var selectedSpeed: VoiceOption
    @Published var selectedPitch: VoiceOption
    @Published var selectedStyle: VoiceOption
    @Published var isGenerating: Bool = false
    @Published var generationProgress: Double = 0.0
    @Published var generatedCount: Int = 0
    @Published var totalToGenerate: Int = 0
    @Published var errorMessage: String?
    private var article: ArticleModel


    // ArticleDetailViewModel 的引用，用于访问文章数据和更新全局设置
//    @ObservedObject private var articleDetailViewModel: ArticleDetailViewModel
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - 语音选项数据 (已更新 value 属性, 与 AudioService 参数保持一致)
    let voiceOptions: [VoiceOption] // 所有可选的语音
        let speedOptions: [VoiceOption]
        let pitchOptions: [VoiceOption]
        let styleOptions: [VoiceOption]
        
        init(article: ArticleModel) {
            self.article = article
            
            // ... (语音、语速、音调、风格选项数据保持不变，与之前提供的一致)
            self.voiceOptions = [
                VoiceOption(name: "晓晓", description: "女声·温柔", icon: "person.wave.2.fill", value: "zh-CN-XiaoxiaoNeural"),
                VoiceOption(name: "云希", description: "男声·清朗", icon: "person.crop.circle.fill", value: "zh-CN-YunxiNeural"),
                VoiceOption(name: "云扬", description: "男声·阳光", icon: "person.wave.2", value: "zh-CN-YunyangNeural"),
                VoiceOption(name: "晓伊", description: "女声·甜美", icon: "person.fill", value: "zh-CN-XiaoyiNeural"),
                VoiceOption(name: "Jenny", description: "Female·Friendly", icon: "person.crop.circle.fill", value: "en-US-JennyNeural"),
                VoiceOption(name: "Guy", description: "Male·Casual", icon: "person.crop.circle", value: "en-US-GuyNeural")
                // ... (其他语音选项)
            ]
            
            self.speedOptions = [
                VoiceOption(name: "很慢", description: "0.5x", icon: "tortoise.fill", value: "0.5"),
                VoiceOption(name: "慢速", description: "0.75x", icon: "tortoise", value: "0.75"),
                VoiceOption(name: "正常", description: "1.0x", icon: "bolt", value: "1.0"),
                VoiceOption(name: "快速", description: "1.25x", icon: "hare", value: "1.25"),
                VoiceOption(name: "很快", description: "1.5x", icon: "hare.fill", value: "1.5"),
                VoiceOption(name: "极速", description: "2.0x", icon: "bolt.fill", value: "2.0")
            ]
            
            self.pitchOptions = [
                VoiceOption(name: "很低沉", description: "-50", icon: "arrow.down.to.line", value: "-50"),
                VoiceOption(name: "低沉", description: "-25", icon: "arrow.down", value: "-25"),
                VoiceOption(name: "标准", description: "0", icon: "music.note", value: "0"),
                VoiceOption(name: "高亢", description: "+25", icon: "arrow.up", value: "25"),
                VoiceOption(name: "很高亢", description: "+50", icon: "arrow.up.to.line", value: "50")
            ]
            
            self.styleOptions = [
                VoiceOption(name: "通用风格", description: "标准朗读", icon: "theatermasks.fill", value: "general"),
                VoiceOption(name: "智能助手", description: "AI助手", icon: "sparkle.magnifyingglass", value: "assistant"),
                VoiceOption(name: "聊天对话", description: "自然交流", icon: "message.fill", value: "chat"),
                VoiceOption(name: "客服专业", description: "服务场景", icon: "headset.fill", value: "customerservice"),
                VoiceOption(name: "新闻播报", description: "正式专业", icon: "newspaper.fill", value: "newscast"),
                VoiceOption(name: "亲切温暖", description: "情感表达", icon: "heart.text.square.fill", value: "affectionate"),
                VoiceOption(name: "平静舒缓", description: "放松镇定", icon: "bed.double.fill", value: "calm"),
                VoiceOption(name: "愉快欢乐", description: "积极开朗", icon: "face.smiling.fill", value: "cheerful"),
                VoiceOption(name: "温和柔美", description: "温柔细腻", icon: "hand.raised.fill", value: "gentle"),
                VoiceOption(name: "抒情诗意", description: "富有感情", icon: "music.note.list", value: "lyrical"),
                VoiceOption(name: "严肃正式", description: "庄重认真", icon: "exclamationmark.shield.fill", value: "serious")
            ]
            self.selectedVoice = voiceOptions[0]
            self.selectedSpeed = speedOptions[0]
            self.selectedPitch = pitchOptions[0]
            self.selectedStyle = styleOptions[0]
//            let initialGlobalOptions = articleDetailViewModel.articleGlobalVoiceOptions
//            self.selectedVoice = voiceOptions.first(where: { $0.value == initialGlobalOptions.voiceValue }) ?? voiceOptions[0]
//            self.selectedSpeed = speedOptions.first(where: { $0.value == initialGlobalOptions.speedValue }) ?? speedOptions[0]
//            self.selectedPitch = pitchOptions.first(where: { $0.value == initialGlobalOptions.pitchValue }) ?? pitchOptions[0]
//            self.selectedStyle = styleOptions.first(where: { $0.value == initialGlobalOptions.styleValue }) ?? styleOptions[0]
            
            
//            articleDetailViewModel.$articleGlobalVoiceOptions
//                .sink { [weak self] newOptions in
//                    guard let self = self else { return }
//                    // 仅当本地选择与文章全局设置不同时才更新，避免循环更新
//                    if self.selectedVoice.value != newOptions.voiceValue {
//                        self.selectedVoice = self.voiceOptions.first(where: { $0.value == newOptions.voiceValue }) ?? self.voiceOptions[0]
//                    }
//                    if self.selectedSpeed.value != newOptions.speedValue {
//                        self.selectedSpeed = self.speedOptions.first(where: { $0.value == newOptions.speedValue }) ?? self.speedOptions[0]
//                    }
//                    if self.selectedPitch.value != newOptions.pitchValue {
//                        self.selectedPitch = self.pitchOptions.first(where: { $0.value == newOptions.pitchValue }) ?? self.pitchOptions[0]
//                    }
//                    if self.selectedStyle.value != newOptions.styleValue {
//                        self.selectedStyle = self.styleOptions.first(where: { $0.value == newOptions.styleValue }) ?? self.styleOptions[0]
//                    }
//                }
//                .store(in: &cancellables)
        }
        
        func generateVoiceForAllParagraphs() {
            guard !isGenerating else { return }
            
            // 使用 ArticleDetailViewModel 中文章的 paragraphUUIDs 来获取段落
            let paragraphsUUIDsToProcess = article.paragraphUUIDs
            
            guard !paragraphsUUIDsToProcess.isEmpty else {
                errorMessage = "没有找到任何段落可供生成语音。"
                return
            }
            
            isGenerating = true
            generatedCount = 0
            totalToGenerate = paragraphsUUIDsToProcess.count
            generationProgress = 0.0
            errorMessage = nil
            
            let dispatchGroup = DispatchGroup()
            
            for paragraphUUID in paragraphsUUIDsToProcess {
                dispatchGroup.enter()
                
//                if let realm = try? Realm(), let paragraph = realm.object(ofType: ParagraphModel.self, forPrimaryKey: paragraphUUID) {
//                    AudioService.shared.generateAndSaveAudio(
//                        for: paragraph.text,
//                        paragraphUUID: paragraph.uuid,
//                        voiceSelection: selectedVoice, // 使用当前选中的设置
//                        speedSelection: selectedSpeed,
//                        pitchSelection: selectedPitch,
//                        styleSelection: selectedStyle
//                    ) { [weak self] success, voiceModel in
//                        DispatchQueue.main.async {
//                            self?.generatedCount += 1
//                            self?.generationProgress = Double(self?.generatedCount ?? 0) / Double(self?.totalToGenerate ?? 1)
//                            if !success {
//                                self?.errorMessage = "部分语音生成失败。请检查网络或重试。"
//                            }
//                            dispatchGroup.leave()
//                        }
//                    }
//                } else {
//                    print("Error: Paragraph with UUID \(paragraphUUID) not found for generation.")
//                    dispatchGroup.leave()
//                }
            }
            
            dispatchGroup.notify(queue: .main) { [weak self] in
                self?.isGenerating = false
                print("所有段落语音生成完成！")
                // 刷新文章数据以显示新的语音
//                self?.$articleDetailViewModel.refreshArticleData()
            }
        }
}
