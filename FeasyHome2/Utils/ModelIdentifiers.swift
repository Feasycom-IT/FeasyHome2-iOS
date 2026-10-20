//
//  ModelIdentifiers.swift
//  FeasyMesh
//
//  Created by chenchanghua on 2022/6/17.
//

import Foundation

extension UInt16 {
    
    // Bluetooth SIG Models
    static let configurationServerModelId: UInt16 = 0x0000
    static let configurationClientModelId: UInt16 = 0x0001
    
    static let genericOnOffServerModelId: UInt16 = 0x1000
    static let genericOnOffClientModelId: UInt16 = 0x1001
    static let genericLevelServerModelId: UInt16 = 0x1002
    static let genericLevelClientModelId: UInt16 = 0x1003
    
    static let genericDefaultTransitionTimeServerModelId: UInt16 = 0x1004
    static let genericDefaultTransitionTimeClientModelId: UInt16 = 0x1005
    
    static let genericPowerOnOffServerModelId: UInt16 = 0x1006
    static let genericPowerOnOffSetupServerModelId: UInt16 = 0x1007
    static let genericPowerOnOffClientModelId: UInt16 = 0x1008
    
    static let sceneServerModelId: UInt16 = 0x1203
    static let sceneSetupServerModelId: UInt16 = 0x1204
    static let sceneClientModelId: UInt16 = 0x1205
    
    static let sensorServerModelId: UInt16 = 0x1100
    static let sensorServerSetupModelId: UInt16 = 0x1101
    static let sensorClientModelId: UInt16 = 0x1102
    
    // Supported vendor models
    static let simpleOnOffModelId: UInt16 = 0x0001
    static let nordicSemiconductorCompanyId: UInt16 = 0x0059
    
}
