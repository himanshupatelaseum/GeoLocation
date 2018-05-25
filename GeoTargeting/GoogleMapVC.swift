//
//  GoogleMapVC.swift
//  GeoTargeting
//
//  Created by Eugene Trapeznikov on 4/23/16.
//  Copyright © 2016 Evgenii Trapeznikov. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import GoogleMaps
import UserNotifications

class GoogleMapVC: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: GMSMapView!
    
    let locationManager = CLLocationManager()
    var monitoredRegions: Dictionary<String, Date> = [:]
    var isInsideLocation = false
    var indexOfLocation = -1
    let currentLocationMarker = GMSMarker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup locationManager
        locationManager.delegate = self;
        locationManager.distanceFilter = 10.0
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .automotiveNavigation
        locationManager.allowsBackgroundLocationUpdates = true
        
        // setup mapView
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        
//        currentLocationMarker.icon = #imageLiteral(resourceName: "my_location")

        // setup test data
//        setupData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        mapView.clear()
//        currentLocationMarker.map = mapView
//        currentLocationMarker.groundAnchor = CGPoint(x: 0.5, y: 0.5);
        setupData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // status is not determined
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        }
            // authorization were denied
        else if CLLocationManager.authorizationStatus() == .denied {
            showAlert("Location services were previously denied. Please enable location services for this app in Settings.")
        }
            // we do have authorization
        else if CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse{
            
            self.locationManager.startUpdatingLocation()
            self.locationManager.startUpdatingHeading()
        }
//        DispatchQueue.main.async {
//
//        }
    }
    
    func setupData() {
        // check if can monitor regions
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            
            var bounds = GMSCoordinateBounds()
            for dict in arrayLocations {
                let latitude = Double((dict as AnyObject).value(forKey: "latitude") as! String)
                let longitude = Double((dict as AnyObject).value(forKey: "longitude") as! String)
                self.addMoteringPlace(title: (dict as AnyObject).value(forKey: "title") as! String, latitude: latitude!, longitude: longitude!)
                bounds = bounds.includingCoordinate(CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!))
            }

            self.mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 100.0))
            
//            self.addMoteringPlace(title: "Satadhar", latitude: 23.06620000, longitude: 72.53260000)
//            self.addMoteringPlace(title: "Home", latitude: 23.08149700, longitude: 72.53834800)
//            self.addMoteringPlace(title: "Landmark Honda", latitude: 23.0480852, longitude: 72.5159037)
        }
        else {
            print("System can't track regions")
        }
    }
    
    func addMoteringPlace(title: String, latitude: Double, longitude: Double) {
        
        let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        let regionRadius = 100.0
        
//        // setup region
//        let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: coordinate.latitude,
//                                                                     longitude: coordinate.longitude), radius: regionRadius, identifier: title)
//        region.notifyOnEntry = true
//        region.notifyOnExit = true
//        locationManager.startMonitoring(for: region)
        
        let annotation = GMSMarker(position: coordinate)
        annotation.title = "\(title)"
        annotation.map = mapView
        
        let circle = GMSCircle(position: coordinate, radius: regionRadius)
        circle.map = mapView
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let circleRenderer = MKCircleRenderer(overlay: overlay)
        circleRenderer.strokeColor = UIColor.red
        circleRenderer.lineWidth = 1.0
        return circleRenderer
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        print(error)
    }
    
//    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
//        showAlert("Enter: \(region.identifier)")
//        monitoredRegions[region.identifier] = Date()
//    }
//
//    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
//        showAlert("Exit: \(region.identifier)")
//        monitoredRegions.removeValue(forKey: region.identifier)
//    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        self.mapView.animate(toBearing: newHeading.trueHeading)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print("Latitude : \(locations[0].coordinate.latitude) Longitude : \(locations[0].coordinate.longitude)")
        let location = locations.last
        
        currentLocationMarker.position = (location?.coordinate)!
        
        if locationManager.heading == nil {
            let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 17.0)
            self.mapView?.animate(to: camera)
        }
        else {
            let camera = GMSCameraPosition.camera(withLatitude: (locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!, zoom: 17.0, bearing: (locationManager.heading?.trueHeading)!, viewingAngle: 0)
            self.mapView?.animate(to: camera)
        }
        
        let isAlreadyInsideLocation = isInsideLocation
        let previousIndex = indexOfLocation
        
        for i in 0..<arrayLocations.count {
            let dict = arrayLocations[i] as! NSDictionary
            let coordinate = CLLocation(latitude: Double(dict.value(forKey: "latitude") as! String)!, longitude: Double(dict.value(forKey: "longitude") as! String)!)
            let distance = location?.distance(from: coordinate)
            if distance! <= 100.0 {
                isInsideLocation = true
                indexOfLocation = i
                break
            }
            else {
                isInsideLocation = false
            }
        }
        
        if isAlreadyInsideLocation && isInsideLocation && previousIndex != indexOfLocation {
            let dictPrev = arrayLocations[previousIndex] as! NSDictionary
            let dict = arrayLocations[indexOfLocation] as! NSDictionary
            self.fireNotification(string: "Exit : \(dictPrev.value(forKey: "title") as! String)\nEnter : \(dict.value(forKey: "title") as! String)")
        }
        else if !isAlreadyInsideLocation && isInsideLocation {
            let dict = arrayLocations[indexOfLocation] as! NSDictionary
            self.fireNotification(string: "Enter : \(dict.value(forKey: "title") as! String)")
        }
        else if isAlreadyInsideLocation && !isInsideLocation {
            let dict = arrayLocations[indexOfLocation] as! NSDictionary
            self.fireNotification(string: "Exit : \(dict.value(forKey: "title") as! String)")
        }
        else {
            
        }
        
        //updateRegionsWithLocation(locations[0])
    }
    
    func fireNotification(string: String) {
        
//        showAlert(string)
        
//        let localNotification = UILocalNotification()
//        localNotification.fireDate = Date()
//        localNotification.alertBody = string
//        UIApplication.shared.scheduleLocalNotification(localNotification)
        
        let content = UNMutableNotificationContent()
//        content.title = "Welcome to goa Singam"
        content.body = string
        content.categoryIdentifier = "alarm"
        content.sound = UNNotificationSound.default()
        
        let date = Date()
        var dateComponents = DateComponents()
        dateComponents = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - GMSMapView Delegate
    
    //    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
    //        let camera = GMSCameraPosition.camera(withLatitude: (locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!, zoom: 17.0, bearing: (mapView.myLocation?.horizontalAccuracy)!, viewingAngle: 0)
    //        self.mapView?.animate(to: camera)
    //    }
    
    // MARK: - Comples business logic
    
    func updateRegionsWithLocation(_ location: CLLocation) {
        
        let regionMaxVisiting = 10.0
        var regionsToDelete: [String] = []
        
        for regionIdentifier in monitoredRegions.keys {
            if Date().timeIntervalSince(monitoredRegions[regionIdentifier]!) > regionMaxVisiting {
                showAlert("Thanks for visiting our place")
                
                regionsToDelete.append(regionIdentifier)
            }
        }
        
        for regionIdentifier in regionsToDelete {
            monitoredRegions.removeValue(forKey: regionIdentifier)
        }
    }
    
    // MARK: - Helpers
    
    func showAlert(_ title: String) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
}

