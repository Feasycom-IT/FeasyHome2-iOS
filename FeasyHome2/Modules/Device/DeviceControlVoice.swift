//
//  DeviceControlVoice.swift
//  FeasyHome2
//
//  Created by chenchanghua on 2025/4/11.
//

import UIKit
import SnapKit
import FeasyMeshSDK

class DeviceControlVoice: ProgressVC {

    var device: DeviceTuple?
    
    private var lightTableDataMap: [Int: [Int: String]] = [:]
    private var curtainTableDataMap: [Int: [Int: String]] = [:]
    
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
        label.text = "语音设备"
        label.textColor = UIColor(red: 0.67, green: 0.67, blue: 0.67, alpha: 1.00)
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    /// 底部左侧 “搜索” 按钮
    private let bottomSearchButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("同步语料", for: .normal)
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
        button.setTitle("退网", for: .normal)
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
    
    deinit {
        print("deinit-DeviceScanViewController")
    }
    
    // MARK: - Button Actions
    
    @objc func bottomSearchButtonTapped(_ sender: UIButton) {
        sendSyncMessageSequence(index: 0)
    }
    
    private func sendSyncMessageSequence(index i: Int) {
        guard i <= 32 else {
            print("✅ 所有消息发送完成")
            return
        }
        
        let iHex = String(format: "%02X", i)
        var payloadArray = Array(repeating: "FF", count: 16)
        
        // light table
        if let map = self.lightTableDataMap[i] {
            for (pos, val) in map where pos < 16 {
                payloadArray[pos] = val
            }
        }
        
        // curtain table（仅在 i == 32 时用）
        if i == 32, let map = self.curtainTableDataMap[0] {
            for (pos, val) in map where pos < 16 {
                payloadArray[pos] = val
            }
        }
        
        // 构建 1A 参数 String(kCurrentRoomCode, radix: 16)
        // String(format: "%02X", kCurrentRoomCode)
        let parametersHex1A = i == 32
        ? "1A40" + String(format: "%02X", kCurrentRoomCode) + payloadArray.joined()
        : "1A" + iHex + String(format: "%02X", kCurrentRoomCode) + payloadArray.joined()
        
        // 构建 1B 参数
        let parametersHex1B = i == 32 ? "1B" + String(format: "%02X", kCurrentRoomCode) + "40" : "1B" + String(format: "%02X", kCurrentRoomCode) + iHex
        
        // Step 1: 发 1A
        self.sendVendorMessage(opCodeHex: "F21102", parametersHex: parametersHex1A, logPrefix: "发送1A消息", index: i)
        
        // Step 2: 延迟 0.5 秒发 1B
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.sendVendorMessage(opCodeHex: "F21102", parametersHex: parametersHex1B, logPrefix: "发送1B消息", index: i)
            
            // Step 3: 再延迟 0.5 秒，递归发下一组
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.sendSyncMessageSequence(index: i + 1)
            }
        }
    }


    
    private func sendVendorMessage(opCodeHex: String, parametersHex: String, logPrefix: String, index: Int) {
        guard let opCode = UInt32(opCodeHex, radix: 16),
              let d = self.device else {
            print("\(logPrefix)：参数无效")
            return
        }
        
        let parameters = Data(hex: parametersHex)
        
        var message = RuntimeVendorMessage(opCode: opCode, parameters: parameters)
        message.isSegmented = false
        message.security = .low
        
        do {
            let meshNetwork = MeshNetworkManager.instance.meshNetwork!
            try MeshNetworkManager.instance.send(message, to: MeshAddress(hex: self.padLeftToFour(d.address))!, using: meshNetwork.applicationKeys.last!)
            print("\(logPrefix)：i=\(index)，参数: \(parametersHex)")
        } catch {
            print("\(logPrefix)：发送失败，i=\(index)")
        }
    }

    
    func padLeftToFour(_ input: String) -> String {
        let padded = String(repeating: "0", count: max(0, 4 - input.count)) + input
        return String(padded.suffix(4))  // 保证最终长度不超过 4（保险处理）
    }
    
    @objc func bottomEnrollButtonTapped(_ sender: UIButton) {
        let message = ConfigNodeReset()  // 这里使用 ConfigNodeReset 发送退网消息
        
        guard let d = self.device else { return }
        
        let sections = FSCMeshSDK.getAllNodes(forMeshNetwork: MeshNetworkManager.instance.meshNetwork!)
        let nodes = sections[0].nodes
        var currentNode: Node?
        for node in nodes {
            if node.unicastAddress == Int16(d.address, radix: 16)! {
                currentNode = node
            }
        }
        if let node = currentNode {
            do {
                try MeshNetworkManager.instance.send(message, to: node)
                print("发送单个设备退网消息")
                
                APIManager.shared.deleteVoiceBox(familyId: String(kCurrentFamilyID), mac: "c4:d8:c8:81:2e:f6") { result in
                    switch result {
                    case .success:
                        print("删除语音盒成功")
                    case .failure(let error):
                        print("删除语音盒失败：\(error)")
                    }
                }
                
                
                
            } catch {
                print("发送消息失败：\(error)")
            }
        }
        
        
        
        
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        
        bottomSearchButton.addTarget(self, action: #selector(bottomSearchButtonTapped(_:)), for: .touchUpInside)
        bottomEnrollButton.addTarget(self, action: #selector(bottomEnrollButtonTapped(_:)), for: .touchUpInside)
        
        APIManager.shared.fetchVoiceLightTable(mac: "c4:d8:c8:81:2e:f6") { result in
            if case .success(let data) = result {
                self.lightTableDataMap = self.parseTableData(data.tableData)
            }
        }
        
        APIManager.shared.fetchVoiceCurtainTable(mac: "c4:d8:c8:81:2e:f6") { result in
            if case .success(let data) = result {
                self.curtainTableDataMap = self.parseTableData(data.tableData)
            }
        }
        
    }
    
    private func parseTableData(_ tableData: String?) -> [Int: [Int: String]] {
        var result: [Int: [Int: String]] = [:]
        guard let tableData = tableData else { return result }
        let entries = tableData.split(separator: ",")
        for entry in entries {
            let parts = entry.split(separator: ":")
            if parts.count == 3,
               let index = Int(parts[0]),
               let pos = Int(parts[1]) {
                let value = String(parts[2]).uppercased()
                if result[index] == nil {
                    result[index] = [:]
                }
                result[index]?[pos] = value
            }
        }
        return result
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - 设置界面
    
    private func setupUI() {
        
        // 1. 配置基本属性
        view.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.00)
        title = "搜索结果"  // 如果使用导航栏
        
        // 2. 将子视图添加到主视图
        view.addSubview(deviceInfoBackgroundView)
        deviceInfoBackgroundView.addSubview(deviceImageView)
        deviceInfoBackgroundView.addSubview(deviceNameLabel)
        
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
