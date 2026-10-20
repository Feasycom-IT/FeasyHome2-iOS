//
//  UserViewController.swift
//  FeasyHome2
//
//  Created by chenchanghua on 2024/12/23.
//

import UIKit
import SnapKit
import SDWebImage
import WebKit

class UserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, WKNavigationDelegate {
    private var userInfo:UserInfo!
    var webView:WKWebView!
    
    // 创建头像和用户名的容器视图
    private let profileView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 35 // 圆形头像
        imageView.image = UIImage(named: "avatar_placeholder") // 替换为默认图片
        return imageView
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "鑫哥"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .black
        return label
    }()
    
    // 创建 TableView
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.backgroundColor = .clear
        return tableView
    }()
    
    // 数据源
    private let items: [String] = ["家庭管理", "邀请成员", "数据同步", "关于我们", "隐私政策", "用户协议", "退出登录"]
    private let itemList:[[(imgName:String, titile:String)]] = [[("mine_icon_family","家庭管理")],[("mine_icon_addmember", "邀请成员"),("mine_icon_datasync", "数据同步")],[("mine_icon_about", "关于我们"),("mine_icon_privacy","隐私政策"),("mine_icon_profile", "用户协议")]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1.0)
        setupNavigationContent()
        fetchUserInfo()
        setupWebView()
        setupProfileView()
        setupTableView()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        fetchUserInfo()
    }
    
    private func fetchUserInfo() {
        SceneNetManager.shareInstance.fetchUserInfo { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let userInfo):
                self.userInfo = userInfo
                self.usernameLabel.text =  userInfo.nickname
                if userInfo.avatar.contains("base64") {
                    showSvg(base64String: userInfo.avatar)
                } else {
                    self.avatarImageView.sd_setImage(with:URL(string: baseURL + userInfo.avatar))
                }
            case .failure(let error):
                print("error=\(error)")
            }
        }
    }
    
    private func setupNavigationContent() {
        
        self.navigationItem.title = "FeasyHome"
        
        let backgroundImageView = UIImageView(image: UIImage(named: "img_bg"))
        backgroundImageView.contentMode = .scaleToFill
        
        let safeInsets = self.view.safeAreaInsets
        backgroundImageView.frame = CGRect(x: 0, y: -safeInsets.top, width: self.view.bounds.size.width, height: (self.view.bounds.size.height + safeInsets.top + safeInsets.bottom) * 331.33 / 812)
        
        self.view.addSubview(backgroundImageView)
        self.view.sendSubviewToBack(backgroundImageView)
    }
    
    private func setupProfileView() {
        let imgNext = UIImageView()
        view.addSubview(profileView)
        profileView.addSubview(avatarImageView)
        profileView.addSubview(usernameLabel)
        imgNext.image = UIImage(systemName: "chevron.right")
        imgNext.tintColor = .gray
        profileView.addSubview(imgNext)
        imgNext.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
        }
        
        // 添加点击事件
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileTapped))
        profileView.addGestureRecognizer(tapGesture)
        profileView.isUserInteractionEnabled = true
        
        // 使用 SnapKit 设置约束
        profileView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(80)
        }
        
        avatarImageView.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
            make.width.height.equalTo(70)
        }
        
        usernameLabel.snp.makeConstraints { make in
            make.left.equalTo(avatarImageView.snp.right).offset(16)
            make.centerY.equalToSuperview()
        }
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UserTableViewCell.self, forCellReuseIdentifier: "UserTableViewCell")
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.rowHeight = 60
        
        // 使用 SnapKit 设置约束
        tableView.snp.makeConstraints { make in
            make.top.equalTo(profileView.snp.bottom).offset(20)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    // MARK: - TableView Delegate and DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return itemList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemList[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableViewCell", for: indexPath) as? UserTableViewCell ?? UserTableViewCell(style: .value1, reuseIdentifier: "UserTableViewCell")
        cell.refresh(titleImgName: itemList[indexPath.section][indexPath.row].imgName, title: itemList[indexPath.section][indexPath.row].titile)
        
        if indexPath.section == 1 && indexPath.row == 0 {
            let lable = UILabel()
            lable.text = "二维码"
            cell.addSubview(lable)
            lable.snp.makeConstraints { make in
                make.trailing.equalToSuperview().offset(-58)
                make.centerY.equalToSuperview()
            }
        }
        if indexPath.section == 0 {
            cell.borderView.layer.cornerRadius = 6
        }
//        else if indexPath.section == 1 {
//            if indexPath.row == 0 {
//                let maskLayer = CAShapeLayer()
//                maskLayer.path = UIBezierPath(roundedRect: cell.borderView.bounds, byRoundingCorners: [.topLeft,.topRight], cornerRadii: CGSize(width: 6.0, height: 6.0)).cgPath
//                cell.borderView.layer.mask = maskLayer
//            } else {
//                let maskLayer = CAShapeLayer()
//                maskLayer.path = UIBezierPath(roundedRect: cell.borderView.bounds, byRoundingCorners: [.bottomLeft,.bottomRight], cornerRadii: CGSize(width: 6.0, height: 6.0)).cgPath
//                cell.borderView.layer.mask = maskLayer
//            }
//        } else if indexPath.section == 2 {
//            if indexPath.row == 0 {
//                let maskLayer = CAShapeLayer()
//                maskLayer.path = UIBezierPath(roundedRect: cell.borderView.bounds, byRoundingCorners: [.topLeft,.topRight], cornerRadii: CGSize(width: 6.0, height: 6.0)).cgPath
//                cell.borderView.layer.mask = maskLayer
//            } else if indexPath.row == 2 {
//                let maskLayer = CAShapeLayer()
//                maskLayer.path = UIBezierPath(roundedRect: cell.borderView.bounds, byRoundingCorners: [.bottomLeft,.bottomRight], cornerRadii: CGSize(width: 6.0, height: 6.0)).cgPath
//                cell.borderView.layer.mask = maskLayer
//            }
//        } else {
//            cell.borderView.layer.mask = nil
//        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedItem = items[indexPath.row]
        
        // 处理点击事件
        print("Selected: \(selectedItem)")
        // 在这里可以根据 `selectedItem` 跳转到具体的页面
        
        if indexPath.section == 0 {
            let homeManagementViewController = HomeManagementViewController.init()
            homeManagementViewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(homeManagementViewController, animated: true)
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                let inviteMemberViewController = InviteMemberViewController.init()
                inviteMemberViewController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(inviteMemberViewController, animated: true)
            } else if indexPath.row == 1 {
                //数据同步操作
            }
        } else if indexPath.section == 2 {
            if indexPath.row == 0 {
                let aboutVC = AboutViewController()
                aboutVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(aboutVC, animated: true)
            } else if indexPath.row == 1 {
                let privacyVC = PrivacyViewController()
                privacyVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(privacyVC, animated: true)
            } else if indexPath.row == 2 {
                let userAgreementVC = UserAgreementViewController()
                userAgreementVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(userAgreementVC, animated: true)
            }
        }
    }
    
    // MARK: - Profile View Tapped
    @objc private func profileTapped() {
        print("Profile tapped")
        // 在这里处理头像和名字的点击事件，例如跳转到用户详情页面
        let accountInfoViewController = AccountInfoViewController.init()
        accountInfoViewController.userInfo = self.userInfo
        accountInfoViewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(accountInfoViewController, animated: true)
    }
    
    private func setupWebView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.widthAnchor.constraint(equalToConstant: 30),
            webView.heightAnchor.constraint(equalToConstant: 30),
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
extension UIImage {
    func croppedToMiddle(size: CGSize) -> UIImage? {
        let originalSize = self.size
        let x = (originalSize.width - size.width) / 2
        let y = (originalSize.height - size.height) / 2
        // 创建图像渲染器
        let renderer = UIGraphicsImageRenderer(size: size)
        // 渲染裁剪后的图像
        return renderer.image { _ in
            self.draw(at: CGPoint(x: -x, y: -y))
        }
    }
}

class UserTableViewCell: UITableViewCell {
    let borderView = UIView()
    private let titleImg = UIImageView()
    private let titleLable = UILabel()
    let nextImg = UIImageView()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    private func setupUI() {
        self.backgroundColor = .clear
        self.selectionStyle = .none
        contentView.insertSubview(borderView, at: 0)
        borderView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.top.bottom.equalToSuperview()
        }
        borderView.backgroundColor = UIColor.white
        borderView.addSubview(titleImg)
        titleImg.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }
        borderView.addSubview(titleLable)
        titleLable.snp.makeConstraints { make in
            make.leading.equalTo(titleImg.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
        }
        nextImg.image = UIImage(systemName: "chevron.right")
        nextImg.tintColor = .gray
        borderView.addSubview(nextImg)
        nextImg.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
        }
        
    }
    
    func refresh(titleImgName:String, title:String) {
        self.titleImg.image = UIImage(named: titleImgName)
        self.titleLable.text = title
    }
}
