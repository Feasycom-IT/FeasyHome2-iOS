//
//  FMMacro.swift
//  FeasyHome2
//
//  Created by chenchanghua on 2024/12/23.
//

import Foundation
import UIKit
import FeasyMeshSDK

let kScreen_Height = (UIScreen.main.bounds.size.height)
let kScreen_Width = (UIScreen.main.bounds.size.width)
let kStatusBar_Height = (UIApplication.shared.statusBarFrame.size.height)
let kNavBar_Height = (UIApplication.shared.statusBarFrame.size.height > 20 ? 88 : 64)
let kTabBar_Height = (UIApplication.shared.statusBarFrame.size.height > 20 ? 83 : 49)
let kSafeAreaInsetBottom = (UIApplication.shared.statusBarFrame.size.height > 20 ? 34 : 0)

func RGBColor(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) -> UIColor {
    return UIColor.init(red: CGFloat(Float(r / 255.0)), green: CGFloat(Float(r / 255.0)), blue: CGFloat(Float(r / 255.0)), alpha: CGFloat(Float(a / 1.0)))
}

/// 本地化字符串
func LS(_ string: String) -> String  {
    return NSLocalizedString(string, comment: "")
}

var kCurrentFamilyID: Int = 0
var kCurrentFamilyName: String = ""

var kCurrentRoomID: Int = 0
var kCurrentRoomCode: Int = 0
var kCurrentRoomName: String = ""


