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
    let activityManager = CMMotionActivityManager()
    let pedoMeter = CMPedometer()
    
    func begin() {
        pedoMeter.startUpdates(from: Date(), withHandler: { cmpd, error in
            let cad = cmpd?.currentCadence?.floatValue
            print(cad)
        })
    }
}
