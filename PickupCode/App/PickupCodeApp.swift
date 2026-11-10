import SwiftUI
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        if let shortcutItem = options.shortcutItem {
            handleShortcutItem(shortcutItem)
        }
        let config = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        config.delegateClass = SceneDelegate.self
        return config
    }
}

class SceneDelegate: NSObject, UIWindowSceneDelegate {
    func windowScene(
        _ windowScene: UIWindowScene,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        handleShortcutItem(shortcutItem)
        completionHandler(true)
    }
}

func handleShortcutItem(_ item: UIApplicationShortcutItem) {
    Task { @MainActor in
        try? await Task.sleep(nanoseconds: 200_000_000)
        switch item.type {
        case "cainiao_code":
            JumpManager.shared.jump(to: .cainiaoCode)
        case "taobao_code":
            JumpManager.shared.jump(to: .taobaoCode)
        case "pdd_code":
            JumpManager.shared.jump(to: .pddCode)
        case "taobao_pending":
            JumpManager.shared.jump(to: .taobaoPending)
        case "paste_pickup_code":
            PickupCodeManager.shared.pasteAndParse()
        default:
            if let key = EntryKey(rawValue: item.type) {
                JumpManager.shared.jump(to: key)
            }
        }
    }
}

@main
struct PickupCodeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.colorScheme)
                .onOpenURL { url in
                    handleDeepLink(url)
                }
        }
    }
    
    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "pickupcode" else { return }
        
        if url.host == "paste" || url.path == "/paste" {
            Task { @MainActor in
                PickupCodeManager.shared.pasteAndParse()
            }
            return
        }
        
        var targetKey: EntryKey? = nil
        
        // E.g. pickupcode://jump?entry=taobao_code
        if url.host == "jump",
           let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let entryParam = components.queryItems?.first(where: { $0.name == "entry" })?.value {
            targetKey = EntryKey(rawValue: entryParam)
        }
        
        // E.g. pickupcode://taobao_code or pickupcode:///taobao_code
        if targetKey == nil {
            let pathOrHost = (url.host ?? "").isEmpty ? url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/")) : (url.host ?? "")
            targetKey = EntryKey(rawValue: pathOrHost)
        }
        
        if let key = targetKey {
            Task { @MainActor in
                // Small delay to ensure UI is ready
                try? await Task.sleep(nanoseconds: 150_000_000)
                JumpManager.shared.jump(to: key)
            }
        }
    }
}
