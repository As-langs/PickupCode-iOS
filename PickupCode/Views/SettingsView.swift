import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var systemColorScheme
    
    private var isDarkMode: Bool {
        if let mode = themeManager.colorScheme {
            return mode == .dark
        }
        return systemColorScheme == .dark
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
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
                    
                    // MARK: - About & Credits Section
                    VStack(spacing: 8) {
                        Text("取件快码 v1.0.1 for iOS")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.secondary)
                        
                        Text("作者：Hans")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.primary)
                        
                        Text("致谢：然后啊然后")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 32)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
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
}
