//
//  SceneConfigLightViewController.swift
//  FeasyHome2
//
//  Created by wenjie zeng on 2025/2/13.
//

import UIKit
import FeasyMeshSDK

class SceneConfigLightViewController: UIViewController {
    private var lights:[Device] = []  //[(name:String,status:Int)] = [("灯1",1),("灯2",1)]
    var joinSceneGroupReq:JoinSceneGroupRequest!
    var collectionView:UICollectionView!
    var btnSaveCfg:UIButton!
    var colorTempView:UIView!
    var brightView:UIView!
    var brightnessSlider = UISlider()
    var colorTempSlider = UISlider()
    var colorTempValue:UILabel!
    var brightValue:UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "配置照明"
        self.view.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1.0)
        
        self.fetchSceneDeviceList()
        setupSaveCfgButton()
        setupColorTempView()
        setupBrightView()
        setupCollectionView()
    }
    
    private func fetchSceneDeviceList() {
        SceneNetManager.shareInstance.fetchSceneDeviceList(familyID: kCurrentFamilyID, roomId: joinSceneGroupReq.room_id, address: joinSceneGroupReq.address) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let devices):
                self.lights = devices
                self.collectionView.reloadData()
            case .failure(let error):
                print("error=\(error)")
            }
        }
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
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 30
        layout.itemSize = CGSize(width: kScreen_Width*100.0/375, height: kScreen_Width*100.0/375)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        self.view.addSubview(collectionView)
        collectionView.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1.0)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "ConfigLightCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: collectionTitle.bottomAnchor,constant: 15),
            collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.brightView.topAnchor, constant:-24)
        ])
        
    }
    
    private func setupBrightView() {
        brightView = UIView(frame: .zero)
        self.view.addSubview(brightView)
        brightView.backgroundColor = .white
        brightView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            brightView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            brightView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            brightView.bottomAnchor.constraint(equalTo: self.colorTempView.topAnchor, constant: -24),
            brightView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        let brightLable = UILabel(frame: CGRect(x: 10, y: 20, width: 34, height: 24))
        brightLable.text = "亮度"
        brightLable.textColor = .black
        brightView.addSubview(brightLable)
        brightLable.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }
        
        brightValue = UILabel(frame: CGRect(x: 10, y: 20, width: 34, height: 24))
        brightValue.text = "0%"
        brightValue.textColor = .black
        brightView.addSubview(brightValue)
        brightValue.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
        }
        
        brightnessSlider.backgroundColor = .white
        brightnessSlider.minimumValue = 0
        brightnessSlider.maximumValue = 1
        brightnessSlider.value = 0.0
        brightnessSlider.minimumTrackTintColor = UIColor(red: 0/255.0, green: 117/255.0, blue: 201/255.0, alpha: 1.0)
        brightnessSlider.maximumTrackTintColor = .gray
        brightnessSlider.isContinuous = false
        brightnessSlider.addTarget(self, action: #selector(brightnessSliderChange(_:)), for: UIControl.Event.valueChanged)
        brightView.addSubview(brightnessSlider)
        brightnessSlider.snp.makeConstraints { make in
            make.left.equalTo(brightLable.snp.right).offset(11)
            make.right.equalTo(brightValue.snp.left).offset(-11)
            make.centerY.equalToSuperview()
            make.height.equalTo(20)
        }
    }
    
    @objc private func brightnessSliderChange(_ slider:UISlider) {
        brightValue.text = String.init(format: "%d%%", Int(Float(slider.value*100).rounded()))
        print("slider.vale=\(slider.value)")
        self.OperateSceneLightGroupCmd(sceneID: joinSceneGroupReq.scene_code, groupAddr: joinSceneGroupReq.address, lightNess: Int(Float(slider.value*100).rounded()), ct: Int(Float(colorTempSlider.value*100).rounded()))
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
        colorTempLable.text = "色温"
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
    
    @objc private func colorTempSliderChange(_ slider:UISlider) {
        print("value=\(slider.value)")
        colorTempValue.text = String.init(format: "%d", Int(Float(slider.value*100).rounded()))
        self.OperateSceneLightGroupCmd(sceneID: joinSceneGroupReq.scene_code, groupAddr: joinSceneGroupReq.address, lightNess: Int(Float( brightnessSlider.value*100).rounded()), ct: Int(Float(slider.value*100).rounded()))
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
        print("brightValue=\(brightValue.text!)")
        print("colorTempValue=\(colorTempValue!)")
        for light in lights {
            print("light=\(light.destination),状态:\(light.isOn==1 ? "开":"关")")
        }
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
        self.OperateSceneLightGroupCmdSave(sceneID: joinSceneGroupReq.scene_code, groupAddr: joinSceneGroupReq.address, lightNess: Int(Float(brightnessSlider.value*100).rounded()), ct: Int(Float(colorTempSlider.value*100).rounded()))
    }
    
    private func operateSceneLightOnOffCmd(onOff: Int, deviceAddr: String, groupAddr:String) {
        if let opCode = UInt32("F21102", radix: 16) {
            let meshNetwork = MeshNetworkManager.instance.meshNetwork!
            
            // 将色温值转换为十六进制字符串
            let brightnessHex = String(format: "%02X", onOff)
            
            // 拼接到参数的末尾
            let parametersHex = "13" + brightnessHex + groupAddr
            let parameters = Data(hex: parametersHex)
            
            var message = RuntimeVendorMessage(opCode: opCode, parameters: parameters)
            message.isSegmented = false
            message.security = MeshMessageSecurity.low
            
            do {
                try MeshNetworkManager.instance.send(message, to: MeshAddress(hex: deviceAddr)!, using: meshNetwork.applicationKeys.last!)
                print("发送单个设备的开关调整消息，onOff值：\(onOff)，参数：\(parametersHex)")
            } catch {
                print("发送消息失败：\(error)")
            }
        }
    }
    
    private func OperateSceneLightGroupCmd(sceneID:String, groupAddr:String, lightNess:Int, ct:Int) {
        if let opCode = UInt32("F21102", radix: 16) {
            let meshNetwork = MeshNetworkManager.instance.meshNetwork!
            
            // 将色温值转换为十六进制字符串
            let brightnessHex = String(format: "%02X", lightNess)
            let sceneIDHex = sceneID //String(format: "%02X", Int(sceneID)!)
            let groupAddrHex = String(format: "%02XC0", Int(groupAddr)!)
            let ctHex = String(format: "%02X", ct)
            // 拼接到参数的末尾
            let parametersHex = "0C" + sceneIDHex + groupAddrHex + "01" + brightnessHex + ctHex
            let parameters = Data(hex: parametersHex)
            
            var message = RuntimeVendorMessage(opCode: opCode, parameters: parameters)
            message.isSegmented = false
            message.security = MeshMessageSecurity.low
            
            do {
                try MeshNetworkManager.instance.send(message, to: MeshAddress(hex: "FFFF")!, using: meshNetwork.applicationKeys.last!)
                print("发送场景的开关调整消息，lightNess值：\(lightNess)，参数：\(parametersHex)")
            } catch {
                print("发送场景消息失败：\(error)")
            }
        }
    }
    
    private func OperateSceneLightGroupCmdSave(sceneID:String, groupAddr:String, lightNess:Int, ct:Int) {
        if let opCode = UInt32("F21102", radix: 16) {
            let meshNetwork = MeshNetworkManager.instance.meshNetwork!
            
            // 将色温值转换为十六进制字符串
            let brightnessHex = String(format: "%02X", lightNess)
            let sceneIDHex = sceneID //String(format: "%02X", Int(sceneID)!)
            let groupAddrHex = String(format: "%02XC0", Int(groupAddr)!)
            let ctHex = String(format: "%02X", ct)
            // 拼接到参数的末尾
            let parametersHex = "0C" + sceneIDHex + groupAddrHex + "03" + brightnessHex + ctHex
            let parameters = Data(hex: parametersHex)
            
            var message = RuntimeVendorMessage(opCode: opCode, parameters: parameters)
            message.isSegmented = false
            message.security = MeshMessageSecurity.low
            
            do {
                try MeshNetworkManager.instance.send(message, to: MeshAddress(hex: "FFFF")!, using: meshNetwork.applicationKeys.last!)
                print("发送场景的开关调整消息，lightNess值：\(lightNess)，参数：\(parametersHex)")
            } catch {
                print("发送场景消息失败：\(error)")
            }
        }
    }
}

extension SceneConfigLightViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return lights.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ConfigLightCell", for: indexPath)
        //        cell.largeContentImage = UIImage(named: "light_icon_bulb_on")
        var imgView:UIImageView!
        if lights[indexPath.item].isOn == 1 {
            imgView = UIImageView(image: UIImage(named: "light_icon_bulb_on"))
        } else {
            imgView = UIImageView(image: UIImage(named: "light_icon_bulb_off"))
        }
        cell.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        imgView.tag = indexPath.item
        imgView.isUserInteractionEnabled = true
        imgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(gestureTap(gesture:))))
        
        let nameLable = UILabel(frame: CGRect(x: 10, y: 10, width: 20, height: 20))
        nameLable.text = "灯" + String(lights[indexPath.item].destination)
        nameLable.textColor = .blue
        nameLable.textAlignment = .center
        cell.addSubview(nameLable)
        nameLable.snp.makeConstraints { make in
            make.top.equalTo(imgView.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
        }
        return cell
    }
    
    @objc private func gestureTap(gesture:UITapGestureRecognizer) {
        guard let imgView = gesture.view as? UIImageView else {return}
        if lights[imgView.tag].isOn == 1 {
            imgView.image = UIImage(named: "light_icon_bulb_off")
            lights[imgView.tag].isOn = 0
            self.operateSceneLightOnOffCmd(onOff: 0, deviceAddr: String(format: "%04X", lights[imgView.tag].destination), groupAddr: joinSceneGroupReq.address)
        } else {
            imgView.image = UIImage(named: "light_icon_bulb_on")
            lights[imgView.tag].isOn = 1
            self.operateSceneLightOnOffCmd(onOff: 1, deviceAddr: String(format: "%04X", lights[imgView.tag].destination), groupAddr: joinSceneGroupReq.address)
        }
        
    }
}
