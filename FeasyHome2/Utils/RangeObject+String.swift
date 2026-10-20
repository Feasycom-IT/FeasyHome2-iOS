//
//  RangeObject+String.swift
//  FeasyMesh
//
//  Created by chenchanghua on 2022/6/17.
//

import Foundation
import FeasyMeshSDK

extension RangeObject {
    
    func asString() -> String {
        return "\(lowerBound.asString()) - \(upperBound.asString())"
    }
    
}

extension Array where Element == RangeObject {
    
    func asString() -> String {
        if count == 1 {
            return self[0].asString()
        }
        return "\(count) ranges"
    }
    
}

extension ClosedRange where Bound == UInt16 {
    
    func asString() -> String {
        return "\(lowerBound.asString()) - \(upperBound.asString())"
    }
    
}
