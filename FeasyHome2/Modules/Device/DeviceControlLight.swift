//
//  DeviceControlLight.swift
//  FeasyHome2
//
//  Created by chenchanghua on 2024/12/25.
//

import UIKit
import SnapKit
import FeasyMeshSDK

class DeviceControlLight: ProgressVC {
    
    var groupName: String?
    var address: String?
    private var devices: [Device] = []  // 保存设备数据
    private var sections: [Section] = []
    
    // 添加长按手势识别器的代码
    private var longPressGestureRecognizer: UILongPressGestureRecognizer!
    
    // 模拟设备的开关状态：这里使用一个字典来存储设备状态，key 是设备的地址，value 是开关状态（1 或 0）
    var devicePowerStates: [String: Int] = [:]
    
    // MARK: - UI Elements
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "窗帘区 灯带"
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .black
        return label
    }()
    
    private let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("删除", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.setTitleColor(UIColor(red: 0.67, green: 0.67, blue: 0.67, alpha: 1.00), for: .normal)
        return button
    }()
    
    private let deviceCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 60, height: 86)
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    private let groupControlView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: -2)
        view.layer.shadowRadius = 8
        return view
    }()
    
    private let allOnButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "light_icon_on"), for: .normal)
        button.layer.cornerRadius = 30
        button.layer.masksToBounds = true
        button.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.00)
        return button
    }()
    
    private let allOnLabel: UILabel = {
        let label = UILabel()
        label.text = "全开"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor(red: 0.67, green: 0.67, blue: 0.67, alpha: 1.00)
        return label
    }()
    
    private let allOffButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "light_icon_off"), for: .normal)
        button.layer.cornerRadius = 30
        button.layer.masksToBounds = true
        button.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.00)
        return button
    }()
    
    private let allOffLabel: UILabel = {
        let label = UILabel()
        label.text = "全关"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor(red: 0.67, green: 0.67, blue: 0.67, alpha: 1.00)
        return label
    }()
    
    private let refreshButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "light_icon_refresh"), for: .normal)
        button.layer.cornerRadius = 30
        button.layer.masksToBounds = true
        button.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.00)
        return button
    }()
    
    private let refreshLabel: UILabel = {
        let label = UILabel()
        label.text = "刷新"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor(red: 0.67, green: 0.67, blue: 0.67, alpha: 1.00)
        return label
    }()
    
    private let brightnessLabel: UILabel = {
        let label = UILabel()
        label.text = "亮度"
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = .black
        return label
    }()
    
    private let brightnessSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 100
        slider.value = 50
        return slider
    }()
    
    private let brightnessNumLabel: UILabel = {
        let label = UILabel()
        label.text = "50%"
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = .black
        return label
    }()
    
    private let colorTemperatureLabel: UILabel = {
        let label = UILabel()
        label.text = "色温"
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = .black
        return label
    }()
    
    private let colorTemperatureSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 100
        slider.value = 50
        return slider
    }()
    
    private let colorTemperatureNumLabel: UILabel = {
        let label = UILabel()
        label.text = "50%"
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = .black
        return label
    }()
    
    // MARK: - ActionHandle
    
    @objc private func deleteButtonAction() {
        // 假设 devices 是一个设备数组，且已经有值
        if devices.count == 0 {
            // 调用 deleteGroup 方法删除设备组
            APIManager.shared.deleteGroup(familyId: String(kCurrentFamilyID), roomId: String(kCurrentRoomID), address: self.address ?? "00") { result in
                switch result {
                case .success:
                    print("设备组已成功删除")
                case .failure(let error):
                    print("设备组删除失败: \(error.localizedDescription)")
                }
            }
        } else {
            // 弹框提示设备组内有设备未退网，不能删除
            let alert = UIAlertController(title: "无法删除", message: "组内有设备未退网，不能删除该组", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }

    
    @objc private func allOnButtonAction() {
        self.adjustBrightness(to: 100)
    }
    
    @objc private func allOffButtonAction() {
        self.adjustBrightness(to: 0)
    }
    
    @objc private func brightnessSliderValueChanged(_ sender: UISlider) {
        // 获取滑动条的当前值
        let currentValue = Int(sender.value)
        brightnessNumLabel.text = String(currentValue) + "%"
        self.adjustBrightness(to: currentValue)
    }
    
    @objc private func temperatureSliderValueChanged(_ sender: UISlider) {
        // 获取滑动条的当前值
        let currentValue = Int(sender.value)
        colorTemperatureNumLabel.text = String(currentValue) + "%"
        self.adjustTemperature(to: currentValue)
    }
    
    @objc private func adjustBrightness(to brightness: Int) {
        // 检查传入的亮度值范围是否合法
        guard (0...100).contains(brightness) else {
            print("亮度值超出范围，应为 0 到 100")
            return
        }
        
        if let opCode = UInt32("F21102", radix: 16) {
            let meshNetwork = MeshNetworkManager.instance.meshNetwork!
            
            // 将亮度值转换为十六进制字符串
            let brightnessHex = String(format: "%02X", brightness)
            
            // 拼接到参数的末尾
            let parametersHex = "05" + (address ?? "00") + "C002" + brightnessHex
            let parameters = Data(hex: parametersHex)
            
            var message = RuntimeVendorMessage(opCode: opCode, parameters: parameters)
            message.isSegmented = false
            message.security = MeshMessageSecurity.low
            
            do {
                try MeshNetworkManager.instance.send(message, to: MeshAddress(hex: "FFFF")!, using: meshNetwork.applicationKeys.last!)
                print("发送亮度调整消息，亮度值：\(brightness)，参数：\(parametersHex)")
            } catch {
                print("发送消息失败：\(error)")
            }
        }
    }
    
    @objc private func adjustTemperature(to temperature: Int) {
        // 检查传入的色温值范围是否合法
        guard (0...100).contains(temperature) else {
            print("色温值超出范围，应为 0 到 100")
            return
        }
        
        if let opCode = UInt32("F21102", radix: 16) {
            let meshNetwork = MeshNetworkManager.instance.meshNetwork!
            
            // 将色温值转换为十六进制字符串
            let brightnessHex = String(format: "%02X", temperature)
            
            // 拼接到参数的末尾
            let parametersHex = "05" + (address ?? "00") + "C003" + brightnessHex
            let parameters = Data(hex: parametersHex)
            
            var message = RuntimeVendorMessage(opCode: opCode, parameters: parameters)
            message.isSegmented = false
            message.security = MeshMessageSecurity.low
            
            do {
                try MeshNetworkManager.instance.send(message, to: MeshAddress(hex: "FFFF")!, using: meshNetwork.applicationKeys.last!)
                print("发送色温调整消息，色温值：\(temperature)，参数：\(parametersHex)")
            } catch {
                print("发送消息失败：\(error)")
            }
        }
    }
    
    @objc private func adjustPower(to onOff: Int, to deviceAddress: String) {
        if let opCode = UInt32("F21102", radix: 16) {
            let meshNetwork = MeshNetworkManager.instance.meshNetwork!
            
            // 将色温值转换为十六进制字符串
            let brightnessHex = String(format: "%02X", onOff)
            
            // 拼接到参数的末尾
            let parametersHex = "13" + brightnessHex + (address ?? "00")
            let parameters = Data(hex: parametersHex)
            
            var message = RuntimeVendorMessage(opCode: opCode, parameters: parameters)
            message.isSegmented = false
            message.security = MeshMessageSecurity.low
            
            do {
                try MeshNetworkManager.instance.send(message, to: MeshAddress(hex: deviceAddress)!, using: meshNetwork.applicationKeys.last!)
                print("发送单个设备的开关调整消息，onOff值：\(onOff)，参数：\(parametersHex)")
            } catch {
                print("发送消息失败：\(error)")
            }
        }
    }

    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupCollectionView()
        titleLabel.text = groupName ?? ""
        
        // 设置长按手势识别器
        longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        deviceCollectionView.addGestureRecognizer(longPressGestureRecognizer)
        
        deleteButton.addTarget(self, action: #selector(deleteButtonAction), for: .touchUpInside)
        
        allOnButton.addTarget(self, action: #selector(allOnButtonAction), for: .touchUpInside)
        allOffButton.addTarget(self, action: #selector(allOffButtonAction), for: .touchUpInside)
        brightnessSlider.addTarget(self, action: #selector(brightnessSliderValueChanged(_:)), for: .valueChanged)
        colorTemperatureSlider.addTarget(self, action: #selector(temperatureSliderValueChanged(_:)), for: .valueChanged)
        
        self.downloadDeviceList()
    }
    
    private func downloadDeviceList() {
        APIManager.shared.fetchDeviceList(roomId: String(kCurrentRoomID), address: self.address ?? "00") { result in
            switch result {
            case .success(let devices):
                self.devices = devices  // 将设备列表保存到属性中
                DispatchQueue.main.async {
                    self.deviceCollectionView.reloadData()  // 刷新 collectionView
                }
            case .failure(let error):
                // 错误处理
                print("获取设备列表失败: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - 长按手势处理
    
    @objc private func handleLongPress(sender: UILongPressGestureRecognizer) {
        let location = sender.location(in: deviceCollectionView)
        
        // 判断长按的位置是否在某个 item 上
        if sender.state == .began {
            if let indexPath = deviceCollectionView.indexPathForItem(at: location) {
                let selectedDevice = devices[indexPath.item]
                
                // 弹出提示框询问用户是否退网
                let alertContr = UIAlertController(title: "提示", message: "确定重置设备吗？", preferredStyle: .alert)
                
                alertContr.addAction(UIAlertAction(title: "确定", style: .destructive) { clickHandler in
                    let message = ConfigNodeReset()  // 这里使用 ConfigNodeReset 发送退网消息
                    
                    let meshNetwork = MeshNetworkManager.instance.meshNetwork!
                    
                    let nodes = self.sections[0].nodes
                    var currentNode: Node?
                    for node in nodes {
                        if node.unicastAddress == selectedDevice.destination {
                            currentNode = node
                        }
                    }
                    if let node = currentNode {
                        do {
                            try MeshNetworkManager.instance.send(message, to: node)
                            print("发送单个设备退网消息")
                            
                            APIManager.shared.deleteDevice(familyId: String(kCurrentFamilyID), address: self.address ?? "00", mac: selectedDevice.mac) { result in
                                switch result {
                                case .success():
                                    print("Device deleted successfully.")
                                case .failure(let error):
                                    print("Failed to delete device: \(error.localizedDescription)")
                                }
                            }
                            
                            
                        } catch {
                            print("发送消息失败：\(error)")
                        }
                    }
                })
                
                alertContr.addAction(UIAlertAction(title: "取消", style: .cancel) { clickHandler in
                    NSLog("点击了取消")
                })
                
                self.present(alertContr, animated: true, completion: nil)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        MeshNetworkManager.instance.delegate = self
        MeshNetworkManager.instance.proxyFilter.setType(.exclusionList)
        let meshNetwork = MeshNetworkManager.instance.meshNetwork
        navigationItem.title = "照明控制"
        
        self.reloadNodesData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.reloadNodesData()
        }
        
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.00)
        
        // 添加子视图
        view.addSubview(titleLabel)
        view.addSubview(deleteButton)
        view.addSubview(deviceCollectionView)
        view.addSubview(groupControlView)
        
        groupControlView.addSubview(allOnButton)
        groupControlView.addSubview(allOffButton)
        groupControlView.addSubview(refreshButton)
        groupControlView.addSubview(allOnLabel)
        groupControlView.addSubview(allOffLabel)
        groupControlView.addSubview(refreshLabel)
        groupControlView.addSubview(brightnessLabel)
        groupControlView.addSubview(brightnessSlider)
        groupControlView.addSubview(brightnessNumLabel)
        groupControlView.addSubview(colorTemperatureLabel)
        groupControlView.addSubview(colorTemperatureSlider)
        groupControlView.addSubview(colorTemperatureNumLabel)
        
        // 设置约束
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.equalToSuperview().offset(16)
        }
        
        deleteButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        deviceCollectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(240)
        }
        
        groupControlView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(280)
        }
        
        allOnButton.snp.makeConstraints { make in
            make.top.equalTo(groupControlView).offset(24)
            make.leading.equalTo(groupControlView).offset(32)
            make.size.equalTo(CGSize(width: 60, height: 60))
        }
        
        allOnLabel.snp.makeConstraints { make in
            make.top.equalTo(allOnButton.snp.bottom).offset(6)
            make.centerX.equalTo(allOnButton)
        }
        
        allOffButton.snp.makeConstraints { make in
            make.top.equalTo(groupControlView).offset(24)
            make.centerX.equalTo(groupControlView)
            make.size.equalTo(CGSize(width: 60, height: 60))
        }
        
        allOffLabel.snp.makeConstraints { make in
            make.top.equalTo(allOffButton.snp.bottom).offset(6)
            make.centerX.equalTo(allOffButton)
        }
        
        refreshButton.snp.makeConstraints { make in
            make.top.equalTo(groupControlView).offset(24)
            make.trailing.equalTo(groupControlView).offset(-32)
            make.size.equalTo(CGSize(width: 60, height: 60))
        }
        
        refreshLabel.snp.makeConstraints { make in
            make.top.equalTo(refreshButton.snp.bottom).offset(6)
            make.centerX.equalTo(refreshButton)
        }
        
        brightnessLabel.snp.makeConstraints { make in
            make.top.equalTo(refreshLabel.snp.bottom).offset(30)
            make.leading.equalToSuperview().inset(40)
        }
        
        brightnessSlider.snp.makeConstraints { make in
            make.centerY.equalTo(brightnessLabel)
            make.left.equalTo(brightnessLabel.snp.right).offset(8)
        }
        
        brightnessNumLabel.snp.makeConstraints { make in
            make.centerY.equalTo(brightnessLabel)
            make.left.equalTo(brightnessSlider.snp.right).offset(8)
            make.trailing.equalToSuperview().inset(40)
        }
        
        colorTemperatureLabel.snp.makeConstraints { make in
            make.top.equalTo(brightnessLabel.snp.bottom).offset(30)
            make.leading.equalToSuperview().inset(40)
        }
        
        colorTemperatureSlider.snp.makeConstraints { make in
            make.centerY.equalTo(colorTemperatureLabel)
            make.left.equalTo(colorTemperatureLabel.snp.right).offset(8)
        }
        
        colorTemperatureNumLabel.snp.makeConstraints { make in
            make.centerY.equalTo(colorTemperatureLabel)
            make.left.equalTo(colorTemperatureSlider.snp.right).offset(8)
            make.trailing.equalToSuperview().inset(40)
        }
    }
    
    private func setupCollectionView() {
        deviceCollectionView.dataSource = self
        deviceCollectionView.delegate = self
        deviceCollectionView.register(DeviceLightCell.self, forCellWithReuseIdentifier: "DeviceCell")
    }
}

// MARK: - UICollectionView DataSource & Delegate

extension DeviceControlLight: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return devices.count  // 返回设备数组的数量
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DeviceCell", for: indexPath) as! DeviceLightCell
        let device = devices[indexPath.row]  // 获取对应的设备
        
        // 设置设备信息
        cell.configure(with: String(device.destination))  // 使用设备名称或默认值
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let device = devices[indexPath.row]  // 获取对应的设备
        let deviceAddress = String(format: "%04X", device.destination)  // 假设 device 有一个 address 属性
        let currentState = devicePowerStates[deviceAddress] ?? 0  // 获取当前设备的开关状态，默认为 0（关）
        
        // 切换开关状态
        let newState = (currentState == 1) ? 0 : 1  // 如果是 1（开），则切换为 0（关），反之亦然
        
        // 更新设备状态
        devicePowerStates[deviceAddress] = newState
        
        // 调用调节电源的函数
        adjustPower(to: newState, to: deviceAddress)
    }
}


// MARK: - Device Cell

class DeviceLightCell: UICollectionViewCell {
    
    private let bgView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 30
        view.layer.masksToBounds = true
        view.backgroundColor = UIColor(red: 0, green: 0.46, blue: 0.79, alpha: 1.00)
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "dev_search_icon_light"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    var node: Node!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(bgView)
        bgView.addSubview(iconImageView)
        contentView.addSubview(nameLabel)
        
        bgView.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.height.equalTo(60)
        }
        
        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(28)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(bgView.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with name: String) {
        nameLabel.text = name
    }
}

extension DeviceControlLight: ProvisioningViewDelegate {
    
    // 当一个新设备完成provisioned时的回调
    func provisionerDidProvisionNewDevice(_ node: Node) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
}

private extension DeviceControlLight {
    
    func reloadNodesData() {
        sections.removeAll()
        sections = FSCMeshSDK.getAllNodes(forMeshNetwork: MeshNetworkManager.instance.meshNetwork!)
        self.downloadDeviceList()
        
        print("节点数据获取到位:\n" + "\(sections)")
        for currentSection in sections {
            print("==========")
            print(currentSection.type.title ?? "")
            for currentNode in currentSection.nodes {
                print((currentNode.name ?? "") + "  " + currentNode.unicastAddress.asString())
            }
            print("==========")
        }
    }
}

extension DeviceControlLight: MeshNetworkDelegate {
    
    func meshNetworkManager(_ manager: MeshNetworkManager,
                            didReceiveMessage message: MeshMessage,
                            sentFrom source: Address, to destination: Address) {
        
        // Handle the message based on its type.
        switch message {
            
        case is ConfigNodeResetStatus:
            done {
                self.reloadNodesData()
            }
            
        case is ConfigCompositionDataStatus:
            print("获取到 ConfigCompositionDataStatus 信息")
            
        default:
            break
        }
    }
    
    func meshNetworkManager(_ manager: MeshNetworkManager,
                            failedToSendMessage message: MeshMessage,
                            from localElement: Element, to destination: Address,
                            error: Error) {
        done {
            print("Error:" + "\(error.localizedDescription)")
        }
    }
    
}
