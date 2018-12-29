//
//  TasksCollectionViewController.swift
//  WunderLINQ
//
//  Created by Keith Conger on 12/5/18.
//  Copyright © 2018 Black Box Embedded, LLC. All rights reserved.
//

import CoreLocation
import UIKit
import MapKit
import CoreLocation
import AVFoundation
import SQLite3
import Photos

private let reuseIdentifier = "Cell"

class TasksCollectionViewController: UICollectionViewController, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureFileOutputRecordingDelegate {
    
    @IBOutlet weak var taskImage: UIImageView!
    @IBOutlet weak var taskLabel: UILabel!
    
    var tasks = [Tasks]()
    
    var mapping = [Int]()
    
    @IBOutlet weak var cameraImageView: UIImageView!
    
    var device: AVCaptureDevice?
    var captureSession: AVCaptureSession?
    var cameraImage: UIImage?
    
    let videoCaptureSession = AVCaptureSession()
    let movieOutput = AVCaptureMovieFileOutput()
    var activeInput: AVCaptureDeviceInput!
    var outputURL: URL!
    
    var db: OpaquePointer?
    var waypoints = [Waypoint]()
    
    var itemRow = 0
    
    let scenic = ScenicAPI()
    
    private func loadRows() {
        let taskRow1 = UserDefaults.standard.integer(forKey: "task_one_preference")
        if (taskRow1 < 10){
            mapping.append(taskRow1)
        }
        let taskRow2 = UserDefaults.standard.integer(forKey: "task_two_preference")
        if (taskRow2 < 10){
            mapping.append(taskRow2)
        }
        let taskRow3 = UserDefaults.standard.integer(forKey: "task_three_preference")
        if (taskRow3 < 10){
            mapping.append(taskRow3)
        }
        let taskRow4 = UserDefaults.standard.integer(forKey: "task_four_preference")
        if (taskRow4 < 10){
            mapping.append(taskRow4)
        }
        let taskRow5 = UserDefaults.standard.integer(forKey: "task_five_preference")
        if (taskRow5 < 10){
            mapping.append(taskRow5)
        }
        let taskRow6 = UserDefaults.standard.integer(forKey: "task_six_preference")
        if (taskRow6 < 10){
            mapping.append(taskRow6)
        }
        let taskRow7 = UserDefaults.standard.integer(forKey: "task_seven_preference")
        if (taskRow7 < 10){
            mapping.append(taskRow7)
        }
        let taskRow8 = UserDefaults.standard.integer(forKey: "task_eight_preference")
        if (taskRow8 < 10){
            mapping.append(taskRow8)
        }
        let taskRow9 = UserDefaults.standard.integer(forKey: "task_nine_preference")
        if (taskRow9 < 10){
            mapping.append(taskRow9)
        }
        let taskRow10 = UserDefaults.standard.integer(forKey: "task_ten_preference")
        if (taskRow10 < 10){
            mapping.append(taskRow10)
        }
    }
    private func loadTasks() {
        // Navigate Task
        guard let task0 = Tasks(label: NSLocalizedString("task_title_navigation", comment: ""), icon: UIImage(named: "Map")?.withRenderingMode(.alwaysTemplate)) else {
            fatalError("Unable to instantiate Navigate Task")
        }
        // Go Home Task
        guard let task1 = Tasks(label: NSLocalizedString("task_title_gohome", comment: ""), icon: UIImage(named: "Home")?.withRenderingMode(.alwaysTemplate)) else {
            fatalError("Unable to instantiate Go Home Task")
        }
        // Call Home Task
        guard let task2 = Tasks(label: NSLocalizedString("task_title_favnumber", comment: ""), icon: UIImage(named: "Phone")?.withRenderingMode(.alwaysTemplate)) else {
            fatalError("Unable to instantiate Call Home Task")
        }
        // Call Contact Task
        guard let task3 = Tasks(label: NSLocalizedString("task_title_callcontact", comment: ""), icon: UIImage(named: "Contacts")?.withRenderingMode(.alwaysTemplate)) else {
            fatalError("Unable to instantiate Call Contact Task")
        }
        // Take Photo Task
        guard let task4 = Tasks(label: NSLocalizedString("task_title_photo", comment: ""), icon: UIImage(named: "Camera")?.withRenderingMode(.alwaysTemplate)) else {
            fatalError("Unable to instantiate Take Photo Task")
        }
        // Take Selfie Task
        guard let task5 = Tasks(label: NSLocalizedString("task_title_selfie", comment: ""), icon: UIImage(named: "Camera")?.withRenderingMode(.alwaysTemplate)) else {
            fatalError("Unable to instantiate Take Photo Task")
        }
        // Video Recording Task
        guard let task6 = Tasks(label: NSLocalizedString("task_title_start_record", comment: ""), icon: UIImage(named: "VideoCamera")?.withRenderingMode(.alwaysTemplate)) else {
            fatalError("Unable to instantiate Video Recording Task")
        }
        // Trip Log Task
        var tripLogLabel = NSLocalizedString("task_title_start_trip", comment: "")
        if LocationService.sharedInstance.isRunning(){
            tripLogLabel = NSLocalizedString("task_title_stop_trip", comment: "")
        }
        guard let task7 = Tasks(label: tripLogLabel, icon: UIImage(named: "Road")?.withRenderingMode(.alwaysTemplate)) else {
            fatalError("Unable to instantiate Trip Log Task")
        }
        // Save Waypoint Task
        guard let task8 = Tasks(label: NSLocalizedString("task_title_waypoint", comment: ""), icon: UIImage(named: "MapMarker")?.withRenderingMode(.alwaysTemplate)) else {
            fatalError("Unable to instantiate Save Waypoint Task")
        }
        // Navigate to Waypoint Task
        guard let task9 = Tasks(label: NSLocalizedString("task_title_waypoint_nav", comment: ""), icon: UIImage(named: "Route")?.withRenderingMode(.alwaysTemplate)) else {
            fatalError("Unable to instantiate Navigate to Waypoint Task")
        }
        tasks += [task0, task1, task2, task3, task4, task5, task6, task7, task8, task9]
    }
    
    private func execute_task(taskID:Int) {
        print("Execute Task ID: \(taskID)")
        switch taskID {
        case 0:
            //Navigation
            let navApp = UserDefaults.standard.integer(forKey: "nav_app_preference")
            switch (navApp){
            case 0:
                //Apple Maps
                let map = MKMapItem()
                map.openInMaps(launchOptions: nil)
            case 1:
                //Google Maps
                //https://developers.google.com/maps/documentation/urls/ios-urlscheme
                if let googleMapsURL = URL(string: "comgooglemaps-x-callback://?x-success=wunderlinq://&x-source=WunderLINQ") {
                    if (UIApplication.shared.canOpenURL(googleMapsURL)) {
                        if #available(iOS 10, *) {
                            UIApplication.shared.open(googleMapsURL, options: [:], completionHandler: nil)
                        } else {
                            UIApplication.shared.openURL(googleMapsURL as URL)
                        }
                    }
                }
            case 2:
                //Scenic
                //https://github.com/guidove/Scenic-Integration/blob/master/README.md
                self.scenic.sendToScenicForNavigation(coordinate: CLLocationCoordinate2D(latitude: 0,longitude: 0), name: "WunderLINQ")
            case 3:
                //Sygic
                //https://www.sygic.com/developers/professional-navigation-sdk/ios/custom-url
                let urlString = "com.sygic.aura://"
                
                if let sygicURL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                    if (UIApplication.shared.canOpenURL(sygicURL)) {
                        if #available(iOS 10, *) {
                            UIApplication.shared.open(sygicURL, options: [:], completionHandler: nil)
                        } else {
                            UIApplication.shared.openURL(sygicURL as URL)
                        }
                    }
                }
            case 4:
                //Waze
                if let wazeURL = URL(string: "waze://") {
                    if (UIApplication.shared.canOpenURL(wazeURL)) {
                        if #available(iOS 10, *) {
                            UIApplication.shared.open(wazeURL, options: [:], completionHandler: nil)
                        } else {
                            UIApplication.shared.openURL(wazeURL as URL)
                        }
                    }
                }
            default:
                //Apple Maps
                let map = MKMapItem()
                map.openInMaps(launchOptions: nil)
            }
            break
        case 1:
            //Go Home
            if let homeAddress = UserDefaults.standard.string(forKey: "gohome_address_preference"){
                if homeAddress != "" {
                    let navApp = UserDefaults.standard.integer(forKey: "nav_app_preference")
                    switch (navApp){
                    case 0:
                        //Apple Maps
                        let geocoder = CLGeocoder()
                        geocoder.geocodeAddressString(homeAddress,
                                                      completionHandler: { (placemarks, error) in
                                                        if error == nil {
                                                            let placemark = placemarks?.first
                                                            let lat = placemark?.location?.coordinate.latitude
                                                            let lon = placemark?.location?.coordinate.longitude
                                                            let destLatitude: CLLocationDegrees = lat!
                                                            let destLongitude: CLLocationDegrees = lon!
                                                            
                                                            let coordinates = CLLocationCoordinate2DMake(destLatitude, destLongitude)
                                                            let navPlacemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
                                                            let mapitem = MKMapItem(placemark: navPlacemark)
                                                            let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
                                                            mapitem.openInMaps(launchOptions: options)
                                                        }
                                                        else {
                                                            // An error occurred during geocoding.
                                                            self.showToast(message: NSLocalizedString("geocode_error", comment: ""))
                                                        }
                        })
                    case 1:
                        //Google Maps
                        //https://developers.google.com/maps/documentation/urls/ios-urlscheme
                        let homeAddressFixed = homeAddress.replacingOccurrences(of: " ", with: "+")
                        if let googleMapsURL = URL(string: "comgooglemaps-x-callback://?daddr=\(homeAddressFixed)&directionsmode=driving&x-success=wunderlinq://?resume=true&x-source=WunderLINQ") {
                            print("google map selected url")
                            if (UIApplication.shared.canOpenURL(googleMapsURL)) {
                                if #available(iOS 10, *) {
                                    UIApplication.shared.open(googleMapsURL, options: [:], completionHandler: nil)
                                } else {
                                    UIApplication.shared.openURL(googleMapsURL as URL)
                                }
                            }
                        }
                    case 2:
                        //Scenic
                        //https://github.com/guidove/Scenic-Integration/blob/master/README.md
                        let geocoder = CLGeocoder()
                        geocoder.geocodeAddressString(homeAddress,
                                                      completionHandler: { (placemarks, error) in
                                                        if error == nil {
                                                            let placemark = placemarks?.first
                                                            let lat = placemark?.location?.coordinate.latitude
                                                            let lon = placemark?.location?.coordinate.longitude
                                                            let destLatitude: CLLocationDegrees = lat!
                                                            let destLongitude: CLLocationDegrees = lon!
                                                            
                                                            self.scenic.sendToScenicForNavigation(coordinate: CLLocationCoordinate2D(latitude: destLatitude,longitude: destLongitude), name: NSLocalizedString("home", comment: ""))
                                                        }
                                                        else {
                                                            // An error occurred during geocoding.
                                                            self.showToast(message: NSLocalizedString("geocode_error", comment: ""))
                                                        }
                        })
                    case 3:
                        //Sygic
                        //https://www.sygic.com/developers/professional-navigation-sdk/ios/custom-url
                        let geocoder = CLGeocoder()
                        geocoder.geocodeAddressString(homeAddress,
                                                      completionHandler: { (placemarks, error) in
                                                        if error == nil {
                                                            let placemark = placemarks?.first
                                                            let lat = placemark?.location?.coordinate.latitude
                                                            let lon = placemark?.location?.coordinate.longitude
                                                            let destLatitude: CLLocationDegrees = lat!
                                                            let destLongitude: CLLocationDegrees = lon!
                                                            
                                                            let urlString = "com.sygic.aura://coordinate|\(destLongitude)|\(destLatitude)|drive"
                                                            
                                                            if let sygicURL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                                                                if (UIApplication.shared.canOpenURL(sygicURL)) {
                                                                    if #available(iOS 10, *) {
                                                                        UIApplication.shared.open(sygicURL, options: [:], completionHandler: nil)
                                                                    } else {
                                                                        UIApplication.shared.openURL(sygicURL as URL)
                                                                    }
                                                                }
                                                            }
                                                        }
                                                        else {
                                                            // An error occurred during geocoding.
                                                            self.showToast(message: NSLocalizedString("geocode_error", comment: ""))
                                                        }
                        })
                    case 4:
                        //Waze
                        // https://developers.google.com/waze/deeplinks/
                        let homeAddressFixed = homeAddress.replacingOccurrences(of: " ", with: "+")
                        if let wazeURL = URL(string: "https://waze.com/ul?q=\(homeAddressFixed)&navigate=yes") {
                            if (UIApplication.shared.canOpenURL(wazeURL)) {
                                if #available(iOS 10, *) {
                                    UIApplication.shared.open(wazeURL, options: [:], completionHandler: nil)
                                } else {
                                    UIApplication.shared.openURL(wazeURL as URL)
                                }
                            }
                        }
                    default:
                        //Apple Maps
                        let geocoder = CLGeocoder()
                        geocoder.geocodeAddressString(homeAddress,
                                                      completionHandler: { (placemarks, error) in
                                                        if error == nil {
                                                            let placemark = placemarks?.first
                                                            let lat = placemark?.location?.coordinate.latitude
                                                            let lon = placemark?.location?.coordinate.longitude
                                                            let destLatitude: CLLocationDegrees = lat!
                                                            let destLongitude: CLLocationDegrees = lon!
                                                            
                                                            let coordinates = CLLocationCoordinate2DMake(destLatitude, destLongitude)
                                                            let navPlacemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
                                                            let mapitem = MKMapItem(placemark: navPlacemark)
                                                            let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
                                                            mapitem.openInMaps(launchOptions: options)
                                                        }
                                                        else {
                                                            // An error occurred during geocoding.
                                                            self.showToast(message: NSLocalizedString("geocode_error", comment: ""))
                                                        }
                        })
                    }
                } else {
                    self.showToast(message: NSLocalizedString("toast_address_not_set", comment: ""))
                }
            } else {
                self.showToast(message: NSLocalizedString("toast_address_not_set", comment: ""))
            }
            break
        case 2:
            //Favorite Number
            if let phoneNumber = UserDefaults.standard.string(forKey: "callhome_number_preference"){
                if phoneNumber != "" {
                    if let phoneCallURL = URL(string: "telprompt:\(phoneNumber)") {
                        if (UIApplication.shared.canOpenURL(phoneCallURL)) {
                            if #available(iOS 10, *) {
                                UIApplication.shared.open(phoneCallURL, options: [:], completionHandler: nil)
                            } else {
                                UIApplication.shared.openURL(phoneCallURL as URL)
                            }
                        }
                    }
                } else {
                    self.showToast(message: NSLocalizedString("toast_phone_not_set", comment: ""))
                }
            } else {
                self.showToast(message: NSLocalizedString("toast_phone_not_set", comment: ""))
            }
            break
        case 3:
            //Call Contact
            performSegue(withIdentifier: "taskGridToContacts", sender: self)
            break
        case 4:
            //Take Photo
            setupCamera(position: .back)
            setupTimer()
            break
        case 5:
            //Take Photo
            setupCamera(position: .front)
            setupTimer()
            break
        case 6:
            //Video Recording
            if movieOutput.isRecording == true {
                movieOutput.stopRecording()
                var currentMapping = 0
                for task in mapping {
                    if task == 6{
                        (self.collectionView?.cellForItem(at: IndexPath(row: currentMapping, section: 0) as IndexPath) as! TaskCollectionViewCell).taskLabel.text = NSLocalizedString("task_title_start_record", comment: "")
                    }
                    currentMapping = currentMapping + 1
                }
            } else {
                if setupSession() {
                    startSession()
                }
                if (self.videoCaptureSession.isRunning) {
                    startCapture()
                    var currentMapping = 0
                    for task in mapping {
                        if task == 6{
                            (self.collectionView?.cellForItem(at: IndexPath(row: currentMapping, section: 0) as IndexPath) as! TaskCollectionViewCell).taskLabel.text = NSLocalizedString("task_title_stop_record", comment: "")
                        }
                        currentMapping = currentMapping + 1
                    }
                }
            }
            
            break
        case 7:
            //Trip Log
            if LocationService.sharedInstance.isRunning(){
                LocationService.sharedInstance.stopUpdatingLocation()
                var currentMapping = 0
                for task in mapping {
                    if task == 7{
                        (self.collectionView?.cellForItem(at: IndexPath(row: currentMapping, section: 0) as IndexPath) as! TaskCollectionViewCell).taskLabel.text = NSLocalizedString("task_title_start_trip", comment: "")
                    }
                    currentMapping = currentMapping + 1
                }
            } else {
                LocationService.sharedInstance.startUpdatingLocation(type: "triplog")
                var currentMapping = 0
                for task in mapping {
                    if task == 7{
                        (self.collectionView?.cellForItem(at: IndexPath(row: currentMapping, section: 0) as IndexPath) as! TaskCollectionViewCell).taskLabel.text = NSLocalizedString("task_title_stop_trip", comment: "")
                    }
                    currentMapping = currentMapping + 1
                }
            }
            break
        case 8:
            //Save Waypoint
            if LocationService.sharedInstance.isRunning(){
                LocationService.sharedInstance.saveWaypoint()
            } else {
                LocationService.sharedInstance.startUpdatingLocation(type: "waypoint")
            }
            self.showToast(message: NSLocalizedString("toast_waypoint_saved", comment: ""))
            break
        case 9:
            //Navigate to Waypoint
            //Call Contact
            performSegue(withIdentifier: "taskGridToWaypoints", sender: self)
            break
        default:
            print("Unknown Task")
        }
    }
    
    // MARK: - Handling User Interaction
    
    override var keyCommands: [UIKeyCommand]? {
        let commands = [
            UIKeyCommand(input: "\u{d}", modifierFlags:[], action: #selector(selectItem), discoverabilityTitle: "Select item"),
            UIKeyCommand(input: UIKeyInputUpArrow, modifierFlags:[], action: #selector(upRow), discoverabilityTitle: "Go up"),
            UIKeyCommand(input: UIKeyInputDownArrow, modifierFlags:[], action: #selector(downRow), discoverabilityTitle: "Go down"),
            UIKeyCommand(input: UIKeyInputLeftArrow, modifierFlags:[], action: #selector(leftScreen), discoverabilityTitle: "Go left"),
            UIKeyCommand(input: UIKeyInputRightArrow, modifierFlags:[], action: #selector(rightScreen), discoverabilityTitle: "Go right")
        ]
        return commands
    }
    
    @objc func selectItem() {
        execute_task(taskID: itemRow)
    }
    
    @objc func upRow() {
        if (itemRow == 0){
            let nextRow = mapping.count - 1
            itemRow = nextRow
        } else if (itemRow < mapping.count ){
            let nextRow = itemRow - 1
            itemRow = nextRow
        }
        let indexPath = IndexPath(row: itemRow, section: 0)
        self.collectionView!.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
        self.collectionView!.reloadData()
    }
    
    @objc func downRow() {
        if (itemRow == (mapping.count - 1)){
            let nextRow = 0
            itemRow = nextRow
        } else if (itemRow < mapping.count ){
            let nextRow = itemRow + 1
            itemRow = nextRow
        }
        let indexPath = IndexPath(row: itemRow, section: 0)
        self.collectionView!.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
        self.collectionView!.reloadData()
    }
    
    @objc func leftScreen() {
        performSegue(withIdentifier: "taskGridToCompass", sender: [])
        
    }
    
    @objc func rightScreen() {
        performSegue(withIdentifier: "taskGridTomotorcycle", sender: [])
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func forward(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "unwindToContainerVC", sender: self)
    }
    
    func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizerDirection.right {
            performSegue(withIdentifier: "taskGridToCompass", sender: [])
        }
        else if gesture.direction == UISwipeGestureRecognizerDirection.left {
            performSegue(withIdentifier: "taskGridTomotorcycle", sender: [])
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        if UserDefaults.standard.bool(forKey: "nightmode_preference") {
            Theme.dark.apply()
            self.navigationController?.isNavigationBarHidden = true
            self.navigationController?.isNavigationBarHidden = false
        } else {
            Theme.default.apply()
            self.navigationController?.isNavigationBarHidden = true
            self.navigationController?.isNavigationBarHidden = false
        }
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
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
        
        let forwardBtn = UIButton()
        forwardBtn.setImage(UIImage(named: "Right")?.withRenderingMode(.alwaysTemplate), for: .normal)
        forwardBtn.addTarget(self, action: #selector(rightScreen), for: .touchUpInside)
        let forwardButton = UIBarButtonItem(customView: forwardBtn)
        let forwardButtonWidth = forwardButton.customView?.widthAnchor.constraint(equalToConstant: 30)
        forwardButtonWidth?.isActive = true
        let forwardButtonHeight = forwardButton.customView?.heightAnchor.constraint(equalToConstant: 30)
        forwardButtonHeight?.isActive = true
        self.navigationItem.title = NSLocalizedString("quicktask_title", comment: "")
        self.navigationItem.leftBarButtonItems = [backButton]
        self.navigationItem.rightBarButtonItems = [forwardButton]
        
        if UserDefaults.standard.bool(forKey: "display_brightness_preference") {
            UIScreen.main.brightness = CGFloat(1.0)
        } else {
            UIScreen.main.brightness = CGFloat(UserDefaults.standard.float(forKey: "systemBrightness"))
        }
        
        loadTasks();
        loadRows();
        
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
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return mapping.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TaskCollectionViewCell", for: indexPath) as! TaskCollectionViewCell
    
        // Configure the cell
        let tasks = self.tasks[mapping[indexPath.row]]
        
        cell.displayContent(icon: tasks.icon!, label: tasks.label)
        
        if (itemRow == indexPath.row){
            cell.highlightEffect()
        } else {
            if UserDefaults.standard.bool(forKey: "nightmode_preference") {
                cell.removeHighlight(color: UIColor.black)
            } else {
                cell.removeHighlight(color: UIColor.white)
            }
        }
        
        if UserDefaults.standard.bool(forKey: "nightmode_preference") {
            cell.taskImage.tintColor = UIColor.white
        } else {
            cell.taskImage.tintColor = UIColor.black
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Row Selected: \(indexPath.row)")
        execute_task(taskID: mapping[indexPath.row])
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
    func setupCamera(position: AVCaptureDevicePosition) {
        // tweak delay
        let discoverySession = AVCaptureDeviceDiscoverySession(deviceTypes: [.builtInWideAngleCamera],
                                                               mediaType: AVMediaTypeVideo,
                                                               position: position)
        device = discoverySession?.devices[0]
        
        let input: AVCaptureDeviceInput
        do {
            input = try AVCaptureDeviceInput(device: device)
        } catch {
            return
        }
        
        let output = AVCaptureVideoDataOutput()
        output.alwaysDiscardsLateVideoFrames = true
        
        let queue = DispatchQueue(label: "cameraQueue")
        output.setSampleBufferDelegate(self, queue: queue)
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable: kCVPixelFormatType_32BGRA]
        
        captureSession = AVCaptureSession()
        captureSession?.addInput(input)
        captureSession?.addOutput(output)
        captureSession?.sessionPreset = AVCaptureSessionPresetPhoto
        
        let connection = output.connection(withMediaType: AVFoundation.AVMediaTypeVideo)
        connection?.videoOrientation = AVCaptureVideoOrientation(rawValue: UIDevice.current.orientation.rawValue)!
        
        captureSession?.startRunning()
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        CVPixelBufferLockBaseAddress(imageBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let baseAddress = UnsafeMutableRawPointer(CVPixelBufferGetBaseAddress(imageBuffer!))
        let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer!)
        let width = CVPixelBufferGetWidth(imageBuffer!)
        let height = CVPixelBufferGetHeight(imageBuffer!)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let newContext = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo:
            CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue)
        // update the video orientation to the device one
        //newContext.videoOrientation = AVCaptureVideoOrientation(rawValue: UIDevice.currentDevice().orientation.rawValue)!
        
        let newImage = newContext!.makeImage()
        cameraImage = UIImage(cgImage: newImage!)
        
        CVPixelBufferUnlockBaseAddress(imageBuffer!, CVPixelBufferLockFlags(rawValue: 0))
    }
    
    func setupTimer() {
        _ = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(snapshot), userInfo: nil, repeats: false)
    }
    
    func snapshot() {
        if ( cameraImage == nil ){
            print("No Image")
        } else {
            UIImageWriteToSavedPhotosAlbum(cameraImage!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
        captureSession?.stopRunning()
    }
    
    //MARK: - Add image to Library
    func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if error != nil {
            // we got back an error!
            // the alert view
            print("Picture Save Error")
        } else {
            self.showToast(message: NSLocalizedString("toast_photo_taken", comment: ""))
        }
    }
    
    //MARK:- Setup Camera
    
    func setupSession() -> Bool {
        
        videoCaptureSession.sessionPreset = AVCaptureSessionPresetHigh
        
        // Setup Camera
        let camera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if videoCaptureSession.canAddInput(input) {
                videoCaptureSession.addInput(input)
                activeInput = input
            }
        } catch {
            print("Error setting device video input: \(error)")
            return false
        }
        
        // Setup Microphone
        let microphone = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
        
        do {
            let micInput = try AVCaptureDeviceInput(device: microphone)
            if videoCaptureSession.canAddInput(micInput) {
                videoCaptureSession.addInput(micInput)
            }
        } catch {
            print("Error setting device audio input: \(error)")
            return false
        }
        
        // Movie output
        if videoCaptureSession.canAddOutput(movieOutput) {
            videoCaptureSession.addOutput(movieOutput)
        }
        return true
    }
    
    func setupCaptureMode(_ mode: Int) {
        // Video Mode
    }
    
    //MARK:- Camera Session
    func startSession() {
        if !videoCaptureSession.isRunning {
            videoQueue().async {
                self.videoCaptureSession.startRunning()
            }
        }
    }
    
    func stopSession() {
        if videoCaptureSession.isRunning {
            videoQueue().async {
                self.videoCaptureSession.stopRunning()
            }
        }
    }
    
    func videoQueue() -> DispatchQueue {
        return DispatchQueue.main
    }
    
    func currentVideoOrientation() -> AVCaptureVideoOrientation {
        var orientation: AVCaptureVideoOrientation
        
        switch UIDevice.current.orientation {
        case .portrait:
            orientation = AVCaptureVideoOrientation.portrait
        case .landscapeRight:
            orientation = AVCaptureVideoOrientation.landscapeLeft
        case .portraitUpsideDown:
            orientation = AVCaptureVideoOrientation.portraitUpsideDown
        default:
            orientation = AVCaptureVideoOrientation.landscapeRight
        }
        
        return orientation
    }
    
    func startCapture() {
        startRecording()
    }
    
    func tempURL() -> URL? {
        let directory = NSTemporaryDirectory() as NSString
        
        if directory != "" {
            let path = directory.appendingPathComponent(NSUUID().uuidString + ".mp4")
            return URL(fileURLWithPath: path)
        }
        return nil
    }
    
    func startRecording() {
        if movieOutput.isRecording == false {
            let connection = movieOutput.connection(withMediaType: AVMediaTypeVideo)
            if (connection?.isVideoOrientationSupported)! {
                connection?.videoOrientation = currentVideoOrientation()
            }
            
            if (connection?.isVideoStabilizationSupported)! {
                connection?.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
            }
            
            let device = activeInput.device
            if (device?.isSmoothAutoFocusSupported)! {
                do {
                    try device?.lockForConfiguration()
                    device?.isSmoothAutoFocusEnabled = false
                    device?.unlockForConfiguration()
                } catch {
                    print("Error setting configuration: \(error)")
                }
                
            }
            
            outputURL = tempURL()
            movieOutput.startRecording(toOutputFileURL: outputURL, recordingDelegate: self)
            
        }
        else {
            stopRecording()
        }
        
    }
    
    func stopRecording() {
        if movieOutput.isRecording == true {
            movieOutput.stopRecording()
        }
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
        
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        if (error != nil) {
            print("Error recording movie: \(error!.localizedDescription)")
        } else {
            let fileURL = outputURL as URL
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: fileURL as URL)
            }) { saved, error in
                if saved {
                    // the alert view
                    let alert = UIAlertController(title: "", message: "Video Saved", preferredStyle: .alert)
                    self.present(alert, animated: true, completion: nil)
                    
                    // change to desired number of seconds (in this case 2 seconds)
                    let when = DispatchTime.now() + 3
                    DispatchQueue.main.asyncAfter(deadline: when){
                        // your code with delay
                        alert.dismiss(animated: true, completion: nil)
                    }
                } else {
                    print("In capture didfinish, didn't save")
                }
            }
            
        }
        outputURL = nil
    }

}
