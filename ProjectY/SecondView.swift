//
//  SecondView.swift
//  ProjectY
//
//  Created by iosdev on 6.5.2021.
//

import UIKit
import RealmSwift
import MapKit
import CoreLocation
import HealthKit
import MOPRIMTmdSdk


class SecondView: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var workoutAction: UIButton!
    
    

    
    let workout = Workout()
        
        var seconds     = 0.0
        var distance    = 0.0
        var instantPace = 0.0
        var trainingHasBegun: Bool = false
        
        lazy var locationManager: CLLocationManager = {
            var _locationManager = CLLocationManager()
            _locationManager.delegate = self
            _locationManager.desiredAccuracy = kCLLocationAccuracyBest
            _locationManager.activityType = .fitness
            _locationManager.distanceFilter = 10.0
            return _locationManager
        }()
        
        lazy var locations = [CLLocation]()
        lazy var timer = Timer()
    
    func saveWorkout() {

            workout.distance = Float(distance)
        
            workout.duration = Int(seconds)
            workout.timestamp = NSDate()

            for location in locations {
                let _location = Location()
                _location.timestamp = location.timestamp as NSDate
                _location.latitude = location.coordinate.latitude
                _location.longitude = location.coordinate.longitude
                workout.locations.append(_location)
            }
            
            if workout.save() {
                print("Workout saved!")
            } else {
                print("Could not save the run!")
            }
        }
    
    @IBAction func startTracking(_ sender: Any) {
        if trainingHasBegun == false {
                    trainingHasBegun = true
                    seconds = 0.0
                    distance = 0.0
                    locations.removeAll(keepingCapacity: false)
                    
                    timer = Timer.scheduledTimer(timeInterval: 1,
                                               target: self,
                                               selector: #selector(self.eachSecond),
                                               userInfo: nil,
                                               repeats: true)
                    startLocationUpdates()
                    
                    trainingHasBegun = true;
                    workoutAction.setTitle("Stop", for: .normal)
                    workoutAction.backgroundColor = .red
                } else {
                    trainingHasBegun = false
                    workoutAction.backgroundColor = .blue
                    stopWorkout()
                    saveWorkout()
                }
            }

            func stopTimer() {
                timer.invalidate()
            }
            
            func startLocationUpdates() {
                locationManager.startUpdatingLocation()
            }
            
            func stopWorkout() {
                stopTimer()
                locationManager.stopUpdatingLocation()
            }
            
    @objc func eachSecond(timer: Timer) {

                seconds += 1
                let secondsQuantity = HKQuantity(unit: HKUnit.second(), doubleValue: seconds)
                timeLabel.text = secondsQuantity.description
                let distanceQuantity = HKQuantity(unit: HKUnit.meter(), doubleValue: distance)
                distanceLabel.text = distanceQuantity.description
                let paceUnit = HKUnit.second().unitDivided(by: HKUnit.meter())
                let paceQuantity = HKQuantity(unit: paceUnit, doubleValue: seconds / distance)
                paceLabel.text = paceQuantity.description
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("code is connected")

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)

          locationManager = CLLocationManager()
          locationManager.delegate = self
          locationManager.desiredAccuracy = kCLLocationAccuracyBest
          locationManager.allowsBackgroundLocationUpdates = true
          locationManager.activityType = .fitness
          locationManager.distanceFilter = 10.0
          locationManager.requestAlwaysAuthorization()
          
          mapView.showsUserLocation = true
      }
}
class Workout: Object {

    @objc dynamic var timestamp = NSDate()
    @objc dynamic var duration = 0
    @objc dynamic var distance: Float = 0.0
    @objc dynamic var descent: Float = 0.0
    @objc dynamic var climb: Float = 0.0
    var locations = List<Location>()

    func save() -> Bool {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(self)
            }
            return true
        } catch let error as NSError {
            print(">>> Realm error: ", error.localizedDescription)
            return false
        }
    }
    
}

class Location: Object {

    @objc dynamic var timestamp = NSDate()
    @objc dynamic var longitude: Double = 0.0
    @objc dynamic var latitude: Double = 0.0
}
    

    
    extension SecondView {
        
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

            for location in locations {
                if location.horizontalAccuracy < 10 {
                    if self.locations.count > 0 {
                        distance += location.distance(from: self.locations.last!)
                        
                        var coords = [CLLocationCoordinate2D]()
                        coords.append(self.locations.last!.coordinate)
                        coords.append(location.coordinate)
                        
                        instantPace = location.distance(from: self.locations.last!)/(location.timestamp.timeIntervalSince(self.locations.last!.timestamp))
                        
                        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
                        mapView.setRegion(region, animated: true)

                        mapView.addOverlay(MKPolyline(coordinates: &coords, count: coords.count))
                    }
                    self.locations.append(location)
                }
            }
        }
        
    }
    
 
    extension SecondView: MKMapViewDelegate {

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {

            if overlay is MKPolyline {
                let polylineRenderer = MKPolylineRenderer(overlay: overlay)
                polylineRenderer.strokeColor = UIColor.green
                polylineRenderer.lineWidth = 3
                return polylineRenderer
            }
            return MKOverlayRenderer()
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
   


