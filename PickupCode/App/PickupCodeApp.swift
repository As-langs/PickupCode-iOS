import SwiftUI

@main
struct PickupCodeApp: App {
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
