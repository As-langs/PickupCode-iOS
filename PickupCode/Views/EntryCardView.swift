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
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}
