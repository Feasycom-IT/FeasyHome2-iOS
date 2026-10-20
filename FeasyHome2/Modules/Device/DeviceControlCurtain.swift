//
//  DeviceControlCurtain.swift
//  FeasyHome2
//
//  Created by chenchanghua on 2024/12/25.
//

import UIKit
import FeasyMeshSDK

class DeviceControlCurtain: UIViewController {
    
    var device: DeviceTuple?
    private let titleLabel = UILabel()
    private let btnDelete = UIButton()
    private let imgView = UIImageView()
    private let bottomView = UIView()
    private let btnCurtainReverse = UIButton()
    private var direction = false
    private let btnCurtainClean = UIButton()
    private let btnCurtainOpen = UIButton()
    private let btnCurtainClose = UIButton()
    private let btnCurtainRefresh = UIButton()
    private let slider = UISlider()
    private let sliderValue = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1.0)
        setupUI()
    }
    
    private func setupUI() {
        titleLabel.text = device?.name
        self.view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(108)
            make.leading.equalToSuperview().offset(24)
            make.height.equalTo(24)
        }
        
        btnDelete.setTitle("删除", for: .normal)
        btnDelete.setTitleColor(UIColor(red: 170/255.0, green: 170/255.0, blue: 170/255.0, alpha: 1.0), for: .normal)
        btnDelete.addTarget(self, action: #selector(deleteGroupAction), for: .touchUpInside)
        self.view.addSubview(btnDelete)
        btnDelete.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-24)
            make.height.equalTo(24)
            make.centerY.equalTo(titleLabel)
        }
        
        imgView.image = UIImage(named: "img_curtain")
        self.view.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(275)
        }
        
        bottomView.backgroundColor = .white
        bottomView.layer.cornerRadius = 20
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(341)
        }
        
        // 反转
        btnCurtainReverse.setImage(UIImage(named: "curtain_icon_reverse"), for: .normal)
        btnCurtainReverse.setImage(UIImage(named: "curtain_icon_reverse_active"), for: .selected)
        btnCurtainReverse.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1.0)
        btnCurtainReverse.layer.cornerRadius = 30
        btnCurtainReverse.addTarget(self, action: #selector(btnReverseAction), for: .touchUpInside)
        bottomView.addSubview(btnCurtainReverse)
        btnCurtainReverse.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.leading.equalToSuperview().offset(32)
            make.height.width.equalTo(60)
        }
        
        let curtainReverseTitle = UILabel()
        curtainReverseTitle.text = "反向运行"
        curtainReverseTitle.textAlignment = .center
        curtainReverseTitle.font = UIFont.systemFont(ofSize: 14)
        curtainReverseTitle.textColor = UIColor(red: 170/255.0, green: 170/255.0, blue: 170/255.0, alpha: 1.0)
        bottomView.addSubview(curtainReverseTitle)
        curtainReverseTitle.snp.makeConstraints { make in
            make.top.equalTo(btnCurtainReverse.snp.bottom).offset(2)
            make.centerX.equalTo(btnCurtainReverse.snp.centerX)
            make.height.equalTo(20)
        }
        
        // 清除
        btnCurtainClean.setImage(UIImage(named: "curtain_icon_clean"), for: .normal)
        btnCurtainClean.setImage(UIImage(named: "curtain_icon_clean_active"), for: .selected)
        btnCurtainClean.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1.0)
        btnCurtainClean.layer.cornerRadius = 30
        btnCurtainClean.addTarget(self, action: #selector(clearButtonAction), for: .touchUpInside)
        bottomView.addSubview(btnCurtainClean)
        btnCurtainClean.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-32)
            make.height.width.equalTo(60)
        }
        
        let curtainCleanTitle = UILabel()
        curtainCleanTitle.text = "清除行程"
        curtainCleanTitle.textAlignment = .center
        curtainCleanTitle.font = UIFont.systemFont(ofSize: 14)
        curtainCleanTitle.textColor = UIColor(red: 170/255.0, green: 170/255.0, blue: 170/255.0, alpha: 1.0)
        bottomView.addSubview(curtainCleanTitle)
        curtainCleanTitle.snp.makeConstraints { make in
            make.top.equalTo(btnCurtainClean.snp.bottom).offset(2)
            make.centerX.equalTo(btnCurtainClean.snp.centerX)
            make.height.equalTo(20)
        }
        
        // 全关
        btnCurtainClose.setImage(UIImage(named: "curtain_icon_close"), for: .normal)
        btnCurtainClose.setImage(UIImage(named: "curtain_icon_close_active"), for: .selected)
        btnCurtainClose.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1.0)
        btnCurtainClose.layer.cornerRadius = 30
        btnCurtainClose.addTarget(self, action: #selector(allCloseButtonAction), for: .touchUpInside)
        bottomView.addSubview(btnCurtainClose)
        btnCurtainClose.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(134)
            make.leading.equalToSuperview().offset(32)
            make.height.width.equalTo(60)
        }
        
        let curtainCloseTitle = UILabel()
        curtainCloseTitle.text = "全关"
        curtainCloseTitle.textAlignment = .center
        curtainCloseTitle.font = UIFont.systemFont(ofSize: 14)
        curtainCloseTitle.textColor = UIColor(red: 170/255.0, green: 170/255.0, blue: 170/255.0, alpha: 1.0)
        bottomView.addSubview(curtainCloseTitle)
        curtainCloseTitle.snp.makeConstraints { make in
            make.top.equalTo(btnCurtainClose.snp.bottom).offset(2)
            make.centerX.equalTo(btnCurtainClose.snp.centerX)
            make.height.equalTo(20)
        }
        
        // 刷新
        btnCurtainRefresh.setImage(UIImage(named: "curtain_icon_refresh"), for: .normal)
        btnCurtainRefresh.setImage(UIImage(named: "curtain_icon_refresh_active"), for: .selected)
        btnCurtainRefresh.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1.0)
        btnCurtainRefresh.layer.cornerRadius = 30
        bottomView.addSubview(btnCurtainRefresh)
        btnCurtainRefresh.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(134)
            make.centerX.equalToSuperview()
            make.height.width.equalTo(60)
        }
        
        let curtainRefreshTitle = UILabel()
        curtainRefreshTitle.text = "刷新"
        curtainRefreshTitle.textAlignment = .center
        curtainRefreshTitle.font = UIFont.systemFont(ofSize: 14)
        curtainRefreshTitle.textColor = UIColor(red: 170/255.0, green: 170/255.0, blue: 170/255.0, alpha: 1.0)
        bottomView.addSubview(curtainRefreshTitle)
        curtainRefreshTitle.snp.makeConstraints { make in
            make.top.equalTo(btnCurtainRefresh.snp.bottom).offset(2)
            make.centerX.equalTo(btnCurtainRefresh.snp.centerX)
            make.height.equalTo(20)
        }
        
        // 全开
        btnCurtainOpen.setImage(UIImage(named: "curtain_icon_open"), for: .normal)
        btnCurtainOpen.setImage(UIImage(named: "curtain_icon_open_active"), for: .selected)
        btnCurtainOpen.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1.0)
        btnCurtainOpen.layer.cornerRadius = 30
        btnCurtainOpen.addTarget(self, action: #selector(allOpenButtonAction), for: .touchUpInside)
        bottomView.addSubview(btnCurtainOpen)
        btnCurtainOpen.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(134)
            make.trailing.equalToSuperview().offset(-32)
            make.height.width.equalTo(60)
        }
        
        let curtainOpenTitle = UILabel()
        curtainOpenTitle.text = "全开"
        curtainOpenTitle.textAlignment = .center
        curtainOpenTitle.font = UIFont.systemFont(ofSize: 14)
        curtainOpenTitle.textColor = UIColor(red: 170/255.0, green: 170/255.0, blue: 170/255.0, alpha: 1.0)
        bottomView.addSubview(curtainOpenTitle)
        curtainOpenTitle.snp.makeConstraints { make in
            make.top.equalTo(btnCurtainOpen.snp.bottom).offset(2)
            make.centerX.equalTo(btnCurtainOpen.snp.centerX)
            make.height.equalTo(20)
        }
        
        // 开合度
        let sliderTitle = UILabel()
        sliderTitle.text = "开合"
        sliderTitle.textAlignment = .center
        sliderTitle.font = UIFont.systemFont(ofSize: 14)
        sliderTitle.textColor = .black
        bottomView.addSubview(sliderTitle)
        sliderTitle.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(261)
            make.leading.equalToSuperview().offset(40)
            make.height.equalTo(20)
        }
        
        sliderValue.text = "100%"
        sliderValue.textAlignment = .center
        sliderValue.font = UIFont.systemFont(ofSize: 14)
        sliderValue.textColor = .black
        bottomView.addSubview(sliderValue)
        sliderValue.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(261)
            make.trailing.equalToSuperview().offset(-40)
            make.height.equalTo(20)
        }
        
        slider.minimumValue = 0
        slider.maximumValue = 100
        slider.addTarget(self, action: #selector(curtainSliderValueChanged(_:)), for: .valueChanged)
        bottomView.addSubview(slider)
        slider.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(261)
            make.left.equalTo(sliderTitle.snp.right).offset(16)
            make.right.equalTo(sliderValue.snp.left).offset(-16)
            make.centerY.equalTo(sliderTitle)
        }
    }
    
    // MARK: - ActionHandle
    
    @objc private func btnReverseAction() {
        direction = !direction
        if let device = device {
            OperateCurtainCmd(address: device.address, direction: direction)
        }
    }
    
    @objc private func allCloseButtonAction() {
        if let device = device {
            self.adjustCurtain(address: device.address, to: 0)
        }
    }
    
    @objc private func allOpenButtonAction() {
        if let device = device {
            self.adjustCurtain(address: device.address, to: 100)
        }
    }
    
    @objc private func curtainSliderValueChanged(_ sender: UISlider) {
        if let device = device {
            let currentValue = Int(sender.value)
            self.adjustCurtain(address: device.address, to: currentValue)
        }
    }
    
    private func OperateCurtainCmd(address:String, direction:Bool) {
        if let opCode = UInt32("F21102", radix: 16) {
            let meshNetwork = MeshNetworkManager.instance.meshNetwork!
            
            let addressHex = String(format: "%02XC0", Int(address)!)
            let directionHex = String(format: "%02X", direction)
            
            let parametersHex = "05" + addressHex + "03" + directionHex
            let parameters = Data(hex: parametersHex)
            
            var message = RuntimeVendorMessage(opCode: opCode, parameters: parameters)
            message.isSegmented = false
            message.security = MeshMessageSecurity.low
            
            do {
                try MeshNetworkManager.instance.send(message, to: MeshAddress(hex: "FFFF")!, using: meshNetwork.applicationKeys.last!)
                print("发送窗帘反转消息，direction值：\(direction)，参数：\(parametersHex)")
            } catch {
                print("发送窗帘反转消息失败：\(error)")
            }
        }
    }
    
    @objc private func adjustCurtain(address:String, to progress: Int) {
        // 检查传入的开合值范围是否合法
        guard (0...100).contains(progress) else {
            print("开合值超出范围，应为 0 到 100")
            return
        }
        
        if let opCode = UInt32("F21102", radix: 16) {
            let meshNetwork = MeshNetworkManager.instance.meshNetwork!
            
            let addressHex = String(format: "%02XC0", Int(address)!)
            
            // 将开合值转换为十六进制字符串
            let progressHex = String(format: "%02X", progress)
            
            // 拼接到参数的末尾
            let parametersHex = "05" + addressHex + "02" + progressHex
            let parameters = Data(hex: parametersHex)
            
            var message = RuntimeVendorMessage(opCode: opCode, parameters: parameters)
            message.isSegmented = false
            message.security = MeshMessageSecurity.low
            
            do {
                try MeshNetworkManager.instance.send(message, to: MeshAddress(hex: "FFFF")!, using: meshNetwork.applicationKeys.last!)
                print("发送开合值调整消息，开合值：\(progress)，参数：\(parametersHex)")
            } catch {
                print("发送消息失败：\(error)")
            }
        }
    }
    
    @objc private func clearButtonAction() {
        
        if let opCode = UInt32("F21102", radix: 16), let device = device {
            let meshNetwork = MeshNetworkManager.instance.meshNetwork!
            
            let addressHex = String(format: "%02XC0", Int(device.address)!)
            
            let parametersHex = "05" + addressHex + "0400"
            let parameters = Data(hex: parametersHex)
            
            var message = RuntimeVendorMessage(opCode: opCode, parameters: parameters)
            message.isSegmented = false
            message.security = MeshMessageSecurity.low
            
            do {
                try MeshNetworkManager.instance.send(message, to: MeshAddress(hex: "FFFF")!, using: meshNetwork.applicationKeys.last!)
            } catch {
                print("发送消息失败：\(error)")
            }
        }
    }
    
    @objc private func deleteGroupAction() {
        let alertVC = UIAlertController(title: "删除该窗帘组", message: "确定删除该窗帘组?", preferredStyle: .alert)
        let alertOK = UIAlertAction(title: "确定", style: .default) { alert in
            SceneNetManager.shareInstance.deleteCurtainGroup(familyID: kCurrentFamilyID, roomId: kCurrentRoomID, address: self.device!.address) { [weak self] result in
                switch result {
                case .success(let response):
                    print("response.msg=\(response.msg)")
                    self?.navigationController?.popViewController(animated: true)
                case .failure(let error):
                    print("error=\(error.localizedDescription)")
                }
            }
        }
        let alertCancel = UIAlertAction(title: "取消", style: .cancel)
        alertVC.addAction(alertOK)
        alertVC.addAction(alertCancel)
        self.present(alertVC, animated: false)
    }
    
}
