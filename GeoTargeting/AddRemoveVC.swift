//
//  AddRemoveVC.swift
//  GeoTargeting
//
//  Created by mac on 24/05/18.
//  Copyright © 2018 Evgenii Trapeznikov. All rights reserved.
//

import Foundation
import UIKit
import GooglePlacePicker

class AddRemoveVC: UIViewController, GMSPlacePickerViewControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tblView: UITableView!
    var selectedPlaceTitle = String()
    var selectedLocation = CLLocationCoordinate2D()
    
    override func viewDidLoad() {
        
    }
    
    @IBAction func actionAddNew(_ sender: Any) {
        let config = GMSPlacePickerConfig(viewport: nil)
        let placePicker = GMSPlacePickerViewController(config: config)
        placePicker.delegate = self
        present(placePicker, animated: true, completion: nil)
    }
    
    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true) {
            
            self.selectedPlaceTitle = place.name// + ", " + place.formattedAddress!
            self.selectedLocation = place.coordinate
            let dict : NSDictionary = [
                "title" : self.selectedPlaceTitle,
                "latitude" : "\(self.selectedLocation.latitude)",
                "longitude" : "\(self.selectedLocation.longitude)"
            ]
            arrayLocations.add(dict)
            UserDefaults.standard.set(arrayLocations, forKey: "arrayLocations")
            _ = UserDefaults.standard.synchronize()
            self.tblView.reloadData()
        }
    }
    
    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
        // Dismiss the place picker, as it cannot dismiss itself.
        viewController.dismiss(animated: true, completion: nil)
        selectedPlaceTitle = ""
        selectedLocation = CLLocationCoordinate2D()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayLocations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = (arrayLocations[indexPath.row] as! NSDictionary).value(forKey: "title") as? String
        cell.textLabel?.numberOfLines = 0
        
        if indexPath.row % 2 == 0 {
            cell.contentView.backgroundColor = UIColor.white
        }
        else {
            cell.contentView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            arrayLocations.removeObject(at: indexPath.row)
            UserDefaults.standard.set(arrayLocations, forKey: "arrayLocations")
            _ = UserDefaults.standard.synchronize()
            tblView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        self.tblView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}
