//
//  SelectSceneVC.swift
//  FeasyHome2
//
//  Created by chenchanghua on 2025/5/13.
//

import UIKit

class SelectSceneVC: UIViewController {
    // MARK: - Properties
    
    var sceneItemList: [SceneListItem] = []
    private var selectedFirstComponentIndex: Int = 0
    
    var onSelectedScene:((_: SceneListItem) -> Void)?
    
    private var tipTitleLabel: UILabel!
    private var locationPickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        
        fetchHomeSceneList()
        setupUI()
    }
    
    // MARK: - Fetch Data
    private func fetchHomeSceneList() {
        SceneNetManager.shareInstance.fetchHomeSceneList(familyId: kCurrentFamilyID) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(let homeAndSceneList):
                sceneItemList = homeAndSceneList.sceneList
                locationPickerView.reloadAllComponents()
            case .failure(let error):
                print(error.errorDescription!)
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

        onSelectedScene?(sceneItemList[selectedFirstComponentIndex])
        
        self.dismiss(animated: false)
    }
}

// MARK: - UIPickerView Delegate & DataSource

extension SelectSceneVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sceneItemList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return sceneItemList[row].sceneName
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedFirstComponentIndex = row
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 48
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 150
    }
    
}
