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

import CoreLocation
import MapKit
import UIKit
import SQLite3

class WaypointsNavTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    var db: OpaquePointer?
    var waypoints = [Waypoint]()
    var itemRow = 0
    
    private var locationManager: CLLocationManager!
    private var currentLocation: CLLocation?
    
    var firstRun = true;
    
    let scenic = ScenicAPI()
    
    override var keyCommands: [UIKeyCommand]? {
        
        let commands = [
            UIKeyCommand(input: "\u{d}", modifierFlags:[], action: #selector(selectItem), discoverabilityTitle: "Select item"),
            UIKeyCommand(input: UIKeyCommand.inputUpArrow, modifierFlags:[], action: #selector(upRow), discoverabilityTitle: "Go up"),
            UIKeyCommand(input: UIKeyCommand.inputDownArrow, modifierFlags:[], action: #selector(downRow), discoverabilityTitle: "Go down"),
            UIKeyCommand(input: UIKeyCommand.inputLeftArrow, modifierFlags:[], action: #selector(leftScreen), discoverabilityTitle: "Go left")
        ]
        return commands
    }
    
    @objc func selectItem() {
        navigateToWaypoint(id: itemRow)
    }
    
    @objc func upRow() {
        firstRun = false
        if (itemRow == 0){
            let nextRow = waypoints.count - 1
            if #available(iOS 13.0, *) {
                self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.contentView.backgroundColor = UIColor(named: "backgrounds")!
                self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.textLabel?.backgroundColor = UIColor(named: "backgrounds")!
                self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.textLabel?.textColor = UIColor(named: "imageTint")!
            } else {
                switch(UserDefaults.standard.integer(forKey: "darkmode_preference")){
                case 0:
                    //OFF
                    self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.contentView.backgroundColor = UIColor.white
                    self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.textLabel?.backgroundColor = UIColor.white
                    self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.textLabel?.textColor = UIColor.black
                case 1:
                    //On
                    self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.contentView.backgroundColor = UIColor.black
                    self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.textLabel?.backgroundColor = UIColor.black
                    self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.textLabel?.textColor = UIColor.white
                default:
                    //Default
                    self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.contentView.backgroundColor = UIColor.white
                    self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.textLabel?.backgroundColor = UIColor.white
                    self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.textLabel?.textColor = UIColor.black
                }
            }
            tableView.reloadData()
            self.tableView.cellForRow(at: IndexPath(row: nextRow, section: 0) as IndexPath)?.contentView.backgroundColor = UIColor(named: "accent")!
            self.tableView.cellForRow(at: IndexPath(row: nextRow, section: 0) as IndexPath)?.textLabel?.backgroundColor = UIColor(named: "accent")!
            self.tableView.cellForRow(at: IndexPath(row: nextRow, section: 0) as IndexPath)?.textLabel?.textColor = UIColor.white
            self.tableView.scrollToRow(at: IndexPath(row: nextRow, section: 0), at: .middle, animated: true)
            itemRow = nextRow
        } else if (itemRow < waypoints.count ){
            let nextRow = itemRow - 1
            if #available(iOS 13.0, *) {
                self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.contentView.backgroundColor = UIColor(named: "backgrounds")!
                self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.textLabel?.backgroundColor = UIColor(named: "backgrounds")!
                self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.textLabel?.textColor = UIColor(named: "imageTint")!
            } else {
                switch(UserDefaults.standard.integer(forKey: "darkmode_preference")){
                case 0:
                    //OFF
                    self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.contentView.backgroundColor = UIColor.white
                    self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.textLabel?.backgroundColor = UIColor.white
                    self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.textLabel?.textColor = UIColor.black
                case 1:
                    //On
                    self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.contentView.backgroundColor = UIColor.black
                    self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.textLabel?.backgroundColor = UIColor.black
                    self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.textLabel?.textColor = UIColor.white
                default:
                    //Default
                    self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.contentView.backgroundColor = UIColor.white
                    self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.textLabel?.backgroundColor = UIColor.white
                    self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.textLabel?.textColor = UIColor.black
                }
            }
            tableView.reloadData()
            self.tableView.cellForRow(at: IndexPath(row: nextRow, section: 0) as IndexPath)?.contentView.backgroundColor = UIColor(named: "accent")!
            self.tableView.cellForRow(at: IndexPath(row: nextRow, section: 0) as IndexPath)?.textLabel?.backgroundColor = UIColor(named: "accent")!
            self.tableView.cellForRow(at: IndexPath(row: nextRow, section: 0) as IndexPath)?.textLabel?.textColor = UIColor.white
            self.tableView.scrollToRow(at: IndexPath(row: nextRow, section: 0), at: .middle, animated: true)
            itemRow = nextRow
        }
    }
    @objc func downRow() {
        if firstRun{
            firstRun = false
            if #available(iOS 13.0, *) {
                self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.contentView.backgroundColor = UIColor(named: "backgrounds")!
                self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.textLabel?.backgroundColor = UIColor(named: "backgrounds")!
                self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.textLabel?.textColor = UIColor(named: "imageTint")!
            } else {
                switch(UserDefaults.standard.integer(forKey: "darkmode_preference")){
                case 0:
                    //OFF
                    self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.contentView.backgroundColor = UIColor.white
                    self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.textLabel?.backgroundColor = UIColor.white
                    self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.textLabel?.textColor = UIColor.black
                case 1:
                    //On
                    self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.contentView.backgroundColor = UIColor.black
                    self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.textLabel?.backgroundColor = UIColor.black
                    self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.textLabel?.textColor = UIColor.white
                default:
                    //Default
                    self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.contentView.backgroundColor = UIColor.white
                    self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.textLabel?.backgroundColor = UIColor.white
                    self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.textLabel?.textColor = UIColor.black
                }
            }
            self.tableView.cellForRow(at: IndexPath(row: 0, section: 0) as IndexPath)?.contentView.backgroundColor = UIColor(named: "accent")!
            self.tableView.cellForRow(at: IndexPath(row: 0, section: 0) as IndexPath)?.textLabel?.backgroundColor = UIColor(named: "accent")!
            self.tableView.cellForRow(at: IndexPath(row: 0, section: 0) as IndexPath)?.textLabel?.textColor = UIColor.white
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .middle, animated: true)
        } else {
            if (itemRow == (waypoints.count - 1)){
                let nextRow = 0
                if #available(iOS 13.0, *) {
                    self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.contentView.backgroundColor = UIColor(named: "backgrounds")!
                    self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.textLabel?.backgroundColor = UIColor(named: "backgrounds")!
                    self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.textLabel?.textColor = UIColor(named: "imageTint")!
                } else {
                    switch(UserDefaults.standard.integer(forKey: "darkmode_preference")){
                    case 0:
                        //OFF
                        self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.contentView.backgroundColor = UIColor.white
                        self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.textLabel?.backgroundColor = UIColor.white
                        self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.textLabel?.textColor = UIColor.black
                    case 1:
                        //On
                        self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.contentView.backgroundColor = UIColor.black
                        self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.textLabel?.backgroundColor = UIColor.black
                        self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.textLabel?.textColor = UIColor.white
                    default:
                        //Default
                        self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.contentView.backgroundColor = UIColor.white
                        self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.textLabel?.backgroundColor = UIColor.white
                        self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.textLabel?.textColor = UIColor.black
                    }
                }
                tableView.reloadData()
                self.tableView.cellForRow(at: IndexPath(row: nextRow, section: 0) as IndexPath)?.contentView.backgroundColor = UIColor(named: "accent")!
                self.tableView.cellForRow(at: IndexPath(row: nextRow, section: 0) as IndexPath)?.textLabel?.backgroundColor = UIColor(named: "accent")!
                self.tableView.cellForRow(at: IndexPath(row: nextRow, section: 0) as IndexPath)?.textLabel?.textColor = UIColor.white
                self.tableView.scrollToRow(at: IndexPath(row: nextRow, section: 0), at: .middle, animated: true)
                itemRow = nextRow
            } else if (itemRow < waypoints.count ){
                let nextRow = itemRow + 1
                if #available(iOS 13.0, *) {
                    self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.contentView.backgroundColor = UIColor(named: "backgrounds")!
                    self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.textLabel?.backgroundColor = UIColor(named: "backgrounds")!
                    self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.textLabel?.textColor = UIColor(named: "imageTint")!
                } else {
                    switch(UserDefaults.standard.integer(forKey: "darkmode_preference")){
                    case 0:
                        //OFF
                        self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.contentView.backgroundColor = UIColor.white
                        self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.textLabel?.backgroundColor = UIColor.white
                        self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.textLabel?.textColor = UIColor.black
                    case 1:
                        //On
                        self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.contentView.backgroundColor = UIColor.black
                        self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.textLabel?.backgroundColor = UIColor.black
                        self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.textLabel?.textColor = UIColor.white
                    default:
                        //Default
                        self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.contentView.backgroundColor = UIColor.white
                        self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.textLabel?.backgroundColor = UIColor.white
                        self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.textLabel?.textColor = UIColor.black
                    }
                }
                tableView.reloadData()
                self.tableView.cellForRow(at: IndexPath(row: nextRow, section: 0) as IndexPath)?.contentView.backgroundColor = UIColor(named: "accent")!
                self.tableView.cellForRow(at: IndexPath(row: nextRow, section: 0) as IndexPath)?.textLabel?.backgroundColor = UIColor(named: "accent")!
                self.tableView.cellForRow(at: IndexPath(row: nextRow, section: 0) as IndexPath)?.textLabel?.textColor = UIColor.white
                self.tableView.scrollToRow(at: IndexPath(row: nextRow, section: 0), at: .middle, animated: true)
                itemRow = nextRow
            }
        }
    }
    
    @objc func leftScreen() {
        _ = navigationController?.popViewController(animated: true)
        //performSegue(withIdentifier: "waypointsToTaskGrid", sender: [])
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizer.Direction.right {
            _ = navigationController?.popViewController(animated: true)
            //performSegue(withIdentifier: "waypointsToTaskGrid", sender: [])
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        switch(UserDefaults.standard.integer(forKey: "darkmode_preference")){
        case 0:
            //OFF
            if #available(iOS 13.0, *) {
                overrideUserInterfaceStyle = .light
                self.navigationController?.isNavigationBarHidden = true
                self.navigationController?.isNavigationBarHidden = false
            } else {
                Theme.default.apply()
                self.navigationController?.isNavigationBarHidden = true
                self.navigationController?.isNavigationBarHidden = false
            }
        case 1:
            //On
            if #available(iOS 13.0, *) {
                overrideUserInterfaceStyle = .dark
                self.navigationController?.isNavigationBarHidden = true
                self.navigationController?.isNavigationBarHidden = false
            } else {
                Theme.dark.apply()
                self.navigationController?.isNavigationBarHidden = true
                self.navigationController?.isNavigationBarHidden = false
            }
        default:
            //Default
            //Default
            if #available(iOS 13.0, *) {
            } else {
                Theme.default.apply()
                self.navigationController?.isNavigationBarHidden = true
                self.navigationController?.isNavigationBarHidden = false
            }
        }

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
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
        self.navigationItem.title = NSLocalizedString("waypoints_nav_title", comment: "")
        self.navigationItem.leftBarButtonItems = [backButton]
        
        if UserDefaults.standard.bool(forKey: "display_brightness_preference") {
            UIScreen.main.brightness = CGFloat(1.0)
        } else {
            UIScreen.main.brightness = CGFloat(UserDefaults.standard.float(forKey: "systemBrightness"))
        }
        
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
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return waypoints.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     
        let cell = tableView.dequeueReusableCell(withIdentifier: "WaypointsNavTableViewCell", for: indexPath)
        
        var wpt = waypoints[indexPath.row].date
        if !(waypoints[indexPath.row].label! == ""){
            wpt = waypoints[indexPath.row].label
        }
        
        cell.textLabel?.text = wpt
        // Configure the cell...
        if #available(iOS 13.0, *) {
            cell.contentView.backgroundColor = UIColor(named: "backgrounds")!
            cell.textLabel?.backgroundColor = UIColor(named: "backgrounds")!
            cell.textLabel?.textColor = UIColor(named: "imageTint")!
        } else {
            switch(UserDefaults.standard.integer(forKey: "darkmode_preference")){
            case 0:
                //OFF
                cell.contentView.backgroundColor = UIColor.white
                cell.backgroundColor = UIColor.white
                cell.textLabel?.textColor = UIColor.black
            case 1:
                //On
                cell.contentView.backgroundColor = UIColor.black
                cell.textLabel?.backgroundColor = UIColor.black
                cell.textLabel?.textColor = UIColor.white
            default:
                //Default
                cell.contentView.backgroundColor = UIColor.white
                cell.textLabel?.backgroundColor = UIColor.white
                cell.textLabel?.textColor = UIColor.black
            }
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Create a variable that you want to send based on the destination view controller
        // You can get a reference to the data by using indexPath shown below
        //waypoints[indexPath.row].id
        navigateToWaypoint(id: indexPath.row)
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

    func navigateToWaypoint(id: Int){
        let lat = waypoints[id].latitude
        let lon = waypoints[id].longitude
        let label = waypoints[id].label
        
        if let latitude = lat?.toDouble(), let longitude = lon?.toDouble(){
            
            let destLatitude: CLLocationDegrees = latitude
            let destLongitude: CLLocationDegrees = longitude
            
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
                    let urlString = "mapsme://route?sll=\(startLatitude),\(startLongitude)&saddr=\(NSLocalizedString("trip_view_waypoint_start_label", comment: ""))&dll=\(destLatitude),\(destLongitude)&daddr=\(label ?? ""))&type=vehicle&backurl=wunderlinq://"
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
            case 6:
                //OsmAnd
                // osmandmaps://?lat=45.6313&lon=34.9955&z=8&title=New+York
                let urlString = "osmandmaps://navigate?lat=\(destLatitude)&lon=\(destLongitude)&z=8&title=\(label ?? "")"
                if let mapsMeURL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                    if (UIApplication.shared.canOpenURL(mapsMeURL)) {
                        if #available(iOS 10, *) {
                            UIApplication.shared.open(mapsMeURL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                        } else {
                            UIApplication.shared.openURL(mapsMeURL as URL)
                        }
                    }
                }
            case 7:
                // Here We Go
                // https://developer.here.com/documentation/mobility-on-demand-toolkit/dev_guide/topics/navigation.html
                // here-route://mylocation/37.870090,-122.268150,Downtown%20Berkeley?ref=WunderLINQ&m=d
                let urlString = "here-route://mylocation/\(destLatitude),\(destLongitude),\(label ?? "")?ref=WunderLINQ&m=d"
                if let hereURL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                    if (UIApplication.shared.canOpenURL(hereURL)) {
                        if #available(iOS 10, *) {
                            UIApplication.shared.open(hereURL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                        } else {
                            UIApplication.shared.openURL(hereURL as URL)
                        }
                    }
                }
            case 8:
                // TomTom GO
                // https://discussions.tomtom.com/en/discussion/1118783/url-schemes-for-go-navigation-ios/
                // tomtomgo://x-callback-url/navigate?destination=52.371183,4.892504
                let urlString = "tomtomgo://x-callback-url/navigate?destination=\(destLatitude),\(destLongitude)"
                if let hereURL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                    if (UIApplication.shared.canOpenURL(hereURL)) {
                        if #available(iOS 10, *) {
                            UIApplication.shared.open(hereURL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                        } else {
                            UIApplication.shared.openURL(hereURL as URL)
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
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
