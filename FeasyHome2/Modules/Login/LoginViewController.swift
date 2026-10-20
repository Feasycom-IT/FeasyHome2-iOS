//
//  LoginViewController.swift
//  FeasyHome2
//
//  Created by chenchanghua on 2025/1/7.
//

import UIKit
import SnapKit
import Alamofire

class LoginViewController: UIViewController {
    
    // MARK: - UI Elements
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "img_logo") // 替换为实际图片名称
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let appNameLabel: UILabel = {
        let label = UILabel()
        label.text = "FeasyHome"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    private let phoneBgView: UIView = {
        let bgView = UIView()
        bgView.backgroundColor = .white
        bgView.layer.cornerRadius = 6
        bgView.layer.masksToBounds = true
        return bgView
    }()
    
    private let phoneImageV: UIImageView = {
        let imageV = UIImageView(image: UIImage(named: "log_icon_phone"))
        return imageV
    }()
    
    private let phoneTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "请输入手机号"
        textField.borderStyle = .none
        textField.keyboardType = .phonePad
        return textField
    }()
    
    private let codeBgView: UIView = {
        let bgView = UIView()
        bgView.backgroundColor = .white
        bgView.layer.cornerRadius = 6
        bgView.layer.masksToBounds = true
        return bgView
    }()
    
    private let codeImageV: UIImageView = {
        let imageV = UIImageView(image: UIImage(named: "log_icon_verify"))
        return imageV
    }()
    
    private let codeTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "请输入验证码"
        textField.borderStyle = .none
        return textField
    }()
    
    private let sendCodeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("发送验证码", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitleColor(.systemBlue, for: .normal)
        return button
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("登录", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 0, green: 0.46, blue: 0.79, alpha: 1.00)
        button.layer.cornerRadius = 6
        return button
    }()
    
    private let privacyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .systemGray
        label.textAlignment = .left
        
        let fullText = "登录代表您已同意 《FeasyHome隐私政策》"
        let attributedString = NSMutableAttributedString(string: fullText)
        let range = (fullText as NSString).range(of: "《FeasyHome隐私政策》")
        attributedString.addAttribute(.foregroundColor, value: UIColor(red: 0, green: 0.46, blue: 0.79, alpha: 1.00), range: range)
        label.attributedText = attributedString
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private let privacyCheckbox: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "circle"), for: .normal)
        button.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .selected)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.00)
        setupNavigationContent()
        setupSubviews()
        
        sendCodeButton.addTarget(self, action: #selector(sendCodeButtonAction), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginButtonAction), for: .touchUpInside)
        privacyCheckbox.addTarget(self, action: #selector(privacyCheckboxTapped), for: .touchUpInside)
        privacyLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleLabelTap(_:))))
    }
    
    func setupNavigationContent() {
        
        let backgroundImageView = UIImageView(image: UIImage(named: "img_bg"))
        backgroundImageView.contentMode = .scaleToFill
        
        let safeInsets = self.view.safeAreaInsets
        backgroundImageView.frame = CGRect(x: 0, y: -safeInsets.top, width: self.view.bounds.size.width, height: (self.view.bounds.size.height + safeInsets.top + safeInsets.bottom) * 331.33 / 812)
        
        self.view.addSubview(backgroundImageView)
        self.view.sendSubviewToBack(backgroundImageView)
    }
    
    // MARK: - ActionHandle
    
    @objc private func sendCodeButtonAction() {
        // 检查手机号输入框是否有值
        guard let mobile = phoneTextField.text, !mobile.isEmpty else {
            print("手机号不能为空")
            return
        }
        
        // 调用封装好的方法
        APIManager.shared.fetchCaptcha(mobile: mobile) { result in
            switch result {
            case .success(let captchaResponse):
                // 处理成功响应
                print("验证码请求成功：")
                print("Code: \(captchaResponse.code)")
                print("Message: \(captchaResponse.msg)")
                print("Time: \(captchaResponse.time)")
                print("Captcha: \(captchaResponse.data)")
                
                self.codeTextField.text = String(captchaResponse.data)
                
            case .failure(let error):
                // 处理失败响应
                print("验证码请求失败：\(error.localizedDescription)")
            }
        }
    }
    
    @objc private func loginButtonAction() {
        // 1. 获取用户输入
        guard let mobile = phoneTextField.text, !mobile.isEmpty else {
            showAlert(message: "请输入手机号")
            return
        }
        
        guard let captcha = codeTextField.text, !captcha.isEmpty else {
            showAlert(message: "请输入验证码")
            return
        }
        
        // 2. 检查隐私政策是否同意
        guard privacyCheckbox.isSelected else {
            showAlert(message: "请同意隐私政策")
            return
        }
        
        // 3. 显示加载指示器
        let loadingIndicator = createLoadingIndicator()
        view.addSubview(loadingIndicator)
        loadingIndicator.startAnimating()
        
        // 4. 调用登录 API
        APIManager.shared.loginWithCaptcha(mobile: mobile, captcha: captcha) { [weak self] result in
            // 确保 self 仍然存在
            guard let self = self else { return }
            
            // 5. 隐藏加载指示器
            DispatchQueue.main.async {
                loadingIndicator.stopAnimating()
                loadingIndicator.removeFromSuperview()
            }
            
            switch result {
            case .success(let token):
                print("登录成功，Token: \(token)")
                // 6. 保存 Token
                TokenManager.shared.saveToken(token)
                
                // 7. 跳转到主页面
                DispatchQueue.main.async {
                    let mainVC = MainTabBarController()
                    if let window = UIApplication.shared.windows.first {
                        window.rootViewController = mainVC
                        window.makeKeyAndVisible()
                    }
                }
                
            case .failure(let error):
                print("登录失败: \(error.localizedDescription)")
                // 8. 显示错误提示
                DispatchQueue.main.async {
                    self.showAlert(message: "登录失败\n请确认手机号与验证码的正确性")
                }
            }
        }
    }
    
    @objc private func handleLabelTap(_ sender: UITapGestureRecognizer) {
        let text = privacyLabel.text ?? ""
        let range = (text as NSString).range(of: "《FeasyHome隐私政策》")
        if sender.didTapAttributedTextInLabel(label: privacyLabel, inRange: range) {
            print("点击FeasyHome隐私政策")
        }
    }
    
    // 辅助方法：显示警告弹窗
    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // 辅助方法：创建加载指示器
    private func createLoadingIndicator() -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.center = view.center
        indicator.hidesWhenStopped = true
        return indicator
    }
    
    @objc private func privacyCheckboxTapped() {
        privacyCheckbox.isSelected.toggle()
    }

    
    private func setupSubviews() {
        // Add subviews
        view.addSubview(logoImageView)
        view.addSubview(appNameLabel)
        view.addSubview(phoneBgView)
        phoneBgView.addSubview(phoneImageV)
        phoneBgView.addSubview(phoneTextField)
        view.addSubview(codeBgView)
        codeBgView.addSubview(codeImageV)
        codeBgView.addSubview(codeTextField)
        codeBgView.addSubview(sendCodeButton)
        view.addSubview(loginButton)
        view.addSubview(privacyLabel)
        view.addSubview(privacyCheckbox)
        
        // Use SnapKit for layout
        logoImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(100)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(100)
        }
        
        appNameLabel.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }
        
        phoneBgView.snp.makeConstraints { make in
            make.top.equalTo(appNameLabel.snp.bottom).offset(60)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(48)
        }
        
        phoneImageV.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(20)
            make.width.height.equalTo(20)
        }
        
        phoneTextField.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(phoneImageV.snp.right).offset(8)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(44)
        }
        
        codeBgView.snp.makeConstraints { make in
            make.top.equalTo(phoneBgView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(48)
        }
        
        codeImageV.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(20)
            make.width.height.equalTo(20)
        }
        
        sendCodeButton.snp.makeConstraints { make in
            make.centerY.equalTo(codeBgView)
            make.right.equalTo(codeBgView.snp.right).offset(-20)
        }
        
        codeTextField.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(codeImageV.snp.right).offset(8)
            make.right.equalTo(sendCodeButton.snp.left).offset(-20)
            make.height.equalTo(44)
        }
        
        sendCodeButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        codeTextField.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(codeBgView.snp.bottom).offset(30)
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
            make.height.equalTo(50)
        }
        
        privacyCheckbox.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.bottom.equalTo(view.snp.bottom).offset(-70)
            make.width.height.equalTo(20)
        }
        
        privacyLabel.snp.makeConstraints { make in
            make.leading.equalTo(privacyCheckbox.snp.trailing).offset(10)
            make.centerY.equalTo(privacyCheckbox)
            make.trailing.equalToSuperview().offset(-30)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view .endEditing(true)
    }
}

extension UITapGestureRecognizer {
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        let location = location(in: label)
        let textStorage = NSTextStorage(attributedString: label.attributedText ?? NSAttributedString())
        let textContainer = NSTextContainer(size: label.bounds.size)
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
        
        let index = layoutManager.glyphIndex(for: location, in: textContainer)
        let charRange = layoutManager.characterRange(forGlyphRange: NSRange(location: index, length: 1), actualGlyphRange: nil)
        
        return NSLocationInRange(charRange.location, targetRange)
    }
}


