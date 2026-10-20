# FeasyHome2 iOS 工程接入说明

## 文件与架构

- [FeasyMeshSDK.framework](../FeasyHome2/VendorSDK/FeasyMeshSDK.framework)：蓝牙 Mesh SDK，版本 2.2.1，静态 framework。
- framework 只包含真机 arm64，未包含模拟器切片；SDK 实现源码不在本仓库中。
- 公开接口见 framework 内的 `Modules/FeasyMeshSDK.swiftmodule/arm64-apple-ios.swiftinterface`。

## 打开示例工程

使用 Xcode 16 及以上版本打开根目录 `FeasyHome2.xcworkspace`，选择 `FeasyHome2` scheme 和 iPhone 真机。仓库包含 Pods、Podfile 和锁文件，重装依赖时在根目录执行 `pod install`。

主 App target 为 iOS 15，版本 0.0.0.2，构建号 1，Bundle ID `feasycom.com.FeasyHome2`。真机部署前应改用自己的签名团队和可用 Bundle ID。

账号、家庭、房间等功能依赖 `FeasyHome2/APIManager.swift` 中配置的云端接口，需要可用账号与网络。

## 在自己的项目中接入

将 `FeasyMeshSDK.framework` 添加到 App target，并在 Framework Search Paths 中加入其所在目录（可参考示例工程 Build Settings）。framework 为静态库，无需嵌入（Do Not Embed）。在 Info.plist 中配置 `NSBluetoothAlwaysUsageDescription`。

```swift
import FeasyMeshSDK
```

基本流程可参考 `FeasyHome2/AppDelegate.swift` 与 `FeasyHome2/Modules/Device/`：

1. 创建 `MeshNetworkManager`，按需设置定时器与重传参数，调用 `load()` 加载已保存的网络；没有网络时用 `Provisioner` 调用 `createNewMeshNetwork(withName:by:)` 并 `save()`。
2. 设置 `localElements`，注册本地需要的 Mesh 模型代理（示例见 `FeasyHome2/MeshNetwork/`）。
3. 建立 GATT 代理连接作为 bearer（示例 `NetworkConnection.swift`）。
4. 扫描未配网设备后调用 `provision(unprovisionedDevice:over:)` 获得 `ProvisioningManager` 完成配网，OOB 选择参考 `OobSelector.swift`。
5. 使用 `send(_:to:...)` 系列方法发送配置消息与 Generic / Light / Scene / Sensor 等模型消息。

`FSCMeshSDK` 封装了节点、分组、网络密钥、应用密钥和 Provisioner 的常用查询与管理方法。

## 接口参考

- [SDK Swift 接口](../FeasyHome2/VendorSDK/FeasyMeshSDK.framework/Modules/FeasyMeshSDK.swiftmodule)
- [示例 Mesh 模型代理](../FeasyHome2/MeshNetwork)

本文依据已提供的工程与 SDK 接口整理；完整编译和硬件功能测试未在此次仓库整理中执行。
