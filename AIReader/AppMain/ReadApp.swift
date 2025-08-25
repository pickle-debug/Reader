import SwiftUI
import DebugSwift

@main
struct ReadApp: App {
    // DebugSwift 通常不需要一个实例属性，因为它通常通过静态方法进行配置和显示。
    // 如果 DebugSwift 要求一个实例，那么你可以在 init() 中创建它并存储在一个单例或静态变量中。
    // 但根据你提供的配置代码，它使用的是静态方法 `DebugSwift.setup()` 和 `DebugSwift.show()`。

    @Environment(\.scenePhase) private var scenePhase // 引入 scenePhase 来监听应用状态
    private let debugSwift = DebugSwift()

    init() {
        #if DEBUG
        // 在应用启动时进行 DebugSwift 的初始化设置
        debugSwift.setup()
        // debugSwift.setup(disable: [.leaksDetector]) // 如果需要禁用某些功能
        #endif
        print("App initialized. DebugSwift setup called (if in DEBUG).")
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                // 使用 .onChange 监听 scenePhase 的变化
                .onChange(of: scenePhase) { newPhase in
                    #if DEBUG
                    if newPhase == .active {
                        // 当应用变为活跃状态时显示 DebugSwift
                        debugSwift.show()
                        print("App became active. DebugSwift show called.")
                    } else if newPhase == .inactive {
                        // 可选：当应用变为非活跃状态时隐藏 DebugSwift
                        // DebugSwift.hide() // 如果 DebugSwift 有 hide 方法并且你需要这个行为
                        print("App became inactive.")
                    } else if newPhase == .background {
                        // 可选：当应用进入后台时隐藏 DebugSwift
                        // DebugSwift.hide() // 如果 DebugSwift 有 hide 方法并且你需要这个行为
                        print("App went to background.")
                    }
                    #endif
                }
        }
    }
}
