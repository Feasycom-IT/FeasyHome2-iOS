//
//  TokenManager.swift
//  FeasyHome2
//
//  Created by chenchanghua on 2025/1/7.
//

import UIKit

class TokenManager {
    static let shared = TokenManager()
    private let tokenKey = "userToken"
    
    // 保存 Token
    func saveToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: tokenKey)
    }
    
    // 获取 Token
    func getToken() -> String? {
        return UserDefaults.standard.string(forKey: tokenKey)
    }
    
    // 删除 Token（用户注销时调用）
    func clearToken() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
    }
    
    // 判断是否已登录
    func isLoggedIn() -> Bool {
        return getToken() != nil
    }
}
