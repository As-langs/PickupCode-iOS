import Foundation
import SwiftUI
import Combine

/// 单条取件码本地存储模型
struct PickupRecord: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var code: String          // 取件码，如 "1-2-3045", "10-2-301", "834021"
    var company: String       // 快递公司，如 "顺丰速运", "中通快递", "菜鸟驿站"
    var location: String      // 提货点/柜，如 "东门菜鸟驿站3号柜"
    var rawText: String       // 原始文本
    var date: Date = Date()
    var isPicked: Bool = false // 是否已取件
}

@MainActor
class PickupCodeManager: ObservableObject {
    static let shared = PickupCodeManager()
    
    @Published var records: [PickupRecord] = []
    @Published var toastMessage: String? = nil
    
    private let keyStorage = "pickup_records_storage_v2"
    
    init() {
        loadRecords()
    }
    
    func loadRecords() {
        if let data = UserDefaults.standard.data(forKey: keyStorage),
           let list = try? JSONDecoder().decode([PickupRecord].self, from: data) {
            // 保持待取优先排列
            self.records = sortPendingFirst(list)
        }
    }
    
    func saveRecords() {
        if let data = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(data, forKey: keyStorage)
        }
    }
    
    /// 待取优先排序助手
    private func sortPendingFirst(_ list: [PickupRecord]) -> [PickupRecord] {
        let pending = list.filter { !$0.isPicked }
        let taken = list.filter { $0.isPicked }
        return pending + taken
    }
    
    @discardableResult
    func add(record: PickupRecord) -> Bool {
        // 防止同地点同取件码重复添加
        if let existingIdx = records.firstIndex(where: { $0.code == record.code && $0.location == record.location }) {
            records.remove(at: existingIdx)
            var updated = record
            updated.date = Date()
            updated.isPicked = false
            records.insert(updated, at: 0)
            records = sortPendingFirst(records)
            saveRecords()
            showToast("已更新已存在的取件码：\(record.code)")
            return true
        }
        
        // 新增取件码直接插入待取最顶端
        records.insert(record, at: 0)
        records = sortPendingFirst(records)
        saveRecords()
        showToast("已成功收录取件码：\(record.code)")
        return true
    }
    
    /// 切换取件状态并自动触发位置调整（取件后自动跳到底部，没取的替补上来）
    func togglePicked(id: UUID) {
        guard let idx = records.firstIndex(where: { $0.id == id }) else { return }
        
        var item = records.remove(at: idx)
        item.isPicked.toggle()
        
        if item.isPicked {
            // 刚取完件：沉底到所有未取件下方
            let unpickedCount = records.filter { !$0.isPicked }.count
            records.insert(item, at: unpickedCount)
            let status = "已标记为已取并移至下方"
            showToast("\(item.code) \(status)")
        } else {
            // 重新标记为待取：放回到待取列表末尾
            let unpickedCount = records.filter { !$0.isPicked }.count
            records.insert(item, at: unpickedCount)
            showToast("\(item.code) 已重新标记为待取")
        }
        
        saveRecords()
    }
    
    /// 向上移动一位（仅在同状态项中移动）
    func moveUp(id: UUID) {
        move(id: id, direction: -1)
    }
    
    /// 向下移动一位（仅在同状态项中移动）
    func moveDown(id: UUID) {
        move(id: id, direction: 1)
    }
    
    /// 置顶该项
    func moveToTop(id: UUID) {
        guard let idx = records.firstIndex(where: { $0.id == id }) else { return }
        var item = records.remove(at: idx)
        item.isPicked = false
        records.insert(item, at: 0)
        records = sortPendingFirst(records)
        saveRecords()
        showToast("已将 \(item.code) 置顶")
    }
    
    /// 移动取件码顺序（对齐 Android CodeStore.move）
    func move(id: UUID, direction: Int) {
        guard let idx = records.firstIndex(where: { $0.id == id }), direction != 0 else { return }
        let currentStatus = records[idx].isPicked
        let step = direction > 0 ? 1 : -1
        
        var targetIdx: Int? = nil
        var i = idx + step
        while i >= 0 && i < records.count {
            if records[i].isPicked == currentStatus {
                targetIdx = i
                break
            }
            i += step
        }
        
        if let swapIdx = targetIdx {
            let item = records.remove(at: idx)
            records.insert(item, at: swapIdx)
            saveRecords()
            showToast("已调整取件码顺序")
        }
    }
    
    /// 拖拽排序支持
    func moveItem(fromOffsets source: IndexSet, toOffset destination: Int) {
        records.move(fromOffsets: source, toOffset: destination)
        saveRecords()
    }
    
    func delete(id: UUID) {
        records.removeAll(where: { $0.id == id })
        saveRecords()
        showToast("已删除该取件码")
    }
    
    func clearPicked() {
        records.removeAll(where: { $0.isPicked })
        saveRecords()
        showToast("已清理所有已取件记录")
    }
    
    func clearAll() {
        records.removeAll()
        saveRecords()
        showToast("已清空全部记录")
    }
    
    // MARK: - 智能短信取件码解析引擎 (对齐 Android 2.1.5 CodeExtractor & CodeMeta)
    
    /// 字符全角半角标准化与符号归一化
    static func normalize(_ str: String) -> String {
        var sb = ""
        sb.reserveCapacity(str.count)
        for scalar in str.unicodeScalars {
            let val = scalar.value
            if val >= 65296 && val <= 65305 { // ０-９
                sb.append(Character(UnicodeScalar(val - 65248)!))
            } else if val >= 65313 && val <= 65338 { // Ａ-Ｚ
                sb.append(Character(UnicodeScalar(val - 65248)!))
            } else if val >= 65345 && val <= 65370 { // ａ-ｚ
                sb.append(Character(UnicodeScalar(val - 65248)!))
            } else if val == 65293 || val == 8212 || val == 8211 || val == 8213 || val == 65123 || val == 8722 || val == 95 || val == 126 || val == 65374 { // －, —, –, ―, ﹣, −, _, ~, ～
                sb.append("-")
            } else if val == 12288 { // 全角空格
                sb.append(" ")
            } else if val == 12304 || val == 12305 || val == 12300 || val == 12301 || val == 12302 || val == 12303 || val == 8220 || val == 8221 { // 【】「」『』“”
                sb.append(" ")
            } else {
                sb.append(Character(scalar))
            }
        }
        return sb
    }
    
    /// 门牌、楼栋、单元等单位过滤（防止将 3栋2单元501室、2号楼 识别为取件码）
    static func followedByUnit(in str: String, utf16End: Int) -> Bool {
        let ns = str as NSString
        guard utf16End >= 0 && utf16End < ns.length else { return false }
        let char = ns.character(at: utf16End)
        // 21495: 号, 26635: 栋, 24162: 幢, 27004: 楼, 23460: 室, 23618: 层, 24231: 座, 21333: 单(元), 31859: 米, 35: #, 65283: ＃
        return char == 21495 || char == 26635 || char == 24162 || char == 27004 ||
               char == 23460 || char == 23618 || char == 24231 || char == 21333 ||
               char == 31859 || char == 35 || char == 65283
    }
    
    static func tidy(_ str: String?) -> String {
        guard let s = str else { return "" }
        var res = s.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        while res.hasPrefix("-") { res.removeFirst() }
        while res.hasSuffix("-") { res.removeLast() }
        return res
    }
    
    static func isLabelPlausible(_ s: String) -> Bool {
        if s.isEmpty || s.count > 16 { return false }
        if s.range(of: #"^(19|20)\d{2}-\d{1,2}-\d{1,2}$"#, options: .regularExpression) != nil { return false }
        if s.range(of: #"^\d{11,}$"#, options: .regularExpression) != nil { return false }
        var digitCount = 0
        for c in s {
            if c >= "0" && c <= "9" {
                digitCount += 1
            } else if !((c >= "A" && c <= "Z") || c == "-") {
                return false
            }
        }
        return digitCount >= 1
    }
    
    static func isPlausible(_ s: String) -> Bool {
        if s.count < 3 || s.count > 16 { return false }
        if s.range(of: #"^(19|20)\d{2}-\d{1,2}-\d{1,2}$"#, options: .regularExpression) != nil { return false }
        if s.range(of: #"^\d{11,}$"#, options: .regularExpression) != nil { return false }
        var digitCount = 0
        var letterCount = 0
        for c in s {
            if c >= "0" && c <= "9" {
                digitCount += 1
            } else if c >= "A" && c <= "Z" {
                letterCount += 1
            } else if c != "-" {
                return false
            }
        }
        return digitCount >= 3 && letterCount <= 3
    }
    
    static func scoreOf(_ s: String) -> Int {
        var dashCount = 0
        for c in s where c == "-" { dashCount += 1 }
        let withoutDashes = s.replacingOccurrences(of: "-", with: "")
        return (dashCount * 6) + min(withoutDashes.count, 8)
    }
    
    /// 核心高精度取件码提取
    static func extractCode(from text: String) -> String? {
        let normalized = normalize(text)
        guard !normalized.isEmpty else { return nil }
        
        let ns = normalized as NSString
        let fullRange = NSRange(location: 0, length: ns.length)
        
        // 1. 带标签优先匹配 (LABELLED)
        let labelRegexStr = #"(?:取件码|取货码|提货码|取餐码|取餐号|取件号|取货号|提货号|取件编号|取货编号|取件密码|取货密码|提货密码|领取码|领取号|码号|凭码|验证码|密码|code)\s*[:：]?\s*(?:是|为|no\.?|:)?\s*([A-Za-z0-9]{1,4}(?:-{1,3}[A-Za-z0-9]{1,6}){0,3})(?![A-Za-z0-9])"#
        if let regex = try? NSRegularExpression(pattern: labelRegexStr, options: .caseInsensitive) {
            let matches = regex.matches(in: normalized, options: [], range: fullRange)
            var labelledHits: [(code: String, score: Int)] = []
            for match in matches {
                if match.numberOfRanges > 1 && match.range(at: 1).location != NSNotFound {
                    let groupRange = match.range(at: 1)
                    let candidate = tidy(ns.substring(with: groupRange))
                    let endPos = groupRange.location + groupRange.length
                    if isLabelPlausible(candidate) && !followedByUnit(in: normalized, utf16End: endPos) {
                        labelledHits.append((candidate, scoreOf(candidate) + 100))
                    }
                }
            }
            if let best = labelledHits.max(by: { $0.score < $1.score }) {
                return best.code
            }
        }
        
        // 2. 无前缀正则候选库并加权评分
        var hits: [(code: String, score: Int)] = []
        func collectMatches(pattern: String, weight: Int) {
            guard let regex = try? NSRegularExpression(pattern: pattern) else { return }
            let matches = regex.matches(in: normalized, options: [], range: fullRange)
            for m in matches {
                let range = m.numberOfRanges > 1 ? m.range(at: 1) : m.range(at: 0)
                let candidate = tidy(ns.substring(with: range))
                let endPos = range.location + range.length
                if isPlausible(candidate) && !followedByUnit(in: normalized, utf16End: endPos) {
                    hits.append((candidate, scoreOf(candidate) + weight))
                }
            }
        }
        
        collectMatches(pattern: #"(?<![0-9A-Za-z-])(\d{1,2}-\d{1,2}-\d{1,5})(?![0-9A-Za-z-])"#, weight: 34)
        collectMatches(pattern: #"(?<![0-9A-Za-z-])([A-Za-z]\d{1,2}-\d{1,5}-\d{1,5})(?![0-9A-Za-z-])"#, weight: 36)
        collectMatches(pattern: #"(?<![0-9A-Za-z-])([A-Za-z]?\d{1,2}-\d{1,2}-\d{1,2}-\d{1,3})(?![0-9A-Za-z-])"#, weight: 32)
        collectMatches(pattern: #"(?<![0-9A-Za-z-])(\d{1,3}-\d{2,5})(?![0-9A-Za-z-])"#, weight: 26)
        collectMatches(pattern: #"(?<![0-9A-Za-z-])([A-Za-z]-?\d{3,6})(?![0-9A-Za-z-])"#, weight: 24)
        
        if normalized.trimmingCharacters(in: .whitespaces).count <= 12 {
            if let regex = try? NSRegularExpression(pattern: #"(?<![0-9A-Za-z-])(\d{3,8})(?![0-9A-Za-z-])"#) {
                let matches = regex.matches(in: normalized, options: [], range: fullRange)
                for m in matches {
                    let range = m.range(at: 1)
                    let candidate = tidy(ns.substring(with: range))
                    let endPos = range.location + range.length
                    if isPlausible(candidate) && !followedByUnit(in: normalized, utf16End: endPos) {
                        hits.append((candidate, 12))
                    }
                }
            }
        }
        
        if let best = hits.max(by: { $0.score < $1.score }) {
            return best.code
        }
        return nil
    }
    
    /// 26 大主流承运商匹配表 (对齐 Android 2.1.5 CodeMeta)
    static let couriers: [(keyword: String, name: String)] = [
        ("顺丰", "顺丰速运"),
        ("丰网", "丰网速运"),
        ("中通", "中通快递"),
        ("圆通", "圆通速递"),
        ("申通", "申通快递"),
        ("韵达", "韵达快递"),
        ("极兔", "极兔速递"),
        ("J&T", "极兔速递"),
        ("邮政", "中国邮政"),
        ("EMS", "EMS特快"),
        ("京东", "京东快递"),
        ("德邦", "德邦快递"),
        ("百世", "百世快递"),
        ("天天", "天天快递"),
        ("宅急送", "宅急送"),
        ("丹鸟", "菜鸟直送"),
        ("菜鸟", "菜鸟驿站"),
        ("丰巢", "丰巢智能柜"),
        ("兔喜", "兔喜生活"),
        ("妈妈驿站", "妈妈驿站"),
        ("驿收发", "驿收发"),
        ("苏宁", "苏宁物流"),
        ("安能", "安能物流"),
        ("优速", "优速快递"),
        ("跨越", "跨越速运"),
        ("闪送", "闪送"),
        ("多多", "多多驿站"),
        ("拼多多", "多多驿站")
    ]
    
    /// 自提地点与柜机号码提取 (对齐 Android 2.1.5 CodeMeta.place)
    static func extractPlace(from text: String) -> String {
        let normalized = normalize(text)
        let ns = normalized as NSString
        let fullRange = NSRange(location: 0, length: ns.length)
        
        var placeStr = ""
        
        // 模式 1：动词引导词匹配
        let verbPattern = #"(?:请到|请至|请前往|到|至|前往)\s*([\u4e00-\u9fa5A-Za-z0-9（）()·\-]{2,26}(?:菜鸟驿站|驿站|快递柜|智能柜|自提柜|丰巢|代收点|服务站|服务点|网点|便利店|超市|门卫|物业))"#
        if let regex = try? NSRegularExpression(pattern: verbPattern) {
            if let m = regex.firstMatch(in: normalized, options: [], range: fullRange), m.numberOfRanges > 1 {
                placeStr = cleanPlace(ns.substring(with: m.range(at: 1)))
            }
        }
        
        // 模式 2：物理实体特征词
        if placeStr.isEmpty {
            let namePattern = #"(?:^|[\s，,。；;、])([\u4e00-\u9fa5A-Za-z0-9（）()·\-]{2,26}(?:菜鸟驿站|驿站|快递柜|智能柜|自提柜|丰巢|代收点|服务站|服务点))"#
            if let regex = try? NSRegularExpression(pattern: namePattern) {
                if let m = regex.firstMatch(in: normalized, options: [], range: fullRange), m.numberOfRanges > 1 {
                    placeStr = cleanPlace(ns.substring(with: m.range(at: 1)))
                }
            }
        }
        
        // 模式 3：显式地址标签
        if placeStr.isEmpty {
            let addrPattern = #"(?:取件地址|取件点|自提点|地址|地点)\s*[:：]\s*([^\s，,。；;]{3,32})"#
            if let regex = try? NSRegularExpression(pattern: addrPattern) {
                if let m = regex.firstMatch(in: normalized, options: [], range: fullRange), m.numberOfRanges > 1 {
                    placeStr = cleanPlace(ns.substring(with: m.range(at: 1)))
                }
            }
        }
        
        // 模式 4：柜号抽取并补全（如 "东门菜鸟驿站 3号柜"）
        let cabinetPattern = #"(\d{1,2}\s*号柜)"#
        if let regex = try? NSRegularExpression(pattern: cabinetPattern) {
            if let m = regex.firstMatch(in: normalized, options: [], range: fullRange), m.numberOfRanges > 1 {
                let cabinet = ns.substring(with: m.range(at: 1)).replacingOccurrences(of: " ", with: "")
                if placeStr.isEmpty {
                    return cabinet
                } else if !placeStr.contains(cabinet) {
                    return "\(placeStr) \(cabinet)"
                }
            }
        }
        
        return placeStr.isEmpty ? "自提点" : placeStr
    }
    
    private static func cleanPlace(_ str: String) -> String {
        var s = str.trimmingCharacters(in: .whitespacesAndNewlines)
        s = s.replacingOccurrences(of: #"^(?:请凭|凭|在此|到|至|在|：|:|\s)+"#, with: "", options: .regularExpression)
        s = s.replacingOccurrences(of: #"(?:请|，|,|。|\s)+$"#, with: "", options: .regularExpression)
        if s.contains("(") && !s.contains(")") { s.append(")") }
        if s.contains("（") && !s.contains("）") { s.append("）") }
        return s.count > 28 ? String(s.prefix(28)) : s
    }
    
    /// 从一段文本中智能挑出取件码、快递公司、自提点
    func parse(text: String) -> PickupRecord? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        
        // 1. 提取取件码
        guard let matchedCode = Self.extractCode(from: trimmed) else { return nil }
        
        // 2. 识别快递承运商
        let normalized = Self.normalize(trimmed)
        var matchedCompany = "快递包裹"
        for item in Self.couriers {
            if normalized.contains(item.keyword) {
                matchedCompany = item.name
                break
            }
        }
        
        // 3. 识别提货地点 / 柜号
        let matchedLocation = Self.extractPlace(from: trimmed)
        
        return PickupRecord(
            code: matchedCode,
            company: matchedCompany,
            location: matchedLocation,
            rawText: trimmed,
            date: Date(),
            isPicked: false
        )
    }
    
    /// 从剪贴板一键读取并解析
    @discardableResult
    func pasteAndParse() -> Bool {
        guard let clipboard = UIPasteboard.general.string, !clipboard.isEmpty else {
            showToast("剪贴板中没有文字")
            return false
        }
        
        if let record = parse(text: clipboard) {
            return add(record: record)
        } else {
            showToast("未在剪贴板中识别到取件码")
            return false
        }
    }
    
    func showToast(_ msg: String) {
        toastMessage = msg
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            if self.toastMessage == msg {
                self.toastMessage = nil
            }
        }
    }
}
