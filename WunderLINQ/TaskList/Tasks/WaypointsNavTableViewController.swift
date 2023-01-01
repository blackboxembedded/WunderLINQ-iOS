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

class WaypointsNavTableViewController: UITableViewController {
    
    var db: OpaquePointer?
    var waypoints = [Waypoint]()
    var itemRow = 0
    
    private var locationManager: CLLocationManager!
    private var currentLocation: CLLocation?
    private var highlightColor: UIColor?
    
    var firstRun = true;
    
    override var keyCommands: [UIKeyCommand]? {
        
        let commands = [
            UIKeyCommand(input: "\u{d}", modifierFlags:[], action: #selector(selectItem), discoverabilityTitle: "Select item"),
            UIKeyCommand(input: UIKeyCommand.inputUpArrow, modifierFlags:[], action: #selector(upRow), discoverabilityTitle: "Go up"),
            UIKeyCommand(input: UIKeyCommand.inputDownArrow, modifierFlags:[], action: #selector(downRow), discoverabilityTitle: "Go down"),
            UIKeyCommand(input: UIKeyCommand.inputLeftArrow, modifierFlags:[], action: #selector(leftScreen), discoverabilityTitle: "Go left")
        ]
        if #available(iOS 15, *) {
            commands.forEach { $0.wantsPriorityOverSystemBehavior = true }
        }
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
            self.tableView.cellForRow(at: IndexPath(row: nextRow, section: 0) as IndexPath)?.contentView.backgroundColor = highlightColor
            self.tableView.cellForRow(at: IndexPath(row: nextRow, section: 0) as IndexPath)?.textLabel?.backgroundColor = highlightColor
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
            self.tableView.cellForRow(at: IndexPath(row: nextRow, section: 0) as IndexPath)?.contentView.backgroundColor = highlightColor
            self.tableView.cellForRow(at: IndexPath(row: nextRow, section: 0) as IndexPath)?.textLabel?.backgroundColor = highlightColor
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
            self.tableView.cellForRow(at: IndexPath(row: 0, section: 0) as IndexPath)?.contentView.backgroundColor = highlightColor
            self.tableView.cellForRow(at: IndexPath(row: 0, section: 0) as IndexPath)?.textLabel?.backgroundColor = highlightColor
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
                self.tableView.cellForRow(at: IndexPath(row: nextRow, section: 0) as IndexPath)?.contentView.backgroundColor = highlightColor
                self.tableView.cellForRow(at: IndexPath(row: nextRow, section: 0) as IndexPath)?.textLabel?.backgroundColor = highlightColor
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
                self.tableView.cellForRow(at: IndexPath(row: nextRow, section: 0) as IndexPath)?.contentView.backgroundColor = highlightColor
                self.tableView.cellForRow(at: IndexPath(row: nextRow, section: 0) as IndexPath)?.textLabel?.backgroundColor = highlightColor
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
        
        if let colorData = UserDefaults.standard.data(forKey: "highlight_color_preference"){
            highlightColor = NSKeyedUnarchiver.unarchiveObject(with: colorData) as? UIColor
        } else {
            highlightColor = UIColor(named: "accent")
        }

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
        let latitude = waypoints[id].latitude
        let longitude = waypoints[id].longitude
        let label = waypoints[id].label
        if let lat = latitude?.toDouble(), let lon = longitude?.toDouble(), let current = currentLocation {
            NavAppHelper.navigateTo(destLatitude: lat, destLongitude: lon, destLabel: label, currentLatitude: current.coordinate.latitude, currentLongitude: current.coordinate.longitude)
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}

extension WaypointsNavTableViewController: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            print("Location permission denied")
            self.showToast(message: NSLocalizedString("negative_location_alert_body", comment: ""))
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        @unknown default:
            print("Fatal Error")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        do { currentLocation = locations.last }
    }
}
