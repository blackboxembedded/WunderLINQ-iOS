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
import os.log

class WaypointsNavTableViewController: UITableViewController {
    
    var backButton: UIBarButtonItem!
    var faultsBtn: UIButton!
    var faultsButton: UIBarButtonItem!
    
    var db: OpaquePointer?
    var waypoints = [Waypoint]()
    var itemRow = 0

    private var highlightColor: UIColor?
    
    var firstRun = true;
    
    let motorcycleData = MotorcycleData.shared
    let faults = Faults.shared
    
    override var keyCommands: [UIKeyCommand]? {
        
        let commands = [
            UIKeyCommand(input: "\u{d}", modifierFlags:[], action: #selector(selectItem)),
            UIKeyCommand(input: UIKeyCommand.inputUpArrow, modifierFlags:[], action: #selector(upRow)),
            UIKeyCommand(input: "+", modifierFlags:[], action: #selector(upRow)),
            UIKeyCommand(input: UIKeyCommand.inputDownArrow, modifierFlags:[], action: #selector(downRow)),
            UIKeyCommand(input: "-", modifierFlags:[], action: #selector(downRow)),
            UIKeyCommand(input: UIKeyCommand.inputLeftArrow, modifierFlags:[], action: #selector(leftScreen))
        ]
        if #available(iOS 15, *) {
            commands.forEach { $0.wantsPriorityOverSystemBehavior = true }
        }
        return commands
    }
    
    @objc func selectItem() {
        SoundManager().playSoundEffect("enter")
        navigateToWaypoint(id: itemRow)
    }
    
    @objc func upRow() {
        SoundManager().playSoundEffect("directional")
        firstRun = false
        if (itemRow == 0){
            let nextRow = waypoints.count - 1
            self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.contentView.backgroundColor = UIColor(named: "backgrounds")!
            self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.textLabel?.backgroundColor = UIColor(named: "backgrounds")!
            self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.textLabel?.textColor = UIColor(named: "imageTint")!
            tableView.reloadData()
            self.tableView.cellForRow(at: IndexPath(row: nextRow, section: 0) as IndexPath)?.contentView.backgroundColor = highlightColor
            self.tableView.cellForRow(at: IndexPath(row: nextRow, section: 0) as IndexPath)?.textLabel?.backgroundColor = highlightColor
            self.tableView.cellForRow(at: IndexPath(row: nextRow, section: 0) as IndexPath)?.textLabel?.textColor = UIColor.white
            self.tableView.scrollToRow(at: IndexPath(row: nextRow, section: 0), at: .middle, animated: true)
            itemRow = nextRow
        } else if (itemRow < waypoints.count ){
            let nextRow = itemRow - 1
            self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.contentView.backgroundColor = UIColor(named: "backgrounds")!
            self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.textLabel?.backgroundColor = UIColor(named: "backgrounds")!
            self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.textLabel?.textColor = UIColor(named: "imageTint")!
            tableView.reloadData()
            self.tableView.cellForRow(at: IndexPath(row: nextRow, section: 0) as IndexPath)?.contentView.backgroundColor = highlightColor
            self.tableView.cellForRow(at: IndexPath(row: nextRow, section: 0) as IndexPath)?.textLabel?.backgroundColor = highlightColor
            self.tableView.cellForRow(at: IndexPath(row: nextRow, section: 0) as IndexPath)?.textLabel?.textColor = UIColor.white
            self.tableView.scrollToRow(at: IndexPath(row: nextRow, section: 0), at: .middle, animated: true)
            itemRow = nextRow
        }
    }
    @objc func downRow() {
        SoundManager().playSoundEffect("directional")
        if firstRun{
            firstRun = false
            self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.contentView.backgroundColor = UIColor(named: "backgrounds")!
            self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.textLabel?.backgroundColor = UIColor(named: "backgrounds")!
            self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.textLabel?.textColor = UIColor(named: "imageTint")!
            self.tableView.cellForRow(at: IndexPath(row: 0, section: 0) as IndexPath)?.contentView.backgroundColor = highlightColor
            self.tableView.cellForRow(at: IndexPath(row: 0, section: 0) as IndexPath)?.textLabel?.backgroundColor = highlightColor
            self.tableView.cellForRow(at: IndexPath(row: 0, section: 0) as IndexPath)?.textLabel?.textColor = UIColor.white
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .middle, animated: true)
        } else {
            if (itemRow == (waypoints.count - 1)){
                let nextRow = 0
                self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.contentView.backgroundColor = UIColor(named: "backgrounds")!
                self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.textLabel?.backgroundColor = UIColor(named: "backgrounds")!
                self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.textLabel?.textColor = UIColor(named: "imageTint")!
                tableView.reloadData()
                self.tableView.cellForRow(at: IndexPath(row: nextRow, section: 0) as IndexPath)?.contentView.backgroundColor = highlightColor
                self.tableView.cellForRow(at: IndexPath(row: nextRow, section: 0) as IndexPath)?.textLabel?.backgroundColor = highlightColor
                self.tableView.cellForRow(at: IndexPath(row: nextRow, section: 0) as IndexPath)?.textLabel?.textColor = UIColor.white
                self.tableView.scrollToRow(at: IndexPath(row: nextRow, section: 0), at: .middle, animated: true)
                itemRow = nextRow
            } else if (itemRow < waypoints.count ){
                let nextRow = itemRow + 1
                self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.contentView.backgroundColor = UIColor(named: "backgrounds")!
                self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.textLabel?.backgroundColor = UIColor(named: "backgrounds")!
                self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.textLabel?.textColor = UIColor(named: "imageTint")!
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
        SoundManager().playSoundEffect("directional")
        _ = navigationController?.popViewController(animated: true)
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizer.Direction.right {
            _ = navigationController?.popViewController(animated: true)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let colorData = UserDefaults.standard.data(forKey: "highlight_color_preference"){
            highlightColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData)
        } else {
            highlightColor = UIColor(named: "accent")
        }

        setNavBarColors()

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        let backBtn = UIButton()
        backBtn.setImage(UIImage(named: "Left")?.withRenderingMode(.alwaysTemplate), for: .normal)
        backBtn.tintColor = UIColor(named: "imageTint")
        backBtn.addTarget(self, action: #selector(leftScreen), for: .touchUpInside)
        backButton = UIBarButtonItem(customView: backBtn)
        let backButtonWidth = backButton.customView?.widthAnchor.constraint(equalToConstant: 30)
        backButtonWidth?.isActive = true
        let backButtonHeight = backButton.customView?.heightAnchor.constraint(equalToConstant: 30)
        backButtonHeight?.isActive = true
        faultsBtn = UIButton(type: .custom)
        let faultsImage = UIImage(named: "Alert")?.withRenderingMode(.alwaysTemplate)
        faultsBtn.setImage(faultsImage, for: .normal)
        faultsBtn.tintColor = UIColor.clear
        faultsBtn.accessibilityIgnoresInvertColors = true
        faultsBtn.addTarget(self, action: #selector(self.faultsButtonTapped), for: .touchUpInside)
        faultsButton = UIBarButtonItem(customView: faultsBtn)
        let faultsButtonWidth = faultsButton.customView?.widthAnchor.constraint(equalToConstant: 30)
        faultsButtonWidth?.isActive = true
        let faultsButtonHeight = faultsButton.customView?.heightAnchor.constraint(equalToConstant: 30)
        faultsButtonHeight?.isActive = true
        // Update Buttons
        if (faults.getallActiveDesc().isEmpty){
            faultsBtn.tintColor = UIColor.clear
            faultsButton.isEnabled = false
        } else {
            faultsBtn.tintColor = UIColor(named: "motorrad_red")
            faultsButton.isEnabled = true
        }
        self.navigationItem.title = NSLocalizedString("waypoints_nav_title", comment: "")
        self.navigationItem.leftBarButtonItems = [backButton, faultsButton]
        
        if UserDefaults.standard.bool(forKey: "display_brightness_preference") {
            UIScreen.main.brightness = CGFloat(1.0)
        } else {
            UIScreen.main.brightness = CGFloat(UserDefaults.standard.float(forKey: "systemBrightness"))
        }
        
        // Waypoint databse
        let databaseURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("waypoints.sqlite")
        // Opening the database
        if sqlite3_open(databaseURL.path, &db) != SQLITE_OK {
            os_log("WaypointsNavTableViewController: error opening database")
        }
        // Creating table
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS records (id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT, latitude TEXT, longitude TEXT, elevation TEXT, label TEXT)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            os_log("WaypointsNavTableViewController: error creating table: \(errmsg)")
        }
        // Update table if needed
        let updateStatementString = "ALTER TABLE records ADD COLUMN elevation TEXT"
        var updateStatement: OpaquePointer?
        if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                os_log("WaypointsNavTableViewController: Table updated successfully")
            } else {
                os_log("WaypointsNavTableViewController: Error updating table")
            }
        } else {
            os_log("WaypointsNavTableViewController: Error preparing update statement")
        }

        
        readWaypoints()
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
        cell.contentView.backgroundColor = UIColor(named: "backgrounds")!
        cell.textLabel?.backgroundColor = UIColor(named: "backgrounds")!
        cell.textLabel?.textColor = UIColor(named: "imageTint")!

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
        let queryString = "SELECT id, date, latitude, longitude, elevation, label FROM records ORDER BY id DESC"
        
        //statement pointer
        var stmt:OpaquePointer?
        
        //preparing the query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            os_log("WaypointsNavTableViewController: error preparing insert: \(errmsg)")
            return
        }
        
        //traversing through all the records
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let id = sqlite3_column_int(stmt, 0)
            let date = String(cString: sqlite3_column_text(stmt, 1))
            let latitude = String(cString: sqlite3_column_text(stmt, 2))
            let longitude = String(cString: sqlite3_column_text(stmt, 3))
            var elevation = ""
            if ( sqlite3_column_text(stmt, 4) != nil ){
                elevation = String(cString: sqlite3_column_text(stmt, 4))
            }
            var label = ""
            if ( sqlite3_column_text(stmt, 5) != nil ){
                label = String(cString: sqlite3_column_text(stmt, 5))
            }
            //adding values to list
            waypoints.append(Waypoint(id: Int(id), date: String(describing: date), latitude: String(describing: latitude), longitude: String(describing: longitude), elevation: String(describing: elevation), label: String(describing: label)))
        }
    }

    func navigateToWaypoint(id: Int){
        let latitude = waypoints[id].latitude
        let longitude = waypoints[id].longitude
        let label = waypoints[id].label
        if let lat = latitude?.toDouble(), let lon = longitude?.toDouble() {
            if let currentLocation = motorcycleData.getLocation() {
                if (!NavAppHelper.navigateTo(destLatitude: lat, destLongitude: lon, destLabel: label, currentLatitude: currentLocation.coordinate.latitude, currentLongitude: currentLocation.coordinate.longitude)){
                    self.showToast(message: NSLocalizedString("nav_app_feature_not_supported", comment: ""))
                }
            }
        }
    }
    
    @objc func faultsButtonTapped() {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "FaultsTableViewController") as! FaultsTableViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func setNavBarColors(){
        switch(UserDefaults.standard.integer(forKey: "darkmode_preference")){
        case 0:
            //OFF
            // Create a custom appearance for the navigation bar
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground() // or configureWithTransparentBackground() if you prefer transparency
            appearance.backgroundColor = UIColor.white // Set your desired background color
            
            // Customize the title text attributes (optional)
            appearance.titleTextAttributes = [.foregroundColor: UIColor.black] // Set text color
            
            // Apply the appearance to the navigation bar
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        case 1:
            //On
            // Create a custom appearance for the navigation bar
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground() // or configureWithTransparentBackground() if you prefer transparency
            appearance.backgroundColor = UIColor.black // Set your desired background color
            
            // Customize the title text attributes (optional)
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white] // Set text color
            
            // Apply the appearance to the navigation bar
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        default:
            //Default
            break
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
