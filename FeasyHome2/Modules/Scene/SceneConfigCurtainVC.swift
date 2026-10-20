//
//  SceneConfigCurtainVC.swift
//  FeasyHome2
//
//  Created by chenchanghua on 2025/5/14.
//

import UIKit
import FeasyMeshSDK

class SceneConfigCurtainVC: UIViewController {
    
    var joinSceneGroupReq:JoinSceneGroupRequest!
    var btnSaveCfg:UIButton!
    
    var colorTempView:UIView!
    var colorTempSlider = UISlider()
    var colorTempValue:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "配置窗帘"
        self.view.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1.0)
        
        setupSaveCfgButton()
        setupColorTempView()
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        let collectionTitle = UILabel(frame: .zero)
        collectionTitle.text =  joinSceneGroupReq.room_name + " - " + joinSceneGroupReq.group_name //"卧室 - 窗帘区 灯带"
        self.view.addSubview(collectionTitle)
        collectionTitle.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionTitle.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor,constant: 20),
            collectionTitle.leadingAnchor.constraint(equalTo: self.view.leadingAnchor,constant: 20)
        ])   
    }
    
    private func setupColorTempView() {
        colorTempView = UIView(frame: .zero)
        self.view.addSubview(colorTempView)
        colorTempView.backgroundColor = .white
        colorTempView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            colorTempView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            colorTempView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            colorTempView.bottomAnchor.constraint(equalTo: self.btnSaveCfg.topAnchor, constant: -24),
            colorTempView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        let colorTempLable = UILabel(frame: CGRect(x: 10, y: 20, width: 34, height: 24))
        colorTempLable.text = "开合"
        colorTempLable.textColor = .black
        colorTempView.addSubview(colorTempLable)
        colorTempLable.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }
        
        colorTempValue = UILabel(frame: CGRect(x: 10, y: 20, width: 34, height: 24))
        colorTempValue.text = "0"
        colorTempValue.textColor = .black
        colorTempView.addSubview(colorTempValue)
        colorTempValue.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
        }
        
        colorTempSlider.backgroundColor = .white
        colorTempSlider.minimumValue = 0
        colorTempSlider.maximumValue = 1
        colorTempSlider.value = 0.0
        colorTempSlider.minimumTrackTintColor = UIColor(red: 0/255.0, green: 117/255.0, blue: 201/255.0, alpha: 1.0)
        colorTempSlider.maximumTrackTintColor = .gray
        colorTempSlider.isContinuous = false
        colorTempSlider.addTarget(self, action: #selector(colorTempSliderChange(_:)), for: UIControl.Event.valueChanged)
        colorTempView.addSubview(colorTempSlider)
        colorTempSlider.snp.makeConstraints { make in
            make.left.equalTo(colorTempLable.snp.right).offset(11)
            make.right.equalTo(colorTempValue.snp.left).offset(-11)
            make.centerY.equalToSuperview()
            make.height.equalTo(20)
        }
    }
    
    @objc private func colorTempSliderChange(_ slider: UISlider) {
        print("value=\(slider.value)")
        colorTempValue.text = String.init(format: "%d", Int(Float(slider.value*100).rounded()))
        self.OperateSceneLightGroupCmd(sceneID: joinSceneGroupReq.scene_code, groupAddr: joinSceneGroupReq.address, ct: Int(Float(slider.value*100).rounded()))
    }
    
    private func setupSaveCfgButton() {
        btnSaveCfg = UIButton(type: .system)
        btnSaveCfg.setTitle("保存配置", for: .normal)
        btnSaveCfg.setTitleColor(.white, for: .normal)
        btnSaveCfg.titleLabel?.font = .systemFont(ofSize: 17)
        btnSaveCfg.backgroundColor = UIColor(red: 0/255.0, green: 117/255.0, blue: 201/255.0, alpha: 1.0)
        btnSaveCfg.layer.cornerRadius = 10
        btnSaveCfg.translatesAutoresizingMaskIntoConstraints = false
        btnSaveCfg.addTarget(self, action: #selector(btnSaveCfgAction), for: .touchUpInside)
        self.view.addSubview(btnSaveCfg)
        
        NSLayoutConstraint.activate([
            btnSaveCfg.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            btnSaveCfg.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            btnSaveCfg.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            btnSaveCfg.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func btnSaveCfgAction() {
        print("colorTempValue=\(colorTempValue!)")

        SceneNetManager.shareInstance.joinSceneGroup(joinSceneGroupReq: joinSceneGroupReq) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let result):
                print("2result.msg=\(result.msg)")
                self.navigationController?.popViewController(animated: true)
            case .failure(let error):
                print("error=\(error)")
            }
        }
        self.OperateSceneLightGroupCmdSave(sceneID: joinSceneGroupReq.scene_code, groupAddr: joinSceneGroupReq.address, ct: Int(Float(colorTempSlider.value*100).rounded()))
    }
    
    private func OperateSceneLightGroupCmd(sceneID:String, groupAddr:String, ct:Int) {
        if let opCode = UInt32("F21102", radix: 16) {
            let meshNetwork = MeshNetworkManager.instance.meshNetwork!
            
            let sceneIDHex = sceneID //String(format: "%02X", Int(sceneID)!)
            let groupAddrHex = String(format: "%02XC0", Int(groupAddr)!)
            let ctHex = String(format: "%02X", ct)
            
            // 拼接到参数的末尾
            let parametersHex = "0C" + sceneIDHex + groupAddrHex + "01" + ctHex
            let parameters = Data(hex: parametersHex)
            
            var message = RuntimeVendorMessage(opCode: opCode, parameters: parameters)
            message.isSegmented = false
            message.security = MeshMessageSecurity.low
            
            do {
                try MeshNetworkManager.instance.send(message, to: MeshAddress(hex: "FFFF")!, using: meshNetwork.applicationKeys.last!)
            } catch {
                print("发送场景消息失败：\(error)")
            }
        }
    }
    
    private func OperateSceneLightGroupCmdSave(sceneID:String, groupAddr:String, ct:Int) {
        if let opCode = UInt32("F21102", radix: 16) {
            let meshNetwork = MeshNetworkManager.instance.meshNetwork!
            
            let sceneIDHex = sceneID //String(format: "%02X", Int(sceneID)!)
            let groupAddrHex = String(format: "%02XC0", Int(groupAddr)!)
            let ctHex = String(format: "%02X", ct)
            
            // 拼接到参数的末尾
            let parametersHex = "0C" + sceneIDHex + groupAddrHex + "02" + ctHex
            let parameters = Data(hex: parametersHex)
            
            var message = RuntimeVendorMessage(opCode: opCode, parameters: parameters)
            message.isSegmented = false
            message.security = MeshMessageSecurity.low
            
            do {
                try MeshNetworkManager.instance.send(message, to: MeshAddress(hex: "FFFF")!, using: meshNetwork.applicationKeys.last!)
            } catch {
                print("发送场景消息失败：\(error)")
            }
        }
    }
}
