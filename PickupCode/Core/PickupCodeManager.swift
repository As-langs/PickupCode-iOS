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
            self.records = list
        }
    }
    
    func saveRecords() {
        if let data = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(data, forKey: keyStorage)
        }
    }
    
    @discardableResult
    func add(record: PickupRecord) -> Bool {
        // Prevent duplicate code with same location
        if let existingIdx = records.firstIndex(where: { $0.code == record.code && $0.location == record.location }) {
            records[existingIdx].date = Date()
            records[existingIdx].isPicked = false
            saveRecords()
            showToast("已更新已存在的取件码：\(record.code)")
            return true
        }
        
        records.insert(record, at: 0)
        saveRecords()
        showToast("已成功收录取件码：\(record.code)")
        return true
    }
    
    func togglePicked(id: UUID) {
        if let idx = records.firstIndex(where: { $0.id == id }) {
            records[idx].isPicked.toggle()
            saveRecords()
            let status = records[idx].isPicked ? "已标记为已取" : "已标记为待取"
            showToast("\(records[idx].code) \(status)")
        }
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
    
    /// 从一段文本中智能挑出取件码、快递公司、自提点
    func parse(text: String) -> PickupRecord? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        
        // 0. 提取短信签名抬头（如 【菜鸟驿站】、【丰巢】）并分离正文
        var signature: String? = nil
        var body = trimmed
        if let sigRange = trimmed.range(of: #"^[【\[][^】\]]+[】\]]"#, options: .regularExpression) {
            let fullSig = String(trimmed[sigRange])
            signature = fullSig.trimmingCharacters(in: CharacterSet(charactersIn: "【】[]")).trimmingCharacters(in: .whitespacesAndNewlines)
            body = String(trimmed[sigRange.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        // 1. 识别快递承运商 / 快递公司
        let couriers: [(String, String)] = [
            ("顺丰", "顺丰速运"),
            ("极兔", "极兔速递"),
            ("中通", "中通快递"),
            ("圆通", "圆通速递"),
            ("申通", "申通快递"),
            ("韵达", "韵达快递"),
            ("京东", "京东快递"),
            ("德邦", "德邦快递"),
            ("丹鸟", "丹鸟物流"),
            ("邮政", "中国邮政"),
            ("EMS", "EMS特快")
        ]
        
        let stations: [(String, String)] = [
            ("菜鸟", "菜鸟驿站"),
            ("丰巢", "丰巢智能柜"),
            ("多多", "多多驿站"),
            ("拼多多", "多多驿站"),
            ("京东派", "京东派")
        ]
        
        var matchedCompany = "快递包裹"
        // 优先匹配正文中明确提及的快递公司（如“您的极兔速递包裹”）
        for (kw, name) in couriers {
            if body.contains(kw) {
                matchedCompany = name
                break
            }
        }
        // 次优匹配短信签名中的快递品牌（如【顺丰速运】）
        if matchedCompany == "快递包裹", let sig = signature {
            for (kw, name) in couriers {
                if sig.contains(kw) {
                    matchedCompany = name
                    break
                }
            }
        }
        // 再次匹配自提网络品牌（如【菜鸟驿站】、【丰巢】）
        if matchedCompany == "快递包裹", let sig = signature {
            for (kw, name) in stations {
                if sig.contains(kw) {
                    matchedCompany = name
                    break
                }
            }
        }
        // 最后匹配正文中的自提品牌
        if matchedCompany == "快递包裹" {
            for (kw, name) in stations {
                if body.contains(kw) {
                    matchedCompany = name
                    break
                }
            }
        }
        
        // 2. 识别取件码
        var matchedCode = ""
        let codePatterns = [
            // 形如 "取件码: 1-2-3045", "提货码123456", "凭 3号柜4021"
            "(?:取件码|提货码|出库码|凭码|取货码|验证码|凭)[：:\\s]*([A-Za-z0-9\\-—_#号]{2,15})",
            // 形如 1-2-3045, 12-3-4001, 1-2-3-4
            "\\b(\\d{1,4}[-—_#号]\\d{1,4}[-—_#号]\\d{1,5})\\b",
            // 形如 A-1234, B3-201
            "\\b([A-Za-z]{1,2}[-—_#号]?\\d{2,6})\\b",
            // 形如 12-3456
            "\\b(\\d{1,3}[-—_#号]\\d{2,6})\\b",
            // 纯数字 5~8 位
            "\\b(\\d{5,8})\\b"
        ]
        
        for pat in codePatterns {
            if let regex = try? NSRegularExpression(pattern: pat, options: .caseInsensitive) {
                let ns = trimmed as NSString
                if let match = regex.firstMatch(in: trimmed, options: [], range: NSRange(location: 0, length: ns.length)) {
                    let range = match.numberOfRanges > 1 && match.range(at: 1).location != NSNotFound ? match.range(at: 1) : match.range(at: 0)
                    let found = ns.substring(with: range).trimmingCharacters(in: .whitespacesAndNewlines)
                    if found.count >= 2 && !found.hasPrefix("http") {
                        matchedCode = found
                        break
                    }
                }
            }
        }
        
        if matchedCode.isEmpty {
            // 后备方案：检测 4-6 位数字
            if let regex = try? NSRegularExpression(pattern: "\\b\\d{4,6}\\b") {
                let ns = trimmed as NSString
                if let match = regex.firstMatch(in: trimmed, options: [], range: NSRange(location: 0, length: ns.length)) {
                    matchedCode = ns.substring(with: match.range)
                }
            }
        }
        
        guard !matchedCode.isEmpty else { return nil }
        
        // 3. 识别驿站 / 自提点 / 智能柜 / 门店
        var matchedLocation = "自提点"
        
        // 模式 1：从引导词（到/至/在/存放于/自提点等）提取具体门店/地点，截止到取件动词或标点
        let locPattern1 = #"(?:到|至|在|存放于|放置于|已送达|已到达|已存入|已到|自提点[：:\s]?|提货点[：:\s]?|取件点[：:\s]?|请到)\s*([^，。！？,!?\n]{2,35}?)(?:尽早取|尽快取|请及时取|及时取|请取|取件|取货|提取|领取|查收|逾期|过期|详询|如有|，|。|！|!|\n|$)"#
        
        // 模式 2：正文中包含驿站/柜机/门店/超市等具体词汇
        let locPattern2 = #"([^，。！？,!?\n\s]{2,25}?(?:驿站|自提点|智能柜|自提柜|号柜|柜机|便利店|超市|门卫室|门卫|代收点|代管点|丰巢|小卖部|物业|收发室|传达室|大堂|前台|店))"#
        
        if let regex = try? NSRegularExpression(pattern: locPattern1) {
            let ns = body as NSString
            if let match = regex.firstMatch(in: body, options: [], range: NSRange(location: 0, length: ns.length)) {
                let range = match.range(at: 1)
                var loc = ns.substring(with: range).trimmingCharacters(in: .whitespacesAndNewlines)
                loc = loc.replacingOccurrences(of: #"^(?:请凭|凭|在此|到|至|在|\s)+"#, with: "", options: .regularExpression)
                loc = loc.trimmingCharacters(in: CharacterSet(charactersIn: "【】[]:：,，。!！?？ "))
                if loc.contains("(") && !loc.contains(")") { loc.append(")") }
                if loc.contains("（") && !loc.contains("）") { loc.append("）") }
                loc = loc.trimmingCharacters(in: CharacterSet(charactersIn: "【】[]:：,，。!！?？ "))
                if loc.count >= 2 {
                    matchedLocation = loc
                }
            }
        }
        
        if matchedLocation == "自提点" {
            if let regex = try? NSRegularExpression(pattern: locPattern2) {
                let ns = body as NSString
                if let match = regex.firstMatch(in: body, options: [], range: NSRange(location: 0, length: ns.length)) {
                    let range = match.range(at: 1)
                    var loc = ns.substring(with: range).trimmingCharacters(in: .whitespacesAndNewlines)
                    loc = loc.trimmingCharacters(in: CharacterSet(charactersIn: "【】[]:：,，。!！?？ "))
                    if loc.count >= 2 {
                        matchedLocation = loc
                    }
                }
            }
        }
        
        // 若正文未提取到具体门店，但签名中有明显自提属性，使用签名
        if matchedLocation == "自提点", let sig = signature, (sig.contains("驿站") || sig.contains("柜") || sig.contains("点")) {
            matchedLocation = sig
        }
        
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
    
    private func showToast(_ msg: String) {
        toastMessage = msg
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            if self.toastMessage == msg {
                self.toastMessage = nil
            }
        }
    }
}
