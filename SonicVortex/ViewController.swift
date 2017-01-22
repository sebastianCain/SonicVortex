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

    //MARK: Properties
    @IBOutlet weak var startLayer: UIView!
    @IBOutlet weak var runLayer: UIView!
    
    @IBOutlet weak var start: UIButton!
    @IBOutlet weak var end: UIButton!
    
    @IBOutlet weak var vizLayer: UIView!
    @IBOutlet weak var play: UIButton!
    @IBOutlet weak var cadenceLabel: UILabel!
    @IBOutlet weak var bpmCircle: UIView!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var playY: NSLayoutConstraint!
    @IBOutlet weak var vizY: NSLayoutConstraint!
    @IBOutlet weak var startY: NSLayoutConstraint!
    
    var displayLink: CADisplayLink!
    var circlez = [CALayer]()
    var superpowered = Superpowered()

    var minLat: CLLocationDegrees = 0
    var maxLat: CLLocationDegrees = 0
    var minLon: CLLocationDegrees = 0
    var maxLon: CLLocationDegrees = 0
    
    let manager = CLLocationManager()
    var previousLocation : CLLocation!
    var annotations = [CLLocationCoordinate2D]()
    var startTime: Float64 = 0.0
    var endTime: Float64 = 0.0
    var elapsedTime: Float64 = 0.0
    var elapsedDist: Float64 = 0.0
    var countToThree = 0
    var begin = false {
        didSet {
            if begin {
                mapSetup()
            }
        }
    }
    var finish = false {
        didSet {
            if finish {
                completeRun()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var location = locations[0]
        if locations.count > 1 {
            location = locations.last!
        }
        
        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.01,0.01)
        let myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude,location.coordinate.longitude)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        mapView.setRegion(region, animated: true)
        
        mapView.showsUserLocation = true
        
        if (previousLocation as CLLocation?) != nil {
            if previousLocation.distance(from: location) > 10 {
                addAnnotationsOnMap(locationToPoint: location)
                elapsedDist += previousLocation.distance(from: location)
                previousLocation = location
                if location.coordinate.latitude < minLat {
                    minLat = location.coordinate.latitude
                }
                if location.coordinate.latitude > minLat {
                    maxLat = location.coordinate.latitude
                }
                if location.coordinate.latitude < minLat {
                    minLon = location.coordinate.longitude
                }
                if location.coordinate.latitude < minLat {
                    maxLon = location.coordinate.longitude
                }
            }
        }
        else {
            minLat = location.coordinate.latitude
            maxLat = location.coordinate.latitude
            minLon = location.coordinate.longitude
            maxLon = location.coordinate.longitude
            addAnnotationsOnMap(locationToPoint: location)
            previousLocation = location
        }
        if (NSDate().timeIntervalSince1970-startTime > 5) {
            let polyline = MKPolyline(coordinates: &annotations, count: annotations.count)
            mapView.add(polyline)
        }
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
    
    override func viewWillLayoutSubviews() {
        playY.constant = -150
        vizY.constant = 150
        startY.constant = -150
    }
    
//Map stuff//
    func mapSetup() {
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.mapType = MKMapType(rawValue: 0)!
        mapView.setUserTrackingMode(MKUserTrackingMode.follow, animated: true)
        startTime = NSDate().timeIntervalSince1970
    }
    
    /*static func takeSnapshot(mapView: MKMapView, withCallback: (UIImage?, NSError?) -> ()) {
        let options = MKMapSnapshotOptions()
        options.region = mapView.region
        options.size = mapView.frame.size
        options.scale = UIScreen.mainScreen().scale
        
        let snapshotter = MKMapSnapshotter(options: options)
        snapshotter.startWithCompletionHandler() { snapshot, error in
            guard snapshot != nil else {
                withCallback(nil, error)
                return
            }
            
            withCallback(snapshot!.image, nil)
        }
    }
    
    static func takeSnapshot(mapView: MKMapView, filename: String) {
        
        MapHelper.takeSnapshot(mapView) { (image, error) -> () in
            guard image != nil else {
                print(error)
                return
            }
            
            if let data = UIImagePNGRepresentation(image!) {
                let filename = getDocumentsDirectory().stringByAppendingPathComponent("\(filename).png")
                data.writeToFile(filename, atomically: true)
            }
        }
    }
    
    static func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory as NSString
    }*/
    
    func completeRun() {
        endTime = NSDate().timeIntervalSince1970
        
        elapsedTime = endTime - startTime
        
        /*let center: CLLocationCoordinate2D = CLLocationCoordinate2DMake((maxLat-minLat)/2,(maxLon-minLon)/2)
        let span = MKCoordinateSpanMake(maxLat-minLat, maxLon-minLon)
        let region = MKCoordinateRegionMake(center, span)
        
        mapView.setRegion(region, animated: false)
        
        self.takeSnapshot(mapView)*/
        
        manager.stopUpdatingLocation()
        
        let avc = self.storyboard?.instantiateViewController(withIdentifier: "avc") as! AnalysisViewController
        //avc.img = img
        avc.time = "\(Int(elapsedTime/60))m \(Int(elapsedTime.truncatingRemainder(dividingBy: 60)))s"
        avc.dist = "\(Float(Int(elapsedDist/10))/100)km"
        self.show(avc, sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        superpowered.toggle()
        superpowered.togglePlayback()
        
        //CoreMotionInterface.beginTracking()
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "cad"), object: nil, queue: OperationQueue.main, using: { notif in
            let cadence = (notif.object as! NSNumber).floatValue
            let bpm = cadence*60
            var tempo = bpm/140.0
            tempo = Float(Int(tempo*10))/10
            self.cadenceLabel.text = "\(tempo)x tempo"
            (self.bpmCircle.layer.sublayers?.first as! CAShapeLayer).strokeEnd = CGFloat(bpm)/300.0
            self.superpowered.updateCadence(Double(cadence))
        })
        //gradient.setNeedsDisplay()
        
        start.layer.cornerRadius = 75
        start.layer.borderColor = UIColor.white.cgColor
        start.layer.borderWidth = 7
        start.alpha = 0.5
        
        end.layer.cornerRadius = 15
        end.layer.borderColor = UIColor.white.cgColor
        end.layer.borderWidth = 1.5
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(endTriggered))
        end.addGestureRecognizer(lpgr)
        
        play.layer.cornerRadius = 35
        play.layer.borderColor = UIColor.white.cgColor
        play.layer.borderWidth = 1.5
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
        
        for i in 0..<32 {
            let circle = CALayer()
            circle.frame = CGRect(x: 0, y: 0, width: 7, height: 7)
            circle.cornerRadius = 4
            circle.backgroundColor = UIColor.white.cgColor
            circle.position = CircleManager.position(index: i)
            circle.transform = CATransform3DRotate(CATransform3DIdentity, CGFloat(CircleManager.rotation(index: i)), 0, 0, 1)

            vizLayer.layer.addSublayer(circle)
            circlez.append(circle)
        }
        startLayer.alpha = 1.0
        runLayer.alpha = 0.0
    }
    
    func onDisplayLink() {
        // Get the frequency values.
        let frequencies = UnsafeMutablePointer<Float>.allocate(capacity: 16)
        superpowered.getFrequencies(frequencies)
        
        // Wrapping the UI changes in a CATransaction block like this prevents animation/smoothing.
        CATransaction.begin()
        CATransaction.setAnimationDuration(0)
        CATransaction.setDisableActions(true)
        
        // Set the dimension of every frequency bar.
        for n in 0..<32 {
            var h: CGFloat = 0.0
            if n < 16 {
                h = CGFloat(frequencies[n]) * CGFloat(200.0)
            } else {
                h = CGFloat(frequencies[31-n]) * CGFloat(200.0)
            }
            circlez[n].bounds = CGRect(x: 0, y: 0, width: 7, height: max(CGFloat(h), 7.0))
        }
        
        CATransaction.commit()
        frequencies.deallocate(capacity: 16)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: - Triggers
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
    
    @IBAction func startTriggered(_ sender: UIButton) {
        begin = true
        startY.constant = 150
        UIView.animate(withDuration: 1, delay: 0.0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.startLayer.layoutIfNeeded()
        }, completion: { b in
            UIView.animate(withDuration: 0.3, animations: {
                self.startLayer.alpha = 0.0
                self.runLayer.alpha = 1.0
            }, completion: { b in
                self.startLayer.isUserInteractionEnabled = false
                self.runLayer.isUserInteractionEnabled = true
            })
        })
    }
    
    @IBAction func tempoTriggered(_ sender: UIButton) {
        superpowered.toggleFx()
    }
    
    //MARK: - Long Press Gest Recog
    func endTriggered() {
        if !finish {
            finish = true
        }
    }

}

