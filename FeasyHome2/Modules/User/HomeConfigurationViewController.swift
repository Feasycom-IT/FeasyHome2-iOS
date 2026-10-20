//
//  HomeConfigurationViewController.swift
//  FeasyHome2
//
//  Created by chenchanghua on 2024/12/23.
//

import UIKit

class HomeConfigurationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Properties
    var configTableView: UITableView!
    var deleteHomeButton: UIButton!
    var renameHomeButton: UIButton!
    
    var home: Family!
    var homes = ["房间管理", "成员管理"] // 配置选项
    var homeName: String!
    var rooms: [Room] = []
    var members: [Member] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置视图背景色和标题
        self.view.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1.0)
        self.navigationItem.title = home.familyName
        
        fetchRoomList()
        fetchMemberList()
        // 创建配置列表
        setupConfigTableView()
        
        // 创建删除家庭和家庭命名按钮
        setupBottomButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchRoomList()
        fetchMemberList()
    }
    
    private func fetchRoomList() {
        APIManager.shared.fetchRoomList(familyId: home.id) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let roomList):
                self.rooms = roomList
                configTableView.reloadData()
            case .failure(let error):
                print("error=\(error)")
            }
        }
    }
    
    private func fetchMemberList() {
        SceneNetManager.shareInstance.fetchMemberList(familyId: home.id) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let memberList):
                self.members = memberList
                configTableView.reloadData()
            case .failure(let error):
                print("error=\(error)")
            }
        }
    }
    
    // MARK: - 创建配置列表视图
    func setupConfigTableView() {
        configTableView = UITableView(frame: .zero, style: .plain)
        configTableView.delegate = self
        configTableView.dataSource = self
        configTableView.translatesAutoresizingMaskIntoConstraints = false
        configTableView.rowHeight = 80
        configTableView.backgroundColor = .clear
        configTableView.separatorStyle = .none
        self.view.addSubview(configTableView)
        
        NSLayoutConstraint.activate([
            configTableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor,constant: 20),
            configTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            configTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            configTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -80)
        ])
    }
    
    // MARK: - 创建删除家庭和家庭命名按钮视图
    func setupBottomButtons() {
        // 删除家庭按钮
        deleteHomeButton = UIButton(type: .system)
        deleteHomeButton.setTitle("删除家庭", for: .normal)
        deleteHomeButton.setTitleColor(.red, for: .normal)
        deleteHomeButton.backgroundColor = .white
        deleteHomeButton.layer.cornerRadius = 10
        deleteHomeButton.translatesAutoresizingMaskIntoConstraints = false
        deleteHomeButton.addTarget(self, action: #selector(deleteHomeTapped), for: .touchUpInside)
        self.view.addSubview(deleteHomeButton)
        
        // 家庭命名按钮
        renameHomeButton = UIButton(type: .system)
        renameHomeButton.setTitle("家庭命名", for: .normal)
        renameHomeButton.setTitleColor(.black, for: .normal)
        renameHomeButton.backgroundColor = .white
        renameHomeButton.layer.cornerRadius = 10
        renameHomeButton.translatesAutoresizingMaskIntoConstraints = false
        renameHomeButton.addTarget(self, action: #selector(renameHomeTapped), for: .touchUpInside)
        self.view.addSubview(renameHomeButton)
        
        // 设置按钮的布局约束
        NSLayoutConstraint.activate([
            deleteHomeButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            deleteHomeButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            deleteHomeButton.heightAnchor.constraint(equalToConstant: 50),
            deleteHomeButton.widthAnchor.constraint(equalToConstant: (self.view.frame.size.width - 60) / 2),
            
            renameHomeButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            renameHomeButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            renameHomeButton.heightAnchor.constraint(equalToConstant: 50),
            renameHomeButton.widthAnchor.constraint(equalTo: deleteHomeButton.widthAnchor)
        ])
    }
    
    // MARK: - UITableView DataSource & Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return homes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConfigCell") ?? UITableViewCell(style: .value1, reuseIdentifier: "ConfigCell")
//        cell.textLabel?.text = homes[indexPath.row]
//        
//        if indexPath.row == 0 {
//            cell.detailTextLabel?.text =  String(format: "%d房间", rooms.count) //"5房间" // 示例房间数
//        } else if indexPath.row == 1 {
//            cell.detailTextLabel?.text = String(format: "%d成员", members.count)//"3成员" // 示例成员数
//        }
//        cell.accessoryType = .disclosureIndicator
        
        cell.backgroundColor = .clear
        let borderView = UIView()
        borderView.backgroundColor = .white
        borderView.layer.cornerRadius = 6
        cell.addSubview(borderView)
        borderView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(64)
        }
        let titile = UILabel()
        titile.text = homes[indexPath.row]
        borderView.addSubview(titile)
        titile.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }
        let imgView = UIImageView()
        borderView.addSubview(imgView)
        imgView.image = UIImage(systemName: "chevron.right")
        imgView.tintColor = .gray
        imgView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
        }
        let detail = UILabel()
        borderView.addSubview(detail)
        if indexPath.row == 0 {
            detail.text =  String(format: "%d房间", rooms.count)
        } else if indexPath.row == 1 {
            detail.text = String(format: "%d成员", members.count)
        }
        detail.snp.makeConstraints { make in
            make.trailing.equalTo(imgView.snp.leading).offset(-12)
            make.centerY.equalToSuperview()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            // 跳转到房间管理页面
            let roomVC = RoomManagementViewController()
            roomVC.familyId = home.id
            self.navigationController?.pushViewController(roomVC, animated: true)
        } else if indexPath.row == 1 {
            // 跳转到成员管理页面
            let memberVC = MemberManagementViewController()
            memberVC.members = self.members
            self.navigationController?.pushViewController(memberVC, animated: true)
        }
    }
    
    // MARK: - 删除家庭按钮事件
    @objc func deleteHomeTapped() {
        let alert = UIAlertController(title: "删除家庭", message: "确定要删除这个家庭吗？", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "确定", style: .destructive) { _ in
            guard let familyId = self.home?.id else {
                print("无效的家庭 ID")
                return
            }
            
            APIManager.shared.deleteFamily(familyId: familyId) { result in
                switch result {
                case .success:
                    print("家庭已删除")
                    self.navigationController?.popViewController(animated: true)
                case .failure(let error):
                    print("删除家庭失败：\(error.localizedDescription)")
                    self.showErrorAlert(message: "删除家庭失败，请稍后重试")
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true)
    }
    
    // MARK: - 家庭命名按钮事件
    @objc func renameHomeTapped() {
        let alert = UIAlertController(title: "家庭命名", message: "请输入新的家庭名称", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "新的家庭名称"
            textField.text = self.homeName
        }
        
        let confirmAction = UIAlertAction(title: "确定", style: .default) { _ in
            guard let textField = alert.textFields?.first, let newHomeName = textField.text, !newHomeName.isEmpty, let familyId = self.home?.id else {
                self.showErrorAlert(message: "名称不能为空")
                return
            }
            
            // 中文字符与英文字符都计算在内，一个字符算一个单位
            if newHomeName.count > 6 {
                self.showErrorAlert(message: "名称最大长度为6")
                return
            }
            
            APIManager.shared.modifyFamilyName(familyId: familyId, familyName: newHomeName) { result in
                switch result {
                case .success:
                    print("家庭名称已修改为：\(newHomeName)")
                    self.homeName = newHomeName
                    self.navigationItem.title = self.homeName // 更新标题
                case .failure(let error):
                    print("修改家庭名称失败：\(error.localizedDescription)")
                    self.showErrorAlert(message: "修改家庭名称失败，请稍后重试")
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true)
    }
    
    func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "错误", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        self.present(alert, animated: true)
    }

}

