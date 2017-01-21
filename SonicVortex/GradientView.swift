//
//  GradientView.swift
//  SonicVortex
//
//  Created by Sebastian Cain on 1/21/17.
//  Copyright © 2017 Sebastian Cain. All rights reserved.
//
//

import UIKit

class GradientView: UIView {
    
    
    
    override func draw(_ rect: CGRect) {
        super.draw(frame)
        
        
        
        let color1 = UIColor(red: 255, green: 95, blue: 109, alpha: 1.0)
        let color2 = UIColor(red: 255, green: 195, blue: 113, alpha: 1.0)
        
        //2 - get the current context
        let context = UIGraphicsGetCurrentContext()
        let colors = [color1.cgColor, color2.cgColor] as CFArray
        
        //3 - set up the color space
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        //4 - set up the color stops
        let colorLocations:[CGFloat] = [0.0, 1.0]
        
        //5 - create the gradient
        let gradient = CGGradient(colorsSpace: colorSpace,
                                  colors: colors,
                                  locations: colorLocations)
        
        //6 - draw the gradient
        let startPoint = CGPoint(x:0, y: 0)
        let endPoint = CGPoint(x:300, y:300)
        context!.drawLinearGradient(gradient!,
                                    start: startPoint,
                                    end: endPoint,
                                    options: [])
    }
}
