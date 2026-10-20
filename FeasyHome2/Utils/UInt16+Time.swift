//
//  UInt16+Time.swift
//  FeasyMesh
//
//  Created by chenchanghua on 2022/6/17.
//

import Foundation

extension UInt16 {
    
    func asTime() -> String {
        if self / 3600 > 0 {
            return "\(self / 3600) h \((self % 3600) / 60) min \(self % 60) sec"
        }
        if self / 60 > 0 {
            return "\(self / 60) min \(self % 60) sec"
        }
        if self == 1 {
            return "1 second"
        }
        return "\(self) seconds"
    }
    
}

extension ClosedRange where Bound == UInt16 {
    
    func asTime() -> String {
        return "\(lowerBound.asTime())...\(upperBound.asTime())"
    }
    
}
