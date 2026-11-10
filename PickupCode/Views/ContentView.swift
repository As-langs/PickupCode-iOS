import SwiftUI

struct ContentView: View {
    @StateObject private var jumpManager = JumpManager.shared
    @StateObject private var pickupManager = PickupCodeManager.shared
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var systemColorScheme
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var showingSettings = false
    @State private var isEditingOrder = false
    
    @State private var entries: [EntryKey] = [
        .cainiaoCode,
        .taobaoCode,
        .taobaoCainiaoPending,
        .pddCode,
        .pddPickup,
        .jdCode,
        .taobaoPending,
        .pddPending,
        .jdPending,
        .douyinPending,
        .kuaishouPending,
        .dewuPending,
        .xhsPending
    ]
    
    private let prefs = UserDefaults.standard
    private let keyOrderEntries = "order_entries_v2"
    
    private var isDarkMode: Bool {
        if let mode = themeManager.colorScheme {
            return mode == .dark
        }
        return systemColorScheme == .dark
    }
    
    private var activeToastMessage: String? {
        jumpManager.toastMessage ?? pickupManager.toastMessage
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
                    
                    // Section 1: 取件码模块 (智能提取与本地记录)
                    PickupCodeSectionView()
                    
                    // Section 2: 快捷入口 (合并网格：支持1列、2列、3列)
                    entriesSection
                    
                    // Drag / Edit Hint
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
            if let toast = activeToastMessage {
                VStack {
                    ToastView(message: toast)
                        .padding(.top, 10)
                    Spacer()
                }
                .zIndex(999)
                .transition(.move(edge: .top).combined(with: .opacity))
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
                
                Text("四个身份码 · 九个查件入口")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(secondaryTextColor)
            }
            
            Spacer()
            
            HStack(spacing: 10) {
                // Quick Grid Column Toggle Button
                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        let nextVal = (themeManager.gridColumns.rawValue % 3) + 1
                        themeManager.gridColumns = GridColumnSetting(rawValue: nextVal) ?? .one
                    }
                }) {
                    Image(systemName: gridIconName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(primaryTextColor)
                        .frame(width: 38, height: 38)
                        .background(headerButtonBackground)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(headerButtonBorder, lineWidth: 1)
                        )
                }
                
                // Edit/Reorder toggle
                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        isEditingOrder.toggle()
                    }
                }) {
                    Image(systemName: isEditingOrder ? "checkmark" : "arrow.up.arrow.down")
                        .font(.system(size: 14, weight: .semibold))
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
                        .font(.system(size: 15, weight: .medium))
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
    
    private var gridIconName: String {
        switch themeManager.gridColumns {
        case .one: return "rectangle.grid.1x2"
        case .two: return "square.grid.2x2"
        case .three: return "square.grid.3x3"
        }
    }
    
    // MARK: - Entries Section (1, 2, or 3 columns)
    
    private var entriesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(themeAccentColor)
                    .frame(width: 4, height: 16)
                
                Text("快捷入口")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(primaryTextColor)
                
                Text("\(entries.count) 个平台直达")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(themeAccentColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(themeAccentColor.opacity(0.12))
                    )
                
                Spacer()
                
                Text(themeManager.gridColumns.title)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(secondaryTextColor)
            }
            .padding(.leading, 2)
            
            // Grid or List Content
            if themeManager.gridColumns == .one {
                // One Column: List style
                VStack(spacing: 10) {
                    if isEditingOrder {
                        ForEach(entries) { entry in
                            EntryCardView(key: entry, isEditing: true) { }
                        }
                        .onMove(perform: moveEntry)
                    } else {
                        ForEach(entries) { entry in
                            EntryCardView(key: entry, isEditing: false) {
                                jumpManager.jump(to: entry)
                            }
                        }
                    }
                }
            } else {
                // Two or Three Columns: Grid style
                let cols = Array(repeating: GridItem(.flexible(), spacing: 10), count: themeManager.gridColumns.rawValue)
                LazyVGrid(columns: cols, spacing: 10) {
                    ForEach(entries) { entry in
                        GridEntryCardView(
                            key: entry,
                            columns: themeManager.gridColumns.rawValue,
                            isEditing: isEditingOrder
                        ) {
                            jumpManager.jump(to: entry)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Reordering Logic
    
    private func moveEntry(from source: IndexSet, to destination: Int) {
        entries.move(fromOffsets: source, toOffset: destination)
        saveOrder()
    }
    
    private func loadOrder() {
        let defaultEntries: [EntryKey] = [
            .cainiaoCode,
            .taobaoCode,
            .taobaoCainiaoPending,
            .pddCode,
            .pddPickup,
            .jdCode,
            .taobaoPending,
            .pddPending,
            .jdPending,
            .douyinPending,
            .kuaishouPending,
            .dewuPending,
            .xhsPending
        ]
        
        if let saved = prefs.string(forKey: keyOrderEntries) {
            let keys = saved.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
            let loaded = keys.compactMap { EntryKey(rawValue: $0) }
            var result = loaded.filter { defaultEntries.contains($0) }
            var hasNew = false
            for item in defaultEntries {
                if !result.contains(item) {
                    result.append(item)
                    hasNew = true
                }
            }
            self.entries = result.isEmpty ? defaultEntries : result
            if hasNew {
                saveOrder()
            }
        } else {
            // Check legacy order_code and order_query for seamless upgrade
            var legacyList: [EntryKey] = []
            if let savedCode = prefs.string(forKey: "order_code") {
                let keys = savedCode.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
                legacyList.append(contentsOf: keys.compactMap { EntryKey(rawValue: $0) })
            }
            if let savedQuery = prefs.string(forKey: "order_query") {
                let keys = savedQuery.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
                legacyList.append(contentsOf: keys.compactMap { EntryKey(rawValue: $0) })
            }
            
            var result = legacyList.filter { defaultEntries.contains($0) }
            for item in defaultEntries {
                if !result.contains(item) {
                    result.append(item)
                }
            }
            self.entries = result.isEmpty ? defaultEntries : result
            saveOrder()
        }
    }
    
    private func saveOrder() {
        let str = entries.map { $0.rawValue }.joined(separator: ",")
        prefs.set(str, forKey: keyOrderEntries)
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
