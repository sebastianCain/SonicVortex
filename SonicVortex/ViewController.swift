//
//  ViewController.swift
//  SonicVortex
//
//  Created by Sebastian Cain on 1/20/17.
//  Copyright © 2017 Sebastian Cain. All rights reserved.
//

//import SuperpoweredIOSAudioIO

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var play: UIButton!
    @IBOutlet weak var cadenceLabel: UILabel!
    @IBOutlet weak var bpmCircle: UIView!
    @IBOutlet weak var mapView: MKMapView!
    var displayLink: CADisplayLink!
    
    var superpowered = Superpowered()
    
    
    let manager = CLLocationManager()
    var previousLocation : CLLocation!
    
    var originalSettingsSet = false
    
    var annotations = [CLLocationCoordinate2D]()
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var location = locations[0]
        print("1")
        if locations.count > 1 {
            print("2")
            location = locations.last!
        }
        
        if !originalSettingsSet {
            let span:MKCoordinateSpan = MKCoordinateSpanMake(0.01,0.01)
            let myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude,location.coordinate.longitude)
            let region:MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
            mapView.setRegion(region, animated: true)
            originalSettingsSet = true
        }
        
        mapView.showsUserLocation = true
        
        if (previousLocation as CLLocation?) != nil {
            if previousLocation.distance(from: location) > 50 {
                addAnnotationsOnMap(locationToPoint: location)
                previousLocation = location
            }
        } else {
            addAnnotationsOnMap(locationToPoint: location)
            previousLocation = location
        }

        let polyline = MKPolyline(coordinates: &annotations, count: annotations.count)
        mapView.add(polyline)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if (overlay is MKPolyline) {
            let pr = MKPolylineRenderer(overlay: overlay)
            pr.strokeColor = UIColor.red
            pr.lineWidth = 5
            return pr
        }
        return MKOverlayRenderer()
    }
    
    func addAnnotationsOnMap(locationToPoint: CLLocation) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = locationToPoint.coordinate
        let geoCoder = CLGeocoder ()
        geoCoder.reverseGeocodeLocation(locationToPoint, completionHandler: { (placemarks, error) -> Void in
            if let p = placemarks, p.count > 0 {
                let placemark = p[0]
                var addressDictionary = placemark.addressDictionary;
                annotation.title = addressDictionary?["Name"] as? String
            }
        })
        annotations.append(annotation.coordinate)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        superpowered.toggle()
        superpowered.togglePlayback()
        
        //Map stuff//
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.mapType = MKMapType(rawValue: 0)!
        mapView.userTrackingMode = MKUserTrackingMode(rawValue: 2)!
        
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
        
        displayLink = CADisplayLink(target: self, selector: #selector(ViewController.onDisplayLink))
        displayLink.preferredFramesPerSecond = 1
        displayLink.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
        
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
        let originY:CGFloat = self.view.frame.size.height - 20
        let width:CGFloat = (self.view.frame.size.width - 47) / 8
        var frame:CGRect = CGRect(x: 20, y: 0, width: width, height: 0)
        for n in 0...7 {
            frame.size.height = CGFloat(frequencies[n]) * 4000
            frame.origin.y = originY - frame.size.height
            frame.origin.x += width + 1
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

