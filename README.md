# 取件快码 for iOS (PickupCode)

<p align="center">
  <img src="PickupCode/Resources/Images/AppIcon60x60@3x.png" width="100" height="100" alt="取件快码 图标" style="border-radius: 22px;">
</p>

<p align="center">
  <b>三个身份码 · 七个查件入口</b><br>
  一站式出示各平台驿站取件身份码，极速直达主流电商订单物流界面。<br>
  原生纯 SwiftUI 重构，极速轻巧，纯净无广告，隐私安全。
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-iOS%2016.0%2B-blue.svg" alt="Platform">
  <img src="https://img.shields.io/badge/Language-Swift%205-orange.svg" alt="Language">
  <img src="https://img.shields.io/badge/UI-SwiftUI-green.svg" alt="SwiftUI">
  <img src="https://img.shields.io/badge/License-MIT-lightgrey.svg" alt="License">
</p>

---

## ✨ 核心特性

- ⚡️ **三大平台身份码**：
  - **淘宝身份码**（菜鸟驿站扫码出示）
  - **京东身份码**（订单内一键查看取件码）
  - **拼多多身份码**（多多驿站扫码出示）
- 📦 **七大电商查件入口**：
  - **淘宝待取**（直达待收货与校园驿站）
  - **京东待取**（京东订单物流与取件码）
  - **拼多多待取**（多多待收货包裹列表）
  - **抖音待取**（抖音商城-我的订单待收货）
  - **快手待取**（快手小店订单列表）
  - **得物待取**（得物买家订单物流）
  - **小红书待取** 🆕（小红书订单中心与物流）
- 🎨 **雅致界面设计**：
  - **青简**（清新竹简 · 雅致绿意）
  - **雾青**（雾感毛玻璃 · 现代科技）
  - **素白**（纯简素白 · 极简克制）
  - 完美适配深色模式（跟随系统 / 浅色 / 深色）。
- 🔀 **自由拖拽排序**：轻触右上角切换编辑模式，长按把手自由调整入口前后次序，记忆持久化。
- 🍃 **超小体积与隐私**：完全无需网络权限，本地直接调用系统底层 URL Scheme 跳转，极速直达。

---

## 📲 桌面快捷组件（官方签名快捷指令）

为解决自签名证书或部分 iOS 环境下小组件签名失效的问题，本项目精心制作了**苹果官方加密签名的快捷指令**（提供二合一全能版与独立拆分版）。

> 💡 **特点**：
> - 采用 Apple 官方 `shortcuts sign` 加密签名，**导入时绝不弹“不支持导入未签名文件”的警告**；
> - 100% 原生支持 iOS 桌面快捷指令小组件，**永不掉签、永不闪退、无需证书**；
> - 在桌面轻点即可在屏幕上方弹出半透明原生菜单，秒选直达！

| 快捷指令版本 | 菜单交互模式 | 涵盖平台与入口 | 下载链接 |
| :--- | :--- | :--- | :--- |
| ⭐️ **取件快码（二合一全能版）**<br>*(推荐)* | 智能二级菜单：<br>1. 🪪 驿站身份码<br>2. 📦 查询快递待取 | **全功能集合**：<br>淘宝、京东、拼多多身份码 +<br>淘宝、京东、多多、抖音、快手、得物、小红书待取 | [📥 点击下载 `取件快码_二合一.shortcut`](Shortcuts/取件快码_二合一.shortcut) |
| **取件身份码（独立版）** | 一级菜单直接展示 3 项 | 淘宝、京东、拼多多 身份码 | [📥 点击下载 `取件身份码.shortcut`](Shortcuts/取件身份码.shortcut) |
| **快递待取（独立版）** | 一级菜单直接展示 7 项 | 淘宝、京东、多多、抖音、快手、得物、小红书 待取 | [📥 点击下载 `快递待取.shortcut`](Shortcuts/快递待取.shortcut) |

### 快捷指令安装与添加到桌面

1. **导入快捷指令**：
   - **方式一（隔空投送）**：使用 Mac 将下载的 `.shortcut` 文件通过 AirDrop 发送到 iPhone，点击 **「添加快捷指令」**。
   - **方式二（iCloud 同步）**：在登录相同 Apple ID 的 Mac 或 iPad 上双击打开该 `.shortcut` 文件，稍等数秒即可通过 iCloud 自动同步到手机。
2. **添加到主屏幕小组件**：
   - 长按 iPhone 桌面空白处，点击左上角 **「+」** 号；
   - 搜索并选择 **「快捷指令」**；
   - 选择 **单个快捷指令（小号）** 添加到桌面；
   - 点击该小组件（或长按选择「编辑小组件」），绑定为 **「取件快码（二合一）」** 即可！

<details>
<summary><b>🔍 查看快捷指令内部直达协议（URL Schemes 清单）</b></summary>

如果你想在「快捷指令」App 中自行配置或调试，可以直接复制以下经过真机适配的官方协议：

#### 1. 身份码协议
- **淘宝身份码**：
  ```text
  taobao://m.taobao.com/tbopen/index.html?h5Url=https%3A%2F%2Fmarket.m.taobao.com%2Fapp%2Fcn-yz%2Fmulti-activity%2FauthCode.html
  ```
- **京东身份码**：
  ```text
  openapp.jdmobile://virtual?params=%7B%22category%22%3A%22jump%22%2C%22des%22%3A%22orderlist%22%7D
  ```
- **拼多多身份码**：
  ```text
  pinduoduo://com.xunmeng.pinduoduo/mdkd/package?tab=ID_CODE&entry_source=11&refer_page_name=login&refer_page_sn=10169
  ```

#### 2. 查件待取协议
- **淘宝待取**：
  ```text
  taobao://m.taobao.com/tbopen/index.html?action=ali.open.nav&h5Url=https%3A%2F%2Fh5.m.taobao.com%2Fawp%2Fmtb%2Folist.htm%3FtabCode%3DwaitConfirm
  ```
- **京东待取**：
  ```text
  openapp.jdmobile://virtual?params=%7B%22category%22%3A%22jump%22%2C%22des%22%3A%22orderlist%22%7D
  ```
- **拼多多待取**：
  ```text
  pinduoduo://com.xunmeng.pinduoduo/orders.html?status=wait_receive
  ```
- **抖音待取**：
  ```text
  snssdk1128://ecom_order_list
  ```
- **快手待取**：
  ```text
  kwai://webview?url=https%3A%2F%2Fapp.kwaixiaodian.com%2Fpage%2Fkwaishop-trade-order-list-app%3FlayoutType%3D4%26hyId%3DkwaishopOrder
  ```
- **得物待取**：
  ```text
  dewuapp://m.dewu.com/router/order/buyer/orderList?tabId=0
  ```
- **小红书待取**：
  ```text
  xhsdiscover://rn/order/list
  ```
</details>

---

## 📦 IPA 安装方法

### 1. TrollStore（巨魔商店，推荐）
- 直接通过 AirDrop、文件或网页分享将 `取件快码-1.0.ipa` 传送到手机；
- 在分享菜单中选择 **「TrollStore」** 安装即可永久使用。

> 💡 **解决抖音多开/修改版抢协议技巧**：  
> 若手机上同时安装了第三方抖音且跳转时被第三方拦截：打开 TrollStore -> 点击第三方抖音 -> 点击 **「Uninstall URL Scheme」**（注销协议）。第三方抖音所有功能与插件不受任何影响，但取件快码能 100% 直达 App Store 官方抖音！

### 2. 证书自签名（LCSign / 轻松签 / 全能签 / Sideloadly）
- 导入 `取件快码-1.0.ipa`；
- 使用个人证书或企业证书签名后直接安装。

---

## 🛠 源码与工程结构

```text
PickupCode-iOS/
├── PickupCode.xcodeproj       # Xcode 16 项目工程文件
├── PickupCode/
│   ├── App/
│   │   └── PickupCodeApp.swift   # 生命周期与 URL Scheme 路由分发
│   ├── Core/
│   │   ├── Models.swift          # 各平台入口定义与深度链接
│   │   ├── ThemeManager.swift    # 主题模式与深色模式控制器
│   │   └── JumpManager.swift     # 触感振动与跳转服务
│   ├── Views/
│   │   ├── ContentView.swift     # 主界面与拖拽排序
│   │   ├── EntryCardView.swift   # 平台入口卡片 UI
│   │   ├── SettingsView.swift    # 纯净设置界面
│   │   ├── ToastView.swift       # 灵动微提示 HUD
│   │   └── PlatformIconView.swift# 平台高清矢量/PNG加载器
│   └── Resources/
│       ├── Info.plist            # 应用权限与跳转协议配置
│       └── Images/               # 提取自原版的 384x384 高清平台图标
├── PickupCodeWidget/             # 原生三合一 WidgetKit 扩展源码
├── Shortcuts/                    # 苹果官方已签名的快捷指令文件
│   ├── 取件快码_二合一.shortcut
│   ├── 取件身份码.shortcut
│   └── 快递待取.shortcut
└── build_ipa.sh                  # 自动化编译打包 IPA 脚本
```

### 本地编译

环境要求：macOS 14+，Xcode 16.0+。

```bash
# 1. 克隆项目
git clone https://github.com/As-langs/PickupCode-iOS.git
cd PickupCode-iOS

# 2. 一键编译并打包生成 IPA
chmod +x build_ipa.sh
./build_ipa.sh
```

---

## 👥 作者与致谢

- **iOS 版本开发**：Hans
- **特别致谢**：然后啊然后
- **Android 原作**：[酷安 @原作者 (UID: 27888540)](https://www.coolapk.com/u/27888540)（感谢原作者优秀的取件快码设计与灵感启发）

---

## 📄 开源许可证

本项目基于 [MIT License](LICENSE) 协议开源。仅供技术学习交流使用。
