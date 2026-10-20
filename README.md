# FeasyHome2 iOS App（SDK + Demo）

FeasyHome2 是基于蓝牙 Mesh 的智能家居 App，支持设备扫描与配网、灯光 / 窗帘 / 面板 / 语音设备控制、分组、场景、家庭与房间管理。本仓库提供 **应用层源码、预编译 FeasyMeshSDK、Xcode 工程及中英文接入说明**。

SDK 以 framework 形式交付，不包含 SDK 实现源码。

> FeasyHome2 iOS application source with the prebuilt FeasyMeshSDK framework, an Xcode workspace and Chinese/English integration guides.

## 1. 下载 / Download

- [浏览应用源码](FeasyHome2)
- [浏览 FeasyMeshSDK](FeasyHome2/VendorSDK/FeasyMeshSDK.framework)

```bash
git clone https://github.com/Feasycom-IT/FeasyHome2-iOS.git
```

本仓库为私有仓库，克隆前需要有仓库访问权限。

## 2. 引入 SDK / Add the SDK

```text
FeasyHome2/VendorSDK/
└── FeasyMeshSDK.framework/
    ├── FeasyMeshSDK              # 静态库二进制
    ├── Headers/FeasyMeshSDK-Swift.h
    └── Modules/                  # Swift module 与 swiftinterface
```

`FeasyMeshSDK.framework` 版本 `2.2.1`，为 **iPhone 真机 arm64 静态 framework**（Swift 6.0.2 编译，开启 library evolution，最低 iOS 11）。不包含模拟器架构，不支持直接构建模拟器目标。

Swift 引入：

```swift
import FeasyMeshSDK
```

具体 API 以 framework 内的 `.swiftinterface` 为准。

## 3. 打开与编译 / Build

使用 macOS 和 Xcode 16 及以上版本（工程使用文件夹同步格式），打开 workspace：

```bash
open FeasyHome2.xcworkspace
```

- Scheme：`FeasyHome2`。
- 主 App target 最低系统：iOS 15。
- 应用版本：`0.0.0.2`；构建号：`1`。
- Bundle ID：`feasycom.com.FeasyHome2`。
- 语言：Swift 5 / UIKit；界面支持中文和英文。
- 第三方库：SnapKit、Alamofire、SDWebImage（CocoaPods）。仓库包含 Pods 与 `Podfile.lock`；需要重装时在根目录运行 `pod install`。
- 真机运行前选择自己的开发团队和可用的 Bundle ID，并按业务确认蓝牙、相机、相册等权限说明。
- 账号、家庭、房间等云端功能请求 `https://api.feasycom.com/feasyhome`（见 `FeasyHome2/APIManager.swift`），需要可用的账号与网络。

不签名的真机目标构建命令：

```bash
xcodebuild -workspace FeasyHome2.xcworkspace -scheme FeasyHome2 \
  -configuration Debug -destination 'generic/platform=iOS' \
  CODE_SIGNING_ALLOWED=NO build
```

本次仓库整理验证了文件结构、SDK 架构和工程识别；未完成 App 编译或真机功能验收。

## 4. 文档 / Documents

- [中文工程接入说明](docs/FeasyHome2_Integration_Guide_CN.md)
- [English integration guide](docs/FeasyHome2_Integration_Guide_EN.md)
- [SDK Swift 接口](FeasyHome2/VendorSDK/FeasyMeshSDK.framework/Modules/FeasyMeshSDK.swiftmodule)

## 5. 目录结构 / Layout

```text
.
├── FeasyHome2/                 # App 源码与资源
│   ├── VendorSDK/              # FeasyMeshSDK.framework
│   ├── MeshNetwork/            # Mesh 模型代理与自定义消息
│   ├── Modules/                # Device、Scene、User、Login 功能模块
│   ├── Global/                 # 全局宏与中英文本地化
│   ├── Utils/                  # 工具扩展、日志导出、取色器
│   └── APIManager.swift        # 云端接口
├── FeasyHome2.xcodeproj/
├── FeasyHome2.xcworkspace/
├── Pods/
├── Podfile
├── Podfile.lock
├── docs/
└── README.md
```

## 6. 说明 / Notes

- 设备配网、控制、分组和场景需要匹配的 Mesh 设备与固件。
- Mesh 网络数据保存在本机；卸载 App 会丢失本地网络配置，请按业务做好导出与备份。
