import SwiftUI

struct PickupCodeSectionView: View {
    @ObservedObject var manager = PickupCodeManager.shared
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var systemColorScheme
    
    @State private var showingManualAdd = false
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
                
                Spacer()
                
                if !manager.records.isEmpty {
                    Menu {
                        Button(role: .destructive) {
                            manager.clearPicked()
                        } label: {
                            Label("清理已取件", systemImage: "checkmark.circle")
                        }
                        
                        Button(role: .destructive) {
                            manager.clearAll()
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
            
            Text("分享、粘贴或手打一段文字，自动挑出码；只存本机")
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
                    ForEach(manager.records) { record in
                        recordRow(record)
                    }
                }
            }
        }
        .sheet(isPresented: $showingManualAdd) {
            manualAddSheet
        }
    }
    
    // MARK: - Record Row
    
    @ViewBuilder
    private func recordRow(_ record: PickupRecord) -> some View {
        HStack(alignment: .center, spacing: 14) {
            // Checkmark button
            Button(action: {
                let haptic = UISelectionFeedbackGenerator()
                haptic.selectionChanged()
                manager.togglePicked(id: record.id)
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
                        .foregroundColor(themeAccentColor)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(themeAccentColor.opacity(0.12))
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
            
            // Copy Code Button
            Button(action: {
                UIPasteboard.general.string = record.code
                let haptic = UINotificationFeedbackGenerator()
                haptic.notificationOccurred(.success)
                JumpManager.shared.toastMessage = "已复制取件码：\(record.code)"
            }) {
                Image(systemName: "doc.on.doc")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(themeAccentColor)
                    .padding(8)
                    .background(themeAccentColor.opacity(0.1))
                    .clipShape(Circle())
            }
            .buttonStyle(ScaleButtonStyle())
            
            // Delete button
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
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(cardBorderColor, lineWidth: 1)
        )
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
