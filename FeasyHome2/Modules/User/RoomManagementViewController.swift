//
//  RoomManagementViewController.swift
//  FeasyHome2
//
//  Created by chenchanghua on 2024/12/23.
//

import UIKit

class RoomManagementViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: - Properties
    var roomTableView: UITableView!
    var addRoomButton: UIButton!
    var rooms: [Room] = [] // 存放房间信息
    var familyId: Int = 0 // 当前家庭 ID
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置视图背景色和标题
        self.view.backgroundColor = .white
        self.navigationItem.title = "房间管理"
        
        // 创建房间列表
        setupRoomTableView()
        
        // 创建添加房间按钮
        setupAddRoomButton()
        
        // 加载房间数据
        fetchRoomList()
        roomTableView.register(RoomTableViewCell.self, forCellReuseIdentifier: "RoomTableViewCell")
        roomTableView.separatorStyle = .none
        roomTableView.rowHeight = 74
        roomTableView.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1.0)
        view.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1.0)
    }
    
    // MARK: - 创建房间列表视图
    func setupRoomTableView() {
        roomTableView = UITableView(frame: .zero, style: .plain)
        roomTableView.delegate = self
        roomTableView.dataSource = self
        roomTableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(roomTableView)
        
        
        NSLayoutConstraint.activate([
            roomTableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            roomTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            roomTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            roomTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -100)
        ])
//        roomTableView.separatorStyle = .singleLine
//        roomTableView.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15) // 调整分隔线内边距
//        roomTableView.layoutMargins = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15) // 调整布局边距（可能需要禁用自动布局边距调整）
//        roomTableView.preservesSuperviewLayoutMargins = false
    }
    
    // MARK: - 创建添加房间按钮视图
    func setupAddRoomButton() {
        addRoomButton = UIButton(type: .system)
        addRoomButton.setTitle("创建房间", for: .normal)
        addRoomButton.setTitleColor(.black, for: .normal)
        addRoomButton.backgroundColor = .white
        addRoomButton.layer.cornerRadius = 10
        addRoomButton.translatesAutoresizingMaskIntoConstraints = false
        addRoomButton.addTarget(self, action: #selector(addRoomTapped), for: .touchUpInside)
        self.view.addSubview(addRoomButton)
        
        NSLayoutConstraint.activate([
            addRoomButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            addRoomButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            addRoomButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            addRoomButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: - 加载房间数据
    func fetchRoomList() {
        APIManager.shared.fetchRoomList(familyId: familyId) { [weak self] result in
            switch result {
            case .success(let rooms):
                self?.rooms = rooms
                self?.roomTableView.reloadData()
            case .failure(let error):
                print("加载房间列表失败: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - UITableView DataSource & Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RoomTableViewCell") as? RoomTableViewCell ?? RoomTableViewCell(style: .value1, reuseIdentifier: "RoomTableViewCell") as? RoomTableViewCell
        
        // 设置房间名称
        let room = rooms[indexPath.row]
        cell?.refreshCell(roomName: room.roomName, deviceNum: room.deviceCount)
        cell?.onEditTapped = {
            self.editRoom(at: indexPath)
        }
        cell?.onDeleteTapped = {
            self.confirmDeleteRoom(at: indexPath)
        }
        cell?.selectionStyle = .none
        return cell!
    }
    
    // MARK: - UITableView 编辑（左滑菜单）
//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//        // 编辑房间名称
//        let editAction = UITableViewRowAction(style: .normal, title: "重新命名") { _, indexPath in
//            self.editRoom(at: indexPath)
//        }
//        editAction.backgroundColor = .blue
//        
//        // 删除房间
//        let deleteAction = UITableViewRowAction(style: .destructive, title: "删除房间") { _, indexPath in
//            self.confirmDeleteRoom(at: indexPath)
//        }
//        
//        return [deleteAction, editAction]
//    }
    
    
    
    // MARK: - 编辑房间名称逻辑
    func editRoom(at indexPath: IndexPath) {
        let room = rooms[indexPath.row]
        
        let alert = UIAlertController(title: "编辑房间", message: "编辑 \"\(room.roomName)\" 的名称", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "房间名称"
            textField.text = room.roomName
        }
        
        let confirmAction = UIAlertAction(title: "确定", style: .default) { _ in
            guard let textField = alert.textFields?.first, let newName = textField.text, !newName.isEmpty else {
                self.showAlert(message: "家庭名称不能为空")
                return
            }
            
            // 中文字符与英文字符都计算在内，一个字符算一个单位
            if newName.count > 6 {
                self.showAlert(message: "名称最大长度为6")
                return
            }
            
            APIManager.shared.modifyRoomName(roomId: room.id, roomName: newName) { [weak self] result in
                switch result {
                case .success:
                    self?.rooms[indexPath.row].roomName = newName
                    self?.roomTableView.reloadData()
                case .failure(let error):
                    print("修改房间名称失败: \(error.localizedDescription)")
                }
            }

        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true)
    }
    
    // 辅助方法：显示警告弹窗
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - 删除房间逻辑
    func confirmDeleteRoom(at indexPath: IndexPath) {
        let room = rooms[indexPath.row]
        
        let alert = UIAlertController(title: "删除房间", message: "确定要删除房间 \"\(room.roomName)\" 吗？", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "确定", style: .destructive) { _ in
            APIManager.shared.deleteRoom(roomId: room.id, familyId: self.familyId) { [weak self] result in
                switch result {
                case .success:
                    self?.rooms.remove(at: indexPath.row)
                    self?.roomTableView.deleteRows(at: [indexPath], with: .automatic)
                case .failure(let error):
                    print("删除房间失败: \(error.localizedDescription)")
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true)
    }
    
    // MARK: - 添加房间按钮事件
    @objc func addRoomTapped() {
        let createRoomVC = NewRoomViewController()
        createRoomVC.roomCreatedCallback = { [weak self] roomName in
            guard let self = self else { return }
            APIManager.shared.createRoom(roomName: roomName, familyId: String(self.familyId)) { result in
                switch result {
                case .success:
                    self.fetchRoomList()
                case .failure(let error):
                    print("创建房间失败: \(error.localizedDescription)")
                }
            }
        }
        
        self.navigationController?.pushViewController(createRoomVC, animated: true)
    }
}

class RoomTableViewCell:UITableViewCell {
    private let borderView = UIView(frame: CGRect(x: 20, y: 10, width: kScreen_Width-40, height: 64))
    private let deleteImgView = UIImageView()
    private let roomName = UILabel()
    private let deviceNum = UILabel()
    private let editImgView = UIImageView()
    
    var onEditTapped:(()->Void)?
    var onDeleteTapped:(()->Void)?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        borderView.backgroundColor = UIColor.white
        borderView.layer.cornerRadius = 6;
        borderView.layer.masksToBounds = true
        contentView.insertSubview(borderView, at: 0)
        contentView.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1.0)
        setupUI()
        
    }
    
    private func setupUI() {
        roomName.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        roomName.textColor = .black
        borderView.addSubview(roomName)
        
        deviceNum.font = UIFont.systemFont(ofSize: 16, weight: .light)
        deviceNum.textColor = .gray
        borderView.addSubview(deviceNum)
        
        deleteImgView.image = UIImage(named: "family_icon_roomdel")!
        borderView.addSubview(deleteImgView)
        deleteImgView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
        }
        deleteImgView.isUserInteractionEnabled = true
        let delTapGesture = UITapGestureRecognizer(target: self, action: #selector(touchDelView))
        deleteImgView.addGestureRecognizer(delTapGesture)
        
        editImgView.image = UIImage(named: "family_icon_edit")
        borderView.addSubview(editImgView)
        editImgView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
        }
        editImgView.isUserInteractionEnabled = true;
        let editTabGesture = UITapGestureRecognizer(target: self, action: #selector(touchEditView))
        editImgView.addGestureRecognizer(editTabGesture)
        
        roomName.snp.makeConstraints { make in
            make.leading.equalTo(deleteImgView.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
        }
        
        deviceNum.snp.makeConstraints { make in
            make.leading.equalTo(roomName.snp.trailing).offset(10)
            make.centerY.equalToSuperview()
        }
    }
    
    @objc private func touchEditView() {
        onEditTapped?()
    }
    
    @objc private func touchDelView() {
        onDeleteTapped?()
    }
    
    public func refreshCell(roomName:String, deviceNum:Int) {
        self.roomName.text = roomName
        self.deviceNum.text = String.init(format: "%d设备", deviceNum)
    }
}
