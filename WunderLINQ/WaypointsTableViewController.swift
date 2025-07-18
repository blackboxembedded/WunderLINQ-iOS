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
import os.log

class WaypointsTableViewController: UITableViewController {
    
    var db: OpaquePointer?
    var waypoints = [Waypoint]()
    var record = 0
    
    @objc func leftScreen() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @objc func addScreen() {
        performSegue(withIdentifier: "waypointsToAddWaypoint", sender: [])
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizer.Direction.right {
            leftScreen()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        let backBtn = UIButton()
        backBtn.setImage(UIImage(named: "Left")?.withRenderingMode(.alwaysTemplate), for: .normal)
        backBtn.tintColor = UIColor(named: "imageTint")
        backBtn.addTarget(self, action: #selector(leftScreen), for: .touchUpInside)
        let backButton = UIBarButtonItem(customView: backBtn)
        let backButtonWidth = backButton.customView?.widthAnchor.constraint(equalToConstant: 30)
        backButtonWidth?.isActive = true
        let backButtonHeight = backButton.customView?.heightAnchor.constraint(equalToConstant: 30)
        backButtonHeight?.isActive = true
        
        let addBtn = UIButton()
        addBtn.setImage(UIImage(named: "Plus")?.withRenderingMode(.alwaysTemplate), for: .normal)
        addBtn.tintColor = UIColor(named: "imageTint")
        addBtn.addTarget(self, action: #selector(addScreen), for: .touchUpInside)
        let addButton = UIBarButtonItem(customView: addBtn)
        let addButtonWidth = addButton.customView?.widthAnchor.constraint(equalToConstant: 30)
        addButtonWidth?.isActive = true
        let addButtonHeight = addButton.customView?.heightAnchor.constraint(equalToConstant: 30)
        addButtonHeight?.isActive = true
        
        self.navigationItem.title = NSLocalizedString("waypoint_title", comment: "")
        self.navigationItem.leftBarButtonItems = [backButton]
        self.navigationItem.rightBarButtonItems = [addButton]
        
        // Waypoint Database
        let databaseURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("waypoints.sqlite")
        // Opening the database
        if sqlite3_open(databaseURL.path, &db) != SQLITE_OK {
            NSLog("WaypointsTableViewController: error opening database")
        }
        // Creating table
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS records (id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT, latitude TEXT, longitude TEXT, elevation TEXT, label TEXT)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            NSLog("WaypointsTableViewController: error creating table: \(errmsg)")
        }
        // Update table if needed
        let updateStatementString = "ALTER TABLE records ADD COLUMN elevation TEXT"
        var updateStatement: OpaquePointer?
        if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                NSLog("WaypointsTableViewController: Table updated successfully")
            } else {
                NSLog("WaypointsTableViewController: Error updating table")
            }
        } else {
            NSLog("WaypointsTableViewController: Error preparing update statement")
        }
        
        readWaypoints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        readWaypoints()
        tableView.reloadData()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "WaypointsTableViewCell", for: indexPath)

        var wpt = waypoints[indexPath.row].date
        if !(waypoints[indexPath.row].label! == ""){
            wpt = waypoints[indexPath.row].label
        }
        
        cell.textLabel?.text = wpt
        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Create a variable that you want to send based on the destination view controller
        // You can get a reference to the data by using indexPath shown below
        record = waypoints[indexPath.row].id
        performSegue(withIdentifier: "waypointsToWaypoint", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            record = waypoints[indexPath.row].id
            let alert = UIAlertController(title: NSLocalizedString("delete_waypoint_alert_title", comment: ""), message: NSLocalizedString("delete_waypoint_alert_body", comment: ""), preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("delete_bt", comment: ""), style: UIAlertAction.Style.default, handler: { action in
                let queryString = "DELETE FROM records WHERE id = \(self.record)"
                //statement pointer
                var stmt:OpaquePointer?
                //preparing the query
                if sqlite3_prepare(self.db, queryString, -1, &stmt, nil) != SQLITE_OK{
                    let errmsg = String(cString: sqlite3_errmsg(self.db)!)
                    NSLog("WaypointsTableViewController: error preparing insert: \(errmsg)")
                    return
                }
                
                //executing the query to delete row
                if sqlite3_step(stmt) != SQLITE_DONE {
                    let errmsg = String(cString: sqlite3_errmsg(self.db)!)
                    NSLog("WaypointsTableViewController: failure inserting wapoint: \(errmsg)")
                    return
                }
                
                self.readWaypoints()
                self.tableView.reloadData()
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("cancel_bt", comment: ""), style: UIAlertAction.Style.cancel, handler: { action in
            }))
            self.present(alert, animated: true, completion: nil)
        }
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
            NSLog("WaypointsTableViewController: error preparing insert: \(errmsg)")
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "waypointsToWaypoint") {
            let vc = segue.destination as! WaypointViewController
            vc.record = record
        }
    }

}
