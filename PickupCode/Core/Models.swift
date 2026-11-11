import Foundation

enum EntryCategory: String, Codable {
    case identityCode   // 身份码
    case packageQuery   // 查询快递与待取
}

enum EntryKey: String, CaseIterable, Identifiable, Codable {
    // 身份码 (4个)
    case cainiaoCode        = "cainiao_code"
    case taobaoCode         = "taobao_code"
    case pddCode            = "pdd_code"
    case jdCode             = "jd_code"
    
    // 快递与订单待收货 (9个)
    case taobaoCainiaoPending = "taobao_cainiao_pending"
    case pddPickup          = "pdd_pickup"
    case taobaoPending      = "taobao_pending"
    case pddPending         = "pdd_pending"
    case jdPending          = "jd_pending"
    case douyinPending      = "douyin_pending"
    case kuaishouPending    = "kuaishou_pending"
    case dewuPending        = "dewu_pending"
    case xhsPending         = "xhs_pending"
    
    var id: String { rawValue }
    
    var category: EntryCategory {
        switch self {
        case .cainiaoCode, .taobaoCode, .pddCode, .jdCode:
            return .identityCode
        default:
            return .packageQuery
        }
    }
    
    var title: String {
        switch self {
        case .cainiaoCode:          return "菜鸟身份码"
        case .taobaoCode:           return "淘宝身份码"
        case .taobaoCainiaoPending: return "淘宝菜鸟待取"
        case .pddCode:              return "拼多多身份码"
        case .pddPickup:            return "拼多多取快递"
        case .jdCode:               return "京东身份码"
        case .taobaoPending:        return "淘宝待收货"
        case .pddPending:           return "拼多多待收货"
        case .jdPending:            return "京东待取"
        case .douyinPending:        return "抖音待取"
        case .kuaishouPending:      return "快手待取"
        case .dewuPending:          return "得物待取"
        case .xhsPending:           return "小红书待取"
        }
    }
    
    var subtitle: String {
        switch self {
        case .cainiaoCode:
            return "菜鸟App扫码出示"
        case .taobaoCode, .pddCode:
            return "驿站扫码出示"
        case .jdCode:
            return "订单内查看"
        case .taobaoCainiaoPending:
            return "淘宝内置菜鸟包裹"
        case .pddPickup:
            return "自提待取包裹列表"
        case .taobaoPending, .pddPending:
            return "直达待收货包裹"
        case .jdPending:
            return "查看待取包裹"
        case .douyinPending, .kuaishouPending, .dewuPending, .xhsPending:
            return "查看订单物流"
        }
    }
    
    var iconName: String {
        switch self {
        case .cainiaoCode, .taobaoCainiaoPending:
            return "ic_cainiao"
        case .taobaoCode, .taobaoPending:
            return "ic_taobao"
        case .jdCode, .jdPending:
            return "ic_jd"
        case .pddCode, .pddPickup, .pddPending:
            return "ic_pinduoduo"
        case .douyinPending:
            return "ic_douyin"
        case .kuaishouPending:
            return "ic_kuaishou"
        case .dewuPending:
            return "ic_dewu"
        case .xhsPending:
            return "ic_xhs"
        }
    }
    
    var guideMessage: String {
        switch self {
        case .cainiaoCode:
            return "已打开菜鸟身份码，请出示给驿站"
        case .taobaoCode:
            return "已打开淘宝身份码，请出示给驿站"
        case .taobaoCainiaoPending:
            return "已打开淘宝菜鸟待取包裹列表"
        case .jdCode:
            return "已打开京东订单，点开对应订单即可看到取件码"
        case .pddCode:
            return "已打开多多驿站包裹列表出示身份码"
        case .pddPickup:
            return "已打开多多自提待取包裹列表"
        case .taobaoPending:
            return "已直达淘宝待收货订单列表"
        case .pddPending:
            return "已直达拼多多待收货订单列表"
        case .jdPending:
            return "已打开京东订单列表，点开订单查看物流"
        case .douyinPending:
            return "已打开抖音订单列表，可看待收货与物流"
        case .kuaishouPending:
            return "已打开快手小店订单列表"
        case .dewuPending:
            return "已打开得物订单列表"
        case .xhsPending:
            return "已打开小红书订单列表"
        }
    }
    
    var appURLStrings: [String] {
        switch self {
        case .cainiaoCode:
            return [
                "cainiao://desktop/station_code",
                "cainiao://",
                "taobao://m.taobao.com/tbopen/index.html?h5Url=https%3A%2F%2Fmarket.m.taobao.com%2Fapp%2Fcn-yz%2Fmulti-activity%2FauthCode.html"
            ]
        case .taobaoCode:
            return [
                "taobao://m.taobao.com/tbopen/index.html?h5Url=https%3A%2F%2Fmarket.m.taobao.com%2Fapp%2Fcn-yz%2Fmulti-activity%2FauthCode.html",
                "tbopen://m.taobao.com/tbopen/index.html?h5Url=https%3A%2F%2Fmarket.m.taobao.com%2Fapp%2Fcn-yz%2Fmulti-activity%2FauthCode.html",
                "taobao://m.taobao.com/tbopen/index.html?h5Url=https%3A%2F%2Fpages-fast.m.taobao.com%2Fwow%2Fz%2Funiapp%2F1011717%2Flast-mile-fe%2Fend-collect-platform%2Fidentity-code%3Fx-ssr%3Dtrue",
                "tbopen://m.taobao.com/tbopen/index.html?h5Url=https%3A%2F%2Fpages-fast.m.taobao.com%2Fwow%2Fz%2Funiapp%2F1011717%2Flast-mile-fe%2Fend-collect-platform%2Fidentity-code%3Fx-ssr%3Dtrue"
            ]
        case .taobaoCainiaoPending:
            return [
                "taobao://m.taobao.com/tbopen/index.html?h5Url=https%3A%2F%2Fpages-fast.m.taobao.com%2Fwow%2Fz%2Funiapp%2F1100333%2Flast-mile-fe%2Fm-end-school-tab%2Fhome",
                "tbopen://m.taobao.com/tbopen/index.html?h5Url=https%3A%2F%2Fpages-fast.m.taobao.com%2Fwow%2Fz%2Funiapp%2F1100333%2Flast-mile-fe%2Fm-end-school-tab%2Fhome"
            ]
        case .jdCode:
            return [
                "openapp.jdmobile://virtual?params=%7B%22category%22%3A%22jump%22%2C%22des%22%3A%22orderlist%22%7D",
                "openjd://virtual?params=%7B%22category%22%3A%22jump%22%2C%22des%22%3A%22orderlist%22%7D",
                "openapp.jdmobile://",
                "openjd://"
            ]
        case .pddCode:
            return [
                "pinduoduo://com.xunmeng.pinduoduo/mdkd/package?tab=ID_CODE&entry_source=11&refer_page_name=login&refer_page_sn=10169",
                "pinduoduo://com.xunmeng.pinduoduo/mdkd/package?tab=ID_CODE&entry_source=11",
                "pinduoduo://com.xunmeng.pinduoduo/mdkd/package"
            ]
        case .pddPickup:
            return [
                "pinduoduo://com.xunmeng.pinduoduo/mdkd/package",
                "pinduoduo://com.xunmeng.pinduoduo/mdkd/package?tab=ID_CODE&entry_source=11"
            ]
        case .taobaoPending:
            return [
                "taobao://m.taobao.com/tbopen/index.html?action=ali.open.nav&h5Url=https%3A%2F%2Fh5.m.taobao.com%2Fawp%2Fmtb%2Folist.htm%3FtabCode%3DwaitConfirm",
                "tbopen://m.taobao.com/tbopen/index.html?action=ali.open.nav&h5Url=https%3A%2F%2Fh5.m.taobao.com%2Fawp%2Fmtb%2Folist.htm%3FtabCode%3DwaitConfirm"
            ]
        case .pddPending:
            return [
                "pinduoduo://com.xunmeng.pinduoduo/orders.html?type=3",
                "pinduoduo://com.xunmeng.pinduoduo/orders.html?status=wait_receive",
                "pinduoduo://com.xunmeng.pinduoduo/mdkd/package"
            ]
        case .jdPending:
            return [
                "openapp.jdmobile://virtual?params=%7B%22category%22%3A%22jump%22%2C%22des%22%3A%22orderlist%22%7D",
                "openjd://virtual?params=%7B%22category%22%3A%22jump%22%2C%22des%22%3A%22orderlist%22%7D",
                "openapp.jdmobile://"
            ]
        case .douyinPending:
            return [
                "snssdk1128://ecom_order_list",
                "snssdk1128://wallet",
                "snssdk1128://"
            ]
        case .kuaishouPending:
            return [
                "kwai://webview?url=https%3A%2F%2Fapp.kwaixiaodian.com%2Fpage%2Fkwaishop-trade-order-list-app%3FlayoutType%3D4%26hyId%3DkwaishopOrder",
                "kwai://mywallet",
                "kwai://"
            ]
        case .dewuPending:
            return [
                "dewuapp://m.dewu.com/router/order/buyer/orderList?tabId=0",
                "dewuapp://"
            ]
        case .xhsPending:
            return [
                "xhsdiscover://home/store",
                "xhsdiscover://store",
                "xhsdiscover://profile",
                "xhsdiscover://rn/order/list",
                "xhsdiscover://webview?link=https%3A%2F%2Fwww.xiaohongshu.com%2Forder%2Flist",
                "xhsdiscover://home",
                "xhsdiscover://"
            ]
        }
    }
    
    var miniProgramURLString: String? {
        if self == .jdCode {
            return "weixin://dl/business/?appid=wx91d27dbf599dff74&path=pages/index/index"
        }
        return nil
    }
    
    var webURLString: String? {
        switch self {
        case .cainiaoCode:
            return "https://pages.cainiao.com/"
        case .taobaoCode:
            return "https://market.m.taobao.com/app/cn-yz/multi-activity/authCode.html"
        case .taobaoCainiaoPending:
            return "https://pages-fast.m.taobao.com/wow/z/uniapp/1100333/last-mile-fe/m-end-school-tab/home"
        case .jdCode, .jdPending:
            return "https://order.jd.com/center/list.action"
        case .pddCode, .pddPickup, .pddPending:
            return "https://m.pinduoduo.net/mdkd/package?entry_source=18&extra_params=from_wx_jump%3D1&p_channel=0"
        case .taobaoPending:
            return "https://h5.m.taobao.com/awp/mtb/olist.htm?tabCode=waitConfirm"
        case .douyinPending:
            return "https://haohuo.jinritemai.com/views/order/list"
        case .kuaishouPending:
            return "https://app.kwaixiaodian.com/page/kwaishop-trade-order-list-app?layoutType=4&hyId=kwaishopOrder"
        case .dewuPending:
            return "https://m.dewu.com/"
        case .xhsPending:
            return "https://www.xiaohongshu.com/order/list"
        }
    }
}
