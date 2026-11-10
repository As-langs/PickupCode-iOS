import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        completion(SimpleEntry(date: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        let timeline = Timeline(entries: [SimpleEntry(date: Date())], policy: .never)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct WidgetItem: Identifiable {
    let id: String
    let title: String
    let shortName: String
    let subtitle: String
    let iconName: String
    let scheme: String
    let themeColor: Color
}

let widgetItems: [WidgetItem] = [
    WidgetItem(
        id: "cainiao_code",
        title: "菜鸟身份码",
        shortName: "菜鸟",
        subtitle: "扫码出示",
        iconName: "ic_cainiao",
        scheme: "pickupcode://jump?entry=cainiao_code",
        themeColor: Color(red: 0.05, green: 0.52, blue: 1.0) // 菜鸟蓝
    ),
    WidgetItem(
        id: "taobao_code",
        title: "淘宝身份码",
        shortName: "淘宝",
        subtitle: "扫码出示",
        iconName: "ic_taobao",
        scheme: "pickupcode://jump?entry=taobao_code",
        themeColor: Color(red: 1.0, green: 0.35, blue: 0.0) // 淘宝橙
    ),
    WidgetItem(
        id: "jd_code",
        title: "京东身份码",
        shortName: "京东",
        subtitle: "订单查看",
        iconName: "ic_jd",
        scheme: "pickupcode://jump?entry=jd_code",
        themeColor: Color(red: 0.9, green: 0.15, blue: 0.15) // 京东红
    ),
    WidgetItem(
        id: "pdd_code",
        title: "拼多多身份码",
        shortName: "拼多多",
        subtitle: "扫码出示",
        iconName: "ic_pinduoduo",
        scheme: "pickupcode://jump?entry=pdd_code",
        themeColor: Color(red: 0.92, green: 0.22, blue: 0.24) // 多多红
    )
]

struct PickupCodeWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        Group {
            switch family {
            case .systemMedium:
                mediumView
            case .systemSmall:
                smallView
            default:
                mediumView
            }
        }
        .applyWidgetBackground()
    }

    // MARK: - Medium View (3 Equal Cards Side-by-Side)
    private var mediumView: some View {
        HStack(spacing: 10) {
            ForEach(widgetItems) { item in
                Link(destination: URL(string: item.scheme)!) {
                    VStack(spacing: 8) {
                        widgetIcon(named: item.iconName, size: 38)
                        
                        VStack(spacing: 2) {
                            Text(item.shortName)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Text("身份码")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        
                        Text(item.subtitle)
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(item.themeColor)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(item.themeColor.opacity(0.12))
                            .clipShape(Capsule())
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color(UIColor.separator).opacity(0.2), lineWidth: 1)
                    )
                }
            }
        }
        .padding(10)
    }

    // MARK: - Small View (3 Compact Horizontal Rows)
    private var smallView: some View {
        VStack(spacing: 6) {
            ForEach(widgetItems) { item in
                Link(destination: URL(string: item.scheme)!) {
                    HStack(spacing: 8) {
                        widgetIcon(named: item.iconName, size: 24)
                        
                        Text(item.title)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.secondary.opacity(0.7))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
            }
        }
        .padding(10)
    }

    private func widgetIcon(named name: String, size: CGFloat) -> some View {
        Group {
            if let path = Bundle.main.path(forResource: name, ofType: "png"),
               let uiImage = UIImage(contentsOfFile: path) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            } else if let uiImage = UIImage(named: name) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: "qrcode")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.blue)
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.22, style: .continuous))
    }
}

extension View {
    func applyWidgetBackground() -> some View {
        if #available(iOS 17.0, *) {
            return self.containerBackground(Color(UIColor.systemGroupedBackground), for: .widget)
        } else {
            return self.background(Color(UIColor.systemGroupedBackground))
        }
    }
}

@main
struct PickupCodeWidget: Widget {
    let kind: String = "PickupCodeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            PickupCodeWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("取件身份码")
        .description("一键直达淘宝、京东、拼多多取件身份码")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
