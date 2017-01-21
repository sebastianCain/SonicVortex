//
//  CoreMotionInterface.swift
//  SonicVortex
//
//  Created by Noah Fichter on 1/21/17.
//  Copyright © 2017 Sebastian Cain. All rights reserved.
//

import UIKit
import CoreMotion
class CoreMotionInterface: NSObject {
    static let activityManager = CMMotionActivityManager()
    static let pedoMeter = CMPedometer()
    
    //let caddelegate: CadenceDelegate!
    
    static func beginTracking() {
        print(CMPedometer.isCadenceAvailable())
        let date = Date()
        pedoMeter.startUpdates(from: date, withHandler: { cmpd, error in
            if (error == nil) {
                if let data = cmpd {
                    if let cadence = data.currentCadence {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "cad"), object: cadence)
                    }
                }
            } else {
                print(error?.localizedDescription as Any)
            }
        })
        isTracking = true
    }
    
    static func endTracking() {
        pedoMeter.stopUpdates()
        isTracking = false
    }
    
    static var isTracking = true
}
