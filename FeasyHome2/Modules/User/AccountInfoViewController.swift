//
//  AccountInfoViewController.swift
//  FeasyHome2
//
//  Created by chenchanghua on 2024/12/27.
//

import UIKit
import SnapKit
import SDWebImage
import WebKit

class AccountInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, WKNavigationDelegate {
    var userInfo:UserInfo?
    private var itemList:[(title:String, detail:String)]!
    private var webView:WKWebView!
    private var indicator:UIActivityIndicatorView!
    
    // 头像图片 
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 50 // 圆形头像
        return imageView
    }()
    
    // 表格视图
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.isScrollEnabled = false // 禁止滚动
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.backgroundColor = .clear
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1.0)
        setupNavigationContent()
        itemList = [("用户名", userInfo?.nickname ?? ""),
                    ("绑定手机", userInfo?.mobile ?? ""),
                    ("注销账号", ""),]
        setupWebView()
        setupAvatar()
        setupTableView()
    }
    
    private func setupAvatar() {
        // 添加头像视图
        view.addSubview(avatarImageView)
        
        // 使用 SnapKit 设置头像约束
        avatarImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(30)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(100) // 圆形头像大小
        }
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showImagePickerOptions)))
        
        guard let userInfo = userInfo else { return }
        
        if userInfo.avatar.contains("base64") {
            showSvg(base64String: userInfo.avatar)
        } else {
            self.avatarImageView.sd_setImage(with:URL(string: baseURL + userInfo.avatar), placeholderImage: UIImage(named: "icon_add"), context: nil)
        }
    }
    
    @objc func showImagePickerOptions() {
        let alertController = UIAlertController(title: "选择图片", message: nil, preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "拍照", style: .default) { _ in
            self.openCamera()
        }
        let photoLibraryAction = UIAlertAction(title: "从相册选择", style: .default) { _ in
            self.openPhotoLibrary()
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertController.addAction(cameraAction)
        alertController.addAction(photoLibraryAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true // 允许编辑
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            showAlert(message: "您的设备不支持相机")
        }
    }
    
    func openPhotoLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true // 允许编辑
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            showAlert(message: "无法访问相册")
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var imageData:Data?
        if let image = info[.editedImage] as? UIImage {
            print("选择的图片: \(image)")
            imageData = image.jpegData(compressionQuality: 0.5)
        }
        if let mediaURL = info[.imageURL] as? URL {
            indicator = UIActivityIndicatorView(style: .large)
            self.view.addSubview(indicator)
            indicator.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.centerY.equalTo(avatarImageView.snp.centerY)
            }
            indicator.startAnimating()
            SceneNetManager.shareInstance.uploadFile(fileURL: mediaURL, imgData: nil) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let result):
                    if let url = result?.url {
                        
                        guard let userInfo = self.userInfo else { return }
                        
                        SceneNetManager.shareInstance.modifyUserInfo(type: "avatar", nickname: userInfo.nickname, avatarUrl: url) { [weak self] result in
                            guard let self = self else { return }
                            DispatchQueue.main.async {
                                self.indicator.stopAnimating()
                                self.indicator.removeFromSuperview()
                            }
                            switch result {
                            case .success(let response):
                                print("response2=\(response)")
                                if response.code == 1 {
                                    self.avatarImageView.sd_setImage(with: URL(string: baseURL + url))
                                }
                            case .failure(let error):
                                print("error=\(error)")
                            }
                        }
                    }
                case .failure(let error):
                    print("error=\(error)")
                }
            }
        } else if let imgData = imageData {
            indicator = UIActivityIndicatorView(style: .large)
            self.view.addSubview(indicator)
            indicator.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.centerY.equalTo(avatarImageView.snp.centerY)
            }
            indicator.startAnimating()
            SceneNetManager.shareInstance.uploadFile(fileURL: nil, imgData: imgData) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let result):
                    if let url = result?.url {
                        
                        guard let userInfo = self.userInfo else { return }
                        
                        SceneNetManager.shareInstance.modifyUserInfo(type: "avatar", nickname: userInfo.nickname, avatarUrl: url) { [weak self] result in
                            guard let self = self else { return }
                            DispatchQueue.main.async {
                                self.indicator.stopAnimating()
                                self.indicator.removeFromSuperview()
                            }
                            switch result {
                            case .success(let response):
                                print("response2=\(response)")
                                if response.code == 1 {
                                    self.avatarImageView.sd_setImage(with: URL(string: baseURL + url))
                                }
                            case .failure(let error):
                                print("error=\(error)")
                            }
                        }
                    }
                case .failure(let error):
                    print("error=\(error)")
                }
            }
        }
        if let mediaType = info[.mediaType] as? String {
            print("文件类型: \(mediaType)") // 例如 "public.image"
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func setupNavigationContent() {
        
        self.navigationItem.title = "账号信息"
        
        let backgroundImageView = UIImageView(image: UIImage(named: "img_bg"))
        backgroundImageView.contentMode = .scaleToFill 
        
        let safeInsets = self.view.safeAreaInsets
        backgroundImageView.frame = CGRect(x: 0, y: -safeInsets.top, width: self.view.bounds.size.width, height: (self.view.bounds.size.height + safeInsets.top + safeInsets.bottom) * 331.33 / 812)
        
        self.view.addSubview(backgroundImageView)
        self.view.sendSubviewToBack(backgroundImageView)
    }
    
    private func setupTableView() {
        // 添加 TableView
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // 使用 SnapKit 设置 TableView 约束
        tableView.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).offset(20)
            make.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
        tableView.rowHeight = 74
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
    }
    
    // MARK: - TableView Delegate and DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? 
        UITableViewCell(style: .value1, reuseIdentifier: "cell")
        if indexPath.section == 0 {
            cell.textLabel?.text = itemList[indexPath.row].title
            cell.detailTextLabel?.text = itemList[indexPath.row].detail
            if indexPath.row == 0 {
                cell.accessoryType = .disclosureIndicator
            } else if indexPath.row == itemList.count - 1 {
                cell.accessoryType = .disclosureIndicator
            }
        } else {
            cell.textLabel?.text = "退出登录"
            cell.accessoryType = .disclosureIndicator
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedItem = itemList[indexPath.row]
        // 根据选择的项处理点击事件
        if indexPath.section == 0 {
            switch selectedItem.title {
            case "用户名":
                print("点击用户名")
                // 跳转到用户名编辑页面
                editUserName(indexPath: indexPath)
            case "绑定手机":
                print("点击绑定手机")
                // 跳转到绑定手机页面
            case "注销账号":
                print("点击注销账号")
                // 执行注销逻辑
                deleteUser()
            case "退出登录":
                print("点击退出登录")
                // 执行退出登录逻辑
            default:
                break
            }
        } else if indexPath.section == 1 {
            logout()
        }
    }
    
    private func editUserName(indexPath:IndexPath) {
        let oldName = itemList[indexPath.row].detail
        let alertVC = UIAlertController(title: "用户名修改", message: nil, preferredStyle: .alert)
        alertVC.addTextField { textField in
            textField.placeholder = "请输入用户名"
            textField.text = oldName
        }
        let okAct = UIAlertAction(title: "确定", style: .default) { [weak self, weak alertVC] alertAction in
            guard let self = self,
                  let newName = alertVC?.textFields?.first?.text,
                  !newName.isEmpty,
                  newName != oldName else {
                return
            }
            
            SceneNetManager.shareInstance.modifyUserInfo(type: "nickname", nickname: newName, avatarUrl: "") { result in
                switch result {
                case .success(let resp):
                    if resp.code == 1 {
                        print("用户名修改成功!")
                        
                        DispatchQueue.main.async {
                            self.itemList[indexPath.row].detail = newName
                            self.tableView.reloadRows(at: [indexPath], with: .automatic)
                        }
                    }
                case .failure(let error):
                    print("用户名修改失败,error=\(error)");
                }
            }
        }
        let cancelAct = UIAlertAction(title: "取消", style: .cancel)
        alertVC.addAction(okAct)
        alertVC.addAction(cancelAct)
        self.present(alertVC, animated: true)
    }

    private func deleteUser() {
        let alert = UIAlertController(title: "注销", message: "您确定要注销当前用户吗？", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "确定", style: .destructive) { _ in
            // 执行退出登录逻辑
            SceneNetManager.shareInstance.deleteUser { result in
                switch result {
                case .success:
                    print("注销成功")
                    TokenManager.shared.clearToken()
                    // 设置登录页为根视图
                    let loginVC = LoginViewController()
                    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = scene.windows.first {
                        window.rootViewController = loginVC
                        window.makeKeyAndVisible()
                    }
                case .failure(let error):
                    print("注销失败: \(error.localizedDescription)")
                    TokenManager.shared.clearToken()
                    
                    // 设置登录页为根视图
                    let loginVC = LoginViewController()
                    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = scene.windows.first {
                        window.rootViewController = loginVC
                        window.makeKeyAndVisible()
                    }
                }
            }
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true)
    }
    
    private func logout() {
        let alert = UIAlertController(title: "确认退出", message: "您确定要退出登录吗？", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "确定", style: .destructive) { _ in
            // 执行退出登录逻辑
            APIManager.shared.logout { result in
                switch result {
                case .success:
                    print("退出登录成功")
                    TokenManager.shared.clearToken()
                    kCurrentFamilyID = 0
                    kCurrentFamilyName = ""
                    kCurrentRoomID = 0
                    kCurrentRoomCode = 0
                    kCurrentRoomName = ""
                    // 设置登录页为根视图
                    let loginVC = LoginViewController()
                    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = scene.windows.first {
                        window.rootViewController = loginVC
                        window.makeKeyAndVisible()
                    }
                case .failure(let error):
                    print("退出登录失败: \(error.localizedDescription)")
                    TokenManager.shared.clearToken()
                    
                    // 设置登录页为根视图
                    let loginVC = LoginViewController()
                    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = scene.windows.first {
                        window.rootViewController = loginVC
                        window.makeKeyAndVisible()
                    }
                }
            }
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true)
    }
    
    private func setupWebView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.widthAnchor.constraint(equalToConstant: 30), //  35-5-1+1+6-2
            webView.heightAnchor.constraint(equalToConstant: (30)), //  25+5-1-12-1
            webView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            webView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
    }
    
    private func showSvg(base64String: String) {
        guard let data = Data(base64Encoded: base64String.replacingOccurrences(of: "data:image/svg+xml;base64,", with: "")) else {
            print("Base64 解码失败")
            return
        }
        webView.isHidden = false
        webView.loadHTMLString(String(data: data, encoding: .utf8)!, baseURL: nil)
    }
    func captureWebViewContent() {
        webView.evaluateJavaScript("document.readyState") { [weak self] (complete, error) in
            guard let self = self else { return }
            if complete as? String == "complete" {
                let config = WKSnapshotConfiguration()
                self.webView.takeSnapshot(with: config) { (image, error) in
                    if let image = image {
                        let cropSize = CGSize(width: image.size.width / 2, height: image.size.height / 2)
                            if let croppedImage = image.croppedToMiddle(size: cropSize) {
                                self.avatarImageView.image = croppedImage
                                self.avatarImageView.frame = CGRect(x: 0, y: 0, width: cropSize.width, height: cropSize.height)
                                self.webView.isHidden = true
                            }
                    } else if let error = error {
                        print("捕获图像失败: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        captureWebViewContent()
    }
}

