//
//  KeyboardPreloader.swift
//  read
//
//  Created by gidon on 2025/8/22.
//


import UIKit

final class KeyboardPreloader {
    static let shared = KeyboardPreloader()
    private var didPreload = false

    /// 是否处于预热过程（供你的键盘观察者绕过）
    private(set) var isPreloading = false

    /// 在 app Active 后调用一次
    func preload() {
        guard !didPreload else { return }
        didPreload = true

        DispatchQueue.main.async {
            self.isPreloading = true

            // 找到 keyWindow
            guard let window = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .flatMap({ $0.windows })
                .first(where: { $0.isKeyWindow }) else {
                    self.isPreloading = false
                    return
                }

            // 隐藏的文本框（不参与布局、不显示）
            let tf = UITextField(frame: .zero)
            tf.isHidden = true
            tf.isUserInteractionEnabled = false
            // 可选：关闭快捷栏，避免约束抖动日志
            let item = tf.inputAssistantItem
            item.leadingBarButtonGroups = []
            item.trailingBarButtonGroups = []

            window.addSubview(tf)

            // 预热：先成为第一响应者再立即放弃
            tf.becomeFirstResponder()
            tf.resignFirstResponder()

            tf.removeFromSuperview()

            // 稍等一帧再解除“预热锁”，让系统通知走完
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                self.isPreloading = false
            }
        }
    }
}
//若有监听 keyboardWillShow/Hide 来推 UI 的逻辑，在回调里绕开预热阶段，避免“预热”触发你的 UI 动画或状态改变。
final class KeyboardObserver: ObservableObject {
    @Published var isVisible = false
    private var tokens: [NSObjectProtocol] = []

    init() {
        let nc = NotificationCenter.default
        tokens.append(nc.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { _ in
            guard !KeyboardPreloader.shared.isPreloading else { return }
            self.isVisible = true
        })
        tokens.append(nc.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            guard !KeyboardPreloader.shared.isPreloading else { return }
            self.isVisible = false
        })
    }
}
