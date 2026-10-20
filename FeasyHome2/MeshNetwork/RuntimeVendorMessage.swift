//
//  RuntimeVendorMessage.swift
//  FeasyHome2
//
//  Created by chenchanghua on 2025/2/20.
//

import Foundation
import FeasyMeshSDK

struct RuntimeVendorMessage: VendorMessage {
    let opCode: UInt32
    let parameters: Data?
    
    var isSegmented: Bool = false
    var security: MeshMessageSecurity = .low
    
    //    init(opCode: UInt8, for model: Model, parameters: Data?) {
    //        self.opCode = (UInt32(0xC0 | opCode) << 16) | UInt32(model.companyIdentifier!.bigEndian)
    //        self.parameters = parameters
    //    }
    
    //    init(opCode: UInt32, for model: Model, parameters: Data?) {
    //        self.opCode = opCode
    //        self.parameters = parameters
    //    }
    
    init(opCode: UInt32, parameters: Data?) {
        self.opCode = opCode
        self.parameters = parameters
    }
    
    init?(parameters: Data) {
        // This init will never be used, as it's used for incoming messages.
        return nil
    }
}

extension RuntimeVendorMessage: CustomDebugStringConvertible {
    
    var debugDescription: String {
        let hexOpCode = String(format: "%2X", opCode)
        return "RuntimeVendorMessage(opCode: \(hexOpCode), parameters: \(parameters!.hex), isSegmented: \(isSegmented), security: \(security))"
    }
    
}
