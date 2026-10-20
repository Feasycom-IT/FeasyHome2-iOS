//
//  CreateGroupVC.swift
//  FeasyHome2
//
//  Created by chenchanghua on 2025/1/13.
//

import UIKit

class CreateGroupLightVC: UIViewController {
    // MARK: - Properties
    
    var deviceType: Int!
    var onDismiss: (() -> Void)?
    
    private var tipTitleLabel: UILabel!
    private var groupAddress: Int = 0 // 保存群地址数据
    
    private var locationPickerView: UIPickerView!
    private var locations: [LightLocation] = [] // 第一列数据
    private var lightTypes: [LightType] = [] // 第二列数据
    
    private var selectedLocationIndex: Int = 0
    private var selectedLightTypeIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        
        fetchLocationData()
        fetchLightTypeData()
        fetchEnableGroupAddress()
        setupUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        onDismiss?()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        
        let bgView: UIView = {
            let view = UIView()
            view.backgroundColor = .white
            return view
        }()
        view.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(view)
            make.height.equalTo(280)
        }
        
        let tipView: UIView = {
            let view = UIView()
            view.backgroundColor = .white
            return view
        }()
        bgView.addSubview(tipView)
        tipView.snp.makeConstraints { make in
            make.left.right.top.equalTo(bgView)
            make.height.equalTo(48)
        }
        
        tipTitleLabel = {
            let label = UILabel()
            label.text = "创建分组"
            label.numberOfLines = 0
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 17)
            return label
        }()
        tipView.addSubview(tipTitleLabel)
        tipTitleLabel.snp.makeConstraints { make in
            make.centerX.centerY.equalTo(tipView)
        }
        
        let cancelBtn: UIButton = {
            let btn = UIButton(type: .custom)
            btn.setTitle("取消", for: .normal)
            btn.titleLabel?.font = .systemFont(ofSize: 17)
            btn.setTitleColor(UIColor(red: 0.67, green: 0.67, blue: 0.67, alpha: 1.00), for: .normal)
            btn.addTarget(self, action: #selector(cancelBtnTapped), for: .touchUpInside)
            return btn
        }()
        tipView.addSubview(cancelBtn)
        cancelBtn.snp.makeConstraints { make in
            make.centerY.equalTo(tipView)
            make.left.equalTo(bgView).offset(20)
        }
        
        let createGroupBtn: UIButton = {
            let btn = UIButton(type: .custom)
            btn.setTitle("创建", for: .normal)
            btn.titleLabel?.font = .systemFont(ofSize: 17)
            btn.setTitleColor(UIColor(red: 0, green: 0.46, blue: 0.79, alpha: 1.00), for: .normal)
            btn.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
            return btn
        }()
        tipView.addSubview(createGroupBtn)
        createGroupBtn.snp.makeConstraints { make in
            make.centerY.equalTo(tipView)
            make.right.equalTo(bgView).offset(-20)
        }
        
        let lineView: UIView = {
            let line = UIView()
            line.backgroundColor = UIColor(red: 0.87, green: 0.87, blue: 0.87, alpha: 1.00)
            return line
        }()
        bgView.addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.left.right.equalTo(tipView)
            make.top.equalTo(tipView.snp.bottom)
            make.height.equalTo(1)
        }
        
        locationPickerView = UIPickerView()
        locationPickerView.backgroundColor = .white
        locationPickerView.delegate = self
        locationPickerView.dataSource = self
        locationPickerView.translatesAutoresizingMaskIntoConstraints = false
        bgView.addSubview(locationPickerView)
        locationPickerView.snp.makeConstraints { make in
            make.top.equalTo(lineView.snp.bottom)
            make.left.right.bottom.equalTo(bgView)
        }
        
    }
    
    // MARK: - Fetch Data
    private func fetchLocationData() {
        APIManager.shared.fetchLocationList { [weak self] result in
            switch result {
            case .success(let locations):
                self?.locations = locations
                self?.locationPickerView.reloadComponent(0)
            case .failure(let error):
                print("加载灯具位置失败: \(error.localizedDescription)")
            }
        }
    }
    
    private func fetchLightTypeData() {
        APIManager.shared.fetchLightList { [weak self] result in
            switch result {
            case .success(let lightTypes):
                self?.lightTypes = lightTypes
                self?.locationPickerView.reloadComponent(1)
            case .failure(let error):
                print("加载灯具类型失败: \(error.localizedDescription)")
            }
        }
    }
    
    private func fetchEnableGroupAddress() {
        let familyId = String(kCurrentFamilyID) // 替换为实际的家庭ID
        let deviceTypeHex = String(format: "%02X", deviceType) // 将 Int 转为两位十六进制字符串
        
        APIManager.shared.fetchEnableGroupAddress(familyId: familyId, deviceType: deviceTypeHex) { [weak self] result in
            switch result {
            case .success(let groupAddress):
                self?.groupAddress = groupAddress
                let hexAddress = String(format: "0x%02X", groupAddress)
                DispatchQueue.main.async {
                    self?.tipTitleLabel.text = "创建分组" + "\n" + hexAddress
                }
            case .failure(let error):
                print("获取可用群地址失败: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Actions
    @objc private func cancelBtnTapped() {
        dismiss(animated: false)
    }
    
    @objc private func createButtonTapped() {
        guard !locations.isEmpty, !lightTypes.isEmpty else {
            print("数据尚未加载完成")
            return
        }
        
        let selectedLocation = String(selectedLocationIndex)
        let selectedLightType = String(selectedLightTypeIndex)
        let deviceTypeHex = String(format: "%02X", deviceType)
        let familyId = String(kCurrentFamilyID)
        let roomId = String(kCurrentRoomID)
        let address = String(format: "%02X", groupAddress)
        let addressNumber = String(format: "%d", groupAddress)
        
        let groupDefaultName = locations[selectedLocationIndex].text + lightTypes[selectedLightTypeIndex].text
        
        APIManager.shared.createGroup(groupName: groupDefaultName, location: selectedLocation, light: selectedLightType, deviceType: deviceTypeHex, familyId: familyId, roomId: roomId, address: address, addressNumber: addressNumber) { result in
            switch result {
            case .success:
                print("创建分组成功")
            case .failure(let error):
                print("创建分组失败: \(error.localizedDescription)")
            }
            DispatchQueue.main.async {
                self.dismiss(animated: false)
            }
        }
    }
}

// MARK: - UIPickerView Delegate & DataSource

extension CreateGroupLightVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return locations.count
        } else {
            return lightTypes.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return locations[row].text
        } else {
            return lightTypes[row].text
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            selectedLocationIndex = row
        } else {
            selectedLightTypeIndex = row
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 48
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 150
    }
}
