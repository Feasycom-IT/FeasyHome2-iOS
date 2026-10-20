//
//  SelectGroupLightVC.swift
//  FeasyHome2
//
//  Created by chenchanghua on 2025/5/13.
//

import UIKit

class SelectGroupLightVC: UIViewController {
    // MARK: - Properties
    
    var roomList:[Room] = []
    private var lightGroupList:[[LightGroup]] = []
    
    private var curtainGroupList:[CurtainGroup] = []
    
    private var selectedFirstComponentIndex:Int = 0
    private var selectedSecondComponentIndex:Int = 0
    
    var onSelectedGroup:((_ :Room, _ :LightGroup)->Void)?
    
    private var tipTitleLabel: UILabel!
    private var locationPickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        
        fetchSceneGroupList()
        setupUI()
    }
    
    // MARK: - Fetch Data
    private func fetchSceneGroupList() {
        if roomList.count > 0 {
            lightGroupList = Array(repeating: [LightGroup](), count: roomList.count)
        }
        for room in roomList {
            SceneNetManager.shareInstance.fetchSceneGroupList(roomId: room.id, familyId: kCurrentFamilyID) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let groupAndCurtainGroupAndRoomList):
                    curtainGroupList = groupAndCurtainGroupAndRoomList.curtainGroupList
                    if !groupAndCurtainGroupAndRoomList.groupList.isEmpty {
                        for i in 0..<roomList.count {
                            if roomList[i].id == groupAndCurtainGroupAndRoomList.groupList[0].roomId {
                                lightGroupList[i] =  groupAndCurtainGroupAndRoomList.groupList
                                locationPickerView.reloadComponent(1)
                            }
                        }
                    }
                case .failure(let error):
                    print("error = \(error)")
                }
            }
        }
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
            label.text = "添加群组"
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
            btn.addTarget(self, action: #selector(addGroupFromSheet), for: .touchUpInside)
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
    
    // MARK: - Actions
    
    @objc private func cancelBtnTapped() {
        dismiss(animated: false)
    }
    
    @objc private func addGroupFromSheet() {
        if lightGroupList.isEmpty || lightGroupList[selectedFirstComponentIndex].isEmpty {
            showToast("请先选择要添加的设备组")
            return
        }
        
        onSelectedGroup?(roomList[selectedFirstComponentIndex], lightGroupList[selectedFirstComponentIndex][selectedSecondComponentIndex])
        
        self.dismiss(animated: false)
    }
}

// MARK: - UIPickerView Delegate & DataSource

extension SelectGroupLightVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return roomList.count
        } else {
            if lightGroupList.count > 0 {
                return lightGroupList[selectedFirstComponentIndex].count
            } else {
                return 0
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return roomList[row].roomName
        } else {
            return lightGroupList[selectedFirstComponentIndex][row].groupName
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            selectedFirstComponentIndex = row
            locationPickerView.reloadComponent(1)
        } else if component == 1 {
            selectedSecondComponentIndex = row
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 48
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 150
    }
    
}
