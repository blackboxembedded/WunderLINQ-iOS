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

import UIKit
import SQLite3
import GoogleMaps
import MapKit
import CoreGPX

class WaypointViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {
    
    var db: OpaquePointer?
    
    var record: Int?
    var date: String?
    var latitude: String? = ""
    var longitude: String? = ""
    var label: String? = ""
    var waypoints = [Waypoint]()
    var waypoint: Waypoint?
    var indexOfWaypoint: Int?
    
    private var locationManager: CLLocationManager!
    private var currentLocation: CLLocation?
    
    fileprivate var popoverMenuList = [NSLocalizedString("waypoint_view_bt_open", comment: ""),NSLocalizedString("waypoint_view_bt_nav", comment: ""),NSLocalizedString("waypoint_view_bt_share", comment: ""), NSLocalizedString("share_gpx", comment: ""), NSLocalizedString("waypoint_view_bt_delete", comment: "")]
    fileprivate var popover: Popover!
    fileprivate var popoverOptions: [PopoverOption] = [
        .type(.auto),
        .color(UIColor(named: "backgrounds")!),
        .blackOverlayColor(UIColor(white: 0.0, alpha: 0.6))
    ]
    
    let scenic = ScenicAPI()
    
    var menuBtn: UIButton!
    var menuButton: UIBarButtonItem!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var longLabel: UILabel!
    @IBOutlet weak var latLabel: UILabel!
    @IBOutlet weak var labelLabel: UITextField!
    @IBOutlet weak var mapView: GMSMapView!
    
    @objc func leftScreen() {
        _ = navigationController?.popViewController(animated: true)
        //performSegue(withIdentifier: "waypointToWaypoints", sender: [])
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizer.Direction.right {
            if (indexOfWaypoint != 0){
                record = waypoints[indexOfWaypoint! - 1].id
                self.viewDidLoad()
            }
        } else if gesture.direction == UISwipeGestureRecognizer.Direction.left {
            if (indexOfWaypoint != (waypoints.count - 1)){
                record = waypoints[indexOfWaypoint! + 1].id
                self.viewDidLoad()
            }
        }
    }
    
    @objc func menuButtonTapped() {
        popUpMenu()
    }
    
    func popUpMenu() {
        var menuHeight:CGFloat = 46
        menuHeight = CGFloat(46 * popoverMenuList.count)
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width / 2, height: menuHeight))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        self.popover = Popover(options: self.popoverOptions)
        self.popover.willShowHandler = {
        }
        self.popover.didShowHandler = {
        }
        self.popover.willDismissHandler = {
        }
        self.popover.didDismissHandler = {
        }
        self.popover.show(tableView, fromView: self.menuBtn)
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
        if #available(iOS 13.0, *) {
            backBtn.tintColor = UIColor(named: "imageTint")
        }
        backBtn.addTarget(self, action: #selector(leftScreen), for: .touchUpInside)
        let backButton = UIBarButtonItem(customView: backBtn)
        let backButtonWidth = backButton.customView?.widthAnchor.constraint(equalToConstant: 30)
        backButtonWidth?.isActive = true
        let backButtonHeight = backButton.customView?.heightAnchor.constraint(equalToConstant: 30)
        backButtonHeight?.isActive = true
        menuBtn = UIButton()
        menuBtn.setImage(UIImage(named: "Menu")?.withRenderingMode(.alwaysTemplate), for: .normal)
        if #available(iOS 13.0, *) {
            menuBtn.tintColor = UIColor(named: "imageTint")
        }
        menuBtn.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
        let menuButton = UIBarButtonItem(customView: menuBtn)
        let menuButtonWidth = menuButton.customView?.widthAnchor.constraint(equalToConstant: 30)
        menuButtonWidth?.isActive = true
        let menuButtonHeight = menuButton.customView?.heightAnchor.constraint(equalToConstant: 30)
        menuButtonHeight?.isActive = true
        self.navigationItem.title = NSLocalizedString("waypoint_view_title", comment: "")
        self.navigationItem.leftBarButtonItems = [backButton]
        self.navigationItem.rightBarButtonItems = [menuButton]
        
        self.labelLabel.delegate = self
        labelLabel.placeholder = NSLocalizedString("waypoint_view_label_hint", comment: "")
        
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
    
    func open(){
        if let lat = latitude?.toDouble(), let lon = longitude?.toDouble(){
            NavAppHelper.viewWaypoint(destLatitude: lat, destLongitude: lon, destLabel: label)
        }
    }
    
    func navigate(){
        if let lat = latitude?.toDouble(), let lon = longitude?.toDouble(), let current = currentLocation {
            NavAppHelper.navigateTo(destLatitude: lat, destLongitude: lon, destLabel: label, currentLatitude: current.coordinate.latitude, currentLongitude: current.coordinate.longitude)
        }
    }
    
    func share(){
        let text = "http://maps.google.com/maps?saddr=\(latitude!),\(longitude!)"
        
        // set up activity view controller
        let textToShare = [ text ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func exportGPX(){
        if let lat = latitude?.toDouble(), let lon = longitude?.toDouble(){
            let root = GPXRoot(creator: "WunderLINQ")
            let singleWaypoint = GPXWaypoint(latitude: (lat), longitude: (lon))
            singleWaypoint.comment = label
            var fileName = "Waypoint"
            if (label != ""){
                fileName = label!
            }
            root.add(waypoint: singleWaypoint)
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
            do {
                try root.outputToFile(saveAt: url, fileName: fileName)
                let fileURL = url.appendingPathComponent("\(fileName).gpx")
                let vc = UIActivityViewController(activityItems: [fileURL], applicationActivities: [])
                self.present(vc, animated: true)
            } catch {
                print(error)
            }
        }
    }
    
    func delete(){
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
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

extension WaypointViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch(indexPath.row) {
        case 0:
            // Open
            open()
        case 1:
            //Navigate
            navigate()
        case 2:
            //Share
            share()
        case 3:
            //Share GPX
            exportGPX()
        case 4:
            //Delete
            delete()
        default:
            print("Unknown option")
        }
        self.popover.dismiss()
    }
    
}

extension WaypointViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return popoverMenuList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = self.popoverMenuList[(indexPath as NSIndexPath).row]
        return cell
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
