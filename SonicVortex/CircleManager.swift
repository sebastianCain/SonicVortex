//
//  CircleManager.swift
//  SonicVortex
//
//  Created by Sebastian Cain on 1/21/17.
//  Copyright © 2017 Sebastian Cain. All rights reserved.
//

import UIKit

class CircleManager: NSObject {
    
    static let rad: Double = 100
    
    static func rotation(index: Int) -> Double {
        let whole = M_PI * 2.0
        let angle = (Double(index) / 32) * whole + (M_PI/32)
        return angle
    }
    
    static func position(index: Int) -> CGPoint {
        let angle = rotation(index: index) + (M_PI/2.0)
        let x = cos(angle) * rad
        let y = sin(angle) * rad
        return CGPoint(x: x+rad, y: y+rad)
    }
}
