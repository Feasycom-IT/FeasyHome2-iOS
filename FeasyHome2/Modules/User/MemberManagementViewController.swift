//
//  MemberManagementViewController.swift
//  FeasyHome2
//
//  Created by chenchanghua on 2024/12/23.
//

import UIKit
import WebKit

class MemberManagementViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Properties
    var memberTableView: UITableView!
    var inviteMemberButton: UIButton!
    
    var members: [Member]! //= ["鑫哥", "小老婆", "老王"] // 存放成员信息
    var adminName: String = "鑫哥" // 房间管理员的名字
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置视图背景色和标题
        self.view.backgroundColor = .white
        self.navigationItem.title = "成员管理"
        self.view.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1.0)
        // 创建成员列表
        setupMemberTableView()
        
        // 创建邀请成员按钮
        setupInviteMemberButton()
    }
    
    // MARK: - 创建成员列表视图
    func setupMemberTableView() {
        memberTableView = UITableView(frame: .zero, style: .plain)
        memberTableView.delegate = self
        memberTableView.dataSource = self
        memberTableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(memberTableView)
        memberTableView.rowHeight = 74
        memberTableView.separatorStyle = .none
        memberTableView.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1.0)
        
        NSLayoutConstraint.activate([
            memberTableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            memberTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            memberTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            memberTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -70)
        ])
    }
    
    // MARK: - 创建邀请成员按钮视图
    func setupInviteMemberButton() {
        inviteMemberButton = UIButton(type: .system)
        inviteMemberButton.setTitle("邀请成员", for: .normal)
        inviteMemberButton.setTitleColor(.black, for: .normal)
        inviteMemberButton.backgroundColor = .white
        inviteMemberButton.layer.cornerRadius = 10
        inviteMemberButton.translatesAutoresizingMaskIntoConstraints = false
        inviteMemberButton.addTarget(self, action: #selector(inviteMemberTapped), for: .touchUpInside)
        self.view.addSubview(inviteMemberButton)
        
        NSLayoutConstraint.activate([
            inviteMemberButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            inviteMemberButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            inviteMemberButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            inviteMemberButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: - UITableView DataSource & Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return members.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemberTableViewCell") as? MemberTableViewCell ?? MemberTableViewCell(style: .subtitle, reuseIdentifier: "MemberTableViewCell") as MemberTableViewCell
        
        let memberName = members[indexPath.row].nickname
        
        if members[indexPath.row].auth_type == "manage" {
            cell.refreshCell(name: memberName, position: "管理员", profileImageUrl: members[indexPath.row].avatar)
        } else {
            cell.refreshCell(name: memberName, position: "", profileImageUrl: members[indexPath.row].avatar)
        }
        cell.onDelMember = {
            self.deleteMemberTapped(indexPath: indexPath)
        }
        
        return cell
    }
    
    // MARK: - 删除成员事件
    @objc func deleteMemberTapped(indexPath: IndexPath) {
        let index = indexPath.row
        let memberName = members[index]
        
        let alert = UIAlertController(title: "删除成员", message: "确定要删除成员 \"\(memberName)\" 吗？", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "确定", style: .destructive) { _ in
            self.members.remove(at: index)
            self.memberTableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true)
    }
    
    // MARK: - 邀请成员按钮事件
    @objc func inviteMemberTapped() {
        print("点击了邀请成员")
        // 可以在这里实现邀请成员的逻辑，例如弹出输入框让用户输入邀请信息等。
        let alert = UIAlertController(title: "邀请成员", message: "请输入邀请成员名称", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "成员名称"
        }
        let okAction = UIAlertAction(title: "确定", style: .default) { UIAlertAction in
            guard let memberName = alert.textFields?.first?.text, !memberName.isEmpty
             else {
                self.showToast("成员名不能为空")
                return
            }
            print("memberName=\(memberName)")
            APIManager.shared.joinFamily(shareUserID: memberName, authType: "member", familyID: 162) { result in
                print("result=\(result)")
                
            }
        }
        let cancelAction = UIAlertAction(title: "取消", style: .destructive) { UIAlertAction in
            
        }
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true)
    }
}

class MemberTableViewCell:UITableViewCell, WKNavigationDelegate {
    private let profileImgView = UIImageView()
    private let nameLabel = UILabel()
    private let positionLabel = UILabel()
    private let delMemberImgView = UIImageView()
    private let borderView = UIView(frame: CGRect(x: 20, y: 10, width: 335, height: 64))
    var onDelMember:(()->Void)?
    var webView:WKWebView!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        borderView.backgroundColor = .white
        borderView.layer.cornerRadius = 6
        self.contentView.addSubview(borderView)
        self.contentView.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1.0)
        
        setupUI()
        setupWebView()
    }
    
    private func setupUI() {
        borderView.addSubview(delMemberImgView)
        delMemberImgView.image = UIImage(named: "family_icon_delmember")
        delMemberImgView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
        }
        delMemberImgView.isUserInteractionEnabled = true
        let delTapGesture = UITapGestureRecognizer(target: self, action: #selector(delTapGesture))
        delMemberImgView.addGestureRecognizer(delTapGesture)
        
        borderView.addSubview(profileImgView)
        profileImgView.image = UIImage(named: "family_icon_delmember")
        profileImgView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.height.width.equalTo(32)
        }
        profileImgView.contentMode = .scaleAspectFill
        profileImgView.clipsToBounds = true
        profileImgView.layer.cornerRadius = 16
        
        borderView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(profileImgView.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
        }
        
        borderView.addSubview(positionLabel)
        positionLabel.textColor = UIColor(red: 0/255.0, green: 117/255.0, blue: 201/255.0, alpha: 1.0)
        positionLabel.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
        }
    }
    
    public func refreshCell(name:String, position:String, profileImageUrl:String) {
        self.nameLabel.text = name
        self.positionLabel.text = position
        if profileImageUrl.contains("base64") {
            showSvg(base64String: profileImageUrl)
        } else {
            self.profileImgView.sd_setImage(with: URL(string: baseURL + profileImageUrl))
        }
        if position == "管理员" {
            self.delMemberImgView.isHidden = true
        }
    }
    
    @objc private func delTapGesture() {
        self.onDelMember?()
    }
    
    private func setupWebView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        self.contentView.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.widthAnchor.constraint(equalToConstant: 30), //  35-5-1+1+6-2
            webView.heightAnchor.constraint(equalToConstant: (30)), //  25+5-1-12-1
            webView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            webView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
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
                                self.profileImgView.image = croppedImage
                                self.profileImgView.frame = CGRect(x: 0, y: 0, width: cropSize.width, height: cropSize.height)
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
