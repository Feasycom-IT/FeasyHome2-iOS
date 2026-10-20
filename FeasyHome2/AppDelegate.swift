//
//  AppDelegate.swift
//  FeasyHome2
//
//  Created by chenchanghua on 2024/12/23.
//

import UIKit
import os.log
import FeasyMeshSDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var meshNetworkManager: MeshNetworkManager!
    var connection: NetworkConnection!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // 窗口由 SceneDelegate 创建
            
        // 创建一个新的 MeshNetworkManager 实例，并设置其各项定时器和限制参数
        meshNetworkManager = MeshNetworkManager()
        meshNetworkManager.acknowledgmentTimerInterval = 0.150//确认定时器的时间间隔
        meshNetworkManager.transmissionTimerInterval = 0.600//传输定时器的时间间隔
        meshNetworkManager.incompleteMessageTimeout = 10.0//不完整消息的超时时间
        meshNetworkManager.retransmissionLimit = 2//重传次数限制
        meshNetworkManager.acknowledgmentMessageInterval = 4.2//确认消息的时间间隔
        // 由于间隔已增加，可以调整超时。
        // 确认消息将在4.2秒后重复发送，
        // 12.6秒（4.2 + 4.2 * 2），以及29.4秒（4.2 + 4.2 * 2 + 4.2 * 4）。
        // 然后，留出10秒直到不完整的消息超时。
        meshNetworkManager.acknowledgmentMessageTimeout = 40.0//确认消息的超时时间
        meshNetworkManager.logger = self
        
        // 尝试加载已保存的 Mesh 网络配置
        var loaded = false
        do {
            loaded = try meshNetworkManager.load()
        } catch {
            print(error)
            // 忽略错误
        }
        
        // 如果加载失败，则创建一个新的 MeshNetwork
        if !loaded {
            createNewMeshNetwork(withName: "默认家庭")
            
            self.perform(#selector(self.saveKey), with: nil, afterDelay: 1)
            self.perform(#selector(self.saveKey), with: nil, afterDelay: 3)
            sleep(1)
            
            let manager = MeshNetworkManager.instance
            DispatchQueue.global(qos: .userInitiated).async {
                let data = manager.export(.full)
                
                do {
                    let name = manager.meshNetwork?.meshName ?? "mesh"
                    let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(name).json")
                    try data.write(to: fileURL)
                    
                    print(data)
                    print(fileURL)
                    
                    let rooms = ["客厅", "厨房", "卫生间", "走廊", "卧室一", "卧室二", "卧室三", "卧室四"]
                    let rooms_key_name = "RoomNames_" + name
                    
                    UserDefaults.standard.setValue(rooms, forKey: rooms_key_name)
                    UserDefaults.standard.synchronize()
                    
                } catch {
                    print("Export failed: \(error)")
                }
            }
        } else {
            meshNetworkDidChange()
        }
        
        
        return true
    }
    
    // MARK: - UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let config = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        config.delegateClass = SceneDelegate.self
        return config
    }
    
    /// 创建一个具有默认名称和单个 Provisioner 的新的 Mesh 网络。
    /// 完成后，会调用 `meshNetworkDidChange()` 方法。
    func createNewMeshNetwork(withName name: String) {
        // TODO: 实现创建者逻辑
        let provisioner = Provisioner(
            name: UIDevice.current.name,
            allocatedUnicastRange: [AddressRange(0x0001...0x199A)],
            allocatedGroupRange: [AddressRange(0xC000...0xCC9A)],
            allocatedSceneRange: [SceneRange(0x0001...0x3333)]
        )
        _ = meshNetworkManager.createNewMeshNetwork(withName: name, by: provisioner)
        _ = meshNetworkManager.save()
        
        meshNetworkDidChange()
    }
    
    /// 设置本地 Elements 并重新初始化 `NetworkConnection`，以便开始扫描广告新网络 ID 的设备。
    func meshNetworkDidChange() {
        // 关闭现有的网络连接
        connection?.close()
        
        // 获取当前的 Mesh 网络实例
        let meshNetwork = meshNetworkManager.meshNetwork!
        
        // 通用默认过渡时间服务器模型的委托
        let defaultTransitionTimeServerDelegate = GenericDefaultTransitionTimeServerDelegate(meshNetwork)
        
        // 场景服务器和场景设置服务器模型的委托
        let sceneServer = SceneServerDelegate(
            meshNetwork,
            defaultTransitionTimeServer: defaultTransitionTimeServerDelegate
        )
        let sceneSetupServer = SceneSetupServerDelegate(server: sceneServer)
        
        // 设置手机上的本地 Elements
        let element0 = Element(
            name: "Primary Element",
            location: .first,
            models: [
                // 场景服务器和场景设置服务器模型（客户端自动添加）
                Model(sigModelId: .sceneServerModelId, delegate: sceneServer),
                Model(sigModelId: .sceneSetupServerModelId, delegate: sceneSetupServer),
                // 传感器客户端模型
                Model(sigModelId: .sensorClientModelId, delegate: SensorClientDelegate()),
                // 通用电源开关客户端模型
                Model(sigModelId: .genericPowerOnOffClientModelId, delegate: GenericPowerOnOffClientDelegate()),
                // 通用默认过渡时间服务器模型
                Model(
                    sigModelId: .genericDefaultTransitionTimeServerModelId,
                    delegate: defaultTransitionTimeServerDelegate
                ),
                Model(
                    sigModelId: .genericDefaultTransitionTimeClientModelId,
                    delegate: GenericDefaultTransitionTimeClientDelegate()
                ),
                // 由 Bluetooth SIG 定义的 4 个通用模型
                Model(
                    sigModelId: .genericOnOffServerModelId,
                    delegate: GenericOnOffServerDelegate(
                        meshNetwork,
                        defaultTransitionTimeServer: defaultTransitionTimeServerDelegate,
                        elementIndex: 0
                    )
                ),
                Model(
                    sigModelId: .genericLevelServerModelId,
                    delegate: GenericLevelServerDelegate(
                        meshNetwork,
                        defaultTransitionTimeServer: defaultTransitionTimeServerDelegate,
                        elementIndex: 0
                    )
                ),
                Model(sigModelId: .genericOnOffClientModelId, delegate: GenericOnOffClientDelegate()),
                Model(sigModelId: .genericLevelClientModelId, delegate: GenericLevelClientDelegate()),
                // 简单的厂商模型
                Model(
                    vendorModelId: .simpleOnOffModelId,
                    companyId: .nordicSemiconductorCompanyId,
                    delegate: SimpleOnOffClientDelegate()
                )
            ]
        )
        
        let element1 = Element(
            name: "Secondary Element",
            location: .second,
            models: [
                Model(
                    sigModelId: .genericOnOffServerModelId,
                    delegate: GenericOnOffServerDelegate(
                        meshNetwork,
                        defaultTransitionTimeServer: defaultTransitionTimeServerDelegate,
                        elementIndex: 1
                    )
                ),
                Model(
                    sigModelId: .genericLevelServerModelId,
                    delegate: GenericLevelServerDelegate(
                        meshNetwork,
                        defaultTransitionTimeServer: defaultTransitionTimeServerDelegate,
                        elementIndex: 1
                    )
                ),
                Model(sigModelId: .genericOnOffClientModelId, delegate: GenericOnOffClientDelegate()),
                Model(sigModelId: .genericLevelClientModelId, delegate: GenericLevelClientDelegate())
            ]
        )
        
        // 更新 Mesh 网络管理器的本地 Elements
        meshNetworkManager.localElements = [element0, element1]
        
        // 重新初始化网络连接，并设置委托和日志记录器
        connection = NetworkConnection(to: meshNetwork)
        connection!.dataDelegate = meshNetworkManager
        connection!.logger = self
        meshNetworkManager.transmitter = connection
        connection!.open()
    }
    
    
    // 执行两次，绑定时使用lastobject
    @objc func saveKey() {
        let network = MeshNetworkManager.instance.meshNetwork!
        
        let keyIndex: KeyIndex?
        keyIndex = nil
        
//        let newKey: Data! = Data.random128BitKey()
        
        // 西顿的新设备使用固定的AppKey：63 96 47 71 73 4F BD 76 E3 B4 05 19 D1 D9 4A 48
        let b: [UInt8] = [0x63,0x96,0x47,0x71,0x73,0x4F,0xBD,0x76,0xE3,0xB4,0x05,0x19,0xD1,0xD9,0x4A,0x48]
        let d = NSData(bytes: b, length: 16)
        let newKey: Data! = d as Data
        let newName: String! = "App Key \((network.nextAvailableApplicationKeyIndex ?? 0xFFF) + 1)"
        
        _ = try! network.add(applicationKey: newKey, withIndex: keyIndex, name: newName)
        
        if MeshNetworkManager.instance.save() {
            print("SaveAppKey = \(String(describing: newKey.bytes)), name = \(String(describing: newName))")
            print("MeshNetworkManager.instance.save-success")
        } else {
            print("MeshNetworkManager.instance.save-false")
        }
    }
    
}

extension MeshNetworkManager {
    
    static var instance: MeshNetworkManager {
        if Thread.isMainThread {
            return (UIApplication.shared.delegate as! AppDelegate).meshNetworkManager
        } else {
            return DispatchQueue.main.sync {
                return (UIApplication.shared.delegate as! AppDelegate).meshNetworkManager
            }
        }
    }
    
    static var bearer: NetworkConnection! {
        if Thread.isMainThread {
            return (UIApplication.shared.delegate as! AppDelegate).connection
        } else {
            return DispatchQueue.main.sync {
                return (UIApplication.shared.delegate as! AppDelegate).connection
            }
        }
    }
    
}

// MARK: - Logger

extension AppDelegate: LoggerDelegate {
    
    func log(message: String, ofCategory category: LogCategory, withLevel level: LogLevel) {
        if #available(iOS 10.0, *) {
            os_log("%{public}@", log: category.log, type: level.type, message)
        } else {
            NSLog("%@", message)
        }
    }
    
}

extension LogLevel {
    
    /// Mapping from mesh log levels to system log types.
    var type: OSLogType {
        switch self {
        case .debug:       return .debug
        case .verbose:     return .debug
        case .info:        return .info
        case .application: return .default
        case .warning:     return .error
        case .error:       return .fault
        }
    }
    
}

extension LogCategory {
    
    var log: OSLog {
        return OSLog(subsystem: Bundle.main.bundleIdentifier!, category: rawValue)
    }
    
}

