import SwiftUI

struct PickupCodeSectionView: View {
    @ObservedObject var manager = PickupCodeManager.shared
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var systemColorScheme
    
    @State private var showingManualAdd = false
    @State private var showingReorderSheet = false
    @State private var isReordering = false
    @State private var inputCode = ""
    @State private var inputCompany = ""
    @State private var inputLocation = ""
    @State private var inputRawText = ""
    
    private var isDarkMode: Bool {
        if let mode = themeManager.colorScheme {
            return mode == .dark
        }
        return systemColorScheme == .dark
    }
    
    private var pendingRecords: [PickupRecord] {
        manager.records.filter { !$0.isPicked }
    }
    
    private var takenRecords: [PickupRecord] {
        manager.records.filter { $0.isPicked }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack(alignment: .center, spacing: 8) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(themeAccentColor)
                    .frame(width: 4, height: 16)
                
                Text("取件码")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(primaryTextColor)
                
                if !manager.records.isEmpty {
                    Text("待取 \(pendingRecords.count) / 共 \(manager.records.count)")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(themeAccentColor)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(themeAccentColor.opacity(0.12))
                        .clipShape(Capsule())
                }
                
                Spacer()
                
                if !manager.records.isEmpty {
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            isReordering.toggle()
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: isReordering ? "checkmark" : "arrow.up.arrow.down")
                                .font(.system(size: 11, weight: .semibold))
                            Text(isReordering ? "完成" : "移动")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundColor(isReordering ? .white : themeAccentColor)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 5)
                        .background(isReordering ? themeAccentColor : themeAccentColor.opacity(0.12))
                        .clipShape(Capsule())
                    }
                    
                    Menu {
                        Button {
                            showingReorderSheet = true
                        } label: {
                            Label("拖拽列表排序", systemImage: "line.3.horizontal")
                        }
                        
                        Divider()
                        
                        Button(role: .destructive) {
                            withAnimation {
                                manager.clearPicked()
                            }
                        } label: {
                            Label("清理已取件", systemImage: "checkmark.circle")
                        }
                        
                        Button(role: .destructive) {
                            withAnimation {
                                manager.clearAll()
                            }
                        } label: {
                            Label("清空所有记录", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.system(size: 16))
                            .foregroundColor(secondaryTextColor)
                    }
                }
            }
            .padding(.horizontal, 2)
            
            Text("分享或粘贴短信自动挑出码；点击勾选标记已取并移至下方")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(secondaryTextColor)
                .padding(.leading, 2)
            
            // Action Buttons
            HStack(spacing: 12) {
                Button(action: {
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                    manager.pasteAndParse()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "doc.on.clipboard.fill")
                            .font(.system(size: 14, weight: .semibold))
                        Text("粘贴识别")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(themeAccentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(ScaleButtonStyle())
                
                Button(action: {
                    showingManualAdd = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 14, weight: .semibold))
                        Text("手动添加")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(primaryTextColor)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(buttonSecondaryBg)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(cardBorderColor, lineWidth: 1)
                    )
                }
                .buttonStyle(ScaleButtonStyle())
            }
            
            // Records List or Empty State
            if manager.records.isEmpty {
                emptyStateView
            } else {
                VStack(spacing: 10) {
                    // 待取件列表（始终置顶）
                    ForEach(pendingRecords) { record in
                        recordRow(record)
                    }
                    
                    // 已取件列表（如果存在）
                    if !takenRecords.isEmpty {
                        HStack {
                            Text("已取件 (\(takenRecords.count))")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(secondaryTextColor)
                            Spacer()
                            Button("一键清理") {
                                withAnimation {
                                    manager.clearPicked()
                                }
                            }
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(secondaryTextColor.opacity(0.8))
                        }
                        .padding(.top, 6)
                        .padding(.horizontal, 4)
                        
                        ForEach(takenRecords) { record in
                            recordRow(record)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingManualAdd) {
            manualAddSheet
        }
        .sheet(isPresented: $showingReorderSheet) {
            reorderSheet
        }
    }
    
    // MARK: - Record Row
    
    @ViewBuilder
    private func recordRow(_ record: PickupRecord) -> some View {
        HStack(alignment: .center, spacing: 12) {
            // Checkmark button (点击瞬间沉底或恢复)
            Button(action: {
                let haptic = UISelectionFeedbackGenerator()
                haptic.selectionChanged()
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                    manager.togglePicked(id: record.id)
                }
            }) {
                Image(systemName: record.isPicked ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(record.isPicked ? themeAccentColor : secondaryTextColor.opacity(0.5))
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 8) {
                    Text(record.code)
                        .font(.system(size: 19, weight: .bold, design: .monospaced))
                        .foregroundColor(record.isPicked ? secondaryTextColor : primaryTextColor)
                        .strikethrough(record.isPicked, color: secondaryTextColor)
                    
                    Text(record.company)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(record.isPicked ? secondaryTextColor : themeAccentColor)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(record.isPicked ? secondaryTextColor.opacity(0.12) : themeAccentColor.opacity(0.12))
                        .clipShape(Capsule())
                }
                
                HStack(spacing: 6) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 11))
                        .foregroundColor(secondaryTextColor)
                    Text(record.location)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(secondaryTextColor)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            if isReordering {
                // 上移/下移排序按钮
                HStack(spacing: 6) {
                    Button {
                        let haptic = UIImpactFeedbackGenerator(style: .light)
                        haptic.impactOccurred()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                            manager.moveUp(id: record.id)
                        }
                    } label: {
                        Image(systemName: "chevron.up")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(themeAccentColor)
                            .padding(7)
                            .background(themeAccentColor.opacity(0.1))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        let haptic = UIImpactFeedbackGenerator(style: .light)
                        haptic.impactOccurred()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                            manager.moveDown(id: record.id)
                        }
                    } label: {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(themeAccentColor)
                            .padding(7)
                            .background(themeAccentColor.opacity(0.1))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
            } else {
                // 复制取件码快捷按钮
                Button(action: {
                    UIPasteboard.general.string = record.code
                    let haptic = UINotificationFeedbackGenerator()
                    haptic.notificationOccurred(.success)
                    JumpManager.shared.toastMessage = "已复制取件码：\(record.code)"
                }) {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(record.isPicked ? secondaryTextColor : themeAccentColor)
                        .padding(8)
                        .background(record.isPicked ? secondaryTextColor.opacity(0.1) : themeAccentColor.opacity(0.1))
                        .clipShape(Circle())
                }
                .buttonStyle(ScaleButtonStyle())
                
                // 删除按钮
                Button(action: {
                    withAnimation {
                        manager.delete(id: record.id)
                    }
                }) {
                    Image(systemName: "trash")
                        .font(.system(size: 13))
                        .foregroundColor(secondaryTextColor.opacity(0.6))
                        .padding(6)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(record.isPicked ? cardBackground.opacity(0.6) : cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(cardBorderColor, lineWidth: 1)
        )
        .contextMenu {
            Button {
                withAnimation {
                    manager.togglePicked(id: record.id)
                }
            } label: {
                Label(record.isPicked ? "标记为待取" : "标记为已取", systemImage: record.isPicked ? "circle" : "checkmark.circle")
            }
            
            Button {
                withAnimation {
                    manager.moveUp(id: record.id)
                }
            } label: {
                Label("向上移动", systemImage: "arrow.up")
            }
            
            Button {
                withAnimation {
                    manager.moveDown(id: record.id)
                }
            } label: {
                Label("向下移动", systemImage: "arrow.down")
            }
            
            Button {
                withAnimation {
                    manager.moveToTop(id: record.id)
                }
            } label: {
                Label("置顶取件码", systemImage: "arrow.up.to.line")
            }
            
            Divider()
            
            Button {
                UIPasteboard.general.string = record.code
                JumpManager.shared.toastMessage = "已复制取件码：\(record.code)"
            } label: {
                Label("复制取件码", systemImage: "doc.on.doc")
            }
            
            Button(role: .destructive) {
                withAnimation {
                    manager.delete(id: record.id)
                }
            } label: {
                Label("删除", systemImage: "trash")
            }
        }
    }
    
    // MARK: - Reorder Sheet
    
    private var reorderSheet: some View {
        NavigationStack {
            List {
                Section(header: Text("长按右侧把手上下拖动排序，调整代取路线")) {
                    ForEach(manager.records) { item in
                        HStack(spacing: 12) {
                            Image(systemName: item.isPicked ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(item.isPicked ? secondaryTextColor : themeAccentColor)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.code)
                                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                                    .strikethrough(item.isPicked)
                                Text("\(item.company) · \(item.location)")
                                    .font(.system(size: 12))
                                    .foregroundColor(secondaryTextColor)
                            }
                        }
                    }
                    .onMove { source, destination in
                        manager.moveItem(fromOffsets: source, toOffset: destination)
                    }
                }
            }
            .navigationTitle("取件码顺序调整")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
                        showingReorderSheet = false
                    }
                    .fontWeight(.semibold)
                }
            }
            .environment(\.editMode, .constant(.active))
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 8) {
            Image(systemName: "shippingbox")
                .font(.system(size: 32, weight: .light))
                .foregroundColor(secondaryTextColor.opacity(0.5))
                .padding(.top, 8)
            
            Text("还没有记录")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(primaryTextColor.opacity(0.8))
            
            Text("别人分享一段文字过来，或点击上方「粘贴识别」就能存下")
                .font(.system(size: 12))
                .foregroundColor(secondaryTextColor)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(cardBackground.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(cardBorderColor.opacity(0.6), lineWidth: 1)
        )
    }
    
    // MARK: - Manual Add Sheet
    
    private var manualAddSheet: some View {
        NavigationStack {
            Form {
                Section(header: Text("智能文字解析")) {
                    TextField("粘贴整条快递通知短信或文字", text: $inputRawText, axis: .vertical)
                        .lineLimit(3...5)
                    
                    Button("自动分析提取") {
                        if let parsed = manager.parse(text: inputRawText) {
                            inputCode = parsed.code
                            inputCompany = parsed.company
                            inputLocation = parsed.location
                        }
                    }
                    .foregroundColor(themeAccentColor)
                    .disabled(inputRawText.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                
                Section(header: Text("取件详情")) {
                    HStack {
                        Text("取件码")
                            .frame(width: 70, alignment: .leading)
                        TextField("如 1-2-3045 或 8203", text: $inputCode)
                    }
                    
                    HStack {
                        Text("快递公司")
                            .frame(width: 70, alignment: .leading)
                        TextField("如 菜鸟驿站、顺丰", text: $inputCompany)
                    }
                    
                    HStack {
                        Text("取件地点")
                            .frame(width: 70, alignment: .leading)
                        TextField("如 东门菜鸟驿站3号柜", text: $inputLocation)
                    }
                }
            }
            .navigationTitle("添加取件码")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        showingManualAdd = false
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        let record = PickupRecord(
                            code: inputCode.trimmingCharacters(in: .whitespaces),
                            company: inputCompany.isEmpty ? "快递包裹" : inputCompany,
                            location: inputLocation.isEmpty ? "自提点" : inputLocation,
                            rawText: inputRawText
                        )
                        manager.add(record: record)
                        showingManualAdd = false
                        inputCode = ""
                        inputCompany = ""
                        inputLocation = ""
                        inputRawText = ""
                    }
                    .disabled(inputCode.trimmingCharacters(in: .whitespaces).isEmpty)
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    // MARK: - Dynamic Theme Colors
    
    private var themeAccentColor: Color {
        switch themeManager.uiStyle {
        case .paper: return Color(hex: "00A870")
        case .glass: return Color(hex: "00B4D8")
        case .flat:  return Color(hex: "374151")
        }
    }
    
    private var cardBackground: Color {
        switch themeManager.uiStyle {
        case .paper:
            return isDarkMode ? Color(hex: "1A2026") : Color.white
        case .glass:
            return isDarkMode ? Color(hex: "172432").opacity(0.85) : Color.white.opacity(0.75)
        case .flat:
            return isDarkMode ? Color(hex: "1C2127") : Color.white
        }
    }
    
    private var buttonSecondaryBg: Color {
        isDarkMode ? Color(hex: "232B34") : Color(hex: "F3F4F6")
    }
    
    private var cardBorderColor: Color {
        isDarkMode ? Color.white.opacity(0.08) : Color.black.opacity(0.06)
    }
    
    private var primaryTextColor: Color {
        isDarkMode ? Color(hex: "F3F4F6") : Color(hex: "1F2937")
    }
    
    private var secondaryTextColor: Color {
        isDarkMode ? Color(hex: "9CA3AF") : Color(hex: "6B7280")
    }
}
