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
    @IBOutlet weak var tempo: UIButton!
    @IBOutlet weak var cadenceLabel: UILabel!
    var superpowered = Superpowered()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        superpowered.toggle()
        CoreMotionInterface.beginTracking()
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "cad"), object: nil, queue: OperationQueue.main, using: { notif in
            print("lmao delegates")
            let cadence = (notif.object as! NSNumber).floatValue
            self.cadenceLabel.text = "Cadence: \(cadence)"
            self.superpowered.updateCadence(Double(cadence))
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func playTriggered(_ sender: UIButton) {
        superpowered.togglePlayback()
        if (CoreMotionInterface.isTracking) {
            CoreMotionInterface.endTracking()
        } else {
            CoreMotionInterface.beginTracking()
        }
    }
    
    @IBAction func tempoTriggered(_ sender: UIButton) {
        superpowered.toggleFx()
    }
}

