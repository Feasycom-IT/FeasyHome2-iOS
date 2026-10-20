//
//  MainTabBarController.swift
//  FeasyHome2
//
//  Created by chenchanghua on 2024/12/23.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 初始化设备视图控制器并嵌入到导航控制器中
        let deviceVC = DeviceViewController()
        let deviceNavController = UINavigationController(rootViewController: deviceVC)
        deviceVC.tabBarItem = UITabBarItem(title: "设备", image: UIImage( named: "tabbar_icon_dev_active"), tag: 0)
        
        // 初始化场景视图控制器并嵌入到导航控制器中
        let sceneVC = SceneViewController()
        let sceneNavController = UINavigationController(rootViewController: sceneVC)
        sceneVC.tabBarItem = UITabBarItem(title: "场景", image: UIImage(named: "tabbar_icon_scene_active"), tag: 3)
        
        // 初始化我的视图控制器并嵌入到导航控制器中
        let userViewController = UserViewController()
        let userNavController = UINavigationController(rootViewController: userViewController)
        userViewController.tabBarItem = UITabBarItem(title: "我的", image: UIImage(named: "tabbar_icon_mine_active"), tag: 4)

        self.viewControllers = [deviceNavController, sceneNavController, userNavController]
        
        // 设置 tab bar 的外观
        self.tabBar.tintColor = .systemBlue // 选中项颜色
    }
}

