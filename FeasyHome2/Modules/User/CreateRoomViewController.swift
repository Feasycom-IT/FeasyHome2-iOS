//
//  CreateRoomViewController.swift
//  FeasyHome2
//
//  Created by chenchanghua on 2024/12/23.
//

import UIKit

class CreateRoomViewController: UIViewController {
    
    // MARK: - Properties
    var roomCreatedCallback: ((String) -> Void)?
    
    var presetRooms: [String] = ["客厅", "书房", "玄关", "主卧", "次卧", "客房", "餐厅", "厨房", "阳台", "庭院", "卫生间"]
    var selectedPresetButton: UIButton?
    var customRoomNameTextField: UITextField!
    var createButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.navigationItem.title = "创建房间"
        
        // 设置UI组件
        setupUI()
    }
    
    // MARK: - 设置UI布局
    func setupUI() {
        let scrollView = UIScrollView(frame: self.view.bounds)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(scrollView)
        
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: self.view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // 创建预设房间按钮
        var row = 0
        var col = 0
        let buttonWidth = (self.view.frame.size.width - 80) / 3
        let buttonHeight: CGFloat = 40
        let spacing: CGFloat = 10
        
        for i in 0..<presetRooms.count {
            let button = UIButton(type: .custom)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle(presetRooms[i], for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.backgroundColor = .lightGray
            button.layer.cornerRadius = 5
            button.clipsToBounds = true
            button.tag = i
            button.addTarget(self, action: #selector(presetButtonTapped(_:)), for: .touchUpInside)
            contentView.addSubview(button)
            
            let xOffset = CGFloat(col) * (buttonWidth + spacing) + 20
            let yOffset = CGFloat(row) * (buttonHeight + spacing) + 20
            
            NSLayoutConstraint.activate([
                button.topAnchor.constraint(equalTo: contentView.topAnchor, constant: yOffset),
                button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: xOffset),
                button.widthAnchor.constraint(equalToConstant: buttonWidth),
                button.heightAnchor.constraint(equalToConstant: buttonHeight)
            ])
            
            col += 1
            if col == 3 {
                col = 0
                row += 1
            }
        }
        
        // 自定义房间名称输入框
        customRoomNameTextField = UITextField()
        customRoomNameTextField.placeholder = "请输入自定义房间名称"
        customRoomNameTextField.borderStyle = .roundedRect
        customRoomNameTextField.translatesAutoresizingMaskIntoConstraints = false
        customRoomNameTextField.addTarget(self, action: #selector(customRoomNameTextChanged), for: .editingChanged)
        contentView.addSubview(customRoomNameTextField)
        
        let textFieldYOffset = CGFloat(row + 1) * (buttonHeight + spacing) + 20
        
        NSLayoutConstraint.activate([
            customRoomNameTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: textFieldYOffset),
            customRoomNameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            customRoomNameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            customRoomNameTextField.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // 创建按钮
        createButton = UIButton(type: .system)
        createButton.setTitle("创建", for: .normal)
        createButton.setTitleColor(.white, for: .normal)
        createButton.backgroundColor = .blue
        createButton.layer.cornerRadius = 10
        createButton.translatesAutoresizingMaskIntoConstraints = false
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        contentView.addSubview(createButton)
        
        NSLayoutConstraint.activate([
            createButton.topAnchor.constraint(equalTo: customRoomNameTextField.bottomAnchor, constant: 20),
            createButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            createButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            createButton.heightAnchor.constraint(equalToConstant: 50),
            createButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - 预设房间按钮点击事件
    @objc func presetButtonTapped(_ sender: UIButton) {
        // 取消自定义输入框中的内容
        customRoomNameTextField.text = ""
        
        // 更新预设按钮的选中状态
        if let selectedPresetButton = selectedPresetButton {
            selectedPresetButton.backgroundColor = .lightGray
            selectedPresetButton.setTitleColor(.black, for: .normal)
        }
        
        // 设置当前点击的按钮为选中状态
        sender.backgroundColor = .blue
        sender.setTitleColor(.white, for: .normal)
        selectedPresetButton = sender
    }
    
    // MARK: - 自定义房间名称输入框内容变化事件
    @objc func customRoomNameTextChanged() {
        // 取消选中的预设按钮
        if let selectedPresetButton = selectedPresetButton {
            selectedPresetButton.backgroundColor = .lightGray
            selectedPresetButton.setTitleColor(.black, for: .normal)
            self.selectedPresetButton = nil
        }
    }
    
    // MARK: - 创建按钮点击事件
    @objc func createButtonTapped() {
        var roomName: String?
        
        if let customRoomName = customRoomNameTextField.text, !customRoomName.isEmpty {
            roomName = customRoomName
        } else if let selectedButton = selectedPresetButton {
            roomName = selectedButton.title(for: .normal)
        } else {
            // 如果用户没有选择或输入任何房间名称，则提示用户
            let alert = UIAlertController(title: "提示", message: "请选择或输入一个房间名称", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "确定", style: .default)
            alert.addAction(okAction)
            present(alert, animated: true)
            return
        }
        
        if let roomName = roomName, let roomCreatedCallback = roomCreatedCallback {
            roomCreatedCallback(roomName)
        }
        
        navigationController?.popViewController(animated: true)
    }
}

