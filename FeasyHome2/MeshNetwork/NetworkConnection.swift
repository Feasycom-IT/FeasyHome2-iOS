/*
* Copyright (c) 2019, Nordic Semiconductor
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without modification,
* are permitted provided that the following conditions are met:
*
* 1. Redistributions of source code must retain the above copyright notice, this
*    list of conditions and the following disclaimer.
*
* 2. Redistributions in binary form must reproduce the above copyright notice, this
*    list of conditions and the following disclaimer in the documentation and/or
*    other materials provided with the distribution.
*
* 3. Neither the name of the copyright holder nor the names of its contributors may
*    be used to endorse or promote products derived from this software without
*    specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
* ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
* IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
* INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
* NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
* PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
* WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
* ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
* POSSIBILITY OF SUCH DAMAGE.
*/

import Foundation
import CoreBluetooth
import FeasyMeshSDK

/// `NetworkConnection` 类负责维护与 Bluetooth Mesh 代理节点的连接。
/// 它在后台扫描，并连接到广播有网络 ID 或节点身份信标的节点。
///
/// `maxConnections` 定义了允许的最大同时连接数。通过连接多个设备，
/// 该对象允许在与其中一个设备的链接丢失时快速切换到另一个代理。
/// 只有第一个设备会接收发送的消息。然而，`dataDelegate` 会接收到来自任何已连接代理的消息。
class NetworkConnection: NSObject, Bearer {
    /// 用于存储连接模式的 UserDefaults 键。
    private let connectionModeKey = "connectionMode"
    
    /// `NetworkConnection` 可以处理的最大连接数。
    /// 设置为 1，即只允许连接一个代理
    /// 实际的连接数量受设备硬件和系统的限制，iOS 设备通常支持 6-8 个并发蓝牙连接
    static let maxConnections = 1
    /// 用于扫描和连接代理的 Bluetooth Central Manager 实例。
    let centralManager: CBCentralManager
    /// 此连接的 Mesh 网络实例。
    let meshNetwork: MeshNetwork
    /// 已连接的 GATT 代理列表。
    var proxies: [GattBearer] = []
    /// 当任何底层 Bearer 打开时，该标志设置为 `true`。
    var isOpen: Bool = false
    
    /// Bearer 状态变化的代理对象。
    weak var delegate: BearerDelegate?
    /// 接收通过 Bearer 接收到的消息的代理对象。
    weak var dataDelegate: BearerDataDelegate?
    /// 日志代理对象。当设置此代理时，所有已连接代理的日志代理也会被更新。
    weak var logger: LoggerDelegate? {
        didSet {
            proxies.forEach {
                $0.logger = logger
            }
        }
    }
    
    /// 此 Bearer 支持的 PDU 类型。
    public var supportedPduTypes: PduTypes {
        return [.networkPdu, .meshBeacon, .proxyConfiguration]
    }
    
    /// 标志指示网络连接是否已启动。
    /// 当启动时，它会扫描范围内的 Mesh 节点并连接到发现的节点。
    private var isStarted: Bool = false
    
    /// 如果至少有一个代理已连接，则返回 `true`，否则返回 `false`。
    var isConnected: Bool {
        return proxies.contains { $0.isOpen }
    }
    /// 返回已连接代理的名称（第一个打开的代理）。
    var name: String? {
        return proxies.first(where: { $0.isOpen })?.name
    }
    /// 指示是否应自动管理与 Mesh 网络的连接。
    /// 如果为 `true`，则自动扫描和连接代理；如果为 `false`，则需要手动管理连接。
    var isConnectionModeAutomatic: Bool {
        get {
            return UserDefaults.standard.bool(forKey: connectionModeKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: connectionModeKey)
            if newValue && isStarted && centralManager.state == .poweredOn {
                centralManager.scanForPeripherals(withServices: [MeshProxyService.uuid], options: nil)
            }
        }
    }
    
    /// 初始化 `NetworkConnection` 实例，并设置 Bluetooth Central Manager 的代理。
    ///
    /// - Parameter meshNetwork: 要关联的 Mesh 网络实例。
    init(to meshNetwork: MeshNetwork) {
        centralManager = CBCentralManager()
        self.meshNetwork = meshNetwork
        super.init()
        centralManager.delegate = self
        
        // 默认情况下，连接模式为自动。
        UserDefaults.standard.register(defaults: [connectionModeKey : true])
    }
    
    /// 打开 Bearer 连接。
    /// 如果连接模式为自动且 Central Manager 已开启，则开始扫描 Mesh 代理设备。
    func open() {
        if !isStarted && isConnectionModeAutomatic &&
           centralManager.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: [MeshProxyService.uuid], options: nil)
        }
        isStarted = true
    }
    
    /// 关闭 Bearer 连接。
    /// 停止扫描，关闭所有已连接的代理，并清空代理列表。
    func close() {
        centralManager.stopScan()
        proxies.forEach { $0.close() }
        proxies.removeAll()
        isStarted = false
    }
    
    /// 断开当前连接的代理（第一个）。
    /// 🤔这个方法有点问题
    func disconnectCurrent() {
        proxies.first?.close()
    }
    
    /// 通过 Bearer 发送数据。
    ///
    /// - Parameters:
    ///   - data: 要发送的数据。
    ///   - type: 数据的 PDU 类型。
    /// - Throws: 如果 PDU 类型不受支持，或 Bearer 未打开，则抛出相应的错误。
    func send(_ data: Data, ofType type: PduType) throws {
        guard supports(type) else {
            throw BearerError.pduTypeNotSupported
        }
        // 查找第一个已连接的代理。可以根据需要修改为查找最接近的代理，或发送给所有已连接的节点。
        // 发送策略：目前代码中只选择第一个处于打开状态的代理进行发送，但在某些应用场景中，你可能希望将数据广播给所有已连接的代理节点，或者根据 RSSI 强度选择信号最强的代理
        // 负载均衡：如果手机同时连接了多个代理节点，可以通过更复杂的逻辑进行负载均衡，例如轮流发送数据给不同的代理，以防止某一个代理节点的通信压力过大
        guard let proxy = proxies.first(where: { $0.isOpen }) else {
            throw BearerError.bearerClosed
        }
        try proxy.send(data, ofType: type)
    }
    
    /// 如果启用了手动连接模式，此方法可以设置将由 Mesh 网络使用的代理。
    ///
    /// - Parameter bearer: 要使用的 GATT Bearer 代理。
    func use(proxy bearer: GattBearer) {
        guard !isConnectionModeAutomatic else {
            return
        }
        
        bearer.delegate = self
        bearer.dataDelegate = self
        bearer.logger = logger
        
        // 关闭所有其他代理，只保留当前代理。
        proxies.filter { bearer.identifier != $0.identifier }.forEach { $0.close() }
        proxies.append(bearer)
        if bearer.isOpen {
            bearerDidOpen(self)
        }
    }
    
}

/// 扩展 `NetworkConnection` 以符合 `CBCentralManagerDelegate` 协议，
/// 负责处理 Bluetooth Central Manager 的委托方法，
/// 如状态更新和外围设备发现。
extension NetworkConnection: CBCentralManagerDelegate {
    
    /// 当 Central Manager 的状态发生变化时调用。
    ///
    /// 根据 Central Manager 的当前状态，执行相应的操作：
    /// - 如果 Bluetooth 已开启且连接模式为自动，并且当前连接数未达到最大值，
    ///   则开始扫描 Mesh 代理设备。
    /// - 如果 Bluetooth 关闭或正在重置，关闭所有已连接的代理并清空代理列表。
    ///
    /// - Parameter central: 当前的 `CBCentralManager` 实例。
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            // Bluetooth 已开启
            if isStarted && isConnectionModeAutomatic &&
               proxies.count < NetworkConnection.maxConnections {
                // 开始扫描具有 MeshProxyService 的外围设备
                central.scanForPeripherals(withServices: [MeshProxyService.uuid], options: nil)
            }
        case .poweredOff, .resetting:
            // Bluetooth 关闭或正在重置，关闭所有代理并清空列表
            proxies.forEach { $0.close() }
            proxies.removeAll()
        default:
            // 其他状态不做处理
            break
        }
    }
    
    /// 当 Central Manager 发现外围设备时调用。
    ///
    /// 处理发现的外围设备，判断其是否为有效的 Mesh 网络代理：
    /// - 检查是否为 Network ID 信标，并验证是否属于当前 Mesh 网络。
    /// - 如果不是 Network ID 信标，则检查是否为 Node Identity 信标，并验证其哈希和随机值是否匹配当前 Mesh 网络。
    /// - 如果外围设备已连接，则忽略。
    /// - 否则，创建一个新的 `GattBearer` 实例，添加到代理列表，设置其委托，并尝试打开连接。
    /// - 如果达到最大连接数，则停止扫描。
    ///
    /// - Parameters:
    ///   - central: 当前的 `CBCentralManager` 实例。
    ///   - peripheral: 发现的 `CBPeripheral` 实例。
    ///   - advertisementData: 包含外围设备广播数据的字典。
    ///   - RSSI: 接收到的信号强度指示值。
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // --------⬇️排查清楚是否属于当前网络
        
        // 尝试从 advertisementData 中获取 networkId，以确定是否有 Network ID 信标
        // networkId 是用来标识当前 Mesh 网络的一个唯一标识符
        if let networkId = advertisementData.networkId {
            // 使用 meshNetwork.matches(networkId:) 检查发现的设备是否属于当前 Mesh 网络
            guard meshNetwork.matches(networkId: networkId) else {
                // 如果不匹配，就直接返回（忽略这个设备）
                return
            }
        } else {
            // 如果没有找到 Network ID 信标，那么会尝试检查是否为 Node Identity 信标
            // 从广播数据中获取 Node Identity 信息
            guard let nodeIdentity = advertisementData.nodeIdentity,
                  // 通过哈希和随机数检查设备是否属于当前 Mesh 网络
                meshNetwork.matches(hash: nodeIdentity.hash, random: nodeIdentity.random) else {
                // 如果既不是 Network ID，也不是当前网络的 Node Identity，则直接返回，忽略这个设备
                return
            }
        }
        
        // --------⬆️排查清楚是否属于当前网络
        
        // 检查 proxies 列表中是否已经包含与该外围设备（通过 identifier 进行匹配）连接的代理
        guard !proxies.contains(where: { $0.identifier == peripheral.identifier }) else {
            // 如果设备已经连接过，就直接返回，避免重复连接
            return
        }
        
        // 创建一个新的 GattBearer 实例来管理与外围设备的连接
        let bearer = GattBearer(target: peripheral)
        // 将新创建的 GattBearer 实例添加到 proxies 列表中，记录当前连接的代理
        proxies.append(bearer)
        // 设置 GattBearer 的代理为 self，意味着 NetworkConnection 将会响应该承载器的状态变化，例如连接成功、连接断开等事件
        bearer.delegate = self
        // 设置 GattBearer 的数据代理为 self，这样 NetworkConnection 可以处理从代理节点接收到的数据
        bearer.dataDelegate = self
        // 设置 GattBearer 的日志记录器为 logger，确保所有日志都能集中记录到统一的位置
        bearer.logger = logger
        // 检查是否已经达到最大允许的连接数
        // 如果是，则停止扫描以防止连接更多的设备，节约资源并避免超出设计容量
        if proxies.count >= NetworkConnection.maxConnections {
            central.stopScan()
        }
        // 打开与这个代理设备的连接，开始实际的通信过程
        // 在 open() 过程中，GattBearer 会尝试连接到目标设备并发现其 GATT 服务，准备数据通信
        bearer.open()
    }
}

/// 扩展 `NetworkConnection` 以符合 `GattBearerDelegate` 和 `BearerDataDelegate` 协议，
/// 负责处理 GATT Bearer 的事件和接收通过 Bearer 的数据。
extension NetworkConnection: GattBearerDelegate, BearerDataDelegate {
    
    /// 当 Bearer 成功连接到外围设备时调用。
    ///
    /// - Parameter bearer: 被连接的 Bearer 实例。
    func bearerDidConnect(_ bearer: Bearer) {
        // 如果 `NetworkConnection` 尚未标记为打开，并且代理符合 `GattBearerDelegate`，
        // 则通知代理 Bearer 已连接。
        if !isOpen, let delegate = delegate as? GattBearerDelegate {
            delegate.bearerDidConnect(bearer)
        }
    }
    
    /// 当 Bearer 发现外围设备的服务时调用。
    ///
    /// - Parameter bearer: 被发现服务的 Bearer 实例。
    func bearerDidDiscoverServices(_ bearer: Bearer) {
        // 如果 `NetworkConnection` 尚未标记为打开，并且代理符合 `GattBearerDelegate`，
        // 则通知代理 Bearer 已发现服务。
        if !isOpen, let delegate = delegate as? GattBearerDelegate {
            delegate.bearerDidDiscoverServices(bearer)
        }
    }
    
    /// 当 Bearer 被成功打开时调用。
    ///
    /// - Parameter bearer: 被打开的 Bearer 实例。
    func bearerDidOpen(_ bearer: Bearer) {
        // 如果 `NetworkConnection` 已经标记为打开，则无需进一步处理。
        guard !isOpen else {
            return
        }
        // 标记 `NetworkConnection` 为已打开。
        isOpen = true
        // 通知代理，Bearer 已打开。
        delegate?.bearerDidOpen(self)
    }
    
    /// 当 Bearer 被关闭时调用。
    ///
    /// - Parameters:
    ///   - bearer: 被关闭的 Bearer 实例。
    ///   - error: 关闭的原因，如果关闭是预期的则为 `nil`，否则包含错误信息。
    func bearer(_ bearer: Bearer, didClose error: Error?) {
        // 查找并移除已关闭的 Bearer。
        if let index = proxies.firstIndex(of: bearer as! GattBearer) {
            proxies.remove(at: index)
        }
        // 如果连接已启动、连接模式为自动，并且当前连接数低于最大连接数，
        // 则继续扫描代理设备。
        if isStarted && isConnectionModeAutomatic &&
           proxies.count < NetworkConnection.maxConnections {
            centralManager.scanForPeripherals(withServices: [MeshProxyService.uuid], options: nil)
        }
        // 如果没有任何代理设备已连接，则标记为未打开，并通知代理 Bearer 已关闭。
        if proxies.isEmpty {
            isOpen = false
            delegate?.bearer(self, didClose: nil)
        }
    }
    
    /// 当 Bearer 接收到数据时调用。
    ///
    /// - Parameters:
    ///   - bearer: 发送数据的 Bearer 实例。
    ///   - data: 接收到的数据。
    ///   - type: 数据的 PDU 类型。
    func bearer(_ bearer: Bearer, didDeliverData data: Data, ofType type: PduType) {
        // 通知 `dataDelegate` 接收到的数据和其类型。
        dataDelegate?.bearer(self, didDeliverData: data, ofType: type)
    }
    
}
