import SwiftUI
import UIKit

enum UiStyle: Int, CaseIterable, Identifiable {
    case paper = 0   // 青简
    case glass = 1   // 雾青
    case flat  = 2   // 素白
    
    var id: Int { rawValue }
    
    var name: String {
        switch self {
        case .paper: return "青简"
        case .glass: return "雾青"
        case .flat:  return "素白"
        }
    }
    
    var subtitle: String {
        switch self {
        case .paper: return "清新竹简 · 雅致绿意"
        case .glass: return "雾感毛玻璃 · 现代科技"
        case .flat:  return "纯简素白 · 极简克制"
        }
    }
}

enum DarkModeSetting: Int, CaseIterable, Identifiable {
    case followSystem = 0
    case forceLight   = 1
    case forceDark    = 2
    
    var id: Int { rawValue }
    
    var title: String {
        switch self {
        case .followSystem: return "跟随系统"
        case .forceLight:   return "浅色"
        case .forceDark:    return "深色"
        }
    }
}

enum GridColumnSetting: Int, CaseIterable, Identifiable {
    case one   = 1
    case two   = 2
    case three = 3
    
    var id: Int { rawValue }
    
    var title: String {
        switch self {
        case .one:   return "一列"
        case .two:   return "两列"
        case .three: return "三列"
        }
    }
    
    var subtitle: String {
        switch self {
        case .one:   return "一列最清楚"
        case .two:   return "两列兼顾"
        case .three: return "三列最紧凑"
        }
    }
}

@MainActor
class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    private let prefs = UserDefaults.standard
    
    @Published var uiStyle: UiStyle {
        didSet {
            prefs.set(uiStyle.rawValue, forKey: "ui_style")
        }
    }
    
    @Published var darkModeSetting: DarkModeSetting {
        didSet {
            prefs.set(darkModeSetting.rawValue, forKey: "dark_mode_setting")
        }
    }
    
    @Published var gridColumns: GridColumnSetting {
        didSet {
            prefs.set(gridColumns.rawValue, forKey: "grid_columns")
        }
    }
    
    init() {
        let styleVal = prefs.integer(forKey: "ui_style")
        self.uiStyle = UiStyle(rawValue: styleVal) ?? .paper
        
        let darkVal = prefs.integer(forKey: "dark_mode_setting")
        self.darkModeSetting = DarkModeSetting(rawValue: darkVal) ?? .followSystem
        
        let colVal = prefs.integer(forKey: "grid_columns")
        self.gridColumns = GridColumnSetting(rawValue: colVal == 0 ? 1 : colVal) ?? .one
    }
    
    var colorScheme: ColorScheme? {
        switch darkModeSetting {
        case .followSystem: return nil
        case .forceLight:   return .light
        case .forceDark:    return .dark
        }
    }
}

extension Color {
    init(hex: String) {
        let clean = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: clean).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch clean.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
