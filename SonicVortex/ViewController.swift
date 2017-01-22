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

    @IBOutlet weak var vizLayer: UIView!
    @IBOutlet weak var play: UIButton!
    @IBOutlet weak var cadenceLabel: UILabel!
    @IBOutlet weak var bpmCircle: UIView!
    var displayLink: CADisplayLink!
    var circlez = [CALayer]()
    
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
        
        play.layer.cornerRadius = 310
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
        
        let circLayer2 = CAShapeLayer()
        circLayer2.path = CGPath.init(ellipseIn: bpmCircle.bounds, transform: nil)
        circLayer2.strokeColor = UIColor(white: 1.0, alpha: 0.4).cgColor
        circLayer2.fillColor = UIColor.clear.cgColor
        circLayer2.lineWidth = 5
        
        bpmCircle.layer.addSublayer(circLayer2)
        bpmCircle.layer.addSublayer(circLayer)
        
        displayLink = CADisplayLink(target: self, selector: #selector(ViewController.onDisplayLink))
        displayLink.preferredFramesPerSecond = 60
        displayLink.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
        
        for i in 0...16 {
            let circle = CALayer()
            circle.frame = CGRect(x: 0, y: 0, width: 7, height: 7)
            
            circle.cornerRadius = 4
            circle.backgroundColor = UIColor.white.cgColor
            
            circle.position = CircleManager.position(index: i)
            
//            var transform = CATransform3DIdentity;
//            transform = CATransform3DTranslate(transform, circle.position.x+4-vizLayer.center.x, circle.position.y+4-vizLayer.center.y, 0.0);
//            transform = CATransform3DRotate(transform, CGFloat(CircleManager.rotation(index: i)), 0.0, 0.0, -1.0);
//            transform = CATransform3DTranslate(transform, vizLayer.center.x-circle.position.x+4, vizLayer.center.y-circle.position.y+4, 0.0);
            
            //circle.transform = transform
            
            circle.transform = CATransform3DRotate(CATransform3DIdentity, CGFloat(CircleManager.rotation(index: i)), 0, 0, 1)
            
            vizLayer.layer.addSublayer(circle)
            
            circlez.append(circle)
        }
        
    }
    
    func onDisplayLink() {
        // Get the frequency values.
        let frequencies = UnsafeMutablePointer<Float>.allocate(capacity: 8)
        superpowered.getFrequencies(frequencies)
        
        // Wrapping the UI changes in a CATransaction block like this prevents animation/smoothing.
        CATransaction.begin()
        CATransaction.setAnimationDuration(0)
        CATransaction.setDisableActions(true)
        
        // Set the dimension of every frequency bar.
        for n in 0...7 {
            let h = frequencies[n] * 300
            circlez[n].bounds = CGRect(x: 0, y: 0, width: 7, height: max(CGFloat(h), 7.0))
            print(frequencies[n])
        }
        
        CATransaction.commit()
        frequencies.deallocate(capacity: 8)
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

