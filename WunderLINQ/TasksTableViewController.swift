//
//  TasksTableViewController.swift
//  WunderLINQ
//
//  Created by Keith Conger on 8/16/17.
//  Copyright © 2017 Keith Conger. All rights reserved.
//

import CoreLocation
import UIKit
import MapKit
import CoreLocation
import AVFoundation
import SQLite3
import Photos

class TasksTableViewController: UITableViewController, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureFileOutputRecordingDelegate, CLLocationManagerDelegate {
    
    
    //MARK: Properties
    
    var tasks = [Tasks]()
    
    @IBOutlet weak var cameraImageView: UIImageView!
    
    var device: AVCaptureDevice?
    var captureSession: AVCaptureSession?
    var cameraImage: UIImage?
    
    var videoCaptureSession: AVCaptureSession?
    var movieOutput = AVCaptureMovieFileOutput()
    var recording = false
    
    var locationManager: CLLocationManager!
    var db: OpaquePointer?
    var waypoints = [Waypoint]()
    
    var itemRow = 0

    //MARK: Private Methods

    private func loadTasks() {
        // Navigate Task
        guard let task0 = Tasks(label: NSLocalizedString("Navigation", comment: ""), icon: UIImage(named: "Map")) else {
            fatalError("Unable to instantiate Navigate Task")
        }
        // Go Home Task
        guard let task1 = Tasks(label: NSLocalizedString("Go Home", comment: ""), icon: UIImage(named: "Home")) else {
            fatalError("Unable to instantiate Go Home Task")
        }
        // Call Home Task
        guard let task2 = Tasks(label: NSLocalizedString("Call Favorite Number", comment: ""), icon: UIImage(named: "Phone")) else {
            fatalError("Unable to instantiate Call Home Task")
        }
        // Call Contact Task
        guard let task3 = Tasks(label: NSLocalizedString("Call Contact", comment: ""), icon: UIImage(named: "Contacts")) else {
            fatalError("Unable to instantiate Call Contact Task")
        }
        // Take Photo Task
        guard let task4 = Tasks(label: NSLocalizedString("Take Photo", comment: ""), icon: UIImage(named: "Camera")) else {
            fatalError("Unable to instantiate Take Photo Task")
        }
        // Video Recording Task
        guard let task5 = Tasks(label: NSLocalizedString("Start Recording", comment: ""), icon: UIImage(named: "VideoCamera")) else {
            fatalError("Unable to instantiate Video Recording Task")
        }
        // Trip Log Task
        guard let task6 = Tasks(label: NSLocalizedString("Start Trip Log", comment: ""), icon: UIImage(named: "Road")) else {
            fatalError("Unable to instantiate Trip Log Task")
        }
        // Save Waypoint Task
        guard let task7 = Tasks(label: NSLocalizedString("Save Waypoint", comment: ""), icon: UIImage(named: "MapMarker")) else {
            fatalError("Unable to instantiate Save Waypoint Task")
        }
        tasks += [task0, task1, task2, task3, task4, task5, task6, task7]
    }
    
    private func execute_task(taskID:Int) {
        switch taskID {
        case 0:
            print("Navigation")
            let map = MKMapItem()
            map.openInMaps(launchOptions: nil)
            break
        case 1:
            print("Go Home")
            if let homeAddress = UserDefaults.standard.string(forKey: "gohome_address_preference"){
                if homeAddress != "" {
                    let geocoder = CLGeocoder()
                    geocoder.geocodeAddressString(homeAddress) {
                        placemarks, error in
                        let placemark = placemarks?.first
                        let lat = placemark?.location?.coordinate.latitude
                        let lon = placemark?.location?.coordinate.longitude
                        print("Lat: \(String(describing: lat)), Lon: \(String(describing: lon))")
                        
                        let destLatitude: CLLocationDegrees = lat!
                        let destLongitude: CLLocationDegrees = lon!
                        let coordinates = CLLocationCoordinate2DMake(destLatitude, destLongitude)
                        let navPlacemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
                        let mapitem = MKMapItem(placemark: navPlacemark)
                        let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
                        mapitem.openInMaps(launchOptions: options)
                    }
                } else {
                    // the alert view
                    let alert = UIAlertController(title: "", message: "No Go Home address set in Settings", preferredStyle: .alert)
                    self.present(alert, animated: true, completion: nil)
                    
                    // change to desired number of seconds (in this case 2 seconds)
                    let when = DispatchTime.now() + 10
                    DispatchQueue.main.asyncAfter(deadline: when){
                        // your code with delay
                        alert.dismiss(animated: true, completion: nil)
                        
                    }
                }
            } else {
                let alert = UIAlertController(title: "", message: "No Go Home address set in Settings", preferredStyle: .alert)
                self.present(alert, animated: true, completion: nil)
                
                // change to desired number of seconds (in this case 2 seconds)
                let when = DispatchTime.now() + 2
                DispatchQueue.main.asyncAfter(deadline: when){
                    // your code with delay
                    alert.dismiss(animated: true, completion: nil)
                    
                }
            }
            break
        case 2:
            print("Call Home")
            if let phoneNumber = UserDefaults.standard.string(forKey: "callhome_number_preference"){
                if phoneNumber != "" {
                    var validPhoneNumber = ""
                    phoneNumber.characters.forEach {(character) in
                        switch character {
                        case "0"..."9":
                            validPhoneNumber.characters.append(character)
                        default:
                            break
                        }
                    }
                    if let phoneCallURL = URL(string: "telprompt:\(validPhoneNumber)") {
                        if (UIApplication.shared.canOpenURL(phoneCallURL)) {
                            if #available(iOS 10, *) {
                                UIApplication.shared.open(phoneCallURL, options: [:], completionHandler: nil)
                            } else {
                                UIApplication.shared.openURL(phoneCallURL as URL)
                            }
                        }
                    }
                } else {
                    // the alert view
                    let alert = UIAlertController(title: "", message: "No Call Home phone number set in Settings", preferredStyle: .alert)
                    self.present(alert, animated: true, completion: nil)
                    
                    // change to desired number of seconds (in this case 2 seconds)
                    let when = DispatchTime.now() + 2
                    DispatchQueue.main.asyncAfter(deadline: when){
                        // your code with delay
                        alert.dismiss(animated: true, completion: nil)
                    }
                    
                }
            } else {
                // the alert view
                let alert = UIAlertController(title: "", message: "No Call Home phone number set in Settings", preferredStyle: .alert)
                self.present(alert, animated: true, completion: nil)
                
                // change to desired number of seconds (in this case 2 seconds)
                let when = DispatchTime.now() + 2
                DispatchQueue.main.asyncAfter(deadline: when){
                    // your code with delay
                    alert.dismiss(animated: true, completion: nil)
                }
            }
            break
        case 3:
            print("Call Contact")
            performSegue(withIdentifier: "toContacts", sender: self)
            break
        case 4:
            print("Take Photo")
            setupCamera()
            setupTimer()
            break
        case 5:
            print("Video Recording")
            if (recording)
            {
                print("Video: stopRecording")
                movieOutput.stopRecording()
            }else {
                print("Video: starting")
                setupVideoCamera()
            }
            break
        case 6:
            print("Trip Log")
            break
        case 7:
            print("Save Waypoint")
            if (CLLocationManager.locationServicesEnabled())
            {
                locationManager = CLLocationManager()
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.requestAlwaysAuthorization()
                locationManager.startUpdatingLocation()
            }
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
        print("selectItem called")
    }
    @objc func upRow() {
        print("upRow called")
        if (itemRow == 0){
            let nextRow = tasks.count - 1
            self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.contentView.backgroundColor = UIColor.white
            self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.textLabel?.backgroundColor = UIColor.white
            self.tableView.cellForRow(at: IndexPath(row: nextRow, section: 0) as IndexPath)?.contentView.backgroundColor = UIColor.blue
            self.tableView.cellForRow(at: IndexPath(row: nextRow, section: 0) as IndexPath)?.textLabel?.backgroundColor = UIColor.blue
            itemRow = nextRow
        } else if (itemRow < tasks.count ){
            let nextRow = itemRow - 1
            self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.contentView.backgroundColor = UIColor.white
            self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.textLabel?.backgroundColor = UIColor.white
            self.tableView.cellForRow(at: IndexPath(row: nextRow, section: 0) as IndexPath)?.contentView.backgroundColor = UIColor.blue
            self.tableView.cellForRow(at: IndexPath(row: nextRow, section: 0) as IndexPath)?.textLabel?.backgroundColor = UIColor.blue
            itemRow = nextRow
        }
        self.tableView.reloadData()
    }
    @objc func downRow() {
        print("downRow called")
        if (itemRow == (tasks.count - 1)){
            let nextRow = 0
            self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.contentView.backgroundColor = UIColor.white
            self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.textLabel?.backgroundColor = UIColor.white
            self.tableView.cellForRow(at: IndexPath(row: nextRow, section: 0) as IndexPath)?.contentView.backgroundColor = UIColor.blue
            self.tableView.cellForRow(at: IndexPath(row: nextRow, section: 0) as IndexPath)?.textLabel?.backgroundColor = UIColor.blue
            itemRow = nextRow
        } else if (itemRow < tasks.count ){
            let nextRow = itemRow + 1
            self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.contentView.backgroundColor = UIColor.white
            self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.textLabel?.backgroundColor = UIColor.white
            self.tableView.cellForRow(at: IndexPath(row: nextRow, section: 0) as IndexPath)?.contentView.backgroundColor = UIColor.blue
            self.tableView.cellForRow(at: IndexPath(row: nextRow, section: 0) as IndexPath)?.textLabel?.backgroundColor = UIColor.blue
            itemRow = nextRow
        }
        self.tableView.reloadData()
    }
    
    @objc func leftScreen() {
        performSegue(withIdentifier: "backToMusic", sender: [])
        
    }
    
    @objc func rightScreen() {
        performSegue(withIdentifier: "backToBegin", sender: [])
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func forward(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "unwindToContainerVC", sender: self)
    }
    
    func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizerDirection.right {
            print("Swipe Right")
            performSegue(withIdentifier: "backToMusic", sender: [])
        }
        else if gesture.direction == UISwipeGestureRecognizerDirection.left {
            print("Swipe Left")
            performSegue(withIdentifier: "backToBegin", sender: [])
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        loadTasks();
        
        tableView.remembersLastFocusedIndexPath = true
        
        // Uncomment the following line to preserve selection between presentations
        //self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
        let databaseURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("waypoints.sqlite")
        //opening the database
        if sqlite3_open(databaseURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
        
        //creating table
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS records (id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT, latitude TEXT, longitude TEXT)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tasks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure the cell...
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskTableViewCell", for: indexPath)

        let tasks = self.tasks[indexPath.row]
        
        cell.textLabel?.text = tasks.label
        cell.imageView?.image = tasks.icon
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("row: \(indexPath.row)")
        execute_task(taskID: indexPath.row)
    }
    
    
    func setupCamera() {
        // tweak delay
        let discoverySession = AVCaptureDeviceDiscoverySession(deviceTypes: [.builtInWideAngleCamera],
                                                               mediaType: AVMediaTypeVideo,
                                                               position: .back)
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
        print("SNAPSHOT")
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
            let alert = UIAlertController(title: "", message: "Save Error", preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
            
            // change to desired number of seconds (in this case 2 seconds)
            let when = DispatchTime.now() + 2
            DispatchQueue.main.asyncAfter(deadline: when){
                // your code with delay
                alert.dismiss(animated: true, completion: nil)
            }
        } else {
            // the alert view
            let alert = UIAlertController(title: "", message: "Pictue Taken", preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
            
            // change to desired number of seconds (in this case 2 seconds)
            let when = DispatchTime.now() + 2
            DispatchQueue.main.asyncAfter(deadline: when){
                // your code with delay
                alert.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    private var tempFilePath: NSURL = {
        let tempPath = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tempMovie")?.appendingPathExtension("mp4").absoluteString
        if FileManager.default.fileExists(atPath: tempPath!) {
            do {
                try FileManager.default.removeItem(atPath: tempPath!)
            } catch { }
        }
        return NSURL(string: tempPath!)!
    }()
    
    func setupVideoCamera() {
        // tweak delay
        let discoverySession = AVCaptureDeviceDiscoverySession(deviceTypes: [.builtInWideAngleCamera],
                                                               mediaType: AVMediaTypeVideo,
                                                               position: .back)
        device = discoverySession?.devices[0]
        
        let input: AVCaptureDeviceInput
        do {
            input = try AVCaptureDeviceInput(device: device)
        } catch {
            return
        }
        
        let audioDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
        let audioInput: AVCaptureDeviceInput
        do {
            audioInput = try AVCaptureDeviceInput(device: audioDevice)
        } catch {
            return
        }
        
        //start session configuration
        let videoCaptureSession = AVCaptureSession()
        videoCaptureSession.beginConfiguration()
        videoCaptureSession.sessionPreset = AVCaptureSessionPresetHigh
        
        // add device inputs (front camera and mic)
        videoCaptureSession.addInput(input)
        videoCaptureSession.addInput(audioInput)
        
        // add output movieFileOutput
        movieOutput.movieFragmentInterval = kCMTimeInvalid
        videoCaptureSession.addOutput(movieOutput)
        
        // start session
        videoCaptureSession.commitConfiguration()
        videoCaptureSession.startRunning()
        
        // start capture
        let dateFormat = "yyyy-MM-dd-hh:mm:ss"
        var dateFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateFormat = dateFormat
            formatter.locale = Locale.current
            formatter.timeZone = TimeZone.current
            return formatter
        }
        let date = Date().toString() as NSString
        let paths = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0] as String
        //var filePath = "\(documentsDirectory)/WunderLINQ-\(date).mp4"

        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let filePath = documentsURL.appendingPathComponent("WunderLINQ-\(date).mp4")
        movieOutput.startRecording(toOutputFileURL: filePath, recordingDelegate: self)
        
        print("Video: setupVideoCamera()")
        recording = true
        if(videoCaptureSession.isRunning){
            print("Video: setupVideoCamera() videoCaptureSession.isRunning")
        }
        if(movieOutput.isRecording){
            print("Video: setupVideoCamera() movieOutput.isRecording")
        }
    }
    
    private func deviceInputFromDevice(device: AVCaptureDevice?) -> AVCaptureDeviceInput? {
        print("Video: deviceInputFromDevice()")
        guard let validDevice = device else { return nil }
        do {
            return try AVCaptureDeviceInput(device: validDevice)
        } catch let outError {
            print("Device setup error occured \(outError)")
            return nil
        }
    }
    
    func capture(_ output: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        print("Video: capture()")
        
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: URL!, fromConnections connections: [AnyObject]!) {
        print("Video: captureOutput()")
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        if (error != nil)
        {
            print("Unable to save video to the iPhone  \(error.localizedDescription)")
        }
        else
        {
            print("Video: Saving to library")
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL! as URL)
            }) { saved, error in
                if saved {
                    // the alert view
                    let alert = UIAlertController(title: "", message: "Pictue Taken", preferredStyle: .alert)
                    self.present(alert, animated: true, completion: nil)
                    
                    // change to desired number of seconds (in this case 2 seconds)
                    let when = DispatchTime.now() + 2
                    DispatchQueue.main.asyncAfter(deadline: when){
                        // your code with delay
                        alert.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        manager.stopUpdatingLocation()
        
        let coordinations = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude,longitude: userLocation.coordinate.longitude)
        
        //creating a statement
        var stmt: OpaquePointer?
        
        //the insert query
        let queryString = "INSERT INTO records (date, latitude, longitude) VALUES (?,?,?)"
        
        //preparing the query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        //binding the parameters
        let dateFormat = "yyyy-MM-dd hh:mm:ssSSS"
        var dateFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateFormat = dateFormat
            formatter.locale = Locale.current
            formatter.timeZone = TimeZone.current
            return formatter
        }
        let date = Date().toString() as NSString
        let latitude = "\(userLocation.coordinate.latitude)" as NSString
        let longitude = "\(userLocation.coordinate.longitude)" as NSString
        
        if sqlite3_bind_text(stmt, 1, date.utf8String, -1, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        
        if sqlite3_bind_text(stmt, 2, latitude.utf8String, -1, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        if sqlite3_bind_text(stmt, 3, longitude.utf8String, -1, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        
        //executing the query to insert values
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting hero: \(errmsg)")
            return
        }
        readValues()
    }
    
    func readValues(){
        
        //first empty the list of watpoints
        waypoints.removeAll()
        
        //this is our select query
        let queryString = "SELECT * FROM records"
        
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
            //adding values to list
            waypoints.append(Waypoint(id: Int(id), date: String(describing: date), latitude: String(describing: latitude), longitude: String(describing: longitude)))
            print("Database ID: \(id)")
            print("Database Date: \(date)")
            print("Database Lat: \(latitude)")
            print("Database Long: \(longitude)")
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
