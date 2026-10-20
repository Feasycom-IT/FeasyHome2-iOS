//
//  Address+String.swift
//  FeasyMesh
//
//  Created by chenchanghua on 2022/6/17.
//

import Foundation
import FeasyMeshSDK

extension Address {
    
    /// Returns the Address as String in HEX format (with 0x).
    ///
    /// Example: "0x0001"
    func asString() -> String {
        return String(format: "0x%04X", self)
    }
    
    /// Returns the Address as String in HEX format.
    ///
    /// Example: "0001"
    var hex: String {
        return String(format: "%04X", self)
    }
}

extension MeshAddress {
    
    /// Returns the 16-bit Address, or Virtual Label as String.
    ///
    /// Example: "0x0001" or "00000000-0000-0000-000000000000"
    func asString() -> String {
        if let uuid = virtualLabel {
            return uuid.uuidString
        }
        return address.asString()
    }
    
    /// Returns the 16-bit Address, or Virtual Label as String.
    ///
    /// Example: "0001" or "00000000-0000-0000-000000000000"
    var hex: String {
        if let uuid = virtualLabel {
            return uuid.uuidString
        }
        return address.hex
    }
}
