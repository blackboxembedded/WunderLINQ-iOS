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

class WaypointViewController: UIViewController, UITextFieldDelegate {
    
    var db: OpaquePointer?
    
    var record: Int?
    var date: String?
    var latitude: String? = ""
    var longitude: String? = ""
    var label: String?
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var longLabel: UILabel!
    @IBOutlet weak var latLabel: UILabel!
    @IBOutlet weak var labelLabel: UITextField!
    
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var openBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    
    @objc func leftScreen() {
        performSegue(withIdentifier: "waypointToWaypoints", sender: [])
    }
    
    func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizerDirection.right {
            performSegue(withIdentifier: "waypointToWaypoints", sender: [])
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
        activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook ]
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func openPressed(_ sender: Any) {
        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(latitude!.toDouble()!, longitude!.toDouble()!)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = label
        mapItem.openInMaps(launchOptions: options)
    }
    
    @IBAction func deletePressed(_ sender: Any) {
        let queryString = "DELETE FROM records WHERE id = \(record ?? 0)"
        //statement pointer
        var stmt:OpaquePointer?
        
        //preparing the query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        //executing the query to delete row
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting wapoint: \(errmsg)")
            return
        }
        
        performSegue(withIdentifier: "waypointToWaypoints", sender: [])
        
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
        
        readWaypoint()
        
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
            date = String(cString: sqlite3_column_text(stmt, 1))
            latitude = String(cString: sqlite3_column_text(stmt, 2))
            longitude = String(cString: sqlite3_column_text(stmt, 3))
            label = ""
            if ( sqlite3_column_text(stmt, 4) != nil ){
                label = String(cString: sqlite3_column_text(stmt, 4))
            }
        }
    }
}

