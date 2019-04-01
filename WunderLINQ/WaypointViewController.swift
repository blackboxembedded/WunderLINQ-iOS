//
//  WaypointViewController.swift
//  WunderLINQ
//
//  Created by Keith Conger on 7/20/18.
//  Copyright © 2018 Black Box Embedded, LLC. All rights reserved.
//

import UIKit
import SQLite3
import GoogleMaps
import MapKit

class WaypointViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {
    
    var db: OpaquePointer?
    
    var record: Int?
    var date: String?
    var latitude: String? = ""
    var longitude: String? = ""
    var label: String?
    var waypoints = [Waypoint]()
    var waypoint: Waypoint?
    var indexOfWaypoint: Int?
    
    private var locationManager: CLLocationManager!
    private var currentLocation: CLLocation?
    
    let scenic = ScenicAPI()
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var longLabel: UILabel!
    @IBOutlet weak var latLabel: UILabel!
    @IBOutlet weak var labelLabel: UITextField!
    
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var openBtn: UIButton!
    @IBOutlet weak var navBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    
    @objc func leftScreen() {
        performSegue(withIdentifier: "waypointToWaypoints", sender: [])
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizer.Direction.right {
            if (indexOfWaypoint != 0){
                record = waypoints[indexOfWaypoint! - 1].id
                self.viewDidLoad()
            }
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.left {
            if (indexOfWaypoint != (waypoints.count - 1)){
                record = waypoints[indexOfWaypoint! + 1].id
                self.viewDidLoad()
            }
        }
    }

    @IBAction func sharePressed(_ sender: Any) {
        // text to share
        let text = "\(latitude!),\(longitude!)"
        
        // set up activity view controller
        let textToShare = [ text ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func navPressed(_ sender: Any) {
        if let lat = latitude?.toDouble(), let lon = longitude?.toDouble(){
            
            let destLatitude: CLLocationDegrees = lat
            let destLongitude: CLLocationDegrees = lon
            
            let navApp = UserDefaults.standard.integer(forKey: "nav_app_preference")
            switch (navApp){
            case 0:
                //Apple Maps
                let coordinates = CLLocationCoordinate2DMake(destLatitude, destLongitude)
                let navPlacemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
                let mapitem = MKMapItem(placemark: navPlacemark)
                let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
                mapitem.openInMaps(launchOptions: options)
            case 1:
                //Google Maps
                //googlemaps://
                if let googleMapsURL = URL(string: "comgooglemaps-x-callback://?daddr=\(destLatitude),\(destLongitude)&directionsmode=driving&x-success=wunderlinq://?resume=true&x-source=WunderLINQ") {
                    if (UIApplication.shared.canOpenURL(googleMapsURL)) {
                        if #available(iOS 10, *) {
                            UIApplication.shared.open(googleMapsURL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                        } else {
                            UIApplication.shared.openURL(googleMapsURL as URL)
                        }
                    }
                }
            case 2:
                //Scenic
                //https://github.com/guidove/Scenic-Integration/blob/master/README.md
                self.scenic.sendToScenicForNavigation(coordinate: CLLocationCoordinate2D(latitude: destLatitude,longitude: destLongitude), name: label ?? "WunderLINQ")
            case 3:
                //Sygic
                //https://www.sygic.com/developers/professional-navigation-sdk/ios/custom-url
                let urlString = "com.sygic.aura://coordinate|\(destLongitude)|\(destLatitude)|drive"
                
                if let sygicURL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                    if (UIApplication.shared.canOpenURL(sygicURL)) {
                        if #available(iOS 10, *) {
                            UIApplication.shared.open(sygicURL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                        } else {
                            UIApplication.shared.openURL(sygicURL as URL)
                        }
                    }
                }
            case 4:
                //Waze
                //waze://?ll=[lat],[lon]&z=10
                if let wazeURL = URL(string: "waze://?ll=\(destLatitude),\(destLongitude)&navigate=yes") {
                    if (UIApplication.shared.canOpenURL(wazeURL)) {
                        if #available(iOS 10, *) {
                            UIApplication.shared.open(wazeURL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                        } else {
                            UIApplication.shared.openURL(wazeURL as URL)
                        }
                    }
                }
            case 5:
                //Maps.me
                //https://github.com/mapsme/api-ios
                //https://dlink.maps.me/route?sll=55.800800,37.532754&saddr=PointA&dll=55.760158,37.618756&daddr=PointB&type=vehicle
                if currentLocation != nil {
                    let startLatitude: CLLocationDegrees = (self.currentLocation?.coordinate.latitude)!
                    let startLongitude: CLLocationDegrees = (self.currentLocation?.coordinate.longitude)!
                    let urlString = "mapsme://route?sll=\(startLatitude),\(startLongitude)&saddr=\(NSLocalizedString("trip_view_waypoint_start_label", comment: ""))&dll=\(destLatitude),\(destLongitude)&daddr=\(label ?? ""))&type=vehicle"
                    if let mapsMeURL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                        if (UIApplication.shared.canOpenURL(mapsMeURL)) {
                            if #available(iOS 10, *) {
                                UIApplication.shared.open(mapsMeURL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                            } else {
                                UIApplication.shared.openURL(mapsMeURL as URL)
                            }
                        }
                    }
                }
            default:
                //Apple Maps
                let coordinates = CLLocationCoordinate2DMake(destLatitude, destLongitude)
                let navPlacemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
                let mapitem = MKMapItem(placemark: navPlacemark)
                let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
                mapitem.openInMaps(launchOptions: options)
            }
        } else {
            
        }
    }
    @IBAction func openPressed(_ sender: Any) {
        if let lat = latitude?.toDouble(), let lon = longitude?.toDouble(){
            let destLatitude: CLLocationDegrees = lat
            let destLongitude: CLLocationDegrees = lon
            let navApp = UserDefaults.standard.integer(forKey: "nav_app_preference")
            print("NavApp: \(navApp)")
            switch (navApp){
            case 0:
                //Apple Maps
                let regionDistance:CLLocationDistance = 10000
                let coordinates = CLLocationCoordinate2DMake(lat, lon)
                let regionSpan = MKCoordinateRegion.init(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
                let options = [
                    MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                    MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
                ]
                let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
                let mapItem = MKMapItem(placemark: placemark)
                mapItem.name = label
                mapItem.openInMaps(launchOptions: options)
            case 1:
                //Google Maps
                //https://developers.google.com/maps/documentation/urls/ios-urlscheme
                let urlString = "comgooglemaps-x-callback://?q=\(lat),\(lon)&x-success=wunderlinq://?resume=true&x-source=WunderLINQ"
                if let googleMapsURL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                    print("google map selected url")
                    if (UIApplication.shared.canOpenURL(googleMapsURL)) {
                        if #available(iOS 10, *) {
                            UIApplication.shared.open(googleMapsURL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                        } else {
                            UIApplication.shared.openURL(googleMapsURL as URL)
                        }
                    }
                }
            case 2:
                //Scenic
                //https://github.com/guidove/Scenic-Integration/blob/master/README.md
                self.scenic.sendToScenicForNavigation(coordinate: CLLocationCoordinate2D(latitude: destLatitude,longitude: destLongitude), name: label ?? "")
            case 3:
                //Sygic
                //https://www.sygic.com/developers/professional-navigation-sdk/ios/custom-url
                let urlString = "com.sygic.aura://coordinate|\(destLongitude)|\(destLatitude)|show"
                
                if let sygicURL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                    if (UIApplication.shared.canOpenURL(sygicURL)) {
                        if #available(iOS 10, *) {
                            UIApplication.shared.open(sygicURL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                        } else {
                            UIApplication.shared.openURL(sygicURL as URL)
                        }
                    }
                }
            case 4:
                //Waze
                // https://developers.google.com/waze/deeplinks/
                if let wazeURL = URL(string: "https://waze.com/ul?ll=\(lat),\(lon)&z=10") {
                    if (UIApplication.shared.canOpenURL(wazeURL)) {
                        if #available(iOS 10, *) {
                            UIApplication.shared.open(wazeURL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                        } else {
                            UIApplication.shared.openURL(wazeURL as URL)
                        }
                    }
                }
            case 5:
                //Maps.me
                //https://github.com/mapsme/api-ios
                //mapswithme://map?v=1&ll=54.32123,12.34562&n=Point%20Name&id=AnyStringOrEncodedUrl&backurl=UrlToCallOnBackButton&appname=TitleToDisplayInNavBar
                let urlString = "mapsme://map?ll=\(destLatitude),\(destLongitude)&n=\(label ?? "")&id=\(NSLocalizedString("product", comment: ""))&backurl=wunderlinq://&appname=\(NSLocalizedString("product", comment: ""))"
                
                if let mapsMeURL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                    if (UIApplication.shared.canOpenURL(mapsMeURL)) {
                        if #available(iOS 10, *) {
                            UIApplication.shared.open(mapsMeURL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                        } else {
                            UIApplication.shared.openURL(mapsMeURL as URL)
                        }
                    }
                }
            default:
                //Apple Maps
                let regionDistance:CLLocationDistance = 10000
                let coordinates = CLLocationCoordinate2DMake(lat, lon)
                let regionSpan = MKCoordinateRegion.init(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
                let options = [
                    MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                    MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
                ]
                let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
                let mapItem = MKMapItem(placemark: placemark)
                mapItem.name = label
                mapItem.openInMaps(launchOptions: options)
            }
        }
    }
    
    @IBAction func deletePressed(_ sender: Any) {
        
        let alert = UIAlertController(title: NSLocalizedString("delete_waypoint_alert_title", comment: ""), message: NSLocalizedString("delete_waypoint_alert_body", comment: ""), preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("delete_bt", comment: ""), style: UIAlertAction.Style.default, handler: { action in
            let queryString = "DELETE FROM records WHERE id = \(self.record ?? 0)"
            //statement pointer
            var stmt:OpaquePointer?
            
            //preparing the query
            if sqlite3_prepare(self.db, queryString, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(self.db)!)
                print("error preparing insert: \(errmsg)")
                return
            }
            
            //executing the query to delete row
            if sqlite3_step(stmt) != SQLITE_DONE {
                let errmsg = String(cString: sqlite3_errmsg(self.db)!)
                print("failure inserting wapoint: \(errmsg)")
                return
            }
            
            self.performSegue(withIdentifier: "waypointToWaypoints", sender: [])
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("cancel_bt", comment: ""), style: UIAlertAction.Style.cancel, handler: { action in
            // quit app
            //exit(0)
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //Update waypoint label in DB
        let databaseURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("waypoints.sqlite")
        
        //opening the database
        if sqlite3_open(databaseURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
        
        //creating a statement
        var stmt: OpaquePointer?
        
        //the insert query
        let queryString = "UPDATE records SET label='\(labelLabel.text!)' WHERE id = \(record!)"
        
        //preparing the query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }

        //executing the query to insert values
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting waypoint: \(errmsg)")
            return
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
        backBtn.addTarget(self, action: #selector(leftScreen), for: .touchUpInside)
        let backButton = UIBarButtonItem(customView: backBtn)
        let backButtonWidth = backButton.customView?.widthAnchor.constraint(equalToConstant: 30)
        backButtonWidth?.isActive = true
        let backButtonHeight = backButton.customView?.heightAnchor.constraint(equalToConstant: 30)
        backButtonHeight?.isActive = true
        self.navigationItem.title = NSLocalizedString("waypoint_view_title", comment: "")
        self.navigationItem.leftBarButtonItems = [backButton]
        
        self.labelLabel.delegate = self
        
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
        readWaypoints()
        readWaypoint()
        
        indexOfWaypoint = waypoints.firstIndex(of: waypoint!)

        mapView.clear()
        if let lat = latitude?.toDouble(), let lon = longitude?.toDouble(){
            let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: lat, longitude: lon, zoom: 15.0)
            mapView.camera = camera
            mapView.mapType = .hybrid
            // Creates a marker in the center of the map.
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            marker.title = label
            marker.snippet = label
            marker.map = mapView
        } else {
            print("Invalid Value")
        }
        
        dateLabel.text = date
        latLabel.text = latitude
        longLabel.text = longitude
        labelLabel.text = label
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Check for Location Services
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    // MARK - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        do { currentLocation = locations.last }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Don't forget to reset when view is being removed
        AppUtility.lockOrientation(.all)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func readWaypoint(){
        //this is our select query
        let queryString = "SELECT * FROM records WHERE id = \(record ?? 0)"
        
        //statement pointer
        var stmt:OpaquePointer?
        
        //preparing the query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        //traversing through all the records
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let id = Int(sqlite3_column_int(stmt, 0))
            date = String(cString: sqlite3_column_text(stmt, 1))
            latitude = String(cString: sqlite3_column_text(stmt, 2))
            longitude = String(cString: sqlite3_column_text(stmt, 3))
            label = ""
            if ( sqlite3_column_text(stmt, 4) != nil ){
                label = String(cString: sqlite3_column_text(stmt, 4))
            }
            waypoint = Waypoint(id: Int(id), date: String(describing: date), latitude: String(describing: latitude), longitude: String(describing: longitude), label: String(describing: label))
        }
    }
    
    func readWaypoints(){
        
        //first empty the list of watpoints
        waypoints.removeAll()
        
        //this is our select query
        let queryString = "SELECT id,date,latitude,longitude,label FROM records ORDER BY id DESC"
        
        //statement pointer
        var stmt:OpaquePointer?
        
        //preparing the query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        //traversing through all the records
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let id = sqlite3_column_int(stmt, 0)
            let date = String(cString: sqlite3_column_text(stmt, 1))
            let latitude = String(cString: sqlite3_column_text(stmt, 2))
            let longitude = String(cString: sqlite3_column_text(stmt, 3))
            var label = ""
            if ( sqlite3_column_text(stmt, 4) != nil ){
                label = String(cString: sqlite3_column_text(stmt, 4))
            }
            //adding values to list
            waypoints.append(Waypoint(id: Int(id), date: String(describing: date), latitude: String(describing: latitude), longitude: String(describing: longitude), label: String(describing: label)))
        }
    }
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
