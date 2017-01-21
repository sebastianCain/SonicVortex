//
//  ViewController.swift
//  SonicVortex
//
//  Created by Sebastian Cain on 1/20/17.
//  Copyright © 2017 Sebastian Cain. All rights reserved.
//

//import SuperpoweredIOSAudioIO

import UIKit


class ViewController: UIViewController {

    @IBOutlet weak var play: UIButton!
    @IBOutlet weak var cadenceLabel: UILabel!
    @IBOutlet weak var bpmCircle: UIView!
    var superpowered = Superpowered()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        superpowered.toggle()
        superpowered.togglePlayback()
        //CoreMotionInterface.beginTracking()
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "cad"), object: nil, queue: OperationQueue.main, using: { notif in
            let cadence = (notif.object as! NSNumber).floatValue
            let bpm = cadence*60
            self.cadenceLabel.text = "BPM\n\(Int(bpm))"
            (self.bpmCircle.layer.sublayers?.first as! CAShapeLayer).strokeEnd = CGFloat(bpm)/300.0
            self.superpowered.updateCadence(Double(cadence))
        })
        //gradient.setNeedsDisplay()
        
        play.layer.cornerRadius = 35
        play.layer.borderColor = UIColor.white.cgColor
        play.layer.borderWidth = 1
        play.imageEdgeInsets = UIEdgeInsetsMake(18.5, 19.5, 18.5, 17.5)
        play.setImage(UIImage(named: "Pause-100"), for: UIControlState.selected)
        play.setImage(UIImage(named: "Play-100"), for: UIControlState.normal)
        
        let circLayer = CAShapeLayer()
        circLayer.path = CGPath.init(ellipseIn: bpmCircle.bounds, transform: nil)
        circLayer.strokeStart = 0.0
        circLayer.strokeEnd = 0.5
        circLayer.strokeColor = UIColor.white.cgColor
        circLayer.fillColor = UIColor.clear.cgColor
        circLayer.lineCap = kCALineCapRound
        circLayer.lineWidth = 5
        circLayer.transform = CATransform3DRotate(CATransform3DTranslate(CATransform3DIdentity, 0, 150, 0), -CGFloat(M_PI)/CGFloat(2.0), 0, 0, 1)
        
        
        bpmCircle.layer.addSublayer(circLayer)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func playTriggered(_ sender: UIButton) {
        superpowered.togglePlayback()
        if (CoreMotionInterface.isTracking) {
            CoreMotionInterface.endTracking()
            play.isSelected = false
        } else {
            CoreMotionInterface.beginTracking()
            play.isSelected = true
        }
    }
    
    @IBAction func tempoTriggered(_ sender: UIButton) {
        superpowered.toggleFx()
    }
}

