//
//  DeviceScanPanelVC.swift
//  FeasyHome2
//
//  Created by chenchanghua on 2025/2/17.
//

import UIKit
import SnapKit
import FeasyMeshSDK
import CoreBluetooth

class DeviceScanPanelVC: UIViewController {
    var currentNode: Node?
    
    private var centralManager: CBCentralManager!
    private var discoveredPeripherals: [DiscoveredPeripheral] = []
    
    private var alert: UIAlertController?
    
    private var selectedDiscoveredPeripheral: DiscoveredPeripheral?
    
    var provisionBtnItem: UIBarButtonItem!
    
    // MARK: - Bluetooth Properties
    var peripheralManager: CBPeripheralManager?
    
    // MARK: - UI 元素
    
    private let deviceInfoBackgroundView: UIView = {
        let bgView = UIView()
        bgView.backgroundColor = .white
        bgView.layer.cornerRadius = 16
        bgView.layer.masksToBounds = true
        return bgView
    }()
    
    /// 设备图片
    private let deviceImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "dev_search_icon_notfound")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    /// 设备名称标签，例如 “调光灯 0X01”
    private let deviceNameLabel: UILabel = {
        let label = UILabel()
        label.text = "未找到设备"
        label.textColor = UIColor(red: 0.67, green: 0.67, blue: 0.67, alpha: 1.00)
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    /// “重新搜索”按钮（带图标）
    private let reSearchButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.setTitle("重新搜索", for: .normal)
        button.tintColor = .black
        button.layer.cornerRadius = 14
        button.layer.masksToBounds = true
        return button
    }()
    
    /// 底部左侧 “搜索” 按钮
    private let bottomSearchButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("搜索", for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.setImage(UIImage(named: "primary_icon_search"), for: .normal)
        button.layer.cornerRadius = 6
        button.layer.masksToBounds = true
        
        let spacing: CGFloat = 8
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: spacing)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: 0)
        return button
    }()
    
    /// 底部右侧 “入网” 按钮
    private let bottomEnrollButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("入网", for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.gray, for: .disabled)
        button.isEnabled = true
        button.layer.cornerRadius = 6
        button.layer.masksToBounds = true
        button.setImage(UIImage(named: "primary_icon_access"), for: .normal)
        
        let spacing: CGFloat = 8
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: spacing)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: 0)
        return button
    }()
    
    @objc func enrollButtonTapped() {
        print("入网按钮被点击了")
        // 在这里处理按钮点击后的逻辑
        self.selectedDiscoveredPeripheral = discoveredPeripherals.last
        
        if self.selectedDiscoveredPeripheral == nil {
            return
        }
        
        let bearer = PBGattBearer(target: self.selectedDiscoveredPeripheral!.peripheral)
        bearer.logger = MeshNetworkManager.instance.logger
        bearer.delegate = self
        
        alert = UIAlertController(title: LS("Status"), message: LS("Connecting..."), preferredStyle: .alert)
        alert!.addAction(UIAlertAction(title: LS("Cancel"), style: .cancel) { [weak self] action in
            action.isEnabled = false
            self?.alert?.title   = LS("Aborting")
            self?.alert?.message = LS("Cancelling connection...")
            bearer.close()
        })
        present(alert!, animated: true) { [self] in
            
            if nil == self.timeout_open {
                self.timeout_open = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(timout_open_action), userInfo: nil, repeats: false)
            }
            // 打开蓝牙通信
            bearer.open()
        }
    }
    
    // 连接超时计时器
    var timeout_open: Timer?
    @objc func timout_open_action() {
        DispatchQueue.main.async {
            let timout_open_Alert = UIAlertController(title: LS("Error"), message: LS("Request timed out."), preferredStyle: .alert)
            timout_open_Alert.addAction(UIAlertAction(title: LS("OK"), style: .cancel) { [weak self] _ in
                self?.selectedDiscoveredPeripheral = nil
                self?.startScanning()
                self?.presentedViewController?.dismiss(animated: true)
                self?.navigationController?.popViewController(animated: true)
            })
            self.presentedViewController?.dismiss(animated: true)
            self.present(timout_open_Alert, animated: true)
        }
    }
    
    static let attentionTimer: UInt8 = 5
    
    // 当一个新设备完成provisioned时的回调
    weak var delegate: ProvisioningViewDelegate?
    // 待配网的设备
    var unprovisionedDevice: UnprovisionedDevice!
    // 配网需要用到的Bearer
    var bearer: ProvisioningBearer!
    // 配网管理器
    private var provisioningManager: ProvisioningManager!
    // 配网需要的参数
    private var publicKey: PublicKey?
    // 配网需要的参数
    private var authenticationMethod: AuthenticationMethod?
    // 配网需要的参数
    private var capabilitiesReceived = false
    // 配网超时
    var timeout_provisioning: Timer?
    // 配置超时
    var timeout_lastConfig: Timer?
    
    deinit {
        print("deinit-DeviceScanViewController")
    }
    
    var deviceConfigurationHandler: DeviceConfigurationHandler?
    
    var waitingAlert: UIAlertController?
    
    @objc func timeout_provisioning_action() {
        DispatchQueue.main.async {
            let timeout_provisioning_Alert = UIAlertController(title: LS("Error"), message: LS("Request timed out."), preferredStyle: .alert)
            timeout_provisioning_Alert.addAction(UIAlertAction(title: LS("OK"), style: .cancel) { [weak self] _ in
                self?.selectedDiscoveredPeripheral = nil
                self?.startScanning()
                self?.presentedViewController?.dismiss(animated: true)
                self?.navigationController?.popViewController(animated: true)
            })
            self.presentedViewController?.dismiss(animated: true)
            self.present(timeout_provisioning_Alert, animated: true)
        }
    }
    
    @objc func timeout_lastConfig_action() {
        DispatchQueue.main.async {
            let timeout_lastConfig_Alert = UIAlertController(title: LS("Error"), message: LS("Request timed out."), preferredStyle: .alert)
            timeout_lastConfig_Alert.addAction(UIAlertAction(title: LS("OK"), style: .cancel) { [weak self] _ in
                self?.selectedDiscoveredPeripheral = nil
                self?.startScanning()
                self?.presentedViewController?.dismiss(animated: true)
                self?.navigationController?.popViewController(animated: true)
            })
            self.presentedViewController?.dismiss(animated: true)
            self.present(timeout_lastConfig_Alert, animated: true)
        }
    }
    
    // MARK: - Button Actions
    
    @objc func bottomSearchButtonTapped(_ sender: UIButton) {
        if centralManager.state == .poweredOn {
            startScanning()
        }
    }
    
    @objc func reSearchButtonTapped(_ sender: UIButton) {
        if centralManager.state == .poweredOn {
            stopSendBLEBroadcast()
            deviceNameLabel.text = "未找到设备"
            deviceNameLabel.textColor = UIColor(red: 0.67, green: 0.67, blue: 0.67, alpha: 1.00)
            deviceImageView.image = UIImage(named: "dev_search_icon_notfound")
            discoveredPeripherals.removeAll()
            startScanning()
        }
    }
    
    @objc func bottomEnrollButtonTapped(_ sender: UIButton) {
        stopSendBLEBroadcast()
        enrollButtonTapped()
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        centralManager = CBCentralManager()
        setupUI()
        setupNavigationContent()
        
        bottomSearchButton.addTarget(self, action: #selector(bottomSearchButtonTapped(_:)), for: .touchUpInside)
        reSearchButton.addTarget(self, action: #selector(reSearchButtonTapped(_:)), for: .touchUpInside)
        bottomEnrollButton.addTarget(self, action: #selector(bottomEnrollButtonTapped(_:)), for: .touchUpInside)
        
        // 初始化 peripheralManager，并设置 delegate
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - 设置界面
    
    func setupNavigationContent() {
        provisionBtnItem = UIBarButtonItem(title: "开始配网", style: .plain, target: self, action: #selector(enrollButtonTapped))
        provisionBtnItem.setTitleTextAttributes([.foregroundColor: UIColor.clear], for: .disabled)
        provisionBtnItem.isEnabled = false  // 使按钮不可交互
        provisionBtnItem.customView?.isHidden = true  // 让按钮隐藏
        
        self.navigationItem.rightBarButtonItems = [provisionBtnItem]
    }
    
    private func setupUI() {
        
        // 1. 配置基本属性
        view.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.00)
        title = "搜索结果"  // 如果使用导航栏
        
        // 2. 将子视图添加到主视图
        view.addSubview(deviceInfoBackgroundView)
        deviceInfoBackgroundView.addSubview(deviceImageView)
        deviceInfoBackgroundView.addSubview(deviceNameLabel)
        view.addSubview(reSearchButton)
        
        view.addSubview(bottomSearchButton)
        view.addSubview(bottomEnrollButton)
        
        // 3. 使用 SnapKit 进行布局
        
        deviceInfoBackgroundView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(160)
        }
        
        deviceImageView.snp.makeConstraints { make in
            make.top.equalTo(deviceInfoBackgroundView.snp.top).offset(32)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(60)
        }
        
        deviceNameLabel.snp.makeConstraints { make in
            make.top.equalTo(deviceImageView.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
        }
        
        reSearchButton.snp.makeConstraints { make in
            make.top.equalTo(deviceInfoBackgroundView.snp.bottom).offset(12)
            make.size.equalTo(CGSize(width: 80, height: 32))
            make.centerX.equalToSuperview()
        }
        
        bottomSearchButton.snp.makeConstraints { make in
            make.left.equalTo(view.snp.left).offset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            make.width.equalTo((view.bounds.width - 40 - 15) / 2)
            make.height.equalTo(50)
        }
        
        bottomEnrollButton.snp.makeConstraints { make in
            make.right.equalTo(view.snp.right).offset(-20)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            make.width.equalTo((view.bounds.width - 40 - 15) / 2)
            make.height.equalTo(50)
        }
    }
    
}

// MARK: - CBCentralManagerDelegate

extension DeviceScanPanelVC: CBCentralManagerDelegate {
    
    private func startScanning() {
        centralManager.delegate = self
        // 开始扫描周围设备
        centralManager.scanForPeripherals(withServices: [MeshProvisioningService.uuid],
                                          options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
    }
    
    private func stopScanning() {
        // 停止扫描周围设备
        centralManager.stopScan()
    }
    
    // 扫描到周围蓝牙设备的回调
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        if peripheral.name == "FSC-WY001" {
            return
        }
        
        print("DeviceScanCurtainVC\n【扫描到有效外设】:\n\(central),\n\(peripheral),\n\(advertisementData),\(RSSI)\n")
        
        if let unprovisionedDevice = UnprovisionedDevice(advertisementData: advertisementData) {
            
            if let manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data {
                // 判断第18位是否是 0xA0（注意：索引是从 0 开始的，所以第18位是索引 17）
                if manufacturerData.count > 28 { // 确保数据长度足够
                    let byteAtIndex18 = manufacturerData[18]
                    let byteAtIndex19 = manufacturerData[19]
                    let byteAtIndex20 = manufacturerData[20]
                    if byteAtIndex18 == 0xA0 && byteAtIndex19 == 0x82 && byteAtIndex20 == 0x01 {
                        print("DeviceScanViewController\n【扫描到有效外设-面板】:\n\(central),\n\(peripheral),\n\(advertisementData),\(RSSI)\n")
                        
                        if let newDevice = parseManufacturerData(manufacturerData, unprovisionedDevice, peripheral, RSSI.intValue) {
                            
                            let text = newDevice.mac + newDevice.companyID + newDevice.devicePID + newDevice.deviceSID + newDevice.workModel + newDevice.moduleVersion + newDevice.reserve
                            print("print = \(text)")
                            
                            // 判断 newDevice 是否已存在于 discoveredPeripherals 中
                            let isDeviceExists = discoveredPeripherals.contains { $0.mac == newDevice.mac }
                            
                            // 如果不存在，添加到 discoveredPeripherals 中
                            if isDeviceExists {
                                print("设备 \(newDevice.mac) 已经存在")
                            } else {
                                
                                self.stopScanning()
                                
                                let text2 = newDevice.mac + "\n" + newDevice.companyID + newDevice.devicePID + newDevice.deviceSID + newDevice.workModel + newDevice.moduleVersion + newDevice.reserve
                                
                                deviceNameLabel.text = text2
                                deviceNameLabel.textColor = .black
                                deviceImageView.image = UIImage(named: "dev_img_light")
                                discoveredPeripherals.append(newDevice)
                                stopSendBLEBroadcast()
                                
                                let macRange = 2..<8  // "f83c 2a3e 7a18" 从第2到第8个字节
                                let macData = manufacturerData.subdata(in: macRange)
                                let macAddress = macData.reversed().map { String(format: "%02x", $0) }.joined(separator: "")
                                sendBLEBroadcast(macAddress)
                            }
                        }
                        
                    } else {
                        // 不是指定的设备
                    }
                } else {
                    print("数据不足28个字节")
                }
            } else {
                print("没有 Manufacturer Data")
            }
            
        }    }
    
    // 中心蓝牙状态发生改变的回调
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state != .poweredOn {
            print("Central is not powered on")
        } else {
        }
    }
    
    func parseManufacturerData(_ manufacturerData: Data, _ unprovisionedDevice: UnprovisionedDevice, _ peripheral: CBPeripheral, _ rssi: Int) -> DiscoveredPeripheral? {
        // 检查 manufacturerData 长度是否符合预期
        guard manufacturerData.count >= 28 else {
            print("数据长度不足，无法解析")
            return nil
        }
        
        // 解析 MAC 地址
        let macRange = 2..<8  // "f83c 2a3e 7a18" 从第2到第8个字节
        let macData = manufacturerData.subdata(in: macRange)
        let macAddress = macData.reversed().map { String(format: "%02x", $0) }.joined(separator: ":") // 格式化为 MAC 地址字符串
        
        // 解析 companyID
        let companyIDRange = 18..<19  // "a0" companyID
        let companyIDData = manufacturerData.subdata(in: companyIDRange)
        let companyID = companyIDData.map { String(format: "%02x", $0) }.joined()  // 转换为字符串
        
        // 解析 devicePID
        let devicePIDRange = 19..<20  // "01" devicePID
        let devicePIDData = manufacturerData.subdata(in: devicePIDRange)
        let devicePID = devicePIDData.map { String(format: "%02x", $0) }.joined()
        
        
        // 解析 deviceSID
        let deviceSIDRange = 20..<21  // "02" deviceSID
        let deviceSIDData = manufacturerData.subdata(in: deviceSIDRange)
        let deviceSID = deviceSIDData.map { String(format: "%02x", $0) }.joined()
        
        // 解析 workModel
        let workModelRange = 21..<22  // "01" workModel
        let workModelData = manufacturerData.subdata(in: workModelRange)
        let workModel = workModelData.map { String(format: "%02x", $0) }.joined()
        
        // 解析 moduleVersion
        let moduleVersionRange = 22..<24  // "0731" moduleVersion
        let moduleVersionData = manufacturerData.subdata(in: moduleVersionRange)
        let moduleVersion = moduleVersionData.map { String(format: "%02x", $0) }.joined()
        
        // 解析 reserve
        let reserveRange = 24..<29  // "00000000 00" reserve
        let reserveData = manufacturerData.subdata(in: reserveRange)
        let reserve = reserveData.map { String(format: "%02x", $0) }.joined()
        
        // 返回 DiscoveredPeripheral 元组
        return (
            device: unprovisionedDevice,
            peripheral: peripheral,
            rssi: rssi,
            mac: macAddress,
            companyID: companyID,
            devicePID: devicePID,
            deviceSID: deviceSID,
            workModel: workModel,
            moduleVersion: moduleVersion,
            reserve: reserve
        )
    }
    
    // 发送 BLE 广播
    private func sendBLEBroadcast(_ macAddress: String) {
        guard let peripheralManager = peripheralManager else { return }
        
        // 如果蓝牙设备未开启，等待直到蓝牙准备好
        if peripheralManager.state != .poweredOn {
            print("蓝牙未开启，无法发送广播")
            return
        }
        
        peripheralManager.stopAdvertising()
        
        // 拼接完整的 UUID 字符串
        // 格式： 68753A44-4D6F-1226-9C60-0050E4C00067
        let fullUUIDString = "00000000-0000-" + formatMACAddress(macAddress) + "fe0211a0"
        let serviceUUID = CBUUID(string: fullUUIDString)
        
        // 广播数据字典
        let advertisementData: [String: Any] = [
            CBAdvertisementDataLocalNameKey: "A01102",  // 设备名称
            CBAdvertisementDataServiceUUIDsKey: [serviceUUID], // 传递数组形式的 UUID
            CBAdvertisementDataIsConnectable: true      // 设置为可连接
        ]
        
        // 开始广播
        peripheralManager.startAdvertising(advertisementData)
        
        print("开始发送广播, onOff = \(advertisementData)")
    }
    
    private func formatMACAddress(_ macAddress: String) -> String {
        // 确保输入的 macAddress 长度为 12
        guard macAddress.count == 12 else {
            print("MAC 地址无效")
            return macAddress
        }
        
        // 将 MAC 地址分成三个部分，并用 "-" 连接
        let part1 = macAddress.prefix(4)
        let part2 = macAddress[macAddress.index(macAddress.startIndex, offsetBy: 4)..<macAddress.index(macAddress.startIndex, offsetBy: 8)]
        let part3 = macAddress.suffix(4)
        
        return "\(part1)-\(part2)-\(part3)"
    }
    
    // 停止发送 BLE 广播
    private func stopSendBLEBroadcast() {
        peripheralManager?.stopAdvertising()
    }
    
}

extension DeviceScanPanelVC: GattBearerDelegate {
    
    /// GATT 设备连接成功的回调。
    ///
    /// - parameter bearer: 连接的 Bearer。
    func bearerDidConnect(_ bearer: Bearer) {
        DispatchQueue.main.async {
            self.alert?.message = LS("Discovering services...")
        }
    }
    
    /// GATT 设备的服务发现完成的回调。
    ///
    /// - parameter bearer: 连接的 Bearer。
    func bearerDidDiscoverServices(_ bearer: Bearer) {
        DispatchQueue.main.async {
            self.alert?.message = LS("Initializing...")
        }
    }
    
    /// Bearer 准备好使用的回调。
    ///
    /// - parameter bearer: 连接的 Bearer。
    func bearerDidOpen(_ bearer: Bearer) {
        print("待入网设备通信通道已经建立")
        
        timeout_open?.invalidate()
        timeout_open = nil
        
        DispatchQueue.main.async {
            self.alert?.dismiss(animated: false) {
                
                /// bear打开后再进行provisioning操作
                self.unprovisionedDevice = self.selectedDiscoveredPeripheral?.device
                self.bearer = bearer as? ProvisioningBearer
                self.selectedDiscoveredPeripheral = nil
                
                
                let manager = MeshNetworkManager.instance
                self.provisioningManager = try! manager.provision(unprovisionedDevice: self.unprovisionedDevice, over: self.bearer)
                self.provisioningManager.delegate = self
                self.provisioningManager.logger = MeshNetworkManager.instance.logger
                
                if self.provisioningManager.networkKey == nil {
                    
                }
                
                do {
                    try self.provisioningManager!.identify(andAttractFor: DeviceScanLightVC.attentionTimer)
                } catch {
                    print("Error:" + "\(error.localizedDescription)")
                }
                
                // 开始provisioning
                self.perform(#selector(self.startProvisioning), with: nil, afterDelay: 1)
                
            }
            self.alert = nil
        }
    }
    
    /// 该方法是配网承载体（Bearer）关闭时的回调
    /// App 需要根据关闭的原因做出响应，比如处理设备断开连接的情况、配网是否完成、以及执行一些清理和错误处理
    ///
    /// - parameters:
    ///   - bearer: 配网过程中与设备通信的承载体
    ///   - error:  表示关闭的原因。如果为 nil，则表示连接正常关闭；如果有值，则表示由于某种错误导致的断开
    func bearer(_ bearer: Bearer, didClose error: Error?) {
        print("待入网设备断开连接")
        
        if error != nil {
            
            // 清理配网过程中用于处理超时的定时器，防止后续因为定时器触发而导致错误
            
            self.timeout_open?.invalidate()
            self.timeout_open = nil
            
            self.timeout_provisioning?.invalidate()
            self.timeout_provisioning = nil
            
            self.timeout_lastConfig?.invalidate()
            self.timeout_lastConfig = nil
            
            // 提示用户蓝牙连接出现断开，并要求用户重试
            let disconnectedAlert = UIAlertController(title: LS("Error"), message: "配网设备的蓝牙连接出现断开，请重试", preferredStyle: .alert)
            disconnectedAlert.addAction(UIAlertAction(title: LS("OK"), style: .cancel) { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            })
            self.presentedViewController?.dismiss(animated: true)
            self.present(disconnectedAlert, animated: true)
            return
            
        }
        
        // 处理配网未完成的断开
        guard case .complete = provisioningManager.state else {
            DispatchQueue.main.async {
                self.alert?.message = LS("Device disconnected")
                self.alert?.dismiss(animated: true)
                self.alert = nil
                // 设置 selectedDiscoveredPeripheral 为 nil，表示当前没有选中的待配网设备
                self.selectedDiscoveredPeripheral = nil
                self.startScanning()
                self.navigationController?.popViewController(animated: true)
            }
            return
        }
        
        print("待入网设备 Provisioning complete.")
        
        // 保存网络配置和设备配置
        if MeshNetworkManager.instance.save() {
            // 关闭当前视图并处理设备配置
            self.dismiss(animated: true) { [weak self] in
                guard let self = self else { return }
                
                let network = MeshNetworkManager.instance.meshNetwork!
                // 获取网络中对应的节点（node），以便进一步进行设备配置
                if let node = network.node(for: self.unprovisionedDevice) {
                    
                    // 如果 timeout_lastConfig 没有被设置，创建一个 30 秒的超时定时器，用于处理设备配置过程中的超时情况
                    if nil == self.timeout_lastConfig {
                        self.timeout_lastConfig = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(self.timeout_lastConfig_action), userInfo: nil, repeats: false)
                    }
                    
                    self.waitingAlert = UIAlertController(title: "为Mesh通讯做最后的部署...", message: "", preferredStyle: .alert)
                    self.present(self.waitingAlert!, animated: true)
                    
                    // 创建 DeviceConfigurationHandler 实例，并将其与当前节点（node）关联
                    self.deviceConfigurationHandler = DeviceConfigurationHandler(withMeshNetworkManager: MeshNetworkManager.instance)
                    self.deviceConfigurationHandler!.node = node
                    self.deviceConfigurationHandler?.delegate = self
                    self.deviceConfigurationHandler!.configurationHandlerBlock = { [weak self] () -> Void in
                        self?.timeout_lastConfig?.invalidate()
                        self?.timeout_lastConfig = nil
                        self?.presentedViewController?.dismiss(animated: true)
                    }
                    //测试
                    
                    // 由于模块需要重启，延迟 3 秒，以便让设备在重启后有足够的时间恢复并准备好接收 Mesh 消息
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
                        print("startConfiguration")
                        self.deviceConfigurationHandler!.startConfiguration()
                    }
                }
            }
        } else {
            self.presentAlert(title: LS("Cancel"), message: LS("Mesh configuration could not be saved."))
        }
        
    }
}

extension DeviceScanPanelVC: ProvisioningDelegate {
    
    
    /// 用于处理设备配网过程中每个状态的变化
    /// 监听和处理配网过程中设备状态的变化。根据设备的配网状态，执行相应的操作和用户界面的更新
    ///
    /// - parameter unprovisionedDevice: 状态已更改的设备。
    /// - parameter state:               已完成的配置状态。
    func provisioningState(of unprovisionedDevice: UnprovisionedDevice, didChangeTo state: ProvisioningState) {
        
        // 由于涉及到 UI 更新，因此需要在主线程中执行
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            switch state {
                
                /*
                 public enum ProvisioningState {
                 /// Provisioning Manager is ready to start.
                 case ready
                 /// The manager is requesting Provisioning Capabilities from the device.
                 case requestingCapabilities
                 /// Provisioning Capabilities were received.
                 case capabilitiesReceived(_ capabilities: ProvisioningCapabilities)
                 /// Provisioning has been started.
                 case provisioning
                 /// The provisioning process is complete.
                 case complete
                 /// The provisioning has failed because of a local error.
                 case fail(_ error: Error)
                 }
                 */
                
                // 请求设备能力 (requestingCapabilities)
            case .requestingCapabilities:
                
                // 当开始请求设备的能力信息时，显示状态对话框 Initializing...，告诉用户正在初始化
                self.presentStatusDialog(message: LS("Initializing..."))
                // 设置配网超时定时器
                if nil == self.timeout_provisioning {
                    self.timeout_provisioning = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.timeout_provisioning_action), userInfo: nil, repeats: false)
                }
                
                // 接收到设备能力 (capabilitiesReceived)
            case .capabilitiesReceived(let capabilities):
                
                // 如果单播地址设置为automatic（nil），那么现在应该将其设置为正确的值，因为我们知道元素的数量。
                // 一旦收到设备的能力信息，设备的元素数量已经确定
                // 检查是否成功为设备分配了有效的单播地址。如果地址无效，则将 unicastAddress 设置为 nil
                let addressValid = self.provisioningManager.isUnicastAddressValid == true
                if !addressValid {
                    self.provisioningManager.unicastAddress = nil
                }
                
                // 将 capabilitiesReceived 设置为 true，表示已经接收到设备能力
                let capabilitiesWereAlreadyReceived = self.capabilitiesReceived
                // 用来标记是否已经收到过设备能力信息。这用于处理设备在某些情况下断开连接后重新连接的情况
                self.capabilitiesReceived = true
                // 检查当前设备是否受支持
                let deviceSupported = self.provisioningManager.isDeviceSupported == true
                // 关闭状态对话框并进一步处理
                self.dismissStatusDialog {
                    
                    if deviceSupported && addressValid {
                        // 如果设备之前已经断开且重连，此时直接调用 startProvisioning() 继续配网
                        if capabilitiesWereAlreadyReceived {
                            self.startProvisioning()
                        }
                    } else {
                        if !deviceSupported {
                            // 如果设备不受支持，显示错误提示：“Selected device is not supported.”
                            self.presentAlert(title: LS("Error"), message: LS("Selected device is not supported."))
                        } else if !addressValid {
                            // 如果单播地址无效，显示错误提示：“No available Unicast Address in Provisioner's range.”
                            self.presentAlert(title: LS("Error"), message: LS("No available Unicast Address in Provisioner's range."))
                        }
                    }
                }
                
                // 配网完成 (complete)
            case .complete:
                // 配网完成后，取消并释放配网的超时定时器
                self.timeout_provisioning?.invalidate()
                self.timeout_provisioning = nil
                // 配网完成后，调用 bearer.close() 断开与设备的连接
                self.bearer.close()
                // 显示状态对话框 Disconnecting...，提示用户设备正在断开连接
                self.presentStatusDialog(message: LS("Disconnecting..."))
                
            case let .fail(error):
                self.dismissStatusDialog {
                    self.presentAlert(title: LS("Error"), message: LS(error.localizedDescription))
                    // 调用 abort() 方法中止配网过程，清理相关状态
                    self.abort()
                }
                
            default:
                break
            }
        }
    }
    
    func authenticationActionRequired(_ action: AuthAction) {
        switch action {
        case let .provideStaticKey(callback: callback):
            self.dismissStatusDialog {
                let message = "Enter 16-character hexadecimal string."
                self.presentTextAlert(title: "Static OOB Key", message: message,
                                      type: .keyRequired, cancelHandler: nil) { hex in
                    callback(Data(hex: hex))
                }
            }
        case let .provideNumeric(maximumNumberOfDigits: _, outputAction: action, callback: callback):
            self.dismissStatusDialog {
                var message: String
                switch action {
                case .blink:
                    message = "Enter number of blinks."
                case .beep:
                    message = "Enter number of beeps."
                case .vibrate:
                    message = "Enter number of vibrations."
                case .outputNumeric:
                    message = "Enter the number displayed on the device."
                default:
                    message = "Action \(action) is not supported."
                }
                self.presentTextAlert(title: "Authentication", message: message,
                                      type: .unsignedNumberRequired, cancelHandler: nil) { text in
                    callback(UInt(text)!)
                }
            }
        case let .provideAlphanumeric(maximumNumberOfCharacters: _, callback: callback):
            self.dismissStatusDialog {
                let message = "Enter the text displayed on the device."
                self.presentTextAlert(title: "Authentication", message: message,
                                      type: .nameRequired, cancelHandler: nil) { text in
                    callback(text)
                }
            }
        case let .displayAlphanumeric(text):
            self.presentStatusDialog(message: "Enter the following text on your device:\n\n\(text)")
        case let .displayNumber(value, inputAction: action):
            self.presentStatusDialog(message: "Perform \(action) \(value) times on your device.")
        @unknown default:
            fatalError()
        }
    }
    
    func inputComplete() {
        self.presentStatusDialog(message: LS("Provisioning..."))
    }
    
}

private extension DeviceScanPanelVC {
    func presentStatusDialog(message: String, animated flag: Bool = true, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let alert = self.alert {
                alert.message = message
                completion?()
            } else {
                self.alert = UIAlertController(title: LS("Status"), message: message, preferredStyle: .alert)
                self.alert!.addAction(UIAlertAction(title: LS("Cancel"), style: .cancel) { action in
                    action.isEnabled = false
                    self.abort()
                })
                self.present(self.alert!, animated: flag, completion: completion)
            }
        }
    }
    
    func dismissStatusDialog(completion: (() -> Void)? = nil) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let alert = self.alert {
                alert.dismiss(animated: true, completion: completion)
            } else {
                completion?()
            }
            self.alert = nil
        }
    }
    
    func abort() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.alert?.title   = LS("Aborting")
            self.alert?.message = LS("Cancelling connection...")
            
            /// 取消provision 记得断开蓝牙连接
            
            self.bearer.close()
        }
    }
    
}

private extension DeviceScanPanelVC {
    
    /// This method tries to open the bearer had it been closed when on this screen.
    func openBearer() {
        presentStatusDialog(message: LS("Connecting...")) {
            self.bearer.open()
        }
    }
    
    /// 开始对未配置设备进行配网操作，将其加入到现有的 Mesh 网络中
    /// 关键步骤：设备能力检查、公钥读取、认证方法选择、网络密钥分配、正式启动配网
    @objc func startProvisioning() {
        // 用于获取设备的能力信息，它描述了设备支持的配网能力
        guard let capabilities = provisioningManager.provisioningCapabilities else {
            return
        }
        
        // 如果设备的公钥在OOB中可用，则应读取它。
        // capabilities.publicKeyType 表示设备支持的公钥类型（例如 noOob 或 oob）。如果该字段为空，表示设备不需要外部的 OOB 公钥
        let publicKeyNotAvailable = capabilities.publicKeyType.isEmpty
        guard publicKeyNotAvailable || publicKey != nil else {
            // 如果 publicKeyNotAvailable 为 false，并且 publicKey 为 nil，这意味着设备支持 OOB 公钥，但目前还没有设置公钥。
            // 这种情况下，会显示一个对话框 presentOobPublicKeyDialog，让用户输入设备的 OOB 公钥。获取到公钥之后，会递归调用 startProvisioning()，继续执行配网过程
            presentOobPublicKeyDialog(for: unprovisionedDevice) { publicKey in
                self.publicKey = publicKey
                self.startProvisioning()
            }
            return
        }
        // 如果没有设置外部公钥（publicKey 为 nil），则默认设置为 .noOobPublicKey，表示不使用外部公钥，而是依赖内部生成的公钥
        publicKey = publicKey ?? .noOobPublicKey
        
        // 如果支持任何OOB方法，则应选择
        
        // Static OOB：设备可能支持使用一个静态 OOB 值进行认证（通常是一个预共享的静态密码）
        let staticOobNotSupported = capabilities.staticOobType.isEmpty
        // Output OOB：设备可以显示一些信息，例如数字或符号，用户需要将这些输入到配网器中（比如 LED 显示某个数字）
        let outputOobNotSupported = capabilities.outputOobActions.isEmpty
        // Input OOB：设备可能要求用户输入一些信息，例如从 App 中输入到设备中（例如设备上有按键）
        let inputOobNotSupported  = capabilities.inputOobActions.isEmpty
        // 如果 staticOobType、outputOobActions、inputOobActions 全为空，说明设备不支持任何 OOB 认证方法
        guard (staticOobNotSupported && outputOobNotSupported && inputOobNotSupported) || authenticationMethod != nil else {
            // 如果设备支持 OOB 认证方法且当前没有设置 authenticationMethod，则需要用户选择一个认证方法，显示 presentOobOptionsDialog 对话框来让用户选择适当的认证方法
            presentOobOptionsDialog(for: provisioningManager, from: provisionBtnItem) { [weak self] method in
                guard let self = self else { return }
                self.authenticationMethod = method
                self.startProvisioning()
            }
            return
        }
        // 如果设备不支持任何 OOB 方法，且当前没有设置认证方法，则将 authenticationMethod 设置为 .noOob，即不使用 OOB 认证
        if authenticationMethod == nil {
            authenticationMethod = .noOob
        }
        
        /**
         网络密钥是加入 Mesh 网络所必需的一个安全密钥，用于加密和认证设备之间的通信。
         如果 provisioningManager 中还没有网络密钥（即还没有设置网络密钥），则为其分配一个新的网络密钥。
         使用 Data.random128BitKey() 生成一个随机的 128 位密钥，并为网络添加该密钥。
         将生成的密钥赋值给 provisioningManager.networkKey，这确保设备在加入网络时使用这个密钥进行通信。
         */
        if provisioningManager.networkKey == nil {
            let network = MeshNetworkManager.instance.meshNetwork!
            let networkKey = try! network.add(networkKey: Data.random128BitKey(), name: LS("Primary Network Key"))
            provisioningManager.networkKey = networkKey
        }
        
        // 启动配网过程
        presentStatusDialog(message: LS("Provisioning...")) {
            do {
                // 正式启动配网过程，配置过程需要指定加密算法、公钥、以及认证方法
                // .fipsP256EllipticCurve：使用 FIPS P-256 椭圆曲线加密算法，这是 Bluetooth Mesh 规定的标准算法之一，用于确保通信的安全性
                try self.provisioningManager.provision(usingAlgorithm:       .fipsP256EllipticCurve,
                                                       publicKey:            self.publicKey!,
                                                       authenticationMethod: self.authenticationMethod!)
            } catch {
                self.abort()
                self.presentAlert(title: LS("Error"), message: LS(error.localizedDescription))
            }
        }
    }
    
}

extension DeviceScanPanelVC: OobSelector {
    
}

extension DeviceScanPanelVC: ProvisioningViewDelegate {
    
    // 当一个新设备完成provisioned时的回调
    func provisionerDidProvisionNewDevice(_ node: Node) {
        
        currentNode = node
        
        if let p = self.discoveredPeripherals.last { 
            APIManager.shared.createPanel(familyId: String(kCurrentFamilyID), roomId: String(kCurrentRoomID), mac: p.mac, deviceType: p.devicePID, secondType: p.devicePID + p.deviceSID, destination: String(node.unicastAddress)) { result in
                switch result {
                case .success:
                    print("添加面板模块成功")
                case .failure(let error):
                    print("失败：\(error)")
                }
            }
        }
        
        self.navigationController?.popViewController(animated: true)
    }
}

extension DeviceScanPanelVC: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state != .poweredOn {
            print("蓝牙未打开")
            return
        }
    }
}
