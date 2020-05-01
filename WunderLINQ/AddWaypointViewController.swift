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

class AddWaypointViewController: UIViewController, UITextFieldDelegate, GMSMapViewDelegate {
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
            
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.left {
            
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
                print("Not a valid lat or lon")
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
                print("Not a valid lat or lon")
            }
            self.view.endEditing(true)
            return true
        default:
            self.view.endEditing(true)
            return false
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        moveTextField(textField, moveDistance: -250, up: true)
    }

    // Finish Editing The Text Field
    func textFieldDidEndEditing(_ textField: UITextField) {
        moveTextField(textField, moveDistance: -250, up: false)
    }

    // Move the text field in a pretty animation!
    func moveTextField(_ textField: UITextField, moveDistance: Int, up: Bool) {
        let moveDuration = 0.3
        let movement: CGFloat = CGFloat(up ? moveDistance : -moveDistance)

        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
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
        self.latitudeField.delegate = self
        self.longitudeField.delegate = self
        addressField.placeholder = NSLocalizedString("addwaypoint_view_search_hint", comment: "")
        labelField.placeholder = NSLocalizedString("waypoint_view_label_hint", comment: "")
        latitudeField.text = "\(motorcycleData.getLocation().coordinate.latitude)"
        longitudeField.text = "\(motorcycleData.getLocation().coordinate.longitude)"
        
        mapView.delegate = self
        let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude:  motorcycleData.getLocation().coordinate.latitude, longitude: motorcycleData.getLocation().coordinate.longitude, zoom: 15.0)
        mapView.camera = camera
        mapView.mapType = .hybrid
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: motorcycleData.getLocation().coordinate.latitude, longitude: motorcycleData.getLocation().coordinate.longitude)
        marker.map = mapView
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
            if sqlite3_bind_double(stmt, 2, (Double(latitudeField!.text ?? "0.0")!)) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding name: \(errmsg)")
                return
            }
            if sqlite3_bind_double(stmt, 3, (Double(longitudeField!.text ?? "0.0")!)) != SQLITE_OK{
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
