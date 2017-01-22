//
//  AnalysisViewController.swift
//  SonicVortex
//
//  Created by Sebastian Cain on 1/22/17.
//  Copyright © 2017 Sebastian Cain. All rights reserved.
//

import UIKit

class AnalysisViewController: UIViewController {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distLabel: UILabel!
    
    var time: Double?
    var dist: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let t = time {
            timeLabel.text = "Elapsed Time: \(t)"
        }
        if let d = dist {
            distLabel.text = "Elapsed Distance \(d)"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}