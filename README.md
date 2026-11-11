# 取件快码 for iOS (PickupCode)

<p align="center">
  <img src="PickupCode/Resources/Images/AppIcon60x60@3x.png" width="100" height="100" alt="取件快码 图标" style="border-radius: 22px;">
</p>

<p align="center">
  <b>四个身份码 · 九个查件待取入口 · 智能短信取件码识别</b><br>
  一站式出示各平台驿站取件身份码，极速直达主流电商订单物流界面。<br>
  原生纯 SwiftUI 重构，极速轻巧，纯净无广告，零网络权限申请，隐私绝对安全。
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Release-v2.0.0-brightgreen.svg" alt="Release">
  <img src="https://img.shields.io/badge/Platform-iOS%2016.0%2B-blue.svg" alt="Platform">
  <img src="https://img.shields.io/badge/Language-Swift%205-orange.svg" alt="Language">
  <img src="https://img.shields.io/badge/UI-SwiftUI-green.svg" alt="SwiftUI">
  <img src="https://img.shields.io/badge/License-MIT-lightgrey.svg" alt="License">
</p>

---

## ✨ 核心特性 (v2.0.0)

- ⚡️ **四大平台身份码**：
  - **菜鸟身份码** 🆕（菜鸟 App 驿站扫码出示）
  - **淘宝身份码**（菜鸟驿站扫码出示）
  - **京东身份码**（订单内一键查看取件码）
  - **拼多多身份码**（多多买菜/多多驿站扫码出示）
- 📦 **九大电商查件待取入口**：
  - **淘宝待收货**（精准直达待确认收货列表）
  - **淘宝菜鸟待取** 🆕（淘宝内菜鸟校园/驿站待取页面）
  - **京东待取**（京东订单物流与取件码）
  - **拼多多取快递** 🆕（多多买菜/多多驿站待取包裹）
  - **拼多多待收货**（优化直达待收货状态）
  - **抖音待取**（抖音商城-我的订单待收货）
  - **快手待取**（快手小店订单列表）
  - **得物待取**（得物买家订单物流）
  - **小红书待取**（小红书订单中心与物流）
- 📋 **全新取件码管理模块**：
  - **粘贴识别**：智能正则解析短信中的取件码（如 `1-2-3045`、`3号柜4021`）、快递公司及驿站柜号位置。
  - **手动添加**：支持手动记录包裹取件码与自提点。
  - **便捷操作**：卡片大字号高亮、一键复制、点击切换「未取/已取」、左滑删除。
  - **纯本地存储**：数据仅保存在设备沙盒，不请求任何网络权限，隐私无忧。
- 📱 **多列网格布局自由切换**：
  - 支持 **一列（最清楚）**、**两列（兼顾）**、**三列（最紧凑）** 布局切换。
  - 多列模式下标题居中显示在图标正下方，不被挤压省略。
  - 自由拖拽排序并持久化记忆。
- 🚀 **3D Touch / 长按图标快捷方式 (Quick Actions)**：
  - 菜鸟身份码、淘宝身份码、拼多多身份码、淘宝待收货、粘贴识别取件码。
- 🎨 **雅致界面主题**：
  - **青简**（清新竹简 · 雅致绿意）
  - **雾青**（雾感毛玻璃 · 现代科技）
  - **素白**（纯简素白 · 极简克制）
  - 完美适配深色模式（跟随系统 / 浅色 / 深色）。

---

## 📲 桌面快捷组件（官方签名快捷指令）

为解决自签名证书或部分 iOS 环境下小组件签名失效的问题，本项目提供**苹果官方加密签名的快捷指令**（提供二合一全能版与独立拆分版）。

> 💡 **特点**：
> - 采用 Apple 官方 `shortcuts sign` 加密签名，**导入时绝不弹“不支持导入未签名文件”的警告**；
> - 100% 原生支持 iOS 桌面快捷指令小组件，**永不掉签、永不闪退、无需证书**；
> - 在桌面轻点即可在屏幕上方弹出半透明原生菜单，秒选直达！

| 快捷指令版本 | 菜单交互模式 | 涵盖平台与入口 | 下载链接 |
| :--- | :--- | :--- | :--- |
| ⭐️ **取件快码（二合一全能版）**<br>*(推荐)* | 智能二级菜单：<br>1. 🪪 驿站身份码<br>2. 📦 查询快递待取 | **全功能 13 个入口集合**：<br>菜鸟/淘宝/京东/多多身份码 +<br>淘宝/京东/多多/抖音/快手/得物/小红书等 9 大查件入口 | [📥 点击下载 `取件快码_二合一.shortcut`](Shortcuts/取件快码_二合一.shortcut) |
| **取件身份码（独立版）** | 一级菜单直接展示 4 项 | 菜鸟、淘宝、京东、拼多多 身份码 | [📥 点击下载 `取件身份码.shortcut`](Shortcuts/取件身份码.shortcut) |
| **快递待取（独立版）** | 一级菜单直接展示 9 项 | 淘宝、京东、多多、抖音、快手、得物、小红书等待取入口 | [📥 点击下载 `快递待取.shortcut`](Shortcuts/快递待取.shortcut) |

### 快捷指令安装与添加到桌面

1. **导入快捷指令**：
   - 使用 Mac 将下载的 `.shortcut` 文件通过 AirDrop 发送到 iPhone，点击 **「添加快捷指令」**。
2. **添加到主屏幕小组件**：
   - 长按 iPhone 桌面空白处，点击左上角 **「+」** 号；
   - 搜索并选择 **「快捷指令」**；
   - 选择 **单个快捷指令（小号）** 添加到桌面；
   - 点击该小组件，绑定为 **「取件快码（二合一）」** 即可！

---

## 📦 IPA 安装方法

> 📥 **最新版本**：[前往 Releases 页面下载 v2.0.0 产物](https://github.com/As-langs/PickupCode-iOS/releases/latest) （提供 `取件快码-2.0.0.ipa` 与 `PickupCode-2.0.0.ipa`）

### 1. TrollStore（巨魔商店，推荐）
- 直接通过 AirDrop、文件或网页分享将 `取件快码-2.0.0.ipa` 传送到手机；
- 在分享菜单中选择 **「TrollStore」** 安装即可永久使用。
- *覆盖更新提示*：覆盖安装后，请在手机后台彻底划掉一次旧进程以加载全新 2.0.0 布局。

### 2. 证书自签名（LCSign / 轻松签 / 全能签 / Sideloadly）
- 导入 `取件快码-2.0.0.ipa`；
- 使用个人证书或企业证书签名后直接安装。

---

## 🛠 源码与工程结构

```text
PickupCode-iOS/
├── PickupCode.xcodeproj          # Xcode 16 项目工程文件
├── PickupCode/
│   ├── App/
│   │   └── PickupCodeApp.swift   # 生命周期、URL Scheme 与 Quick Actions 分发
│   ├── Core/
│   │   ├── Models.swift          # 13 大入口模型定义与官方 Schemes
│   │   ├── JumpManager.swift     # 极速跳转控制器与反馈
│   │   ├── ThemeManager.swift    # 主题模式与 1-3 列网格排布配置
│   │   └── PickupCodeManager.swift # 短信正则解析、取件码本地管理
│   ├── Views/
│   │   ├── ContentView.swift     # 统一网格首页、取件码卡片、编辑模式
│   │   ├── EntryCardView.swift   # 1列大卡片与 2/3 列网格卡片
│   │   ├── PickupCodeSectionView.swift # 取件码粘贴识别与添加弹窗
│   │   ├── SettingsView.swift    # 主题切换、列数切换、版本信息
│   │   ├── PlatformIconView.swift # 高清官方平台图标渲染
│   │   └── ToastView.swift       # 浮动提示组件
│   └── Resources/
│       ├── Info.plist            # Schemes 白名单与 Quick Actions 定义
│       └── Images/               # 官方高清矢量与位图图标
├── PickupCodeWidget/             # iOS 桌面 WidgetKit 小组件扩展
├── Shortcuts/                    # 苹果官方加密签名的 3 款快捷指令
├── build_ipa.sh                  # 自动化编译、签名与打包脚本
├── build_shortcuts.py            # 快捷指令生成与官方签名脚本
└── generate_pbxproj.py           # Xcode 工程配置同步脚本
```
