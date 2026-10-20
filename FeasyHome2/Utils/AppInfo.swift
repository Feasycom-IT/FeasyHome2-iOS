//
//  AppInfo.swift
//  FeasyMesh
//
//  Created by chenchanghua on 2022/6/17.
//

import Foundation

struct AppInfo {
    
    // Non-instantiable.
    private init() {}
        
    /// Returns Application version as String.
    static var version: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "N/A"
    }
    
    /// Returns Build Number as String.
    static var buildNumber: String {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "N/A"
    }
}
