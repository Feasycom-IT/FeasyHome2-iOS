//
//  DeviceControlPanel.swift
//  FeasyHome2
//
//  Created by chenchanghua on 2025/4/15.
//

import SnapKit
import FeasyMeshSDK

class DeviceControlPanel: UIViewController {
    
    var groupName: String?
    var address: String = "00"
    
    var roomList:[Room] = []
    
    private var panelDetailData: PanelDetailData?
    
    // MARK: - UI Components
    private let titleLabel = UILabel()
    private let deleteButton = UIButton(type: .system)
    
    private let bindLabel = UILabel()
    
    private let leftTopButton = UIButton(type: .system)
    private let rightTopButton = UIButton(type: .system)
    private let leftBottomButton = UIButton(type: .system)
    private let rightBottomButton = UIButton(type: .system)
    
    // 当前选中的按钮编号，1~4
    private var selectedButtonIndex: Int = 1
    
    private var selectedLightGroupNum: Int?
    private var selectedCurtainGroupNum: Int?
    private var selectedSceneNum: Int?
    
    // 四个按钮组成数组便于管理
    private var buttonArray: [UIButton] {
        return [leftTopButton, rightTopButton, leftBottomButton, rightBottomButton]
    }
    
    // 灯组
    private let lightGroupSwitch = UISwitch()
    private let lightGroupLabel = UILabel()
    private let lightGroupSelectionView = UIView()
    private let lightGroupSelectionLabel = UILabel()
    private let arrow1 = UIImageView(image: UIImage(systemName: "chevron.right"))
    
    // 第二行 - Curtain Group
    private let curtainGroupSwitch = UISwitch()
    private let curtainGroupLabel = UILabel()
    private let curtainGroupSelectionView = UIView()
    private let curtainGroupSelectionLabel = UILabel()
    private let arrowCurtain = UIImageView(image: UIImage(systemName: "chevron.right"))
    
    private let sceneSwitch = UISwitch()
    private let sceneLabel = UILabel()
    private let sceneSelectionView = UIView()
    private let sceneSelectionLabel = UILabel()
    private let arrow2 = UIImageView(image: UIImage(systemName: "chevron.right"))
    
    // 第四行 - 色温控制
    private let colTemperatureSwitch = UISwitch()
    private let colTemperatureLabel = UILabel()
    
    // 所有互斥的 switch 集合
    private var allSwitches: [UISwitch] {
        return [lightGroupSwitch, curtainGroupSwitch, sceneSwitch, colTemperatureSwitch]
    }
    
    private let unbindButton = UIButton(type: .system)
    private let bindButton = UIButton(type: .system)
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        loadData()
        setupHeader()
        setupPanelButtons()
        setupBindingSection()
        
        panelButtonTapped(leftTopButton) // 默认选中左上按钮
    }
    
    // MARK: - Header Section
    private func loadData() {
        APIManager.shared.fetchPanelDetail(mac: "b4:35:22:66:4c:4e") { [weak self] result in
            switch result {
            case .success(let data):
                self?.panelDetailData = data
                
                print("面板名称：\(data.panel.deviceName)")
                print("布局列表：\(data.layoutList.map { $0.title })")
            case .failure(let error):
                print("请求失败：\(error.localizedDescription)")
            }
        }
    }
    
    private func updatePanelLayout() {
        let request = UpdateLayoutRequest(
            mac: "B4:35:22:66:42:AA",
            familyId: 648,
            roomId: 2101,
            secondType: "8201",
            btnId: 0,
            bindId: "00",
            bindType: "01",
            doType: 1,
            deviceType: "82"
        )
        
        APIManager.shared.updatePanelLayout(request) { result in
            switch result {
            case .success:
                print("操作成功")
            case .failure(let error):
                print("失败：\(error.localizedDescription)")
            }
        }
    }
    
    private func deletePanel() {
        APIManager.shared.deletePanel(mac: "B4:35:22:66:42:AA", familyId: 648, roomId: 2101) { result in
            switch result {
            case .success:
                print("删除成功")
                // 可执行界面刷新或返回操作
            case .failure(let error):
                print("删除失败：\(error.localizedDescription)")
            }
        }
    }
    
    private func setupHeader() {
        titleLabel.text = "控制面板1"
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        view.addSubview(titleLabel)
        
        deleteButton.setTitle("删除", for: .normal)
        deleteButton.setTitleColor(.lightGray, for: .normal)
        view.addSubview(deleteButton)
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            $0.leading.equalToSuperview().offset(16)
        }
        
        deleteButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview().inset(16)
        }
    }
    
    // MARK: - Panel Buttons
    private func setupPanelButtons() {
        let buttonTitles = ["左上", "右上", "左下", "右下"]
        let buttons = [leftTopButton, rightTopButton, leftBottomButton, rightBottomButton]
        
        for (index, button) in buttons.enumerated() {
            button.setTitle(buttonTitles[index], for: .normal)
            button.setImage(UIImage(systemName: "link"), for: .normal)
            button.tintColor = .gray
            button.backgroundColor = .systemGray6
            button.layer.cornerRadius = 8
            button.tag = index + 1  // 标号从 1 开始
            button.addTarget(self, action: #selector(panelButtonTapped(_:)), for: .touchUpInside)
            view.addSubview(button)
        }
        
        // 2x2 grid
        leftTopButton.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(20)
            $0.width.equalTo(rightTopButton)
            $0.height.equalTo(52)
        }
        
        rightTopButton.snp.makeConstraints {
            $0.top.equalTo(leftTopButton)
            $0.leading.equalTo(leftTopButton.snp.trailing).offset(15)
            $0.trailing.equalToSuperview().inset(20)
            $0.width.equalTo(leftTopButton)
            $0.height.equalTo(52)
        }
        
        leftBottomButton.snp.makeConstraints {
            $0.top.equalTo(leftTopButton.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(20)
            $0.width.equalTo(rightBottomButton)
            $0.height.equalTo(52)
        }
        
        rightBottomButton.snp.makeConstraints {
            $0.top.equalTo(rightTopButton.snp.bottom).offset(12)
            $0.leading.equalTo(leftBottomButton.snp.trailing).offset(15)
            $0.trailing.equalToSuperview().inset(20)
            $0.width.equalTo(leftBottomButton)
            $0.height.equalTo(52)
        }
    }
    
    @objc private func panelButtonTapped(_ sender: UIButton) {
        // 更新 UI 状态
        for button in buttonArray {
            if button == sender {
                button.tintColor = .white
                button.backgroundColor = .systemBlue
            } else {
                button.tintColor = .gray
                button.backgroundColor = .systemGray6
            }
        }
        
        // 记录当前选中的按钮编号
        selectedButtonIndex = sender.tag
        
        print("当前选中按钮编号：\(selectedButtonIndex)")
    }
    
    // MARK: - Binding Section
    private func setupBindingSection() {
        bindLabel.text = "选择绑定"
        bindLabel.font = .systemFont(ofSize: 16, weight: .medium)
        view.addSubview(bindLabel)
        
        bindLabel.snp.makeConstraints {
            $0.top.equalTo(leftBottomButton.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(16)
        }
        
        // 设备组一行
        view.addSubview(lightGroupSwitch)
        view.addSubview(lightGroupLabel)
        view.addSubview(lightGroupSelectionView)
        lightGroupSelectionView.addSubview(lightGroupSelectionLabel)
        lightGroupSelectionView.addSubview(arrow1)
        
        lightGroupLabel.text = "灯组"
        lightGroupSelectionLabel.text = "卧室 电视区 筒灯"
        arrow1.tintColor = .lightGray
        
        lightGroupSelectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(logRoomSelection)))
        
        lightGroupSwitch.snp.makeConstraints {
            $0.top.equalTo(bindLabel.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(16)
        }
        
        lightGroupLabel.snp.makeConstraints {
            $0.centerY.equalTo(lightGroupSwitch)
            $0.leading.equalTo(lightGroupSwitch.snp.trailing).offset(8)
        }
        
        lightGroupSelectionView.snp.makeConstraints {
            $0.centerY.equalTo(lightGroupSwitch)
            $0.leading.equalTo(lightGroupLabel.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(40)
        }
        
        lightGroupSelectionLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview()
        }
        
        arrow1.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview()
        }
        
        // 添加 curtain 组 UI
        view.addSubview(curtainGroupSwitch)
        view.addSubview(curtainGroupLabel)
        view.addSubview(curtainGroupSelectionView)
        curtainGroupSelectionView.addSubview(curtainGroupSelectionLabel)
        curtainGroupSelectionView.addSubview(arrowCurtain)
        
        curtainGroupLabel.text = "窗帘组"
        curtainGroupSelectionLabel.text = "未选择"
        arrowCurtain.tintColor = .lightGray
        
        curtainGroupSelectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(logCurtainSelection)))
        
        curtainGroupSwitch.snp.makeConstraints {
            $0.top.equalTo(lightGroupSwitch.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(16)
        }
        
        curtainGroupLabel.snp.makeConstraints {
            $0.centerY.equalTo(curtainGroupSwitch)
            $0.leading.equalTo(curtainGroupSwitch.snp.trailing).offset(8)
        }
        
        curtainGroupSelectionView.snp.makeConstraints {
            $0.centerY.equalTo(curtainGroupSwitch)
            $0.leading.equalTo(curtainGroupLabel.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(40)
        }
        
        curtainGroupSelectionLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview()
        }
        
        arrowCurtain.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview()
        }
        
        // 场景一行
        view.addSubview(sceneSwitch)
        view.addSubview(sceneLabel)
        view.addSubview(sceneSelectionView)
        sceneSelectionView.addSubview(sceneSelectionLabel)
        sceneSelectionView.addSubview(arrow2)
        
        sceneLabel.text = "场景"
        sceneSelectionLabel.text = "选择"
        arrow2.tintColor = .lightGray
        
        sceneSelectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(logSceneSelection)))
        
        sceneSwitch.snp.makeConstraints {
            $0.top.equalTo(curtainGroupSwitch.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(16)
        }
        
        sceneLabel.snp.makeConstraints {
            $0.centerY.equalTo(sceneSwitch)
            $0.leading.equalTo(sceneSwitch.snp.trailing).offset(8)
        }
        
        sceneSelectionView.snp.makeConstraints {
            $0.centerY.equalTo(sceneSwitch)
            $0.leading.equalTo(sceneLabel.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(40)
        }
        
        sceneSelectionLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview()
        }
        
        arrow2.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview()
        }
        
        // 色温
        view.addSubview(colTemperatureSwitch)
        view.addSubview(colTemperatureLabel)
        
        colTemperatureLabel.text = "色温"
        colTemperatureSwitch.addTarget(self, action: #selector(onSwitchChanged(_:)), for: .valueChanged)
        
        colTemperatureSwitch.snp.makeConstraints {
            $0.top.equalTo(sceneSwitch.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(16)
        }
        
        colTemperatureLabel.snp.makeConstraints {
            $0.centerY.equalTo(colTemperatureSwitch)
            $0.leading.equalTo(colTemperatureSwitch.snp.trailing).offset(8)
        }
        
        // 底部按钮
        view.addSubview(unbindButton)
        view.addSubview(bindButton)
        
        unbindButton.setTitle("解绑", for: .normal)
        unbindButton.setImage(UIImage(systemName: "link.slash"), for: .normal)
        unbindButton.tintColor = .systemBlue
        unbindButton.backgroundColor = .systemGray6
        unbindButton.layer.cornerRadius = 8
        unbindButton.addTarget(self, action: #selector(unbindButtonAction), for: .touchUpInside)
        
        bindButton.setTitle("绑定", for: .normal)
        bindButton.setImage(UIImage(systemName: "link"), for: .normal)
        bindButton.tintColor = .systemGray
        bindButton.backgroundColor = .systemGray6
        bindButton.layer.cornerRadius = 8
        bindButton.addTarget(self, action: #selector(bindButtonAction), for: .touchUpInside)
        
        unbindButton.snp.makeConstraints {
            $0.top.equalTo(colTemperatureSwitch.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(16)
            $0.height.equalTo(44)
            $0.trailing.equalTo(view.snp.centerX).offset(-8)
        }
        
        bindButton.snp.makeConstraints {
            $0.top.equalTo(unbindButton)
            $0.trailing.equalToSuperview().inset(16)
            $0.leading.equalTo(view.snp.centerX).offset(8)
            $0.height.equalTo(unbindButton)
        }
        
        // Switch互斥逻辑
        lightGroupSwitch.addTarget(self, action: #selector(onSwitchChanged(_:)), for: .valueChanged)
        sceneSwitch.addTarget(self, action: #selector(onSwitchChanged(_:)), for: .valueChanged)
        curtainGroupSwitch.addTarget(self, action: #selector(onSwitchChanged(_:)), for: .valueChanged)
        colTemperatureSwitch.addTarget(self, action: #selector(onSwitchChanged(_:)), for: .valueChanged)

    }
    
    // MARK: - Actions
    @objc private func onSwitchChanged(_ sender: UISwitch) {
        for toggle in allSwitches {
            toggle.setOn(toggle == sender, animated: true)
        }
    }
    
    @objc private func logRoomSelection() {
        print("点击了设备组右侧的房间选择区域")
        let vc = SelectGroupLightVC()
        vc.roomList = roomList
        vc.onSelectedGroup  = { [weak self] room, lightGroup in
            guard let self = self else { return }
            
            print("room = \(room), lightGroup = \(lightGroup)")
            
            self.selectedLightGroupNum = lightGroup.addressNumber
        }
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: false, completion: nil)
    }
    
    @objc private func logCurtainSelection() {
        print("点击了窗帘组右侧的选择区域")
        let vc = SelectGroupCurtainVC()
        vc.roomList = roomList
        vc.onSelectedGroup  = { [weak self] room, curtainGroup in
            guard let self = self else { return }
            
            print("room = \(room), curtainGroup = \(curtainGroup)")
            
            self.selectedCurtainGroupNum = curtainGroup.addressNumber
        }
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: false, completion: nil)
    }
    
    @objc private func logSceneSelection() {
        print("点击了场景右侧的选择区域")
        let vc = SelectSceneVC()
        vc.onSelectedScene  = { [weak self] scene in
            guard let self = self else { return }
            
            print("scene = \(scene)")
            
            self.selectedSceneNum = Int(scene.sceneCode)
        }
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: false, completion: nil)
    }
    
    @objc private func unbindButtonAction() {
        bindAction(isBinding: false)
    }
    
    @objc private func bindButtonAction() {
        bindAction(isBinding: true)
    }
    
    @objc private func bindAction(isBinding: Bool) {
        if (lightGroupSwitch.isOn) {
            if let opCode = UInt32("F21102", radix: 16) {
                let meshNetwork = MeshNetworkManager.instance.meshNetwork!
                
                // 要绑定的组地址
                let group = String(format: "%02XC0", selectedLightGroupNum ?? 0)
                
                // 要绑定的按键标号
                let keyNum = String(format: "%02X", selectedButtonIndex)
                
                // 要绑定的主设备类型PID
                let pid = String(format: "%02X", 03)
                
                // 绑定/解绑
                let binding = isBinding ? "01" : "00"
                
                // 拼接参数
                let parametersHex = "07" + group + keyNum + pid + binding
                let parameters = Data(hex: parametersHex)
                
                var message = RuntimeVendorMessage(opCode: opCode, parameters: parameters)
                message.isSegmented = false
                message.security = MeshMessageSecurity.low
                
                do {
                    try MeshNetworkManager.instance.send(message, to: MeshAddress(hex: address)!, using: meshNetwork.applicationKeys.last!)
                    print("发送单个设备的开关调整消息，onOff值：\(1)，参数：\(parametersHex)")
                } catch {
                    print("发送消息失败：\(error)")
                }
            }
        } else if (sceneSwitch.isOn) {
            if let opCode = UInt32("F21102", radix: 16) {
                let meshNetwork = MeshNetworkManager.instance.meshNetwork!
                
                // 要绑定的场景号
                let scene = String(format: "%02X", selectedSceneNum ?? 0)
                
                // 要绑定的按键标号
                let keyNum = String(format: "%02X", selectedButtonIndex)
                
                // 绑定/解绑
                let binding = isBinding ? "01" : "00"
                
                // 拼接参数
                let parametersHex = "09" + scene + keyNum + binding
                let parameters = Data(hex: parametersHex)
                
                var message = RuntimeVendorMessage(opCode: opCode, parameters: parameters)
                message.isSegmented = false
                message.security = MeshMessageSecurity.low
                
                do {
                    try MeshNetworkManager.instance.send(message, to: MeshAddress(hex: address)!, using: meshNetwork.applicationKeys.last!)
                    print("发送单个设备的开关调整消息，onOff值：\(1)，参数：\(parametersHex)")
                } catch {
                    print("发送消息失败：\(error)")
                }
            }
        } else if (curtainGroupSwitch.isOn) {
            if let opCode = UInt32("F21102", radix: 16) {
                let meshNetwork = MeshNetworkManager.instance.meshNetwork!
                
                // 要绑定的组地址
                let group = String(format: "%02XC0", selectedCurtainGroupNum ?? 0)
                
                // 要绑定的按键标号
                let keyNum = String(format: "%02X", selectedButtonIndex)
                
                // 要绑定的主设备类型PID
                let pid = String(format: "%02X", 03)
                
                // 绑定/解绑
                let binding = isBinding ? "01" : "00"
                
                // 拼接参数
                let parametersHex = "07" + group + keyNum + pid + binding
                let parameters = Data(hex: parametersHex)
                
                var message = RuntimeVendorMessage(opCode: opCode, parameters: parameters)
                message.isSegmented = false
                message.security = MeshMessageSecurity.low
                
                do {
                    try MeshNetworkManager.instance.send(message, to: MeshAddress(hex: address)!, using: meshNetwork.applicationKeys.last!)
                    print("发送单个设备的开关调整消息，onOff值：\(1)，参数：\(parametersHex)")
                } catch {
                    print("发送消息失败：\(error)")
                }
            }
        } else if (colTemperatureSwitch.isOn) {
            if let opCode = UInt32("F21102", radix: 16) {
                let meshNetwork = MeshNetworkManager.instance.meshNetwork!
                
                // 要绑定的按键标号
                let keyNum = String(format: "%02X", selectedButtonIndex)
                
                // 绑定/解绑
                let binding = isBinding ? "01" : "00"
                
                // 拼接参数
                let parametersHex = "14" + keyNum + binding
                let parameters = Data(hex: parametersHex)
                
                var message = RuntimeVendorMessage(opCode: opCode, parameters: parameters)
                message.isSegmented = false
                message.security = MeshMessageSecurity.low
                
                do {
                    try MeshNetworkManager.instance.send(message, to: MeshAddress(hex: address)!, using: meshNetwork.applicationKeys.last!)
                    print("发送单个设备的开关调整消息，onOff值：\(1)，参数：\(parametersHex)")
                } catch {
                    print("发送消息失败：\(error)")
                }
            }
        }
    }
    
}



