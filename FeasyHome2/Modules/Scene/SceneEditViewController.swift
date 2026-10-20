//
//  SceneEditViewController.swift
//  FeasyHome2
//
//  Created by wenjie zeng on 2025/2/12.
//

import UIKit
import FeasyMeshSDK

class SceneEditViewController: UIViewController {
    public var roomList:[Room]!
    public var sceneItem:SceneListItem!
    
    private var tableView:UITableView!
    private var sceneDetailLightGroupList:[SceneDetailLightGroup] = []
    private var sceneDetailCurtainGroupList:[SceneDetailCurtainGroup] = []
    
    private var btnSelectLightGroup:UIButton!
    private var btnSelectCurtainGroup:UIButton!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchSceneDetail()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1.0)
        self.navigationItem.title = "编辑场景"
        fetchSceneDetail()
        setupUI()
    }
    
    private func fetchSceneDetail() {
        SceneNetManager.shareInstance.fetchSceneDetail(sceneCode: sceneItem.sceneCode, familyId: kCurrentFamilyID) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let sceneAndGroupAndCurtainGroupList):
                self.sceneDetailLightGroupList = sceneAndGroupAndCurtainGroupList.groupList
                self.sceneDetailCurtainGroupList = sceneAndGroupAndCurtainGroupList.curtainGroupList
                tableView.reloadData()
            case .failure(let error):
                print("error=\(error)")
            }
        }
    }

    private func setupUI() {
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.rowHeight = 74
        tableView.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1.0)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(EditSceneCell.self, forCellReuseIdentifier: "EditSceneCell")
        tableView.register(SceneGroupTableViewCell.self, forCellReuseIdentifier: "EditSceneGroupCell")
        self.view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -70)
        ])
        
        btnSelectLightGroup = UIButton(type: .custom)
        btnSelectLightGroup.setImage(UIImage(named: "scene_icon_add"), for: .normal)
        btnSelectLightGroup.setTitle("选择灯组", for: .normal)
        btnSelectLightGroup.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        btnSelectLightGroup.setTitleColor(.black, for: .normal)
        btnSelectLightGroup.backgroundColor = .white
        btnSelectLightGroup.layer.cornerRadius = 10
        btnSelectLightGroup.translatesAutoresizingMaskIntoConstraints = false
        btnSelectLightGroup.addTarget(self, action: #selector(selectLightGroupAction), for: .touchUpInside)
        self.view.addSubview(btnSelectLightGroup)
        NSLayoutConstraint.activate([
            btnSelectLightGroup.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            btnSelectLightGroup.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            btnSelectLightGroup.widthAnchor.constraint(equalToConstant: 160),
            btnSelectLightGroup.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        btnSelectCurtainGroup = UIButton(type: .custom)
        btnSelectCurtainGroup.setImage(UIImage(named: "scene_icon_add"), for: .normal)
        btnSelectCurtainGroup.setTitle("选择窗帘组", for: .normal)
        btnSelectCurtainGroup.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        btnSelectCurtainGroup.setTitleColor(.black, for: .normal)
        btnSelectCurtainGroup.backgroundColor = .white
        btnSelectCurtainGroup.layer.cornerRadius = 10
        btnSelectCurtainGroup.translatesAutoresizingMaskIntoConstraints = false
        btnSelectCurtainGroup.addTarget(self, action: #selector(selectCurtainGroupAction), for: .touchUpInside)
        self.view.addSubview(btnSelectCurtainGroup)
        NSLayoutConstraint.activate([
            btnSelectCurtainGroup.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            btnSelectCurtainGroup.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            btnSelectCurtainGroup.widthAnchor.constraint(equalToConstant: 160),
            btnSelectCurtainGroup.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func selectLightGroupAction() {
        let vc = SceneBottomSheetViewController()
        vc.isSelectLight = true
        vc.roomList = roomList
        vc.sceneItem = sceneItem
        vc.onSelectedGroup  = { request in
            let vc = SceneConfigLightViewController()
            vc.joinSceneGroupReq = request
            self.navigationController?.pushViewController(vc, animated: true)
        }
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: false, completion: nil)
    }
    
    @objc private func selectCurtainGroupAction() {
        let vc = SceneBottomSheetViewController()
        vc.isSelectLight = false
        vc.roomList = roomList
        vc.sceneItem = sceneItem
        vc.onSelectedGroup  = { request in
            let vc = SceneConfigCurtainVC()
            vc.joinSceneGroupReq = request
            self.navigationController?.pushViewController(vc, animated: true)
        }
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: false, completion: nil)
    }
    
    private func OperateSceneLightGroupCmdDelete(sceneID:String, groupAddr:String) {
        if let opCode = UInt32("F21102", radix: 16) {
            let meshNetwork = MeshNetworkManager.instance.meshNetwork!
            
            let sceneIDHex = String(format: "%02X", Int(sceneID)!)
            let groupAddrHex = String(format: "%02XC0", Int(groupAddr)!)

            // 拼接到参数的末尾
            let parametersHex = "0C" + sceneIDHex + groupAddrHex + "04"
            let parameters = Data(hex: parametersHex)
            
            var message = RuntimeVendorMessage(opCode: opCode, parameters: parameters)
            message.isSegmented = false
            message.security = MeshMessageSecurity.low
            
            do {
                try MeshNetworkManager.instance.send(message, to: MeshAddress(hex: "FFFF")!, using: meshNetwork.applicationKeys.last!)
                print("发送场景的开关调整消息，sceneID值：\(sceneID)，参数：\(parametersHex)")
            } catch {
                print("发送场景消息失败：\(error)")
            }
        }
    }
}

extension SceneEditViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        } else {
            return sceneDetailLightGroupList.count + sceneDetailCurtainGroupList.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            let str = String.init(format: "已添加组 (%d)", sceneDetailLightGroupList.count + sceneDetailCurtainGroupList.count)
            return str
        } else {
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        let label = UILabel()
        label.text = self.tableView(tableView, titleForHeaderInSection: section)
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.topAnchor.constraint(equalTo: view.topAnchor),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EditSceneCell") as? EditSceneCell ?? EditSceneCell(style: .value1, reuseIdentifier: "EditSceneCell")
            
            if indexPath.row == 0 {
                cell.refresh(title: "选择场景", sceneName: sceneItem.sceneName)
                let maskLayer = CAShapeLayer()
                maskLayer.path = UIBezierPath(roundedRect: cell.borderView.bounds, byRoundingCorners: [.topLeft,.topRight], cornerRadii: CGSize(width: 6.0, height: 6.0)).cgPath
                cell.borderView.layer.mask = maskLayer
            } else {
                cell.refresh(title: "场景图片", sceneImgUrl: sceneItem.sceneImageUrl)
                let maskLayer = CAShapeLayer()
                maskLayer.path = UIBezierPath(roundedRect: cell.borderView.bounds, byRoundingCorners: [.bottomLeft,.bottomRight], cornerRadii: CGSize(width: 6.0, height: 6.0)).cgPath
                cell.borderView.layer.mask = maskLayer
            }
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EditSceneGroupCell", for: indexPath) as? SceneGroupTableViewCell ??
            SceneGroupTableViewCell(style: .value1, reuseIdentifier: "EditSceneGroupCell")
            
            var roomName = ""
            var typeName = ""
            
            if (sceneDetailLightGroupList.count > 0 && indexPath.row < sceneDetailLightGroupList.count) {
                for room in roomList {
                    if room.id == sceneDetailLightGroupList[indexPath.row].roomID {
                        roomName = room.roomName
                        break
                    }
                }
                cell.refreshCell(roomName: roomName, groupName: sceneDetailLightGroupList[indexPath.row].groupName, deviceNum: sceneDetailLightGroupList[indexPath.row].deviceCount)
                typeName = "light"
                
                cell.onNextTapped = {
                    let vc = SceneConfigLightViewController()
                    var joinSceneGroupReq = JoinSceneGroupRequest()
                    joinSceneGroupReq.scene_code = self.sceneItem.sceneCode
                    joinSceneGroupReq.family_id = kCurrentFamilyID
                    joinSceneGroupReq.room_id = self.sceneDetailLightGroupList[indexPath.row].roomID
                    joinSceneGroupReq.address = self.sceneDetailLightGroupList[indexPath.row].groupAddress
                    joinSceneGroupReq.device_type = self.sceneDetailLightGroupList[indexPath.row].deviceType
                    joinSceneGroupReq.group_id = self.sceneDetailLightGroupList[indexPath.row].groupID
                    joinSceneGroupReq.type = typeName
                    joinSceneGroupReq.room_name = roomName
                    joinSceneGroupReq.group_name = self.sceneDetailLightGroupList[indexPath.row].groupName
                    vc.joinSceneGroupReq = joinSceneGroupReq
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
                cell.onDeleteTapped = {
                    let alert = UIAlertController(title: "删除设备组?", message: nil, preferredStyle: .alert)
                    let okActionn = UIAlertAction(title: "确认", style: .default) { UIAlertAction in
                        SceneNetManager.shareInstance.deleteSceneGroup(sceneCode: self.sceneItem.sceneCode, familyId: kCurrentFamilyID, groupAddress: self.sceneDetailLightGroupList[indexPath.row].groupAddress) { [weak self] result in
                            guard let self = self else { return }
                            switch result {
                            case .success(let response):
                                if response.code == 1 {
                                    self.sceneDetailLightGroupList.remove(at: indexPath.row)
                                    tableView.reloadData()
                                }
                            case .failure(let error):
                                print("error=\(error)")
                            }
                        }
                        self.OperateSceneLightGroupCmdDelete(sceneID: self.sceneItem.sceneCode, groupAddr: self.sceneDetailLightGroupList[indexPath.row].groupAddress)
                    }
                    let cancelAction = UIAlertAction(title: "取消", style: .cancel)
                    alert.addAction(okActionn)
                    alert.addAction(cancelAction)
                    self.present(alert, animated: false)
                }
                
            } else if (sceneDetailLightGroupList.count > 0) {
                for room in roomList {
                    if room.id == sceneDetailCurtainGroupList[indexPath.row - sceneDetailLightGroupList.count].roomID {
                        roomName = room.roomName
                        break
                    }
                }
                cell.refreshCell(roomName: roomName, groupName: sceneDetailCurtainGroupList[indexPath.row - sceneDetailLightGroupList.count].groupName, deviceNum: sceneDetailCurtainGroupList[indexPath.row - sceneDetailLightGroupList.count].deviceCount)
                typeName = "curtain"
                
                cell.onNextTapped = {
                    let vc = SceneConfigCurtainVC()
                    var joinSceneGroupReq = JoinSceneGroupRequest()
                    joinSceneGroupReq.scene_code = self.sceneItem.sceneCode
                    joinSceneGroupReq.family_id = kCurrentFamilyID
                    joinSceneGroupReq.room_id = self.sceneDetailCurtainGroupList[indexPath.row - self.sceneDetailLightGroupList.count].roomID ?? 0
                    joinSceneGroupReq.address = self.sceneDetailCurtainGroupList[indexPath.row - self.sceneDetailLightGroupList.count].groupAddress
                    joinSceneGroupReq.device_type = self.sceneDetailCurtainGroupList[indexPath.row - self.sceneDetailLightGroupList.count].deviceType
                    joinSceneGroupReq.group_id = self.sceneDetailCurtainGroupList[indexPath.row - self.sceneDetailLightGroupList.count].groupID
                    joinSceneGroupReq.type = typeName
                    joinSceneGroupReq.room_name = roomName
                    joinSceneGroupReq.group_name = self.sceneDetailCurtainGroupList[indexPath.row - self.sceneDetailLightGroupList.count].groupName
                    vc.joinSceneGroupReq = joinSceneGroupReq
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
                cell.onDeleteTapped = {
                    let alert = UIAlertController(title: "删除设备组?", message: nil, preferredStyle: .alert)
                    let okActionn = UIAlertAction(title: "确认", style: .default) { UIAlertAction in
                        SceneNetManager.shareInstance.deleteSceneGroup(sceneCode: self.sceneItem.sceneCode, familyId: kCurrentFamilyID, groupAddress: self.sceneDetailCurtainGroupList[indexPath.row - self.sceneDetailLightGroupList.count].groupAddress) { [weak self] result in
                            guard let self = self else { return }
                            switch result {
                            case .success(let response):
                                if response.code == 1 {
                                    self.sceneDetailCurtainGroupList.remove(at: indexPath.row - self.sceneDetailLightGroupList.count)
                                    tableView.reloadData()
                                }
                            case .failure(let error):
                                print("error=\(error)")
                            }
                        }
                        self.OperateSceneLightGroupCmdDelete(sceneID: self.sceneItem.sceneCode, groupAddr: self.sceneDetailCurtainGroupList[indexPath.row - self.sceneDetailLightGroupList.count].groupAddress)
                    }
                    let cancelAction = UIAlertAction(title: "取消", style: .cancel)
                    alert.addAction(okActionn)
                    alert.addAction(cancelAction)
                    self.present(alert, animated: false)
                }
                
            } else {
                for room in roomList {
                    if room.id == sceneDetailCurtainGroupList[indexPath.row].roomID {
                        roomName = room.roomName
                        break
                    }
                }
                cell.refreshCell(roomName: roomName, groupName: sceneDetailCurtainGroupList[indexPath.row].groupName, deviceNum: sceneDetailCurtainGroupList[indexPath.row].deviceCount)
                typeName = "curtain"
                
                cell.onNextTapped = {
                    let vc = SceneConfigCurtainVC()
                    var joinSceneGroupReq = JoinSceneGroupRequest()
                    joinSceneGroupReq.scene_code = self.sceneItem.sceneCode
                    joinSceneGroupReq.family_id = kCurrentFamilyID
                    joinSceneGroupReq.room_id = self.sceneDetailCurtainGroupList[indexPath.row].roomID ?? 0
                    joinSceneGroupReq.address = self.sceneDetailCurtainGroupList[indexPath.row].groupAddress
                    joinSceneGroupReq.device_type = self.sceneDetailCurtainGroupList[indexPath.row].deviceType
                    joinSceneGroupReq.group_id = self.sceneDetailCurtainGroupList[indexPath.row].groupID
                    joinSceneGroupReq.type = typeName
                    joinSceneGroupReq.room_name = roomName
                    joinSceneGroupReq.group_name = self.sceneDetailCurtainGroupList[indexPath.row].groupName
                    vc.joinSceneGroupReq = joinSceneGroupReq
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
                cell.onDeleteTapped = {
                    let alert = UIAlertController(title: "删除设备组?", message: nil, preferredStyle: .alert)
                    let okActionn = UIAlertAction(title: "确认", style: .default) { UIAlertAction in
                        SceneNetManager.shareInstance.deleteSceneGroup(sceneCode: self.sceneItem.sceneCode, familyId: kCurrentFamilyID, groupAddress: self.sceneDetailCurtainGroupList[indexPath.row].groupAddress) { [weak self] result in
                            guard let self = self else { return }
                            switch result {
                            case .success(let response):
                                if response.code == 1 {
                                    self.sceneDetailCurtainGroupList.remove(at: indexPath.row)
                                    tableView.reloadData()
                                }
                            case .failure(let error):
                                print("error=\(error)")
                            }
                        }
                        self.OperateSceneLightGroupCmdDelete(sceneID: self.sceneItem.sceneCode, groupAddr: self.sceneDetailCurtainGroupList[indexPath.row].groupAddress)
                    }
                    let cancelAction = UIAlertAction(title: "取消", style: .cancel)
                    alert.addAction(okActionn)
                    alert.addAction(cancelAction)
                    self.present(alert, animated: false)
                }
                
            }
            
            cell.selectionStyle = .none
            return cell
        }
    }
}

class EditSceneCell: UITableViewCell {
    private let title = UILabel(frame: CGRect(x: 10, y: 10, width: 20, height: 20))
    private let sceneName = UILabel(frame: CGRect(x: 10, y: 10, width: 20, height: 20))
    private let sceneImgView = UIImageView(frame: CGRect(x: 10, y: 10, width: 20, height: 20))
    let borderView = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1.0)
        contentView.insertSubview(borderView, at: 0)
        
        borderView.backgroundColor = .white
        borderView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.top.bottom.equalToSuperview()
        }
        
        borderView.addSubview(title)
        title.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }
        
        borderView.addSubview(sceneName)
        sceneName.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
        }
        
        sceneImgView.contentMode = .scaleAspectFit
        sceneImgView.clipsToBounds = true
        borderView.addSubview(sceneImgView)
        sceneImgView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 40, height: 25))
        }
    }
    
    func refresh(title:String, sceneName:String) {
        self.title.text = title
        self.sceneName.text = sceneName
        self.sceneName.isHidden = false
        self.sceneImgView.isHidden = true
    }
    
    func refresh(title:String, sceneImgUrl:String) {
        self.title.text = title
        self.sceneImgView.sd_setImage(with: URL(string: baseURL + sceneImgUrl))
        self.sceneName.isHidden = true
        self.sceneImgView.isHidden = false
    }
}

class SceneGroupTableViewCell: UITableViewCell {
    private let borderView = UIView(frame: CGRect(x: 20, y: 10, width: kScreen_Width-40, height: 64))
    private let deleteImgView = UIImageView()
    private let roomName = UILabel()
    private let devName = UILabel()
    private let deviceNum = UILabel()
    private let nextImgView = UIImageView()
    
    var onNextTapped:(()->Void)?
    var onDeleteTapped:(()->Void)?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    private func setupUI() {
        contentView.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1.0)
        contentView.insertSubview(borderView, at: 0)
        
        borderView.backgroundColor = UIColor.white
        borderView.layer.cornerRadius = 6;
        borderView.layer.masksToBounds = true
        
        deleteImgView.image = UIImage(named: "family_icon_roomdel")!
        deleteImgView.isUserInteractionEnabled = true
        let delTapGesture = UITapGestureRecognizer(target: self, action: #selector(touchDelView))
        deleteImgView.addGestureRecognizer(delTapGesture)
        borderView.addSubview(deleteImgView)
        deleteImgView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
        }
        
        roomName.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        roomName.textColor = .black
        borderView.addSubview(roomName)
        roomName.snp.makeConstraints { make in
            make.leading.equalTo(deleteImgView.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
        }
        
        devName.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        devName.textColor = .black
        borderView.addSubview(devName)
        devName.snp.makeConstraints { make in
            make.leading.equalTo(roomName.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
        }
        
        deviceNum.font = UIFont.systemFont(ofSize: 16, weight: .light)
        deviceNum.textColor = .gray
        borderView.addSubview(deviceNum)
        deviceNum.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-38)
            make.centerY.equalToSuperview()
        }
        
        nextImgView.image =  UIImage(systemName: "chevron.right")
        nextImgView.contentMode = .center
        nextImgView.isUserInteractionEnabled = true;
        let editTabGesture = UITapGestureRecognizer(target: self, action: #selector(touchEditView))
        nextImgView.addGestureRecognizer(editTabGesture)
        nextImgView.tintColor = .gray
        borderView.addSubview(nextImgView)
        nextImgView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(64)
            make.width.equalTo(60)
        }
    }
    
    @objc private func touchEditView() {
        onNextTapped?()
    }
    
    @objc private func touchDelView() {
        onDeleteTapped?()
    }
    
    public func refreshCell(roomName:String, groupName:String, deviceNum:Int) {
        self.roomName.text = roomName
        self.devName.text = groupName
        self.deviceNum.text = String.init(format: "%d设备", deviceNum)
    }
}
