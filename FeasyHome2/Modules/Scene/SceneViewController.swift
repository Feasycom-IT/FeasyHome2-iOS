//
//  SceneViewController.swift
//  FeasyHome2
//
//  Created by chenchanghua on 2024/12/23.
//

import UIKit
import FeasyMeshSDK

class SceneViewController: UIViewController {
    
    var homeSwitchButton: UIButton!
    private var interceptView: UIView?
    var homeListTableView: UITableView!
    var homes: [Family] = []
    var selectedHomeIndex = 0
    
    var sceneCollectionView:UICollectionView!
    var sceneItemList:[SceneListItem] = []
    
    let currentSceneView = UIView()
    let currentSceneName = UILabel()
    
    var rooms: [Room] = []
    
    private var currentMenuView: UIStackView?
    private var menuTargetIndex: Int?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "FeasyHome"
        self.view.backgroundColor = UIColor(red: 245.0/255, green: 245.0/255, blue: 245.0/255, alpha: 1.0)
        let backgroundImageView = UIImageView(image: UIImage(named: "img_bg"))
        backgroundImageView.contentMode = .scaleToFill
        
        let safeInsets = self.view.safeAreaInsets
        backgroundImageView.frame = CGRect(x: 0, y: -safeInsets.top, width: self.view.bounds.size.width, height: (self.view.bounds.size.height + safeInsets.top + safeInsets.bottom) * 331.33 / 812)
        
        self.view.addSubview(backgroundImageView)
        self.view.sendSubviewToBack(backgroundImageView)
        
        setupUI()
        setupCurrentSceneView()
        
        fetchFamilyList()
        fetchHomeSceneList()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchFamilyList()
        dismissHomeListTableView()
        for home in homes {
            if home.id == kCurrentFamilyID {
                homeSwitchButton.setTitle("\(home.familyName)", for: .normal)
            }
        }
        fetchHomeSceneList()
        fetchRoomList(for: kCurrentFamilyID)
    }
    
    private func setupCurrentSceneView() {
        currentSceneView.isHidden = true
        currentSceneView.backgroundColor = .white
        currentSceneView.layer.cornerRadius = 20
        self.view.addSubview(currentSceneView)
        currentSceneView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            currentSceneView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 87.5),
            currentSceneView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -87.5),
            currentSceneView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -100)
        ])
        let title = UILabel()
        currentSceneView.addSubview(title)
        title.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: currentSceneView.topAnchor, constant: 9.5),
            title.leadingAnchor.constraint(equalTo: currentSceneView.leadingAnchor, constant: 20.5),
            title.bottomAnchor.constraint(equalTo: currentSceneView.bottomAnchor, constant: -9.5)
        ])
        title.text = "已使用场景"
        title.textAlignment = .left
        currentSceneView.addSubview(currentSceneName)
        currentSceneName.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            currentSceneName.topAnchor.constraint(equalTo: currentSceneView.topAnchor, constant: 9.5),
            currentSceneName.trailingAnchor.constraint(equalTo: currentSceneView.trailingAnchor, constant: -20.5),
            currentSceneName.bottomAnchor.constraint(equalTo: currentSceneView.bottomAnchor, constant: -9.5)
        ])
        currentSceneName.textColor = UIColor(red: 0/255.0, green: 117/255.0, blue: 201/255.0, alpha: 1.0)
        currentSceneName.textAlignment = .right
    }
    
    private func fetchHomeSceneList() {
        SceneNetManager.shareInstance.fetchHomeSceneList(familyId: kCurrentFamilyID) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(let homeAndSceneList):
                sceneItemList = homeAndSceneList.sceneList
                if let currentScene = homeAndSceneList.nowScene {
                    showCurrentSceneInfo(sceneName: currentScene.sceneName)
                }
                sceneCollectionView.reloadData()
                debugPrint(homeAndSceneList)
            case .failure(let error):
                print(error.errorDescription!)
            }
            
        }
    }
    
    private func fetchFamilyList() {
        APIManager.shared.fetchFamilyList { [weak self] result in
            switch result {
            case .success(let familyList):
                self?.homes = familyList
                for i in 0..<familyList.count {
                    if familyList[i].id == kCurrentFamilyID {
                        self?.selectedHomeIndex = i
                        self?.homeSwitchButton.setTitle("\(familyList[i].familyName)", for: .normal)
                        self?.fetchRoomList(for: kCurrentFamilyID)
                    }
                }
            case .failure(let error):
                print("加载家庭列表失败: \(error.localizedDescription)")
            }
        }
    }
    
    private func fetchRoomList(for familyId: Int) {
        APIManager.shared.fetchRoomList(familyId: familyId) { [weak self] result in
            switch result {
            case .success(let roomList):
                self?.rooms = roomList
                if let firstRoom = roomList.first {
                    kCurrentRoomID = firstRoom.id
                    kCurrentRoomCode = firstRoom.roomCode
                }
            case .failure(let error):
                print("加载房间列表失败: \(error.localizedDescription)")
            }
        }
    }
    
    private func showCurrentSceneInfo(sceneName: String) {
        currentSceneView.isHidden = false
        currentSceneName.text = sceneName
    }
    
    private func setupUI() {
        
        homeSwitchButton = UIButton(type: .custom)
        homeSwitchButton.setTitle("", for: .normal)
        homeSwitchButton.setTitleColor(.black, for: .normal)
        homeSwitchButton.setImage(UIImage(named: "icon_unfold"), for: .normal)
        homeSwitchButton.semanticContentAttribute = .forceRightToLeft
        homeSwitchButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        homeSwitchButton.titleLabel?.font = .boldSystemFont(ofSize: 22)
        homeSwitchButton.addTarget(self, action: #selector(switchHomeTapped), for: .touchUpInside)
        view.addSubview(homeSwitchButton)
        homeSwitchButton.translatesAutoresizingMaskIntoConstraints = false
        homeSwitchButton.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top).offset(kNavBar_Height + 22)
            make.left.equalTo(view.snp.left).offset(20)
            make.height.equalTo(50)
        }
        
        let addButton = UIButton(type: .custom)
        if let customImage = UIImage(named: "icon_add") {
            addButton.setImage(customImage, for: .normal)
        }
        addButton.backgroundColor = .white
        addButton.layer.cornerRadius = 15.5
        addButton.layer.masksToBounds = true
        addButton.addTarget(self, action: #selector(addAction), for: .touchUpInside)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addButton)
        addButton.snp.makeConstraints { make in
            make.centerY.equalTo(homeSwitchButton)
            make.right.equalTo(view.snp.right).offset(-20)
            make.size.equalTo(CGSize(width: 31, height: 31))
        }
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = kScreen_Width*15.0/375
        layout.minimumInteritemSpacing = kScreen_Width*15.0/375
        layout.itemSize = CGSize(width: kScreen_Width*160.0/375, height: kScreen_Width*100.0/375)
        sceneCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        sceneCollectionView.delegate = self
        sceneCollectionView.dataSource = self
        sceneCollectionView.backgroundColor = .clear
        sceneCollectionView.register(SceneCollectionViewCel.self, forCellWithReuseIdentifier: "SceneCollectionViewCell")
        self.view.addSubview(sceneCollectionView)
        sceneCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sceneCollectionView.topAnchor.constraint(equalTo: homeSwitchButton.bottomAnchor,constant: 0),
            sceneCollectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor,constant: 20),
            sceneCollectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor,constant: -20),
            sceneCollectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -150)])
        
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
        sceneCollectionView.backgroundView = bgView
    }
    
    @objc private func addAction() {
        let vc = SceneSelectViewController()
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
        vc.selectSceneCallback = { [weak self] item in
            guard let self = self else {return}
            let newItem = SceneListItem(
                id: item.id,
                sceneName: item.sceneName,
                familyid: kCurrentFamilyID,
                sceneImageUrl: item.sceneImageUrl,
                sceneCode: item.sceneCode,
                is_on: 0,
                bind_group: 0,
                updateTime:0,
                groupList: [],
                curtainGroupList:[]
            )
            
            self.sceneItemList.append(newItem)
            self.sceneCollectionView.reloadData()
        }
    }
    
    private func OperateSceneCmd(sceneID:String, onOff:Int) {
        if let opCode = UInt32("F21102", radix: 16) {
            let meshNetwork = MeshNetworkManager.instance.meshNetwork!
            
            // 将色温值转换为十六进制字符串
            let brightnessHex = String(format: "%02X", onOff)
            let sceneIDHex = sceneID
            // 拼接到参数的末尾
            let parametersHex = "12" + sceneIDHex + brightnessHex
            let parameters = Data(hex: parametersHex)
            
            var message = RuntimeVendorMessage(opCode: opCode, parameters: parameters)
            message.isSegmented = false
            message.security = MeshMessageSecurity.low
            
            do {
                try MeshNetworkManager.instance.send(message, to: MeshAddress(hex: "FFFF")!, using: meshNetwork.applicationKeys.last!)
                print("发送场景的开关调整消息，onOff值：\(onOff)，参数：\(parametersHex)")
            } catch {
                print("发送场景消息失败：\(error)")
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
        
        let location = gesture.location(in: interceptView)
        
        if let tableView = homeListTableView {
            if !tableView.frame.contains(location) {
                dismissHomeListTableView()
            }
        } else if let menuStackView = currentMenuView {
            if !menuStackView.frame.contains(location) {
                dismissHomeListTableView()
            }
        } else { return }
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
    
    // MARK: - menu弹出视图
    
    private func showMenu(for cell: UICollectionViewCell, at index: Int) {
        hideCurrentMenu()
        
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
        
        // 移除已有 interceptView
        interceptView?.removeFromSuperview()
        
        // 新建遮罩层
        let interceptView = UIView(frame: window.bounds)
        interceptView.backgroundColor = UIColor.black.withAlphaComponent(0.001)
        self.interceptView = interceptView
        window.addSubview(interceptView)
        
        // 添加 tap 手势用于关闭菜单
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOnInterceptView(_:)))
        tapGesture.cancelsTouchesInView = false // 不阻止子视图响应
        interceptView.addGestureRecognizer(tapGesture)
        
        // 创建菜单视图
        let menuStackView = UIStackView()
        menuStackView.axis = .vertical
        menuStackView.alignment = .fill
        menuStackView.distribution = .fillEqually
        menuStackView.spacing = 0
        menuStackView.layer.cornerRadius = 6
        menuStackView.layer.masksToBounds = true
        menuStackView.backgroundColor = .white
        menuStackView.layer.shadowColor = UIColor.black.cgColor
        menuStackView.layer.shadowOpacity = 0.5
        menuStackView.layer.shadowOffset = CGSize(width: 0, height: 2)
        menuStackView.layer.shadowRadius = 10
        menuStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // 按钮逻辑
        let editButton = createMenuButton(title: "编辑场景", imageName: "scene_icon_switch") {
            let vc = SceneEditViewController()
            vc.sceneItem = self.sceneItemList[index]
            vc.roomList = self.rooms
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
            self.hideCurrentMenu()
        }
        
        let deleteButton = createMenuButton(title: "删除场景", imageName: "scene_icon_delete") { [weak self] in
            guard let self = self else { return }
            let alert = UIAlertController(title: "确认删除", message: "确定要删除该场景吗？", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { _ in
                self.hideCurrentMenu()
            }))
            alert.addAction(UIAlertAction(title: "删除", style: .destructive, handler: { _ in
                SceneNetManager.shareInstance.deleteScene(sceneCode: self.sceneItemList[index].sceneCode, familyId: kCurrentFamilyID) { result in
                    switch result {
                    case .success:
                        self.sceneItemList.remove(at: index)
                        self.sceneCollectionView.reloadData()
                    case .failure(let error):
                        print("删除失败: \(error)")
                    }
                }
                self.hideCurrentMenu()
            }))
            self.present(alert, animated: true, completion: nil)
        }
        
        [editButton, deleteButton].forEach { menuStackView.addArrangedSubview($0) }
        interceptView.addSubview(menuStackView)
        
        // 计算 imgView 在 window 上的位置
        if let sceneCell = cell as? SceneCollectionViewCel {
            let imgViewFrame = sceneCell.imgView.convert(sceneCell.imgView.bounds, to: interceptView)
            
            menuStackView.snp.makeConstraints { make in
                make.top.equalTo(imgViewFrame.minY + 42)
                make.left.equalTo(imgViewFrame.minX + 10)
                make.width.equalTo(140)
                make.height.equalTo(112)
            }
            currentMenuView = menuStackView
            menuTargetIndex = index
        }
    }
    
    private func hideCurrentMenu() {
        currentMenuView?.removeFromSuperview()
        currentMenuView = nil
        menuTargetIndex = nil
        
        interceptView?.removeFromSuperview()
        interceptView = nil
    }
    
    private func createMenuButton(title: String, imageName: String, action: @escaping () -> Void) -> UIButton {
        let button = UIButton(type: .custom)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.setImage(UIImage(named: imageName), for: .normal)
        
        let spacing: CGFloat = 10
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -spacing/2, bottom: 0, right: spacing/2)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: spacing/2, bottom: 0, right: -spacing/2)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: spacing/2, bottom: 0, right: spacing/2)
        
        button.addAction(UIAction { _ in action() }, for: .touchUpInside)
        return button
    }
}

extension SceneViewController: UITableViewDelegate, UITableViewDataSource {
    
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
            let selectedHome = homes[indexPath.row]
            homeSwitchButton.setTitle("\(selectedHome.familyName)", for: .normal)
            kCurrentFamilyID = selectedHome.id
            fetchHomeSceneList()
            fetchRoomList(for: selectedHome.id)
        } else {
            let homeManagementViewController = HomeManagementViewController.init()
            homeManagementViewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(homeManagementViewController, animated: true)
        }
        dismissHomeListTableView()
    }
}

extension SceneViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if sceneItemList.isEmpty {
            sceneCollectionView.backgroundView?.isHidden = false
        } else {
            sceneCollectionView.backgroundView?.isHidden = true
        }
        return sceneItemList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SceneCollectionViewCell", for: indexPath)
        
        if let cell = cell as? SceneCollectionViewCel {
            cell.imgView.sd_setImage(with: URL(string: baseURL + sceneItemList[indexPath.item].sceneImageUrl))
            cell.lable.text = sceneItemList[indexPath.item].sceneName
            cell.onMoreTapped = { [weak self, weak cell] in
                guard let self = self, let cell = cell else { return }
                self.showMenu(for: cell, at: indexPath.item)
            }
            cell.imgView.tag = indexPath.item
            cell.imgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectScene(gesture: ))))
        }
        
        return cell
    }
    
    @objc private func selectScene(gesture:UITapGestureRecognizer) {
        guard let view = gesture.view else { return }
        let id = sceneItemList[view.tag].id
        SceneNetManager.shareInstance.selectScene(id: id, familyId: kCurrentFamilyID) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let result):
                if result.code == 1 {
                    self.showCurrentSceneInfo(sceneName: sceneItemList[view.tag].sceneName)
                }
            case .failure(let error):
                print("error=\(error)")
            }
        }
        self.OperateSceneCmd(sceneID: sceneItemList[view.tag].sceneCode, onOff: 1)
    }
}

class SceneCollectionViewCel: UICollectionViewCell {
    
    var imgView: UIImageView!
    var lable: UILabel!
    var imgViewMore: UIImageView!
    var onMoreTapped: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    private func setupUI() {
        imgView = UIImageView()
        imgView.isUserInteractionEnabled = true
        addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        lable = UILabel()
        lable.textColor = .white
        lable.font = .systemFont(ofSize: 14)
        imgView.addSubview(lable)
        lable.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-5)
            make.centerX.equalToSuperview()
        }
        
        imgViewMore = UIImageView()
        imgViewMore.image = UIImage(named: "scene_icon_more")
        imgViewMore.contentMode = .center
        imgViewMore.isUserInteractionEnabled = true
        imgView.addSubview(imgViewMore)
        imgViewMore.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.trailing.equalToSuperview()
            make.width.height.equalTo(44)
        }
        
        imgViewMore.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(moreTapped)))
    }
    
    @objc private func moreTapped() {
        onMoreTapped?()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
} 

