//
//  DeviceAdditionViewController.swift
//  FeasyHome2
//
//  Created by chenchanghua on 2024/12/23.
//

import UIKit
import CoreBluetooth

class DeviceAdditionViewController: UIViewController {
    
    // MARK: - Properties
    var testSwitch: UISwitch!
    var nextButton: UIButton!
    var selectedButton: UIButton? // 用于记录当前选中的按钮
    let buttonTitles = ["照明", "面板", "窗帘", "语音"]
    
    var currentUUIDPart: UInt16 = 0x0001 // 初始 UUID 部分值
    
    // MARK: - Bluetooth Properties
    var peripheralManager: CBPeripheralManager?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        setupUI()
        
        // 初始化 peripheralManager，并设置 delegate
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopSendBLEBroadcast()
    }
    
    // 将十六进制字符串转换为 Data
    func hexStringToData(_ hex: String) -> Data? {
        var data = Data()
        var tempHex = hex
        // 确保字符串的长度是偶数
        if tempHex.count % 2 != 0 {
            tempHex = "0" + tempHex
        }
        // 遍历字符串，每两位转换为一个字节
        for i in stride(from: 0, to: tempHex.count, by: 2) {
            let startIndex = tempHex.index(tempHex.startIndex, offsetBy: i)
            let endIndex = tempHex.index(startIndex, offsetBy: 2)
            let byteString = String(tempHex[startIndex..<endIndex])
            if let byte = UInt8(byteString, radix: 16) {
                data.append(byte)
            } else {
                print("转换失败: \(byteString)")
                return nil
            }
        }
        return data
    }
    
    // MARK: - UI Setup
    func setupUI() {
        view.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.00)
        
        title = "添加设备"
        
        // 添加"选择设备类型"标签
        let subtitleLabel = UILabel()
        subtitleLabel.text = "选择设备类型"
        subtitleLabel.textAlignment = .center
        subtitleLabel.font = UIFont.systemFont(ofSize: 17)
        subtitleLabel.textColor = .black
        view.addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints { make in
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.top.equalTo(view.snp.top).offset(kNavBar_Height + 20)
            make.height.equalTo(20)
        }
        
//        // 按钮宽度和间距
//        let buttonWidth: CGFloat = (view.frame.size.width - 40 - 45) / 4
//        let buttonHeight: CGFloat = 100
//        let spacing: CGFloat = 15
//        
//        // 创建按钮
//        let buttonImages = ["dev_img_light", "dev_search_icon_panel", "dev_img_curtain", "dev_search_icon_audio"] // 替换为您自己的图片资源
//        
//        for i in 0..<buttonTitles.count {
//            let button = UIButton(type: .custom)
//            button.translatesAutoresizingMaskIntoConstraints = false
//            button.setImage(UIImage(named: buttonImages[i]), for: .normal)
//            button.setTitle(buttonTitles[i], for: .normal)
//            button.setTitleColor(.black, for: .normal)
//            button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
//            
//            button.tag = i + 1 // 为每个按钮设置标签
//            button.addTarget(self, action: #selector(deviceButtonTapped(_:)), for: .touchUpInside)
//            view.addSubview(button)
//            
//            let xOffset = CGFloat(i) * (buttonWidth + spacing) + 20
//            button.snp.makeConstraints { make in
//                make.size.equalTo(CGSize(width: buttonWidth, height: buttonHeight))
//                make.top.equalTo(subtitleLabel.snp.bottom).offset(12)
//                make.left.equalTo(view.snp.left).offset(xOffset)
//            }
//            
//            // 调整 imageEdgeInsets 和 titleEdgeInsets 以确保水平居中
//            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: (buttonWidth - button.imageView!.frame.size.width) / 2, bottom: 30, right: 0)
//            button.titleEdgeInsets = UIEdgeInsets(top: 70, left: -30, bottom: 0, right: 0)
//        }
        
        // 按钮宽度和间距
        let buttonWidth: CGFloat = (view.frame.size.width - 40 - 45) / 4
        let buttonHeight: CGFloat = 100
        let spacing: CGFloat = 15
        
        // 创建按钮
        let buttonImages = ["dev_img_light", "dev_search_icon_panel", "dev_img_curtain", "dev_search_icon_audio"] // 替换为您自己的图片资源
        
        for i in 0..<buttonTitles.count {
            let button = UIButton(type: .custom)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setImage(UIImage(named: buttonImages[i]), for: .normal)
            button.setTitle(buttonTitles[i], for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            
            button.tag = i + 1 // 为每个按钮设置标签
            button.addTarget(self, action: #selector(deviceButtonTapped(_:)), for: .touchUpInside)
            button.backgroundColor = .white // 初始状态为白色背景
            button.layer.borderColor = UIColor.clear.cgColor // 初始状态无边框
            button.layer.borderWidth = 1.0
            button.layer.cornerRadius = 10 // 可根据需要调整圆角
            
            view.addSubview(button)
            
            let xOffset = CGFloat(i) * (buttonWidth + spacing) + 20
            button.snp.makeConstraints { make in
                make.size.equalTo(CGSize(width: buttonWidth, height: buttonHeight))
                make.top.equalTo(subtitleLabel.snp.bottom).offset(12)
                make.left.equalTo(view.snp.left).offset(xOffset)
            }
            
            // 调整 imageEdgeInsets 和 titleEdgeInsets 以确保水平居中
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: (buttonWidth - button.imageView!.frame.size.width) / 2, bottom: 30, right: 0)
            button.titleEdgeInsets = UIEdgeInsets(top: 70, left: -30, bottom: 0, right: 0)
        }
        
        // 无线通讯测试开关
        let testBgView = UIView()
        testBgView.backgroundColor = .white
        testBgView.layer.cornerRadius = 6
        view.addSubview(testBgView)
        testBgView.snp.makeConstraints { make in
            make.left.equalTo(view.snp.left).offset(20)
            make.right.equalTo(view.snp.right).offset(-20)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-99)
            make.height.equalTo(60)
        }
        
        let switchLabel = UILabel()
        switchLabel.text = "无线通讯测试开关"
        switchLabel.font = UIFont.systemFont(ofSize: 16)
        testBgView.addSubview(switchLabel)
        switchLabel.snp.makeConstraints { make in
            make.left.equalTo(testBgView.snp.left).offset(20)
            make.centerY.equalTo(testBgView)
        }
        
        testSwitch = UISwitch()
        testSwitch.onTintColor = UIColor(red: 0, green: 0.46, blue: 0.79, alpha: 1.00)
        testSwitch.addTarget(self, action: #selector(testSwitchChanged), for: .valueChanged)
        testBgView.addSubview(testSwitch)
        testSwitch.snp.makeConstraints { make in
            make.right.equalTo(testBgView.snp.right).offset(-20)
            make.centerY.equalTo(switchLabel)
        }
        
        // 添加“下一步”按钮
        nextButton = UIButton(frame: CGRect(x: 20, y: switchLabel.frame.maxY + 40, width: view.frame.size.width - 40, height: 50))
        nextButton.setTitle("下一步", for: .normal)
        nextButton.setTitle("下一步", for: .disabled)
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.setTitleColor(UIColor(red: 0.67, green: 0.67, blue: 0.67, alpha: 1.00), for: .disabled)
        nextButton.setBackgroundImage(UIImage.image(with: UIColor(red: 0, green: 0.46, blue: 0.79, alpha: 1.00)), for: .normal)
        nextButton.setBackgroundImage(UIImage.image(with: .white), for: .disabled)
        nextButton.layer.cornerRadius = 6
        nextButton.layer.masksToBounds = true
        nextButton.isEnabled = false
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        view.addSubview(nextButton)
        nextButton.snp.makeConstraints { make in
            make.left.equalTo(view.snp.left).offset(20)
            make.right.equalTo(view.snp.right).offset(-20)
            make.height.equalTo(48)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-35)
        }
    }
    
    // MARK: - Button Actions
    
    @objc func deviceButtonTapped(_ sender: UIButton) {
        // 取消之前选中的按钮的选中状态
        selectedButton?.backgroundColor = .white
        selectedButton?.setTitleColor(.black, for: .normal)
        selectedButton?.layer.borderColor = UIColor.clear.cgColor
        
        // 设置当前按钮为选中状态
        selectedButton = sender
        selectedButton?.backgroundColor = .white
        selectedButton?.setTitleColor(UIColor(red: 0, green: 0.46, blue: 0.79, alpha: 1.00), for: .normal)
        selectedButton?.layer.borderColor = UIColor(red: 0, green: 0.46, blue: 0.79, alpha: 1.00).cgColor
        selectedButton?.layer.borderWidth = 1.0
        
        nextButton.isEnabled = true
        
        print("选择了设备类型: \(sender.titleLabel?.text ?? "")")
    }
    
    @objc func nextButtonTapped() {
        guard let selectedButton = selectedButton else {
            print("未选择设备类型")
            return
        }
        
        let selectedDeviceType = selectedButton.tag // 根据按钮的 tag 获取设备类型
        print("当前选中的设备类型是: \(selectedDeviceType)")
        
        if selectedDeviceType == 1 {
            // 将设备类型传递到下一个控制器
            let deviceScanViewController = DeviceScanLightVC()
            deviceScanViewController.selectedDeviceType = selectedDeviceType
            deviceScanViewController.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(deviceScanViewController, animated: true)
        } else if selectedDeviceType == 2 {
            // 将设备类型传递到下一个控制器
            let deviceScanViewController = DeviceScanPanelVC()
            deviceScanViewController.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(deviceScanViewController, animated: true)
        } else if selectedDeviceType == 3 {
            // 将设备类型传递到下一个控制器
            let deviceScanCurtainVC = DeviceScanCurtainVC()
            deviceScanCurtainVC.selectedDeviceType = 6
            deviceScanCurtainVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(deviceScanCurtainVC, animated: true)
        } else if selectedDeviceType == 4 {
            // 将设备类型传递到下一个控制器
            let deviceScanViewController = DeviceScanVoiceVC()
            deviceScanViewController.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(deviceScanViewController, animated: true)
        }
    }
    
    // MARK: - Test Switch Action
    @objc func testSwitchChanged() {
        if testSwitch.isOn {
            // 开启广播，onOff = 1
            sendBLEBroadcast(onOff: 1)
        } else {
            // 关闭广播，onOff = 0
            sendBLEBroadcast(onOff: 0)
        }
    }
    
    // 发送 BLE 广播
    func sendBLEBroadcast(onOff: Int) {
        guard let peripheralManager = peripheralManager else { return }
        
        // 如果蓝牙设备未开启，等待直到蓝牙准备好
        if peripheralManager.state != .poweredOn {
            print("蓝牙未开启，无法发送广播")
            return
        }
        
        peripheralManager.stopAdvertising()
        
        let serviceUUID = generateServiceUUID(onOff: onOff)
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
    
    // 发送 BLE 广播
    func stopSendBLEBroadcast() {
        peripheralManager?.stopAdvertising()
    }
    
    // 生成 BLE 广播的服务 UUID
    func generateServiceUUID(onOff: Int) -> CBUUID {
        // 格式： 68753A44-4D6F-1226-9C60-0050E4C00067
        let baseUUID = "00000000-0000-0000-"
        let incrementedPart = String(format: "%04X", currentUUIDPart)  // 格式化为四位十六进制
        currentUUIDPart += 1
        
        // 根据传入的 onOff 参数决定 suffix 的值
        let fixedSuffix: String
        if onOff == 1 {
            fixedSuffix = "01FFFF0211A0"
        } else {
            fixedSuffix = "00FFFF0211A0"
        }
        
        // 拼接完整的 UUID 字符串
        let fullUUIDString = baseUUID + incrementedPart + "-" + fixedSuffix
        let serviceUUID = CBUUID(string: fullUUIDString)
        
        return serviceUUID
    }
}

extension DeviceAdditionViewController: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state != .poweredOn {
            print("蓝牙未打开")
            return
        }
    }
}

extension UIImage {
    // 将 UIColor 转换为 UIImage
    static func image(with color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
}

