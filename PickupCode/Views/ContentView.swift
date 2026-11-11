import SwiftUI

struct ContentView: View {
    @StateObject private var jumpManager = JumpManager.shared
    @StateObject private var pickupManager = PickupCodeManager.shared
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var systemColorScheme
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var showingSettings = false
    @State private var showingManagementSheet = false
    
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
                        Image(systemName: "hand.tap")
                            .font(.system(size: 12))
                        Text("长按卡片可隐藏入口 · 点击右上角可拖动排序与管理")
                            .font(.system(size: 13, weight: .regular))
                    }
                    .foregroundColor(secondaryTextColor.opacity(0.8))
                    .padding(.top, 6)
                    .padding(.bottom, 36)
                }
                .padding(.horizontal, 20)
            }
            
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
            themeManager.loadOrderAndHidden()
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                themeManager.loadOrderAndHidden()
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
                .environmentObject(themeManager)
        }
        .sheet(isPresented: $showingManagementSheet) {
            EntryManagementView()
                .environmentObject(themeManager)
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("OpenEntryManagement"))) { _ in
            showingManagementSheet = true
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
                
                // Entrance Management & Reorder button
                Button(action: {
                    showingManagementSheet = true
                }) {
                    Image(systemName: "arrow.up.arrow.down")
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
                
                Text("\(themeManager.visibleEntries.count) 个平台直达")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(themeAccentColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(themeAccentColor.opacity(0.12))
                    )
                
                if !themeManager.hiddenEntries.isEmpty {
                    Button(action: { showingManagementSheet = true }) {
                        HStack(spacing: 3) {
                            Image(systemName: "eye.slash")
                                .font(.system(size: 10))
                            Text("已隐藏 \(themeManager.hiddenEntries.count) 项")
                                .font(.system(size: 11, weight: .medium))
                        }
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(Color.gray.opacity(0.12))
                        )
                    }
                }
                
                Spacer()
                
                // Entrance & order management button
                Button(action: { showingManagementSheet = true }) {
                    HStack(spacing: 4) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 11, weight: .semibold))
                        Text("管理")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(themeAccentColor)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(themeAccentColor.opacity(0.1))
                    )
                }
            }
            .padding(.leading, 2)
            
            // Grid or List Content
            if themeManager.gridColumns == .one {
                // One Column: List style
                VStack(spacing: 10) {
                    ForEach(themeManager.visibleEntries) { entry in
                        EntryCardView(key: entry, isEditing: false) {
                            jumpManager.jump(to: entry)
                        }
                    }
                }
            } else {
                // Two or Three Columns: Grid style
                let cols = Array(repeating: GridItem(.flexible(), spacing: 10), count: themeManager.gridColumns.rawValue)
                LazyVGrid(columns: cols, spacing: 10) {
                    ForEach(themeManager.visibleEntries) { entry in
                        GridEntryCardView(
                            key: entry,
                            columns: themeManager.gridColumns.rawValue,
                            isEditing: false
                        ) {
                            jumpManager.jump(to: entry)
                        }
                    }
                }
            }
        }
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
