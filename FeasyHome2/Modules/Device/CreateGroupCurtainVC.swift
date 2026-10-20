//
//  CreateGroupCurtainVC.swift
//  FeasyHome2
//
//  Created by chenchanghua on 2025/2/17.
//

import UIKit

class CreateGroupCurtainVC: UIViewController {
    
    var deviceType: Int!
    var onDismiss: (() -> Void)?
    
    private var tipTitleLabel: UILabel!
    private var groupAddress: Int = 0
    
    private var createButton: UIBarButtonItem!
    
    private var curtainTypePickerView: UIPickerView!
    private var locations: [LightLocation] = []
    private var curtainTypes: [CurtainType] = []
    
    private var selectedCurtainTypeIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        
        fetchCurtainTypeList()
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
        
        curtainTypePickerView = UIPickerView()
        curtainTypePickerView.backgroundColor = .white
        curtainTypePickerView.delegate = self
        curtainTypePickerView.dataSource = self
        curtainTypePickerView.translatesAutoresizingMaskIntoConstraints = false
        bgView.addSubview(curtainTypePickerView)
        curtainTypePickerView.snp.makeConstraints { make in
            make.top.equalTo(lineView.snp.bottom)
            make.left.right.bottom.equalTo(bgView)
        }
        
    }
    
    private func fetchCurtainTypeList() {
        SceneNetManager.shareInstance.fetchCurtainTypeList { [weak self] result in
            switch result {
            case .success(let curtainTypeList):
                self?.curtainTypes = curtainTypeList
                self?.curtainTypePickerView.reloadAllComponents()
            case .failure(let error):
                print("error=\(error.localizedDescription)")
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
        guard !curtainTypes.isEmpty else {
            print("数据尚未加载完成")
            return
        }
        
        let selectedLightType = String(selectedCurtainTypeIndex)
        let deviceType = String(format: "%02d", deviceType)
        let familyId = String(kCurrentFamilyID)
        let roomId = String(kCurrentRoomID)
        let address = String(format: "%02d", groupAddress)
        let addressNumber = String(format: "%d", groupAddress)
        
        let groupDefaultName = curtainTypes[selectedCurtainTypeIndex].text
        
        SceneNetManager.shareInstance.addCurtainGroup(curtain_name: curtainTypes[selectedCurtainTypeIndex].text, curtain_code: curtainTypes[selectedCurtainTypeIndex].code, deviceType: deviceType, familyID: kCurrentFamilyID, roomId: kCurrentRoomID, address: address, address_number: addressNumber) { [weak self] result in
            switch result {
            case .success( let response):
                print("response=\(response)")
            case .failure(let error):
                print("error=\(error.localizedDescription)")
            }
            self?.dismiss(animated: false)
        }
        
        
        
        //        APIManager.shared.createGroup(groupName: groupDefaultName, location: selectedLocation, light: selectedLightType, deviceType: deviceTypeHex, familyId: familyId, roomId: roomId, address: address, addressNumber: addressNumber) { result in
        //            switch result {
        //            case .success:
        //                print("创建分组成功")
        //            case .failure(let error):
        //                print("创建分组失败: \(error.localizedDescription)")
        //            }
        //            DispatchQueue.main.async {
        //                self.dismiss(animated: false)
        //            }
        //        }
    }
}

// MARK: - UIPickerView Delegate & DataSource
extension CreateGroupCurtainVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return curtainTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return curtainTypes[row].text
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCurtainTypeIndex = row
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 48
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 150
    }
}
