//
//  SceneDelegate.swift
//  FeasyHome2
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        window.backgroundColor = .white

        if TokenManager.shared.isLoggedIn() {
            // 已登录，跳转到主页面
            window.rootViewController = MainTabBarController()
        } else {
            // 未登录，跳转到登录页面
            window.rootViewController = LoginViewController()
        }

        self.window = window
        window.makeKeyAndVisible()
    }

}
