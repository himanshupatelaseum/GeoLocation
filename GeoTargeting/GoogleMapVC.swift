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

class GoogleMapVC: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: GMSMapView!
    
    let locationManager = CLLocationManager()
    var monitoredRegions: Dictionary<String, Date> = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup locationManager
        locationManager.delegate = self;
        locationManager.distanceFilter = 10.0
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .automotiveNavigation
        
        // setup mapView
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        
        // setup test data
//        setupData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        mapView.clear()
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
            
        }
        DispatchQueue.main.async {
            
        }
        self.locationManager.startUpdatingLocation()
    }
    
    func setupData() {
        // check if can monitor regions
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            
//            var bounds = GMSCoordinateBounds()
//            for dict in arrayLocations {
//                let latitude = Double((dict as AnyObject).value(forKey: "latitude") as! String)
//                let longitude = Double((dict as AnyObject).value(forKey: "longitude") as! String)
//                self.addMoteringPlace(title: (dict as AnyObject).value(forKey: "title") as! String, latitude: latitude!, longitude: longitude!)
//                bounds = bounds.includingCoordinate(CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!))
//            }
//
//            self.mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 100.0))
            
            self.addMoteringPlace(title: "Satadhar", latitude: 23.06620000, longitude: 72.53260000)
            self.addMoteringPlace(title: "Home", latitude: 23.08149700, longitude: 72.53834800)
            self.addMoteringPlace(title: "Landmark Honda", latitude: 23.0480852, longitude: 72.5159037)
        }
        else {
            print("System can't track regions")
        }
    }
    
    func addMoteringPlace(title: String, latitude: Double, longitude: Double) {
        
        let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        let regionRadius = 100.0
        
        // setup region
        let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: coordinate.latitude,
                                                                     longitude: coordinate.longitude), radius: regionRadius, identifier: title)
        region.notifyOnExit = true
        region.notifyOnEntry = true
        locationManager.startMonitoring(for: region)
        
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
    
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        showAlert("Enter: \(region.identifier)")
        monitoredRegions[region.identifier] = Date()
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        showAlert("Exit: \(region.identifier)")
        monitoredRegions.removeValue(forKey: region.identifier)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Latitude : \(locations[0].coordinate.latitude) Longitude : \(locations[0].coordinate.longitude)")
        
        let location = locations.last
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 17.0)
        self.mapView?.animate(to: camera)
        
        //updateRegionsWithLocation(locations[0])
    }
    
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

