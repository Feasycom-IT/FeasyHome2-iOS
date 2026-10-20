//
//  InviteMemberViewController.swift
//  FeasyHome2
//
//  Created by chenchanghua on 2024/12/27.
//

import UIKit
import SnapKit

class InviteMemberViewController: UIViewController {
    
    // 分享权限按钮
    private let sharePermissionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("分享权限", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        button.tintColor = .black
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        button.contentHorizontalAlignment = .left
        button.backgroundColor = .white
        button.layer.cornerRadius = 8
        return button
    }()
    
    // 邀请信息视图
    private let inviteInfoView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        return view
    }()
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 25 // 圆形头像
        imageView.image = UIImage(named: "avatar_placeholder") // 替换为默认图片
        return imageView
    }()
    
    private let inviteTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "来自“鑫哥”的邀请"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    private let inviteSubtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "授权后可以使用“鑫哥”的所有设备"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        label.textAlignment = .center
        return label
    }()
    
    // 二维码图片
    private let qrCodeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .lightGray // 占位符颜色
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // 刷新按钮
    private let refreshButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("刷新", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        button.tintColor = .blue
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        button.addTarget(self, action: #selector(refreshQRCode), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = "邀请成员"
        
        setupUI()
    }
    
    private func setupUI() {
        // 添加视图
        view.addSubview(sharePermissionButton)
        view.addSubview(inviteInfoView)
        
        inviteInfoView.addSubview(avatarImageView)
        inviteInfoView.addSubview(inviteTitleLabel)
        inviteInfoView.addSubview(inviteSubtitleLabel)
        inviteInfoView.addSubview(qrCodeImageView)
        inviteInfoView.addSubview(refreshButton)
        
        // 设置约束
        sharePermissionButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(50)
        }
        
        inviteInfoView.snp.makeConstraints { make in
            make.top.equalTo(sharePermissionButton.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        
        avatarImageView.snp.makeConstraints { make in
            make.top.equalTo(inviteInfoView).offset(20)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(50) // 圆形头像大小
        }
        
        inviteTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        
        inviteSubtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(inviteTitleLabel.snp.bottom).offset(5)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        
        qrCodeImageView.snp.makeConstraints { make in
            make.top.equalTo(inviteSubtitleLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(150) // 二维码大小
        }
        
        refreshButton.snp.makeConstraints { make in
            make.top.equalTo(qrCodeImageView.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(inviteInfoView).offset(-20)
        }
    }
    
    @objc private func refreshQRCode() {
        print("刷新二维码")
        // 在这里添加刷新二维码的逻辑
    }
}
