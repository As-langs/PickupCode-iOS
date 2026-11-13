import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var systemColorScheme
    @State private var showingEntryManagement = false
    
    private var isDarkMode: Bool {
        if let mode = themeManager.colorScheme {
            return mode == .dark
        }
        return systemColorScheme == .dark
    }
    
    private var accentColor: Color {
        switch themeManager.uiStyle {
        case .paper: return Color(hex: "00A870")
        case .glass: return Color(hex: "00B4D8")
        case .flat:  return Color(hex: "4B5563")
        }
    }
    
    private var secondaryTextColor: Color {
        isDarkMode ? Color(hex: "9CA3AF") : Color(hex: "6B7280")
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - Grid Columns Section
                    settingsSection(title: "每行个数", subtitle: "一列最清楚，三列最紧凑") {
                        Picker("每行个数", selection: $themeManager.gridColumns) {
                            ForEach(GridColumnSetting.allCases) { setting in
                                Text(setting.title).tag(setting)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.vertical, 4)
                    }
                    
                    // MARK: - Dark Mode Section
                    settingsSection(title: "深色模式", subtitle: "跟随你的选择，不跟随系统") {
                        Picker("深色模式", selection: $themeManager.darkModeSetting) {
                            ForEach(DarkModeSetting.allCases) { setting in
                                Text(setting.title).tag(setting)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.vertical, 4)
                    }
                    
                    // MARK: - UI Theme Section
                    settingsSection(title: "界面风格", subtitle: "青简 · 雾青 · 素白，随你挑") {
                        HStack(spacing: 12) {
                            ForEach(UiStyle.allCases) { style in
                                themeChip(style: style, isSelected: themeManager.uiStyle == style) {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                        themeManager.uiStyle = style
                                    }
                                }
                            }
                        }
                    }
                    
                    // MARK: - Entry Management Section
                    settingsSection(title: "入口与排序管理", subtitle: "支持自由拖拽排序及隐藏单个入口") {
                        VStack(spacing: 10) {
                            Button(action: {
                                showingEntryManagement = true
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "slider.horizontal.3")
                                    Text("管理全部入口与拖动排序")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.secondary)
                                }
                                .foregroundColor(accentColor)
                                .font(.system(size: 14, weight: .semibold))
                                .padding(.vertical, 4)
                            }
                            
                            Divider()
                            
                            Button(action: {
                                themeManager.resetOrderAndVisibility()
                                JumpManager.shared.showToast("已恢复默认排序与显示")
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "arrow.counterclockwise")
                                    Text("恢复默认排序与显示（取消所有隐藏）")
                                    Spacer()
                                }
                                .foregroundColor(Color.secondary)
                                .font(.system(size: 14, weight: .medium))
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    
                    // MARK: - About & Authors Section
                    settingsSection(title: "关于取件快码", subtitle: "版本信息、作者与开源主页") {
                        VStack(spacing: 14) {
                            // App Info Header
                            HStack(spacing: 14) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(accentColor.opacity(0.12))
                                        .frame(width: 44, height: 44)
                                    
                                    Image(systemName: "shippingbox.fill")
                                        .font(.system(size: 22))
                                        .foregroundColor(accentColor)
                                }
                                
                                VStack(alignment: .leading, spacing: 3) {
                                    Text("取件快码")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(isDarkMode ? .white : Color(hex: "1F2937"))
                                    
                                    Text("版本 2.1.5 (Build 2026.11.14)")
                                        .font(.system(size: 12))
                                        .foregroundColor(secondaryTextColor)
                                }
                                
                                Spacer()
                                
                                Button {
                                    if let url = URL(string: "https://github.com/As-langs/PickupCode-iOS/releases") {
                                        UIApplication.shared.open(url)
                                    }
                                } label: {
                                    HStack(spacing: 4) {
                                        Text("v2.1.5")
                                            .font(.system(size: 12, weight: .bold, design: .rounded))
                                        Image(systemName: "arrow.up.right")
                                            .font(.system(size: 9))
                                    }
                                    .foregroundColor(accentColor)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(
                                        Capsule()
                                            .fill(accentColor.opacity(0.12))
                                    )
                                }
                            }
                            
                            Divider()
                            
                            // Authors & Credits
                            VStack(spacing: 10) {
                                aboutRow(title: "iOS 版本开发", value: "Hans")
                                
                                Button {
                                    if let url = URL(string: "https://www.coolapk.com/u/27888540") {
                                        UIApplication.shared.open(url)
                                    }
                                } label: {
                                    HStack {
                                        Text("致谢 Android 原作")
                                            .font(.system(size: 13))
                                            .foregroundColor(secondaryTextColor)
                                        Spacer()
                                        Text("酷安 @然后啊然后")
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(Color.blue)
                                        Image(systemName: "arrow.up.right")
                                            .font(.system(size: 10))
                                            .foregroundColor(Color.blue.opacity(0.8))
                                    }
                                }
                            }
                            
                            Divider()
                            
                            // GitHub Project Homepage Link
                            Button {
                                if let url = URL(string: "https://github.com/As-langs/PickupCode-iOS") {
                                    UIApplication.shared.open(url)
                                }
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "link")
                                        .font(.system(size: 13, weight: .semibold))
                                    Text("GitHub 项目主页")
                                        .font(.system(size: 13, weight: .semibold))
                                    Spacer()
                                    Text("As-langs/PickupCode-iOS")
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundColor(.secondary)
                                }
                                .foregroundColor(accentColor)
                                .padding(.vertical, 2)
                            }
                            
                            // Slogan
                            Text("点一下，出码，走人。无广告、不联网、不要权限，配置只存在本机。")
                                .font(.system(size: 11))
                                .foregroundColor(secondaryTextColor.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.top, 2)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
            .background(pageBackground.ignoresSafeArea())
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .semibold))
                }
            }
            .sheet(isPresented: $showingEntryManagement) {
                EntryManagementView()
                    .environmentObject(themeManager)
            }
        }
    }
    
    // MARK: - Helper Views
    
    @ViewBuilder
    private func settingsSection<Content: View>(
        title: String,
        subtitle: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(isDarkMode ? .white : Color(hex: "1F2937"))
                
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(isDarkMode ? Color(hex: "9CA3AF") : Color(hex: "6B7280"))
            }
            .padding(.leading, 4)
            
            VStack {
                content()
            }
            .padding(14)
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(cardBorder, lineWidth: 1)
            )
        }
    }
    
    private func themeChip(style: UiStyle, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(chipPreviewColor(for: style))
                        .frame(height: 38)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(isSelected ? Color.blue : Color.gray.opacity(0.2), lineWidth: isSelected ? 2 : 1)
                        )
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.blue)
                            .font(.system(size: 16))
                    }
                }
                
                Text(style.name)
                    .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? .blue : .primary)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
    
    private func chipPreviewColor(for style: UiStyle) -> Color {
        switch style {
        case .paper: return Color(hex: "E8F5E9")
        case .glass: return Color(hex: "E0F7FA")
        case .flat:  return Color(hex: "F5F5F5")
        }
    }
    
    private var pageBackground: Color {
        isDarkMode ? Color(hex: "121518") : Color(hex: "F8F9FA")
    }
    
    private var cardBackground: Color {
        isDarkMode ? Color(hex: "1E242B") : Color.white
    }
    
    private var cardBorder: Color {
        isDarkMode ? Color(hex: "2E3844") : Color(hex: "E5E7EB")
    }
    
    private func aboutRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 13))
                .foregroundColor(secondaryTextColor)
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(isDarkMode ? Color(hex: "E5E7EB") : Color(hex: "374151"))
        }
    }
}
