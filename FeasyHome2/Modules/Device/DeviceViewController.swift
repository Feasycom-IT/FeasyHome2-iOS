//
//  DeviceViewController.swift
//  FeasyHome2
//
//  Created by chenchanghua on 2024/12/23.
//

import UIKit

typealias DeviceTuple = (type: Int, name: String, address: String, count: Int)

class HomeManagerTCell: UITableViewCell {
    
    private var line: UIView = {
        let line = UIView()
        line.backgroundColor = UIColor(red: 0.87, green: 0.87, blue: 0.87, alpha: 1.00)
        return line
    }()
    
    private var image: UIImageView = {
        let image = UIImageView(image: UIImage(named: "primary_icon_manage"))
        return image
    }()
    
    private var title: UILabel = {
        let title = UILabel()
        title.text = "管理家庭"
        return title
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(line)
        line.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(0.5)
        }
        contentView.addSubview(image)
        image.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(line)
            make.size.equalTo(CGSize(width: 20, height: 20))
        }
        contentView.addSubview(title)
        title.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(image.snp.right).offset(12)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

class DeviceHomeRoomCell: UICollectionViewCell {
    var roomNameLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // 初始化roomNameLabel
        roomNameLabel = UILabel()
        roomNameLabel.textAlignment = .center
        roomNameLabel.font = UIFont.boldSystemFont(ofSize: 18)
        roomNameLabel.numberOfLines = 1 // 防止文字换行
        roomNameLabel.lineBreakMode = .byTruncatingTail // 文字过长时显示省略号
        contentView.addSubview(roomNameLabel)
        roomNameLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView)
            make.height.equalTo(40)
            make.left.equalTo(contentView.snp.left)
            make.right.equalTo(contentView.snp.right)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configureCell(roomName: String, isSelected: Bool) {
        roomNameLabel.text = roomName
        roomNameLabel.textColor = isSelected ? .black : UIColor(red: 0.67, green: 0.67, blue: 0.67, alpha: 1.00)
    }
    
}

class DeviceViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Properties
    var homeSwitchButton: UIButton!
    var addButton: UIButton!
    var roomCollectionView: UICollectionView!
    var deviceCollectionView: UICollectionView!
    var homeListTableView: UITableView!
    private var interceptView: UIView?
    
    var homes: [Family] = []        // 家庭数据从 API 获取
    var rooms: [Room] = []          // 房间数据从 API 获取
    var devices: [DeviceTuple] = [] // 设备列表，用于展示在 collection view 中
    
    var memeryFamilyId = 0
    var selectedHomeIndex = 0
    var selectedRoomIndex = 0
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.00)
        
        setupNavigationContent()
        
        setupTopButtons()
        setupRoomCollectionView()
        setupDeviceCollectionView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchFamilyList()
    }

    func setupNavigationContent() {
        
        self.navigationItem.title = "FeasyHome"
        
        let backgroundImageView = UIImageView(image: UIImage(named: "img_bg"))
        backgroundImageView.contentMode = .scaleToFill
        
        let safeInsets = self.view.safeAreaInsets
        backgroundImageView.frame = CGRect(x: 0, y: -safeInsets.top, width: self.view.bounds.size.width, height: (self.view.bounds.size.height + safeInsets.top + safeInsets.bottom) * 331.33 / 812)
        
        self.view.addSubview(backgroundImageView)
        self.view.sendSubviewToBack(backgroundImageView)
    }
    
    // MARK: - 加载家庭列表
    private func fetchFamilyList() {
        APIManager.shared.fetchFamilyList { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(let familyList):
                if familyList.count == 0 {
                    // 生成 networkId 和 networkData
                    let networkId = UUID().uuidString
                    let networkData = self.generateNetworkData()
                    let familyStr = String.randomString(length: 8) // 生成随机的 familyStr，长度为8
                    
                    // 调用 API 创建家庭
                    APIManager.shared.createFamily(familyName: "默认家庭", networkData: networkData, networkId: networkId, familyStr: familyStr) { [weak self] result in
                        guard let self = self else { return }
                        
                        switch result {
                        case .success():
                            self.fetchFamilyList()
                        case .failure(let error):
                            print("创建家庭失败: \(error.localizedDescription)")
                        }
                    }
                    return
                }
                
                self.homes = familyList
                
                if kCurrentFamilyID != self.memeryFamilyId {
                    for i in 0..<familyList.count {
                        if familyList[i].id == kCurrentFamilyID {
                            self.selectedHomeIndex = i
                            self.selectedRoomIndex = 0
                            kCurrentFamilyName = familyList[i].familyName
                        }
                    }
                }
                
                if kCurrentFamilyID == 0 {
                    if let firstFamily = familyList.first {
                        self.selectedHomeIndex = 0
                        kCurrentFamilyID = firstFamily.id
                        kCurrentFamilyName = firstFamily.familyName
                        self.memeryFamilyId = kCurrentFamilyID
                    }
                }
                self.homeSwitchButton.setTitle(kCurrentFamilyName, for: .normal)
                self.fetchRoomList(for: kCurrentFamilyID)
            case .failure(let error):
                print("加载家庭列表失败: \(error.localizedDescription)")
            }
        }
    }
    
    // 辅助方法：生成 networkData
    private func generateNetworkData() -> String {
        // 根据实际业务逻辑生成 networkData
        // 例如，将一些信息编码为 Base64 字符串
        let data = ["name": "家庭网络"].description.data(using: .utf8) ?? Data()
        return data.base64EncodedString()
    }
    
    // MARK: - 加载房间列表
    private func fetchRoomList(for familyId: Int) {
        APIManager.shared.fetchRoomList(familyId: familyId) { [weak self] result in
            switch result {
            case .success(let roomList):
                self?.rooms = roomList
                self?.roomCollectionView.reloadData()
                
                if let selectedRoomIndex = self?.selectedRoomIndex, selectedRoomIndex != 0, selectedRoomIndex < roomList.count {
                    let selectedRoom = roomList[selectedRoomIndex]
                    kCurrentRoomID = selectedRoom.id
                    kCurrentRoomCode = selectedRoom.roomCode
                    kCurrentRoomName = selectedRoom.roomName
                } else {
                    if let firstRoom = roomList.first {
                        self?.selectedRoomIndex = 0
                        kCurrentRoomID = firstRoom.id
                        kCurrentRoomCode = firstRoom.roomCode
                        kCurrentRoomName = firstRoom.roomName
                    }
                }
                self?.fetchHomeRoomAndDeviceData(familyId: familyId, roomId: kCurrentRoomID)
            case .failure(let error):
                print("加载房间列表失败: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - 加载首页家庭、房间、组列表数据
    private func fetchHomeRoomAndDeviceData(familyId: Int, roomId: Int) {
        APIManager.shared.fetchHomeRoomAndDeviceData(familyId: String(familyId), roomId: String(roomId)) { [weak self] result in
            switch result {
            case .success(let response):
                // 处理从 API 获取的数据并合并设备列表
                var combinedDevices: [DeviceTuple] = []
                
                // 合并 lightGroupList、curtainGroupList、panelList 和 voiceList 中的设备数据
                for group in response.data.lightGroupList {
                    let device = (type: 1, name: group.groupName, address: group.address, count: group.deviceCount)
                    combinedDevices.append(device)
                }
                
                for group in response.data.curtainGroupList {
                    let device = (type: 5, name: group.groupName, address: group.address, count: group.deviceCount)
                    combinedDevices.append(device)
                }
                
                for panel in response.data.panelList {
                    let device = (type: 3, name: panel.deviceName, address: String(format: "%04X", panel.destination), count: 1) // count 设置为1，假设每个面板只有一个设备
                    combinedDevices.append(device)
                }
                
                for voice in response.data.voiceList {
                    let device = (type: 4, name: voice.deviceName, address: String(format: "%02X", voice.destination), count: 1) // count 设置为1，假设每个语音设备只有一个
                    combinedDevices.append(device)
                }
                
                // 更新设备列表
                self?.devices = combinedDevices
                self?.deviceCollectionView.reloadData()
                
            case .failure(let error):
                print("加载设备数据失败: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - 家庭列表弹出视图
    @objc private func switchHomeTapped() {
        guard homeListTableView == nil else {
            dismissHomeListTableView()
            return
        }
        
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
        
        // 遮罩层，覆盖整个屏幕
        let interceptView = UIView(frame: window.bounds)
        interceptView.backgroundColor = UIColor.black.withAlphaComponent(0.001)
        self.interceptView = interceptView
        window.addSubview(interceptView)
        
        // 添加 tableView 到遮罩层上
        let tableView = UITableView(frame: .zero, style: .plain)
        homeListTableView = tableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.cornerRadius = 10
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        interceptView.addSubview(tableView)
        
        // 定位 tableView 相对于 anchor button
        let anchorFrame = homeSwitchButton.convert(homeSwitchButton.bounds, to: interceptView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(anchorFrame.maxY + 8)
            make.left.equalTo(anchorFrame.minX)
            make.width.equalTo(200)
            make.height.equalTo(0)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.updateTableViewHeight()
        }
        
        // 添加 tap 手势，但不阻止 touches 向子视图传递
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOnInterceptView(_:)))
        tapGesture.cancelsTouchesInView = false  // ✅ 允许子视图响应触摸事件
        interceptView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTapOnInterceptView(_ gesture: UITapGestureRecognizer) {
        guard let tableView = homeListTableView else { return }
        
        let location = gesture.location(in: interceptView)
        if !tableView.frame.contains(location) {
            dismissHomeListTableView()
        }
        // 否则：点击的是 tableView 区域 → 不做任何事（保留 cell 响应）
    }
    
    private func updateTableViewHeight() {
        let contentHeight = homeListTableView.contentSize.height
        let maxHeight: CGFloat = 226
        let newHeight = min(contentHeight, maxHeight)
        
        homeListTableView.snp.updateConstraints { make in
            make.height.equalTo(newHeight)
        }
    }
    
    @objc private func dismissHomeListTableView() {
        homeListTableView?.removeFromSuperview()
        homeListTableView = nil
        
        interceptView?.removeFromSuperview()
        interceptView = nil
    }
    
    // MARK: - UITableView DataSource & Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return homes.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < homes.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomeCell") ?? UITableViewCell(style: .default, reuseIdentifier: "HomeCell")
            cell.textLabel?.text = homes[indexPath.row].familyName
            
            if indexPath.row == selectedHomeIndex {
                cell.textLabel?.textColor = .systemBlue
                cell.accessoryType = .checkmark
            } else {
                cell.textLabel?.textColor = .black
                cell.accessoryType = .none
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomeManagerTCell") ?? HomeManagerTCell(style: .default, reuseIdentifier: "HomeManagerTCell")
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < homes.count {
            selectedHomeIndex = indexPath.row
            selectedRoomIndex = 0
            let selectedHome = homes[indexPath.row]
            kCurrentFamilyID = selectedHome.id
            kCurrentFamilyName = selectedHome.familyName
            memeryFamilyId = kCurrentFamilyID
            homeSwitchButton.setTitle(kCurrentFamilyName, for: .normal)
            fetchRoomList(for: selectedHome.id)
        } else {
            let homeManagementViewController = HomeManagementViewController.init()
            homeManagementViewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(homeManagementViewController, animated: true)
        }
        
        dismissHomeListTableView()
    }
    
    // MARK: - UICollectionView DataSource & Delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == roomCollectionView {
            return rooms.count
        } else {
            if devices.count == 0 {
                deviceCollectionView.backgroundView?.isHidden = false
            } else {
                deviceCollectionView.backgroundView?.isHidden = true
            }
            return devices.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == roomCollectionView {
            // 使用自定义的DeviceHomeRoomCell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DeviceHomeRoomCell", for: indexPath) as! DeviceHomeRoomCell
            
            // 获取房间名称
            let roomName = rooms[indexPath.row].roomName
            
            // 配置cell
            cell.configureCell(roomName: roomName, isSelected: indexPath.item == selectedRoomIndex)
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DeviceCell", for: indexPath) as! DeviceCollectionViewCell
            
            // 获取设备数据
            let device = devices[indexPath.item]
            var deviceImage: UIImage?
            if device.type == 1 {
                deviceImage = UIImage(named: "dev_img_light")
            } else if device.type == 5 {
                deviceImage = UIImage(named: "dev_img_curtain")
            } else if device.type == 3 {
                deviceImage = UIImage(named: "dev_search_icon_panel")
            } else {
                deviceImage = UIImage(named: "dev_search_icon_audio")
            }
            let deviceName = device.name
            let deviceCount = device.count
            
            // 配置设备cell
            cell.configureCell(deviceType: device.type, deviceImage: deviceImage ?? UIImage(), deviceName: deviceName, deviceCount: deviceCount)
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == roomCollectionView {
            // 更新选中项的索引
            selectedRoomIndex = indexPath.item
            roomCollectionView.reloadData()
            
            let currentRoom = rooms[selectedRoomIndex]
            print("currentRoom = \(currentRoom.familyId), \(currentRoom.id)")
            kCurrentRoomID = currentRoom.id
            kCurrentRoomCode = currentRoom.roomCode
            kCurrentRoomName = currentRoom.roomName
            fetchHomeRoomAndDeviceData(familyId: kCurrentFamilyID, roomId: kCurrentRoomID)
            
        } else {
            let device = self.devices[indexPath.row]
            if device.type == 1 {
                let deviceLightControl = DeviceControlLight()
                deviceLightControl.groupName = device.name
                deviceLightControl.address = device.address
                deviceLightControl.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(deviceLightControl, animated: true)
            } else if device.type == 5 {
                let deviceControlCurtain = DeviceControlCurtain()
                deviceControlCurtain.device = device
                deviceControlCurtain.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(deviceControlCurtain, animated: true)
            } else if device.type == 3 {
                let deviceControlPanel = DeviceControlPanel()
                deviceControlPanel.groupName = device.name
                deviceControlPanel.address = device.address
                deviceControlPanel.roomList = rooms
                deviceControlPanel.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(deviceControlPanel, animated: true)
            } else if device.type == 4 {
                let deviceControlVoice = DeviceControlVoice()
                deviceControlVoice.device = device
                deviceControlVoice.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(deviceControlVoice, animated: true)
            }
        }
    }
    
    // MARK: - Setup Methods
    private func setupTopButtons() {
        
        // 家庭切换按钮
        homeSwitchButton = UIButton(type: .custom)
        homeSwitchButton.setTitle("", for: .normal)
        homeSwitchButton.setTitleColor(.black, for: .normal)
        homeSwitchButton.setImage(UIImage(named: "icon_unfold"), for: .normal)
        homeSwitchButton.semanticContentAttribute = .forceRightToLeft
        homeSwitchButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        homeSwitchButton.titleLabel?.font = .boldSystemFont(ofSize: 22)
        homeSwitchButton.addTarget(self, action: #selector(switchHomeTapped), for: .touchUpInside)
        homeSwitchButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(homeSwitchButton)
        homeSwitchButton.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top).offset(kNavBar_Height + 22)
            make.left.equalTo(view.snp.left).offset(20)
            make.height.equalTo(50)
        }
        
        // 添加按钮
        addButton = UIButton(type: .custom)
        if let customImage = UIImage(named: "icon_add") {
            addButton.setImage(customImage, for: .normal)
        }
        addButton.backgroundColor = .white
        addButton.layer.cornerRadius = 15.5
        addButton.layer.masksToBounds = true
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addButton)
        addButton.snp.makeConstraints { make in
            make.centerY.equalTo(homeSwitchButton)
            make.right.equalTo(view.snp.right).offset(-20)
            make.size.equalTo(CGSize(width: 31, height: 31))
        }
    }
    
    private func setupRoomCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 20
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
        roomCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        roomCollectionView.delegate = self
        roomCollectionView.dataSource = self
        roomCollectionView.backgroundColor = .clear
        roomCollectionView.showsHorizontalScrollIndicator = false
        roomCollectionView.showsVerticalScrollIndicator = false
        roomCollectionView.register(DeviceHomeRoomCell.self, forCellWithReuseIdentifier: "DeviceHomeRoomCell")
        self.view.addSubview(roomCollectionView)
        roomCollectionView.translatesAutoresizingMaskIntoConstraints = false
        roomCollectionView.snp.makeConstraints { make in
            make.top.equalTo(homeSwitchButton.snp.bottom).offset(0)
            make.left.equalTo(view.snp.left).offset(20)
            make.right.equalTo(view.snp.right).offset(-20)
            make.height.equalTo(40)
        }
        roomCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 100)
        roomCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) 
    }

    private func setupDeviceCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 15
        layout.minimumInteritemSpacing = 15
        layout.itemSize = CGSize(width: 160, height: 120)
        
        deviceCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        deviceCollectionView.delegate = self
        deviceCollectionView.dataSource = self
        deviceCollectionView.backgroundColor = .clear
        let bgView: UIView = {
            let bgV = UIView()
            bgV.backgroundColor = .clear
            let image = UIImageView(image: UIImage(named: "img_default"))
            bgV.addSubview(image)
            image.snp.makeConstraints { make in
                make.size.equalTo(CGSize(width: 280, height: 280))
                make.centerX.equalToSuperview()
                make.top.equalTo(bgV).offset(40)
            }
            
            let label = UILabel()
            label.text = "暂无设备"
            label.textColor = UIColor(red: 0.67, green: 0.67, blue: 0.67, alpha: 1.00)
            bgV.addSubview(label)
            label.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalTo(image.snp.bottom)
            }
            
            return bgV
        }()
        deviceCollectionView.backgroundView = bgView
        deviceCollectionView.register(DeviceCollectionViewCell.self, forCellWithReuseIdentifier: "DeviceCell")
        
        self.view.addSubview(deviceCollectionView)
        deviceCollectionView.snp.makeConstraints { make in
            make.top.equalTo(roomCollectionView.snp.bottom).offset(16)
            make.left.equalTo(view.snp.left).offset(20)
            make.right.equalTo(view.snp.right).offset(-20)
            make.bottom.equalTo(view.snp.bottom).offset(-kTabBar_Height)
        }
    }
    
    // MARK: - Button Actions
    @objc private func addButtonTapped() {
        print("添加按钮被点击")
        // 实现添加设备的逻辑
        let deviceAdditionViewController = DeviceAdditionViewController()
        deviceAdditionViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(deviceAdditionViewController, animated: true)
    }
}

extension DeviceViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {//contentSize
        
        if collectionView == roomCollectionView {
            let roomName = rooms[indexPath.row].roomName
            // 根据房间名称的长度动态计算宽度，可以根据实际需求调整这个逻辑
            let width = roomName.size(withAttributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)]).width
            return CGSize(width: width, height: 40)
        } else {
            return CGSize(width: 160, height: 120)
        }
    }
}



