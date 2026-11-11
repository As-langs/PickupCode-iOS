import SwiftUI

struct EntryCardView: View {
    let key: EntryKey
    let isEditing: Bool
    let onAction: () -> Void
    
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var systemColorScheme
    
    private var isDarkMode: Bool {
        if let mode = themeManager.colorScheme {
            return mode == .dark
        }
        return systemColorScheme == .dark
    }
    
    var body: some View {
        Button(action: {
            if !isEditing {
                onAction()
            }
        }) {
            HStack(spacing: 14) {
                // Icon plate using PlatformIconView
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(iconPlateBackground)
                        .frame(width: 48, height: 48)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(iconPlateBorder, lineWidth: 1)
                        )
                    
                    PlatformIconView(
                        name: key.iconName,
                        size: 34
                    )
                }
                
                // Titles
                VStack(alignment: .leading, spacing: 3) {
                    Text(key.title)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(primaryTextColor)
                    
                    Text(key.subtitle)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(secondaryTextColor)
                }
                
                Spacer()
                
                if isEditing {
                    Image(systemName: "line.3.horizontal")
                        .foregroundColor(.gray)
                        .font(.system(size: 18, weight: .medium))
                        .padding(.trailing, 4)
                } else {
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(accentColor.opacity(0.7))
                        .padding(8)
                        .background(
                            Circle()
                                .fill(accentColor.opacity(0.08))
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(cardBorderColor, lineWidth: 1)
            )
            .shadow(color: cardShadowColor, radius: 8, x: 0, y: 2)
        }
        .buttonStyle(ScaleButtonStyle())
        .contextMenu {
            Button(role: .destructive) {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    themeManager.hide(key)
                }
                JumpManager.shared.showToast("已隐藏「\(key.title)」")
            } label: {
                Label("隐藏此入口", systemImage: "eye.slash")
            }
            
            Button {
                NotificationCenter.default.post(name: NSNotification.Name("OpenEntryManagement"), object: nil)
            } label: {
                Label("入口与排序管理", systemImage: "arrow.up.arrow.down")
            }
            
            if let webStr = key.webURLString, let url = URL(string: webStr) {
                Button {
                    UIApplication.shared.open(url)
                } label: {
                    Label("在 Safari 中打开网页版", systemImage: "safari")
                }
            }
        }
    }
    
    // MARK: - Dynamic Theme Styling
    
    private var primaryTextColor: Color {
        isDarkMode ? Color(hex: "F3F4F6") : Color(hex: "1F2937")
    }
    
    private var secondaryTextColor: Color {
        isDarkMode ? Color(hex: "9CA3AF") : Color(hex: "6B7280")
    }
    
    private var accentColor: Color {
        switch themeManager.uiStyle {
        case .paper:
            return Color(hex: "00A870")
        case .glass:
            return Color(hex: "00B4D8")
        case .flat:
            return Color(hex: "4B5563")
        }
    }
    
    @ViewBuilder
    private var cardBackground: some View {
        switch themeManager.uiStyle {
        case .paper:
            if isDarkMode {
                Color(hex: "1E242B")
            } else {
                Color.white
            }
        case .glass:
            if isDarkMode {
                Color(hex: "1F2833").opacity(0.7)
                    .background(.ultraThinMaterial)
            } else {
                Color.white.opacity(0.7)
                    .background(.ultraThinMaterial)
            }
        case .flat:
            if isDarkMode {
                Color(hex: "1A1E24")
            } else {
                Color.white
            }
        }
    }
    
    private var cardBorderColor: Color {
        switch themeManager.uiStyle {
        case .paper:
            return isDarkMode ? Color(hex: "2E3844") : Color(hex: "E6EFEA")
        case .glass:
            return isDarkMode ? Color.white.opacity(0.12) : Color.white.opacity(0.55)
        case .flat:
            return isDarkMode ? Color(hex: "2A303A") : Color(hex: "E5E7EB")
        }
    }
    
    private var cardShadowColor: Color {
        if isDarkMode {
            return Color.clear
        }
        switch themeManager.uiStyle {
        case .paper:
            return Color(hex: "00A870").opacity(0.04)
        case .glass:
            return Color(hex: "00B4D8").opacity(0.08)
        case .flat:
            return Color.black.opacity(0.03)
        }
    }
    
    private var iconPlateBackground: Color {
        if isDarkMode {
            return Color(hex: "27303B")
        }
        switch themeManager.uiStyle {
        case .paper:
            return Color(hex: "F4FAF6")
        case .glass:
            return Color(hex: "EBF6FA").opacity(0.85)
        case .flat:
            return Color(hex: "F3F4F6")
        }
    }
    
    private var iconPlateBorder: Color {
        if isDarkMode {
            return Color(hex: "34414F")
        }
        switch themeManager.uiStyle {
        case .paper:
            return Color(hex: "D8EBE0")
        case .glass:
            return Color(hex: "CFE7F2")
        case .flat:
            return Color(hex: "E5E7EB")
        }
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Grid Entry Card (for 2 or 3 columns)

struct GridEntryCardView: View {
    let key: EntryKey
    let columns: Int // 2 or 3
    let isEditing: Bool
    let onAction: () -> Void
    
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var systemColorScheme
    
    private var isDarkMode: Bool {
        if let mode = themeManager.colorScheme {
            return mode == .dark
        }
        return systemColorScheme == .dark
    }
    
    var body: some View {
        Button(action: {
            if !isEditing {
                onAction()
            }
        }) {
            VStack(spacing: columns == 3 ? 6 : 8) {
                // Icon plate
                ZStack {
                    RoundedRectangle(cornerRadius: columns == 3 ? 12 : 14, style: .continuous)
                        .fill(iconPlateBackground)
                        .frame(width: columns == 3 ? 46 : 52, height: columns == 3 ? 46 : 52)
                        .overlay(
                            RoundedRectangle(cornerRadius: columns == 3 ? 12 : 14, style: .continuous)
                                .stroke(iconPlateBorder, lineWidth: 1)
                        )
                    
                    PlatformIconView(
                        name: key.iconName,
                        size: columns == 3 ? 32 : 36
                    )
                }
                
                // Title underneath icon (centered, no truncation)
                Text(key.title)
                    .font(.system(size: columns == 3 ? 12 : 13, weight: .semibold, design: .rounded))
                    .foregroundColor(primaryTextColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, columns == 3 ? 10 : 12)
            .padding(.horizontal, 4)
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(cardBorderColor, lineWidth: 1)
            )
            .shadow(color: cardShadowColor, radius: 6, x: 0, y: 2)
        }
        .buttonStyle(ScaleButtonStyle())
        .contextMenu {
            Button(role: .destructive) {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    themeManager.hide(key)
                }
                JumpManager.shared.showToast("已隐藏「\(key.title)」")
            } label: {
                Label("隐藏此入口", systemImage: "eye.slash")
            }
            
            Button {
                NotificationCenter.default.post(name: NSNotification.Name("OpenEntryManagement"), object: nil)
            } label: {
                Label("入口与排序管理", systemImage: "arrow.up.arrow.down")
            }
            
            if let webStr = key.webURLString, let url = URL(string: webStr) {
                Button {
                    UIApplication.shared.open(url)
                } label: {
                    Label("在 Safari 中打开网页版", systemImage: "safari")
                }
            }
        }
    }
    
    private var primaryTextColor: Color {
        isDarkMode ? Color(hex: "F3F4F6") : Color(hex: "1F2937")
    }
    
    @ViewBuilder
    private var cardBackground: some View {
        switch themeManager.uiStyle {
        case .paper:
            if isDarkMode {
                Color(hex: "1E242B")
            } else {
                Color.white
            }
        case .glass:
            if isDarkMode {
                Color(hex: "1F2833").opacity(0.7)
                    .background(.ultraThinMaterial)
            } else {
                Color.white.opacity(0.7)
                    .background(.ultraThinMaterial)
            }
        case .flat:
            if isDarkMode {
                Color(hex: "1A1E24")
            } else {
                Color.white
            }
        }
    }
    
    private var cardBorderColor: Color {
        switch themeManager.uiStyle {
        case .paper:
            return isDarkMode ? Color(hex: "2E3844") : Color(hex: "E6EFEA")
        case .glass:
            return isDarkMode ? Color.white.opacity(0.12) : Color.white.opacity(0.55)
        case .flat:
            return isDarkMode ? Color(hex: "2A303A") : Color(hex: "E5E7EB")
        }
    }
    
    private var cardShadowColor: Color {
        if isDarkMode {
            return Color.clear
        }
        switch themeManager.uiStyle {
        case .paper:
            return Color(hex: "00A870").opacity(0.04)
        case .glass:
            return Color(hex: "00B4D8").opacity(0.08)
        case .flat:
            return Color.black.opacity(0.03)
        }
    }
    
    private var iconPlateBackground: Color {
        if isDarkMode {
            return Color(hex: "27303B")
        }
        switch themeManager.uiStyle {
        case .paper:
            return Color(hex: "F4FAF6")
        case .glass:
            return Color(hex: "EBF6FA").opacity(0.85)
        case .flat:
            return Color(hex: "F3F4F6")
        }
    }
    
    private var iconPlateBorder: Color {
        if isDarkMode {
            return Color(hex: "34414F")
        }
        switch themeManager.uiStyle {
        case .paper:
            return Color(hex: "D8EBE0")
        case .glass:
            return Color(hex: "CFE7F2")
        case .flat:
            return Color(hex: "E5E7EB")
        }
    }
}

// MARK: - Entry Management & Reordering View

struct EntryManagementView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var systemColorScheme
    
    private var isDarkMode: Bool {
        if let mode = themeManager.colorScheme {
            return mode == .dark
        }
        return systemColorScheme == .dark
    }
    
    private var accentColor: Color {
        switch themeManager.uiStyle {
        case .paper:
            return Color(hex: "00A870")
        case .glass:
            return Color(hex: "00B4D8")
        case .flat:
            return Color(hex: "4B5563")
        }
    }
    
    private var secondaryTextColor: Color {
        isDarkMode ? Color(hex: "9CA3AF") : Color(hex: "6B7280")
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(themeManager.orderEntries) { entry in
                        let isVisible = !themeManager.isHidden(entry)
                        let visibleIdx = isVisible ? themeManager.visibleEntries.firstIndex(of: entry) : nil
                        
                        EntryManagementRow(
                            entry: entry,
                            isVisible: isVisible,
                            orderNumber: visibleIdx != nil ? (visibleIdx! + 1) : nil
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                themeManager.toggleHidden(entry)
                            }
                        }
                    }
                    .onMove { source, dest in
                        themeManager.move(from: source, to: dest)
                    }
                } header: {
                    HStack {
                        Text("全部入口 (共 \(themeManager.orderEntries.count) 项 · 已显示 \(themeManager.visibleEntries.count) 项)")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(secondaryTextColor)
                        Spacer()
                    }
                    .padding(.vertical, 4)
                } footer: {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("💡 操作指南：")
                            .font(.system(size: 12, weight: .semibold))
                        Text("• 点击左侧圆圈：显示或隐藏对应入口（至少保留 1 个）")
                        Text("• 长按并拖动右侧三条杠「≡」：可自由上下拖动排序")
                        Text("• 长按主界面任意卡片也可快捷隐藏入口")
                    }
                    .font(.system(size: 11))
                    .foregroundColor(secondaryTextColor.opacity(0.85))
                    .padding(.top, 8)
                }
            }
            .listStyle(.insetGrouped)
            .environment(\.editMode, .constant(.active))
            .navigationTitle("入口管理与排序")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button {
                            withAnimation(.spring()) {
                                themeManager.showAll()
                            }
                            JumpManager.shared.showToast("已显示全部 13 个入口")
                        } label: {
                            Label("全部显示", systemImage: "eye")
                        }
                        
                        Button(role: .destructive) {
                            withAnimation(.spring()) {
                                themeManager.resetOrderAndVisibility()
                            }
                            JumpManager.shared.showToast("已恢复默认排序与显示")
                        } label: {
                            Label("恢复默认排序与显示", systemImage: "arrow.counterclockwise")
                        }
                    } label: {
                        HStack(spacing: 3) {
                            Text("选项")
                            Image(systemName: "chevron.down")
                                .font(.system(size: 11, weight: .bold))
                        }
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(accentColor)
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(accentColor)
                }
            }
        }
    }
}

// MARK: - Entry Management Row

struct EntryManagementRow: View {
    let entry: EntryKey
    let isVisible: Bool
    let orderNumber: Int?
    let onToggle: () -> Void
    
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var systemColorScheme
    
    private var isDarkMode: Bool {
        if let mode = themeManager.colorScheme {
            return mode == .dark
        }
        return systemColorScheme == .dark
    }
    
    private var accentColor: Color {
        switch themeManager.uiStyle {
        case .paper:
            return Color(hex: "00A870")
        case .glass:
            return Color(hex: "00B4D8")
        case .flat:
            return Color(hex: "4B5563")
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Checkmark / Number Toggle Button
            Button(action: onToggle) {
                ZStack {
                    if isVisible, let num = orderNumber {
                        Circle()
                            .fill(accentColor)
                            .frame(width: 24, height: 24)
                        
                        Text("\(num)")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    } else {
                        Circle()
                            .strokeBorder(Color.gray.opacity(0.4), lineWidth: 1.5)
                            .frame(width: 24, height: 24)
                        
                        Circle()
                            .fill(Color.gray.opacity(0.1))
                            .frame(width: 14, height: 14)
                    }
                }
            }
            .buttonStyle(.plain)
            
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(isDarkMode ? Color(hex: "27303B") : Color(hex: "F3F4F6"))
                    .frame(width: 40, height: 40)
                
                PlatformIconView(name: entry.iconName, size: 28)
            }
            
            // Title & Subtitle
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(isVisible ? (isDarkMode ? Color(hex: "F3F4F6") : Color(hex: "1F2937")) : Color.gray)
                
                Text(entry.subtitle)
                    .font(.system(size: 11))
                    .foregroundColor(Color.gray)
            }
            
            Spacer()
            
            // Status Tag
            Text(isVisible ? "已显示" : "未显示")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(isVisible ? accentColor : Color.gray)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(
                    Capsule()
                        .fill(isVisible ? accentColor.opacity(0.12) : Color.gray.opacity(0.12))
                )
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onToggle()
        }
        .padding(.vertical, 4)
    }
}
