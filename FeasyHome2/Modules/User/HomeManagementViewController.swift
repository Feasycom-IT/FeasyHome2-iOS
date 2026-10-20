//
//  HomeManagementViewController.swift
//  FeasyHome2
//
//  Created by chenchanghua on 2024/12/23.
//

import UIKit

// 家庭列表VC
class HomeManagementViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Properties
    var homeTableView: UITableView!
    var addHomeButton: UIButton!
    var homes: [Family] = [] // 存放家庭信息
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置视图背景色和标题
        self.view.backgroundColor = .white
        self.navigationItem.title = "家庭列表"
        view.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1.0)
        setupNavigationContent()
        
        // 创建家庭列表
        setupHomeTableView()
        
        // 创建新建家庭按钮
        setupAddHomeButton()
        
        // 获取家庭列表
        fetchFamilyList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchFamilyList()
    }
    
    // MARK: - 获取家庭列表
    func fetchFamilyList() {
        // 显示加载指示器
        let loadingIndicator = createLoadingIndicator()
        view.addSubview(loadingIndicator)
        loadingIndicator.startAnimating()
        
        APIManager.shared.fetchFamilyList { [weak self] result in
            guard let self = self else { return }
            
            // 隐藏加载指示器
            DispatchQueue.main.async {
                loadingIndicator.stopAnimating()
                loadingIndicator.removeFromSuperview()
            }
            
            switch result {
            case .success(let families):
                self.homes = families
                DispatchQueue.main.async {
                    self.homeTableView.reloadData()
                }
            case .failure(let error):
                print("获取家庭列表失败: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showAlert(message: "获取家庭列表失败: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - 创建家庭列表视图
    func setupHomeTableView() {
        homeTableView = UITableView(frame: .zero, style: .plain)
        homeTableView.delegate = self
        homeTableView.dataSource = self
        homeTableView.translatesAutoresizingMaskIntoConstraints = false
        homeTableView.register(UITableViewCell.self, forCellReuseIdentifier: "HomeCell")
        homeTableView.backgroundColor = .clear
        homeTableView.separatorStyle = .none
        homeTableView.rowHeight = 80
        self.view.addSubview(homeTableView)
        
        NSLayoutConstraint.activate([
            homeTableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            homeTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            homeTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            homeTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -100)
        ])
    }
    
    // MARK: - 创建新建家庭按钮视图
    func setupAddHomeButton() {
        addHomeButton = UIButton(type: .system)
        addHomeButton.setTitle("新建家庭", for: .normal)
        addHomeButton.setTitleColor(.black, for: .normal) // 修改为白色以更好地对比
        addHomeButton.backgroundColor = .white
        addHomeButton.layer.cornerRadius = 10
        addHomeButton.translatesAutoresizingMaskIntoConstraints = false
        addHomeButton.addTarget(self, action: #selector(addHomeTapped), for: .touchUpInside)
        self.view.addSubview(addHomeButton)
        
        NSLayoutConstraint.activate([
            addHomeButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            addHomeButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            addHomeButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            addHomeButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: - UITableView DataSource & Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return homes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "HomeCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) ?? UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        let family = homes[indexPath.row]
        cell.backgroundColor = .clear
        let borderView = UIView()
        borderView.backgroundColor = .white
        borderView.layer.cornerRadius = 6
        cell.addSubview(borderView)
        borderView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(64)
            make.centerY.equalToSuperview()
        }
        let name = UILabel()
        name.text = family.familyName
        borderView.addSubview(name)
        name.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }
        let imgView = UIImageView()
        borderView.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
        }
        imgView.image = UIImage(systemName: "chevron.right")
        imgView.tintColor = .gray
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // 跳转到家庭配置管理页面
        let configVC = HomeConfigurationViewController()
        configVC.home = homes[indexPath.row] // 假设 HomeConfigurationViewController 有一个 'home' 属性
        self.navigationController?.pushViewController(configVC, animated: true)
    }
    
    // MARK: - 新建家庭按钮事件
    @objc public func addHomeTapped() {
        let alert = UIAlertController(title: "新建家庭", message: "请输入家庭名称", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "家庭名称"
        }
        
        let confirmAction = UIAlertAction(title: "确定", style: .default) { _ in
            guard let textField = alert.textFields?.first,
                  let familyName = textField.text,
                  !familyName.isEmpty else {
                self.showAlert(message: "家庭名称不能为空")
                return
            }
            
            // 中文字符与英文字符都计算在内，一个字符算一个单位
            if familyName.count > 6 {
                self.showAlert(message: "名称最大长度为6")
                return
            }
            
            // 生成 networkId 和 networkData
            let networkId = UUID().uuidString
            let networkData = self.generateNetworkData()
            let familyStr = String.randomString(length: 8) // 生成随机的 familyStr，长度为8
            
            // 显示加载指示器
            let loadingIndicator = self.createLoadingIndicator()
            self.view.addSubview(loadingIndicator)
            loadingIndicator.startAnimating()
            
            // 调用 API 创建家庭
            APIManager.shared.createFamily(familyName: familyName, networkData: networkData, networkId: networkId, familyStr: familyStr) { [weak self] result in
                guard let self = self else { return }
                
                // 隐藏加载指示器
                DispatchQueue.main.async {
                    loadingIndicator.stopAnimating()
                    loadingIndicator.removeFromSuperview()
                }
                
                switch result {
                case .success():
                    // 创建成功后，刷新家庭列表
                    self.fetchFamilyList()
                case .failure(let error):
                    print("创建家庭失败: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.showAlert(message: "创建家庭失败: \(error.localizedDescription)")
                    }
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - 辅助方法
    
    // 辅助方法：生成 networkData
    private func generateNetworkData() -> String {
        // 根据实际业务逻辑生成 networkData
        // 例如，将一些信息编码为 Base64 字符串
        let data = ["name": "家庭网络"].description.data(using: .utf8) ?? Data()
        return data.base64EncodedString()
    }
    
    // 辅助方法：显示加载指示器
    private func createLoadingIndicator() -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.center = view.center
        indicator.hidesWhenStopped = true
        return indicator
    }
    
    // 辅助方法：显示警告弹窗
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // Dismiss keyboard when tapping outside
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private func setupNavigationContent() {
        let backgroundImageView = UIImageView(image: UIImage(named: "img_bg"))
        backgroundImageView.contentMode = .scaleToFill
        
        let safeInsets = self.view.safeAreaInsets
        backgroundImageView.frame = CGRect(x: 0, y: -safeInsets.top, width: self.view.bounds.size.width, height: (self.view.bounds.size.height + safeInsets.top + safeInsets.bottom) * 331.33 / 812)
        
        self.view.addSubview(backgroundImageView)
        self.view.sendSubviewToBack(backgroundImageView)
    }
}

extension String {
    /// 生成指定长度的随机字符串
    static func randomString(length: Int) -> String {
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).compactMap { _ in characters.randomElement() })
    }
}
