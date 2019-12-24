//
//  AddWaypointViewController.swift
//  WunderLINQ
//
//  Created by Keith Conger on 12/23/19.
//  Copyright © 2019 Black Box Embedded, LLC. All rights reserved.
//

import Foundation
import UIKit
import SQLite3
import GoogleMaps
import MapKit

class AddWaypointViewController: UIViewController, UITextFieldDelegate, GMSMapViewDelegate {
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var labelField: UITextField!
    
    
    let motorcycleData = MotorcycleData.shared
    
    @objc func leftScreen() {
        _ = navigationController?.popViewController(animated: true)
        //performSegue(withIdentifier: "waypointToWaypoints", sender: [])
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizer.Direction.right {
            
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.left {
            
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AppUtility.lockOrientation(.portrait)
        
        // Do any additional setup after loading the view.

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        let backBtn = UIButton()
        backBtn.setImage(UIImage(named: "Left")?.withRenderingMode(.alwaysTemplate), for: .normal)
        if #available(iOS 13.0, *) {
            backBtn.tintColor = UIColor(named: "imageTint")
        }
        backBtn.addTarget(self, action: #selector(leftScreen), for: .touchUpInside)
        let backButton = UIBarButtonItem(customView: backBtn)
        let backButtonWidth = backButton.customView?.widthAnchor.constraint(equalToConstant: 30)
        backButtonWidth?.isActive = true
        let backButtonHeight = backButton.customView?.heightAnchor.constraint(equalToConstant: 30)
        backButtonHeight?.isActive = true
        self.navigationItem.title = NSLocalizedString("addwaypoint_view_title", comment: "")
        self.navigationItem.leftBarButtonItems = [backButton]
        
        self.labelField.delegate = self
        self.addressField.delegate = self
        
        mapView.delegate = self
        let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude:  motorcycleData.getLocation().coordinate.latitude, longitude: motorcycleData.getLocation().coordinate.longitude, zoom: 15.0)
        mapView.camera = camera
        mapView.mapType = .hybrid
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: motorcycleData.getLocation().coordinate.latitude, longitude: motorcycleData.getLocation().coordinate.longitude)
        marker.map = mapView
        latitudeLabel.text = "\(motorcycleData.getLocation().coordinate.latitude)"
        longitudeLabel.text = "\(motorcycleData.getLocation().coordinate.longitude)"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Don't forget to reset when view is being removed
        AppUtility.lockOrientation(.all)
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D){
        mapView.clear() // clearing Pin before adding new
        let marker = GMSMarker(position: coordinate)
        marker.map = mapView
        
        latitudeLabel.text = "\(coordinate.latitude)"
        longitudeLabel.text = "\(coordinate.longitude)"
    }
    
    @IBAction func lookupPressed(_ sender: Any) {
        let address = addressField.text
        if (address != ""){
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(address!,
                                          completionHandler: { (placemarks, error) in
                                            if error == nil {
                                                let placemark = placemarks?.first
                                                let lat = placemark?.location?.coordinate.latitude
                                                let lon = placemark?.location?.coordinate.longitude
                                                let destLatitude: CLLocationDegrees = lat!
                                                let destLongitude: CLLocationDegrees = lon!
                                                self.latitudeLabel.text = "\(destLatitude)"
                                                self.longitudeLabel.text = "\(destLongitude)"
                                                self.mapView.clear()
                                                let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude:  destLatitude, longitude: destLongitude, zoom: 15.0)
                                                self.mapView.camera = camera
                                                let marker = GMSMarker()
                                                marker.position = CLLocationCoordinate2D(latitude: destLatitude, longitude: destLongitude)
                                                marker.map = self.mapView
                                            }
                                            else {
                                                // An error occurred during geocoding.
                                                self.showToast(message: NSLocalizedString("geocode_error", comment: ""))
                                            }
            })
        }
    }
    
    @IBAction func savePressed(_ sender: Any) {
        if (latitudeLabel.text != "" && longitudeLabel.text != ""){
            var db: OpaquePointer?
            let databaseURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                .appendingPathComponent("waypoints.sqlite")
            //opening the database
            if sqlite3_open(databaseURL.path, &db) != SQLITE_OK {
                print("error opening database")
            }
            
            //creating table
            if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS records (id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT, latitude TEXT, longitude TEXT, label TEXT)", nil, nil, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error creating table: \(errmsg)")
            }
            
            //creating a statement
            var stmt: OpaquePointer?

            //the insert query
            let queryString = "INSERT INTO records (date, latitude, longitude, label) VALUES (?,?,?,?)"
            
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing insert: \(errmsg)")
                return
            }
            
            let date = Date().toString() as NSString
            let label : String = labelField.text ?? ""
            
            if sqlite3_bind_text(stmt, 1, date.utf8String, -1, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding name: \(errmsg)")
                return
            }
            if sqlite3_bind_double(stmt, 2, (Double(latitudeLabel!.text ?? "0.0")!)) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding name: \(errmsg)")
                return
            }
            if sqlite3_bind_double(stmt, 3, (Double(longitudeLabel!.text ?? "0.0")!)) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding name: \(errmsg)")
                return
            }
            if sqlite3_bind_text(stmt, 4, label, -1, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding name: \(errmsg)")
                return
            }
            
            //executing the query to insert values
            if sqlite3_step(stmt) != SQLITE_DONE {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure inserting wapoint: \(errmsg)")
                return
            }
            self.showToast(message: NSLocalizedString("toast_waypoint_saved", comment: ""))
        } else {
            self.showToast(message: NSLocalizedString("toast_waypoint_error", comment: ""))
        }
    }
}
