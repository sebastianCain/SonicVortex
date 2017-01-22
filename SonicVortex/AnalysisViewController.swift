//
//  AnalysisViewController.swift
//  SonicVortex
//
//  Created by Sebastian Cain on 1/22/17.
//  Copyright © 2017 Sebastian Cain. All rights reserved.
//

import UIKit

class AnalysisViewController: UIViewController, PNChartDelegate {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distLabel: UILabel!
    //@IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var home: UIButton!
    @IBOutlet weak var chart: PNLineChart!
    
    var time: String?
    var dist: String?
    var tempoData = [String: Float]()
    //var img: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chart.delegate = self
        let labels: [String] = Array(tempoData.keys)
        chart.setXLabels(labels, withWidth: 240.0/CGFloat(labels.count))
        let data01 = PNLineChartData()
        data01.color = UIColor.white;
        data01.itemCount = UInt(chart.xLabels.count);
        data01.getData = { index in
            return PNLineChartDataItem(y: CGFloat(self.tempoData[labels[Int(index)]]!))
        }
        chart.backgroundColor = UIColor.clear
        chart.chartData = [data01]
        chart.stroke()
        
        
        home.layer.cornerRadius = 10
        home.backgroundColor = UIColor(white: 1.0, alpha: 0.3)
        // Do any additional setup after loading the view.
        if let t = time {
            timeLabel.text = t
        }
        if let d = dist {
            distLabel.text = d
        }
//        if let i = img {
//            imgView.image = i
//        }
    }

    @IBAction func homeTriggered(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
