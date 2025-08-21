# AIReader - AI配音生成器

一个基于SwiftUI的iOS应用，支持文本转语音(TTS)功能，使用Realm进行本地数据存储。

## 功能特性

### 数据存储
- 使用Realm数据库进行本地存储
- 文本数据结构：`uuid`, `text`, `mp3file`, `createTime`, `updateTime`
- 音频文件以UUID命名存储在应用文档目录

### 音频生成
- 集成TTS API：`https://tts-voice-magic.1941109171.workers.dev/v1/audio/speech`
- 支持批量音频生成
- 自动检查本地音频文件，避免重复生成
- 使用Alamofire进行网络请求

### 播放控制
- 支持列表循环、随机播放、单曲循环
- 实时播放进度显示
- 上一首/下一首切换

## 技术栈

- **SwiftUI**: 用户界面框架
- **Realm**: 本地数据库
- **Alamofire**: 网络请求库
- **AVFoundation**: 音频播放

## 数据模型

```swift
class TextModel: Object {
    @Persisted(primaryKey: true) var uuid: String
    @Persisted var text: String
    @Persisted var mp3file: String
    @Persisted var createTime: Date
    @Persisted var updateTime: Date
}
```

## 使用方法

1. 添加文本：点击"+"按钮添加新的文本
2. 选择文本：点击文本项进行选择
3. 生成音频：点击"生成AI配音"按钮
4. 播放控制：使用播放控制按钮进行播放、暂停、切换

## API配置

TTS API请求格式：
```json
{
  "input": "文本内容",
  "voice": "en-US-JennyNeural",
  "speed": 1.0,
  "pitch": "0",
  "style": "general"
}
```

## 文件结构

- `TextModel.swift`: Realm数据模型
- `AudioService.swift`: 音频服务和TTS API集成
- `TextViewModel.swift`: 主要业务逻辑
- `ContentView.swift`: 主界面

## 安装和运行

1. 克隆项目
2. 在Xcode中打开`AIReader.xcodeproj`
3. 选择目标设备或模拟器
4. 运行项目

## 注意事项

- 首次运行时会自动添加示例文本
- 音频文件存储在应用的Documents目录
- 网络请求需要网络连接
- 音频生成可能需要一些时间，请耐心等待
