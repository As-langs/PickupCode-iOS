import SwiftUI

struct ContentView: View {
    @StateObject private var jumpManager = JumpManager.shared
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var systemColorScheme
    
    @State private var showingSettings = false
    @State private var isEditingOrder = false
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var codeEntries: [EntryKey] = [.taobaoCode, .jdCode, .pddCode]
    @State private var queryEntries: [EntryKey] = [
        .taobaoPending, .jdPending, .pddPending,
        .douyinPending, .kuaishouPending, .dewuPending, .xhsPending
    ]
    
    private let prefs = UserDefaults.standard
    private let keyOrderCode = "order_code"
    private let keyOrderQuery = "order_query"
    
    private var isDarkMode: Bool {
        if let mode = themeManager.colorScheme {
            return mode == .dark
        }
        return systemColorScheme == .dark
    }
    
    var body: some View {
        ZStack {
            // Background according to theme
            backgroundView
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header
                    headerView
                        .padding(.top, 12)
                    
                    // Section 1: 身份码
                    sectionContainer(
                        title: "身份码",
                        badge: "驿站扫码出示",
                        accentColor: themeAccentColor
                    ) {
                        if isEditingOrder {
                            ForEach(codeEntries) { entry in
                                EntryCardView(key: entry, isEditing: true) { }
                            }
                            .onMove(perform: moveCodeEntry)
                        } else {
                            ForEach(codeEntries) { entry in
                                EntryCardView(key: entry, isEditing: false) {
                                    jumpManager.jump(to: entry)
                                }
                            }
                        }
                    }
                    
                    // Section 2: 查询快递
                    sectionContainer(
                        title: "查询快递",
                        badge: "订单内查看",
                        accentColor: themeAccentColor
                    ) {
                        if isEditingOrder {
                            ForEach(queryEntries) { entry in
                                EntryCardView(key: entry, isEditing: true) { }
                            }
                            .onMove(perform: moveQueryEntry)
                        } else {
                            ForEach(queryEntries) { entry in
                                EntryCardView(key: entry, isEditing: false) {
                                    jumpManager.jump(to: entry)
                                }
                            }
                        }
                    }
                    
                    // Drag Hint
                    HStack(spacing: 6) {
                        Image(systemName: isEditingOrder ? "checkmark.circle" : "arrow.up.arrow.down")
                            .font(.system(size: 12))
                        Text(isEditingOrder ? "拖动右侧把手完成排序" : "点右上角编辑可拖动排序 · 点卡片极速直达")
                            .font(.system(size: 13, weight: .regular))
                    }
                    .foregroundColor(secondaryTextColor.opacity(0.8))
                    .padding(.top, 6)
                    .padding(.bottom, 36)
                }
                .padding(.horizontal, 20)
            }
            .environment(\.editMode, isEditingOrder ? .constant(.active) : .constant(.inactive))
            
            // Toast Overlay
            if let toast = jumpManager.toastMessage {
                VStack {
                    ToastView(message: toast)
                        .padding(.top, 10)
                    Spacer()
                }
                .zIndex(999)
            }
        }
        .onAppear {
            loadOrder()
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                loadOrder()
            }
        }
        .sheet(isPresented: $showingSettings, onDismiss: {
            loadOrder()
        }) {
            SettingsView()
                .environmentObject(themeManager)
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text("取件快码")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(primaryTextColor)
                
                Text("三个身份码 · 七个查件入口")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(secondaryTextColor)
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                // Edit/Reorder toggle
                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        isEditingOrder.toggle()
                    }
                }) {
                    Image(systemName: isEditingOrder ? "checkmark" : "arrow.up.arrow.down")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(isEditingOrder ? .white : primaryTextColor)
                        .frame(width: 38, height: 38)
                        .background(isEditingOrder ? Color.blue : headerButtonBackground)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(headerButtonBorder, lineWidth: 1)
                        )
                }
                
                // Settings button
                Button(action: { showingSettings = true }) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(primaryTextColor)
                        .frame(width: 38, height: 38)
                        .background(headerButtonBackground)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(headerButtonBorder, lineWidth: 1)
                        )
                }
            }
        }
    }
    
    // MARK: - Section Container
    
    @ViewBuilder
    private func sectionContainer<Content: View>(
        title: String,
        badge: String,
        accentColor: Color,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(accentColor)
                    .frame(width: 4, height: 16)
                
                Text(title)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(primaryTextColor)
                
                Text(badge)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(accentColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(accentColor.opacity(0.12))
                    )
                
                Spacer()
            }
            .padding(.leading, 2)
            
            VStack(spacing: 10) {
                content()
            }
        }
    }
    
    // MARK: - Reordering Logic
    
    private func moveCodeEntry(from source: IndexSet, to destination: Int) {
        codeEntries.move(fromOffsets: source, toOffset: destination)
        saveOrder()
    }
    
    private func moveQueryEntry(from source: IndexSet, to destination: Int) {
        queryEntries.move(fromOffsets: source, toOffset: destination)
        saveOrder()
    }
    
    private func loadOrder() {
        let defaultCode: [EntryKey] = [.taobaoCode, .jdCode, .pddCode]
        let defaultQuery: [EntryKey] = [
            .taobaoPending, .jdPending, .pddPending,
            .douyinPending, .kuaishouPending, .dewuPending, .xhsPending
        ]
        
        if let savedCode = prefs.string(forKey: keyOrderCode) {
            let keys = savedCode.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
            let loaded = keys.compactMap { EntryKey(rawValue: $0) }
            self.codeEntries = loaded.isEmpty ? defaultCode : loaded
        } else {
            self.codeEntries = defaultCode
        }
        
        if let savedQuery = prefs.string(forKey: keyOrderQuery) {
            let keys = savedQuery.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
            let loaded = keys.compactMap { EntryKey(rawValue: $0) }
            var result = loaded.filter { defaultQuery.contains($0) }
            var hasNew = false
            for item in defaultQuery {
                if !result.contains(item) {
                    result.append(item)
                    hasNew = true
                }
            }
            self.queryEntries = result.isEmpty ? defaultQuery : result
            if hasNew {
                saveOrder()
            }
        } else {
            self.queryEntries = defaultQuery
            saveOrder()
        }
    }
    
    private func saveOrder() {
        let codeStr = codeEntries.map { $0.rawValue }.joined(separator: ",")
        let queryStr = queryEntries.map { $0.rawValue }.joined(separator: ",")
        prefs.set(codeStr, forKey: keyOrderCode)
        prefs.set(queryStr, forKey: keyOrderQuery)
    }
    
    // MARK: - Theme Helpers
    
    @ViewBuilder
    private var backgroundView: some View {
        switch themeManager.uiStyle {
        case .paper:
            if isDarkMode {
                Color(hex: "12161A")
            } else {
                LinearGradient(
                    colors: [Color(hex: "F3F8F5"), Color(hex: "EBF3EE")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        case .glass:
            if isDarkMode {
                LinearGradient(
                    colors: [Color(hex: "0E1621"), Color(hex: "172432")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            } else {
                LinearGradient(
                    colors: [Color(hex: "E8F4F8"), Color(hex: "D8EEF5")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        case .flat:
            if isDarkMode {
                Color(hex: "13171B")
            } else {
                Color(hex: "F8F9FA")
            }
        }
    }
    
    private var themeAccentColor: Color {
        switch themeManager.uiStyle {
        case .paper: return Color(hex: "00A870")
        case .glass: return Color(hex: "00B4D8")
        case .flat:  return Color(hex: "374151")
        }
    }
    
    private var primaryTextColor: Color {
        isDarkMode ? Color(hex: "F3F4F6") : Color(hex: "1F2937")
    }
    
    private var secondaryTextColor: Color {
        isDarkMode ? Color(hex: "9CA3AF") : Color(hex: "6B7280")
    }
    
    private var headerButtonBackground: Color {
        isDarkMode ? Color(hex: "1E242B") : Color.white
    }
    
    private var headerButtonBorder: Color {
        isDarkMode ? Color(hex: "2E3844") : Color(hex: "E5E7EB")
    }
}
