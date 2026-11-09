import SwiftUI
import UIKit

@MainActor
class JumpManager: ObservableObject {
    static let shared = JumpManager()
    
    @Published var toastMessage: String? = nil
    private var toastTimer: Task<Void, Never>? = nil
    
    func jump(to key: EntryKey) {
        let haptic = UIImpactFeedbackGenerator(style: .medium)
        haptic.prepare()
        haptic.impactOccurred()
        
        let appUrls = key.appURLStrings.compactMap { URL(string: $0) }
        
        // Step 1: Try installed App scheme (for Douyin, goes directly to ecom_order_list)
        for url in appUrls {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:]) { success in
                    if success {
                        self.showToast(key.guideMessage)
                    } else {
                        self.fallbackOpen(for: key)
                    }
                }
                return
            }
        }
        
        // Step 2: Fallback (Mini Program or Web or direct open)
        fallbackOpen(for: key)
    }
    
    private func fallbackOpen(for key: EntryKey) {
        // Mini Program fallback (e.g. JD -> WeChat)
        if let miniStr = key.miniProgramURLString,
           let miniUrl = URL(string: miniStr),
           UIApplication.shared.canOpenURL(miniUrl) {
            UIApplication.shared.open(miniUrl, options: [:]) { success in
                if success {
                    self.showToast(key.guideMessage)
                } else {
                    self.openWeb(for: key)
                }
            }
            return
        }
        
        // Web fallback
        openWeb(for: key)
    }
    
    private func openWeb(for key: EntryKey) {
        if let webStr = key.webURLString,
           let webUrl = URL(string: webStr) {
            UIApplication.shared.open(webUrl, options: [:]) { success in
                if success {
                    self.showToast("已通过网页版打开 \(key.title)")
                } else {
                    self.showToast("暂时无法打开 \(key.title)")
                }
            }
        } else {
            if let firstUrl = key.appURLStrings.first.flatMap({ URL(string: $0) }) {
                UIApplication.shared.open(firstUrl, options: [:]) { success in
                    if !success {
                        self.showToast("未检测到 \(key.title) 对应应用")
                    }
                }
            } else {
                self.showToast("未检测到 \(key.title) 对应应用")
            }
        }
    }
    
    func showToast(_ message: String) {
        toastTimer?.cancel()
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            self.toastMessage = message
        }
        toastTimer = Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            guard !Task.isCancelled else { return }
            await MainActor.run {
                withAnimation(.easeOut(duration: 0.25)) {
                    self.toastMessage = nil
                }
            }
        }
    }
}
