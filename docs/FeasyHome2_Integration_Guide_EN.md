# FeasyHome2 iOS Integration Guide

## Package

- [`FeasyMeshSDK.framework`](../FeasyHome2/VendorSDK/FeasyMeshSDK.framework) is the Bluetooth Mesh SDK, version 2.2.1, delivered as a static framework.
- The framework contains an arm64 iPhone device slice only. Simulator slices and SDK implementation source are not included.
- The public API is declared in `Modules/FeasyMeshSDK.swiftmodule/arm64-apple-ios.swiftinterface` inside the framework.

## Build the demo

Open `FeasyHome2.xcworkspace` with Xcode 16 or later, select scheme `FeasyHome2` and use a physical iPhone. Pods and the lockfile are included; run `pod install` from the repository root if reinstalling dependencies.

The app target requires iOS 15, version 0.0.0.2, build 1. Its Bundle ID is `feasycom.com.FeasyHome2`. Use your own signing team and an available Bundle ID for device deployment.

Account, home and room features use the cloud API configured in `FeasyHome2/APIManager.swift` and require a valid account and network access.

## Integrate the SDK

Add `FeasyMeshSDK.framework` to your app target and add its folder to Framework Search Paths, using the demo Build Settings as a reference. It is a static framework, so set it to Do Not Embed. Add `NSBluetoothAlwaysUsageDescription` to Info.plist.

```swift
import FeasyMeshSDK
```

The basic flow follows `FeasyHome2/AppDelegate.swift` and `FeasyHome2/Modules/Device/`:

1. Create a `MeshNetworkManager`, tune its timer and retransmission settings, and call `load()`. If no network is stored, create one with a `Provisioner` via `createNewMeshNetwork(withName:by:)` and call `save()`.
2. Set `localElements` and register the local model delegates you need (see `FeasyHome2/MeshNetwork/`).
3. Open a GATT proxy connection as the bearer (see `NetworkConnection.swift`).
4. Scan for unprovisioned devices and call `provision(unprovisionedDevice:over:)` to obtain a `ProvisioningManager`; see `OobSelector.swift` for OOB selection.
5. Use the `send(_:to:...)` methods to send configuration messages and Generic, Light, Scene or Sensor model messages.

`FSCMeshSDK` wraps common queries and management for nodes, groups, network keys, application keys and provisioners.

## Reference

- [SDK Swift interface](../FeasyHome2/VendorSDK/FeasyMeshSDK.framework/Modules/FeasyMeshSDK.swiftmodule)
- [Sample mesh model delegates](../FeasyHome2/MeshNetwork)

This guide is based on the supplied project and SDK interface. The demo passed an unsigned device build; hardware functional tests were not performed during repository packaging.
