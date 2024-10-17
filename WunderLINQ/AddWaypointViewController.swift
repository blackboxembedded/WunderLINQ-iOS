/*
WunderLINQ Client Application
Copyright (C) 2020  Keith Conger, Black Box Embedded, LLC

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

import Foundation
import UIKit
import SQLite3
import GoogleMaps
import MapKit
import CoreGPX

class AddWaypointViewController: UIViewController, UITextFieldDelegate, GMSMapViewDelegate {
    
    var importFile: URL?
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var latitudeField: UITextField!
    @IBOutlet weak var longitudeField: UITextField!
    @IBOutlet weak var labelField: UITextField!
    
    // This constraint ties an element at zero points from the bottom layout guide
    @IBOutlet var keyboardHeightLayoutConstraint: NSLayoutConstraint?
    
    let motorcycleData = MotorcycleData.shared
    
    let LATITUDE_PATTERN:String = "^(\\+|-)?(?:90(?:(?:\\.0{1,16})?)|(?:[0-9]|[1-8][0-9])(?:(?:\\.[0-9]{1,16})?))$"
    let LONGITUDE_PATTERN:String = "^(\\+|-)?(?:180(?:(?:\\.0{1,16})?)|(?:[0-9]|[1-9][0-9]|1[0-7][0-9])(?:(?:\\.[0-9]{1,16})?))$"
    
    @objc func leftScreen() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizer.Direction.right {
            leftScreen()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        switch (textField.tag){
        case 1:
            //Lat
            let lat:String = latitudeField.text ?? ""
            let lon:String = longitudeField.text ?? ""
            if ( lat.range(of: LATITUDE_PATTERN, options: .regularExpression, range: nil, locale: nil) != nil && lon.range(of: LONGITUDE_PATTERN, options: .regularExpression, range: nil, locale: nil) != nil){
                self.mapView.clear()
                let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude:  Double(lat)!, longitude: Double(lon)!, zoom: 15.0)
                self.mapView.camera = camera
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D(latitude: Double(lat)!, longitude: Double(lon)!)
                marker.map = self.mapView
            } else {
                NSLog("AddWaypointViewController: Not a valid lat or lon")
            }
            self.view.endEditing(true)
            return true
        case 2:
            //Lon
            let lat:String = latitudeField.text ?? ""
            let lon:String = longitudeField.text ?? ""
            if ( lat.range(of: LATITUDE_PATTERN, options: .regularExpression, range: nil, locale: nil) != nil && lon.range(of: LONGITUDE_PATTERN, options: .regularExpression, range: nil, locale: nil) != nil){
                self.mapView.clear()
                let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude:  Double(lat)!, longitude: Double(lon)!, zoom: 15.0)
                self.mapView.camera = camera
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D(latitude: Double(lat)!, longitude: Double(lon)!)
                marker.map = self.mapView
            } else {
                NSLog("AddWaypointViewController: Not a valid lat or lon")
            }
            self.view.endEditing(true)
            return true
        default:
            self.view.endEditing(true)
            return false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        let backBtn = UIButton()
        backBtn.setImage(UIImage(named: "Left")?.withRenderingMode(.alwaysTemplate), for: .normal)
        backBtn.tintColor = UIColor(named: "imageTint")
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
        self.latitudeField.delegate = self
        self.longitudeField.delegate = self
        addressField.placeholder = NSLocalizedString("addwaypoint_view_search_hint", comment: "")
        labelField.placeholder = NSLocalizedString("waypoint_view_label_hint", comment: "")
    
        mapView.delegate = self
        mapView.mapType = .hybrid
        // Creates a marker in the center of the map.
        if let currentLocation = motorcycleData.getLocation() {
            let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude:  currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude, zoom: 15.0)
            mapView.camera = camera
            
            latitudeField.text = "\(currentLocation.coordinate.latitude)"
            longitudeField.text = "\(currentLocation.coordinate.longitude)"
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
            marker.map = mapView
        }
        if (importFile != nil){
            NSLog("AddWaypointViewController: URL: " + importFile!.absoluteString)
            let alert = UIAlertController(title: NSLocalizedString("gpx_import_alert_title", comment: ""), message: NSLocalizedString("gpx_import_alert_body", comment: ""), preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("alert_message_exit_ok", comment: ""), style: UIAlertAction.Style.default, handler: { action in
                guard let gpx = GPXParser(withURL: self.importFile!)?.parsedData() else { return }

                // waypoints, tracks, tracksegements, trackpoints are all stored as Array depends on the amount stored in the GPX file.
                for waypoint in gpx.waypoints {
                    self.mapView.clear()
                    let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude:  waypoint.latitude!, longitude: waypoint.longitude!, zoom: 15.0)
                    self.mapView.camera = camera
                    let marker = GMSMarker()
                    marker.position = CLLocationCoordinate2D(latitude: waypoint.latitude!, longitude: waypoint.longitude!)
                    marker.map = self.mapView
                    
                    self.saveWaypoint(lat: waypoint.latitude!,
                                 long: waypoint.longitude!,
                                 label: waypoint.comment ?? "",
                                 date: waypoint.time ?? Date())
                    self.showToast(message: NSLocalizedString("toast_gpx_saved", comment: ""))
                }
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("negative_alert_btn_cancel", comment: ""), style: UIAlertAction.Style.cancel, handler: { action in
            }))
            self.present(alert, animated: true, completion: nil)
            
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
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
        
        latitudeField.text = "\(coordinate.latitude)"
        longitudeField.text = "\(coordinate.longitude)"
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
                                                self.latitudeField.text = "\(destLatitude)"
                                                self.longitudeField.text = "\(destLongitude)"
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
        if (latitudeField.text != "" && longitudeField.text != ""){
            saveWaypoint(lat: (Double(latitudeField!.text ?? "0.0")!),
                         long: (Double(longitudeField!.text ?? "0.0")!),
                         label: labelField.text ?? "",
                         date: Date())
            self.showToast(message: NSLocalizedString("toast_waypoint_saved", comment: ""))
        } else {
            self.showToast(message: NSLocalizedString("toast_waypoint_error", comment: ""))
        }
    }
    
    func saveWaypoint(lat: Double, long: Double, label: String, date: Date?){
        var db: OpaquePointer?
        let databaseURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("waypoints.sqlite")
        //opening the database
        if sqlite3_open(databaseURL.path, &db) != SQLITE_OK {
            NSLog("AddWaypointViewController: error opening database")
        }
        //creating table
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS records (id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT, latitude TEXT, longitude TEXT, elevation TEXT, label TEXT)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            NSLog("AddWaypointViewController: error creating table: \(errmsg)")
        }
        //update table if needed
        let updateStatementString = "ALTER TABLE records ADD COLUMN elevation TEXT"
        var updateStatement: OpaquePointer?
        if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                NSLog("AddWaypointViewController: Table updated successfully")
            } else {
                NSLog("AddWaypointViewController: Error updating table")
            }
        } else {
            NSLog("AddWaypointViewController: Error preparing update statement")
        }
        
        //creating a statement
        var stmt: OpaquePointer?

        //the insert query
        let queryString = "INSERT INTO records (date, latitude, longitude, elevation, label) VALUES (?,?,?,?,?)"
        
        //preparing the query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            NSLog("AddWaypointViewController: error preparing insert: \(errmsg)")
            return
        }
        
        var timestamp = Date().toString() as NSString
        if (date != nil){
            timestamp = (date?.toString())! as NSString
        }
        
        var wptLabel = label as NSString
        
        if sqlite3_bind_text(stmt, 1, timestamp.utf8String, -1, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            NSLog("AddWaypointViewController: failure binding name: \(errmsg)")
            return
        }
        if sqlite3_bind_double(stmt, 2, lat) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            NSLog("AddWaypointViewController: failure binding name: \(errmsg)")
            return
        }
        if sqlite3_bind_double(stmt, 3, long) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            NSLog("AddWaypointViewController: failure binding name: \(errmsg)")
            return
        }
        if sqlite3_bind_text(stmt, 4, nil, -1, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            NSLog("AddWaypointViewController: failure binding name: \(errmsg)")
            return
        }
        if sqlite3_bind_text(stmt, 5, wptLabel.utf8String, -1, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            NSLog("AddWaypointViewController: failure binding name: \(errmsg)")
            return
        }

        //executing the query to insert values
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            NSLog("AddWaypointViewController: failure inserting wapoint: \(errmsg)")
            return
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size else { return }
        
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        view.frame.origin.y -= contentInsets.bottom
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
    }
}
