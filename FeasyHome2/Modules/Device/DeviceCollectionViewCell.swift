//
//  DeviceCollectionViewCell.swift
//  FeasyHome2
//
//  Created by chenchanghua on 2025/2/21.
//

import UIKit

class DeviceCollectionViewCell: UICollectionViewCell {
    
    // 设备图片
    var deviceImageView: UIImageView!
    
    // 设备名称
    var deviceNameLabel: UILabel!
    
    // 设备数量
    var deviceCountLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // 设置背景颜色和圆角
        self.contentView.backgroundColor = .white
        self.contentView.layer.cornerRadius = 10
        self.contentView.layer.masksToBounds = true
        
        // 初始化设备图片
        deviceImageView = UIImageView()
        deviceImageView.contentMode = .scaleAspectFit
        contentView.addSubview(deviceImageView)
        
        // 初始化设备名称Label
        deviceNameLabel = UILabel()
        deviceNameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        deviceNameLabel.textAlignment = .center
        contentView.addSubview(deviceNameLabel)
        
        // 初始化设备数量Label
        deviceCountLabel = UILabel()
        deviceCountLabel.font = UIFont.systemFont(ofSize: 14)
        deviceCountLabel.textAlignment = .center
        deviceCountLabel.textColor = .gray
        contentView.addSubview(deviceCountLabel)
        
        // 设置布局约束
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupConstraints() {
        // 禁用AutoLayout
        deviceImageView.translatesAutoresizingMaskIntoConstraints = false
        deviceNameLabel.translatesAutoresizingMaskIntoConstraints = false
        deviceCountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 添加约束
        NSLayoutConstraint.activate([
            // 设备图片
            deviceImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 17),
            deviceImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
            deviceImageView.widthAnchor.constraint(equalToConstant: 32),
            deviceImageView.heightAnchor.constraint(equalToConstant: 32),
            
            // 设备名称
            deviceNameLabel.topAnchor.constraint(equalTo: deviceImageView.bottomAnchor, constant: 10),
            deviceNameLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
            
            // 设备数量
            deviceCountLabel.topAnchor.constraint(equalTo: deviceNameLabel.bottomAnchor, constant: 5),
            deviceCountLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
            deviceCountLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    // 配置单元格的方法
    func configureCell(deviceType: Int, deviceImage: UIImage, deviceName: String, deviceCount: Int) {
        deviceImageView.image = deviceImage
        deviceNameLabel.text = deviceName
//        if deviceCount == 1 && deviceType != 1 {
//            deviceCountLabel.text = "设备"
//        } else
        deviceCountLabel.text = "\(deviceCount)设备"
    }
}
