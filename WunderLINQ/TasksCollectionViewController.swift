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

class TasksCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureFileOutputRecordingDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var taskImage: UIImageView!
    @IBOutlet weak var taskLabel: UILabel!
    
    var tasks:[Tasks] = [Tasks]()
    
    var mapping = [Int]()
    
    @IBOutlet weak var cameraImageView: UIImageView!
    
    private var locationManager: CLLocationManager!
    private var currentLocation: CLLocation?
    
    var device: AVCaptureDevice?
    var captureSession: AVCaptureSession?
    var cameraImage: UIImage?
    
    let videoCaptureSession = AVCaptureSession()
    let movieOutput = AVCaptureMovieFileOutput()
    var activeInput: AVCaptureDeviceInput!
    var outputURL: URL!
    var isRecording = false
    var actionCamIsOnline = false
    var actionCamIsRecording = false
    
    var db: OpaquePointer?
    var waypoints = [Waypoint]()
    
    var itemRow = 0
    
    var seconds = 10
    var timer = Timer()
    var isTimerRunning = false
    
    let scenic = ScenicAPI()
    
    let motorcycleData = MotorcycleData.shared
    
    let emptyTask = 13;
    
    private func loadRows() {
        let taskRow1 = UserDefaults.standard.integer(forKey: "task_one_preference")
        if (taskRow1 < emptyTask){
            mapping.append(taskRow1)
        }
        let taskRow2 = UserDefaults.standard.integer(forKey: "task_two_preference")
        if (taskRow2 < emptyTask){
            mapping.append(taskRow2)
        }
        let taskRow3 = UserDefaults.standard.integer(forKey: "task_three_preference")
        if (taskRow3 < emptyTask){
            mapping.append(taskRow3)
        }
        let taskRow4 = UserDefaults.standard.integer(forKey: "task_four_preference")
        if (taskRow4 < emptyTask){
            mapping.append(taskRow4)
        }
        let taskRow5 = UserDefaults.standard.integer(forKey: "task_five_preference")
        if (taskRow5 < emptyTask){
            mapping.append(taskRow5)
        }
        let taskRow6 = UserDefaults.standard.integer(forKey: "task_six_preference")
        if (taskRow6 < emptyTask){
            mapping.append(taskRow6)
        }
        let taskRow7 = UserDefaults.standard.integer(forKey: "task_seven_preference")
        if (taskRow7 < emptyTask){
            mapping.append(taskRow7)
        }
        let taskRow8 = UserDefaults.standard.integer(forKey: "task_eight_preference")
        if (taskRow8 < emptyTask){
            mapping.append(taskRow8)
        }
        let taskRow9 = UserDefaults.standard.integer(forKey: "task_nine_preference")
        if (taskRow9 < emptyTask){
            mapping.append(taskRow9)
        }
        let taskRow10 = UserDefaults.standard.integer(forKey: "task_ten_preference")
        if (taskRow10 < emptyTask){
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
        var vidRecLabel = NSLocalizedString("task_title_start_record", comment: "")
        if isRecording{
            vidRecLabel = NSLocalizedString("task_title_stop_record", comment: "")
        }
        guard let task6 = Tasks(label: vidRecLabel, icon: UIImage(named: "VideoCamera")?.withRenderingMode(.alwaysTemplate)) else {
            fatalError("Unable to instantiate Video Recording Task")
        }
        // Trip Log Task
        var tripLogLabel = NSLocalizedString("task_title_start_trip", comment: "")
        let loggingStatus = UserDefaults.standard.string(forKey: "loggingStatus")
        if loggingStatus != nil {
            //Stop Logging
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
        // Settings Task
        guard let task10 = Tasks(label: NSLocalizedString("task_title_settings", comment: ""), icon: UIImage(named: "Cog")?.withRenderingMode(.alwaysTemplate)) else {
            fatalError("Unable to instantiate Settings Task")
        }
        // Action Camera Task
        var actionCamLabel = NSLocalizedString("task_title_actioncam_start_video", comment: "")
        if actionCamIsRecording{
            actionCamLabel = NSLocalizedString("task_title_actioncam_stop_video", comment: "")
        }
        print("Label: \(actionCamLabel)")
        guard let task11 = Tasks(label: actionCamLabel, icon: UIImage(named: "VideoCamera")?.withRenderingMode(.alwaysTemplate)) else {
            fatalError("Unable to instantiate ActionCam Video Recording Task")
        }
        // WeatherMap Task
        guard let task12 = Tasks(label: NSLocalizedString("task_title_weathermap", comment: ""), icon: UIImage(named: "CloudSun")?.withRenderingMode(.alwaysTemplate)) else {
            fatalError("Unable to instantiate Settings Task")
        }
        self.tasks = [task0, task1, task2, task3, task4, task5, task6, task7, task8, task9, task10, task11, task12]
    }
    
    private func execute_task(taskID:Int) {
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
                            UIApplication.shared.open(googleMapsURL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
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
                            UIApplication.shared.open(sygicURL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
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
                            UIApplication.shared.open(wazeURL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                        } else {
                            UIApplication.shared.openURL(wazeURL as URL)
                        }
                    }
                }
            case 5:
                //Maps.me
                //https://github.com/mapsme/api-ios
                if let mapsMeURL = URL(string: "mapsme://&id=wunderlinq://&backurl=wunderlinq://&appname=\(NSLocalizedString("product", comment: ""))") {
                    if (UIApplication.shared.canOpenURL(mapsMeURL)) {
                        if #available(iOS 10, *) {
                            UIApplication.shared.open(mapsMeURL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                        } else {
                            UIApplication.shared.openURL(mapsMeURL as URL)
                        }
                    }
                }
            case 6:
                //OsmAnd
                // osmandmaps://?lat=45.6313&lon=34.9955&z=8&title=New+York
                let urlString = "osmandmaps://"
                if let osmAndURL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                    if (UIApplication.shared.canOpenURL(osmAndURL)) {
                        if #available(iOS 10, *) {
                            UIApplication.shared.open(osmAndURL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                        } else {
                            UIApplication.shared.openURL(osmAndURL as URL)
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
                                    UIApplication.shared.open(googleMapsURL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
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
                                                                        UIApplication.shared.open(sygicURL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
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
                            let geocoder = CLGeocoder()
                            geocoder.geocodeAddressString(homeAddress,
                                                          completionHandler: { (placemarks, error) in
                                                            if error == nil {
                                                                let startLatitude: CLLocationDegrees = (self.currentLocation?.coordinate.latitude)!
                                                                let startLongitude: CLLocationDegrees = (self.currentLocation?.coordinate.longitude)!
                                                                let placemark = placemarks?.first
                                                                let lat = placemark?.location?.coordinate.latitude
                                                                let lon = placemark?.location?.coordinate.longitude
                                                                let destLatitude: CLLocationDegrees = lat!
                                                                let destLongitude: CLLocationDegrees = lon!
                                                                let urlString = "mapsme://route?sll=\(startLatitude),\(startLongitude)&saddr=Start&dll=\(destLatitude),\(destLongitude)&daddr=\(NSLocalizedString("home", comment: ""))&type=vehicle"
                                                                
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
                                                            else {
                                                                // An error occurred during geocoding.
                                                                self.showToast(message: NSLocalizedString("geocode_error", comment: ""))
                                                            }
                            })
                        }
                    case 6:
                        //OsmAnd
                        // osmandmaps://?lat=45.6313&lon=34.9955&z=8&title=New+York
                        let geocoder = CLGeocoder()
                        geocoder.geocodeAddressString(homeAddress,
                                                      completionHandler: { (placemarks, error) in
                                                        if error == nil {
                                                            let placemark = placemarks?.first
                                                            let lat = placemark?.location?.coordinate.latitude
                                                            let lon = placemark?.location?.coordinate.longitude
                                                            let destLatitude: CLLocationDegrees = lat!
                                                            let destLongitude: CLLocationDegrees = lon!
                                                            let urlString = "osmandmaps://navigate?lat=\(destLatitude)&lon=\(destLongitude)&z=8&title=\(NSLocalizedString("home", comment: ""))"
                                                            
                                                            if let osmAndURL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                                                                if (UIApplication.shared.canOpenURL(osmAndURL)) {
                                                                    if #available(iOS 10, *) {
                                                                        UIApplication.shared.open(osmAndURL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                                                                    } else {
                                                                        UIApplication.shared.openURL(osmAndURL as URL)
                                                                    }
                                                                }
                                                            }
                                                        }
                                                        else {
                                                            // An error occurred during geocoding.
                                                            self.showToast(message: NSLocalizedString("geocode_error", comment: ""))
                                                        }
                        })
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
                                UIApplication.shared.open(phoneCallURL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
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
            //Take Rear Photo
            self.showToast(message: NSLocalizedString("toast_photo_taken", comment: ""))
            setupCamera(position: .back)
            setupTimer()
            break
        case 5:
            //Take Front Photo (Selfie)
            self.showToast(message: NSLocalizedString("toast_photo_taken", comment: ""))
            setupCamera(position: .front)
            setupTimer()
            break
        case 6:
            //Video Recording
            if movieOutput.isRecording {
                movieOutput.stopRecording()
                isRecording = false
            } else {
                if setupSession() {
                    startSession()
                }
                if (self.videoCaptureSession.isRunning) {
                    startCapture()
                    isRecording = true
                }
            }
            //loadTasks()
            break
        case 7:
            //Trip Log
            let loggingStatus = UserDefaults.standard.string(forKey: "loggingStatus")
            if loggingStatus != nil {
                //Stop Logging
                UserDefaults.standard.set(nil, forKey: "loggingStatus")
            } else {
                //Start Logging
                let today = Date().toString()
                UserDefaults.standard.set(today, forKey: "loggingStatus")
            }
            //loadTasks()
            break
        case 8:
            //Save Waypoint
            saveWaypoint()
            break
        case 9:
            //Navigate to Waypoint
            performSegue(withIdentifier: "taskGridToWaypoints", sender: self)
            break
        case 10:
            //Settings
            if let appSettings = URL(string: UIApplication.openSettingsURLString + Bundle.main.bundleIdentifier!) {
                if UIApplication.shared.canOpenURL(appSettings) {
                    UIApplication.shared.open(appSettings)
                }
            }
            break
        case 11:
            //ActionCam Control
            if (actionCamIsOnline){
                let actionCamType = UserDefaults.standard.integer(forKey: "actioncam_preference")
                switch (actionCamType){
                case 1:
                    //GoPro Hero3
                    var hero3NeedsPass = false
                    if let goProPassword = UserDefaults.standard.string(forKey: "ACTIONCAM_GOPRO3_PWD"){
                        if (goProPassword != ""){
                            hero3NeedsPass = true
                        } else {
                            hero3NeedsPass = false
                        }
                    } else {
                        hero3NeedsPass = false
                    }
                    if (self.actionCamIsRecording){
                        //Off
                        var offUrl = URL(string: "http://10.5.5.9/bacpac/SH?p=%00")!
                        if (hero3NeedsPass){
                            let goProPassword = UserDefaults.standard.string(forKey: "ACTIONCAM_GOPRO3_PWD")
                            offUrl = URL(string: "http://10.5.5.9/bacpac/SH?t=\(goProPassword ?? "")&p=%00")!
                        }
                        let offTask = URLSession.shared.dataTask(with: offUrl) { (data, response, error) in
                            guard let data = data, let response = response as? HTTPURLResponse else {
                                print("GoPro Hero3 Off: No Response")
                                self.actionCamIsOnline = false
                                if (self.actionCamIsRecording){
                                    self.actionCamIsRecording = false
                                    self.loadTasks()
                                    DispatchQueue.main.async{
                                        self.collectionView!.reloadData()
                                    }
                                }
                                return
                            }
                            
                            switch response.statusCode {
                            case 200:
                                print("GoPro Hero3 Off Response: \(String(data: data, encoding: .utf8)!)")
                                self.actionCamIsOnline = true
                                self.actionCamIsRecording = false
                                self.loadTasks()
                                DispatchQueue.main.async{
                                    self.collectionView!.reloadData()
                                }
                                break
                            case 403:
                                //Bad Pass
                                print("GoPro Hero3 Off: Bad Password")
                                let passwordUrl = URL(string: "http://10.5.5.9/bacpac/sd")!
                                let passwordTask = URLSession.shared.dataTask(with: passwordUrl) { (data, response, error) in
                                    guard let data = data, let response = response as? HTTPURLResponse else {
                                        print("GoPro Hero 3 Get Password: No Response")
                                        self.actionCamIsOnline = false
                                        if (self.actionCamIsRecording){
                                            self.actionCamIsRecording = false
                                            self.loadTasks()
                                            DispatchQueue.main.async{
                                                self.collectionView!.reloadData()
                                            }
                                        }
                                        return
                                    }
                                    
                                    switch response.statusCode {
                                    case 200:
                                        //Write password into preference
                                        let goProPassword = (String(data: data, encoding: .utf8)!).dropFirst(2)
                                        print("GoPro Hero 3 Password: \(goProPassword)")
                                        UserDefaults.standard.set(goProPassword, forKey: "ACTIONCAM_GOPRO3_PWD")
                                        let offUrl = URL(string: "http://10.5.5.9/bacpac/SH?t=\(goProPassword )&p=%00")!
                                        let offTask = URLSession.shared.dataTask(with: offUrl) { (data, response, error) in
                                            guard let data = data, let response = response as? HTTPURLResponse else {
                                                print("GoPro Hero3 On(ReAuth): No Response")
                                                self.actionCamIsOnline = false
                                                if (self.actionCamIsRecording){
                                                    self.actionCamIsRecording = false
                                                    self.loadTasks()
                                                    DispatchQueue.main.async{
                                                        self.collectionView!.reloadData()
                                                    }
                                                }
                                                return
                                            }
                                            
                                            switch response.statusCode {
                                            case 200:
                                                self.actionCamIsOnline = true
                                                print("GoPro Hero3 Off(ReAuth) Response: \(data)")
                                                break
                                            case 403:
                                                //Bad Pass
                                                print("GoPro Hero3 Off(ReAuth): Bad Password")
                                                break
                                            default:
                                                print("GoPro Hero3 Off(ReAuth) Unchecked Status Code: \(response.statusCode)")
                                                if (self.actionCamIsRecording){
                                                    print("Changed to NOT Recording")
                                                    self.actionCamIsRecording = false
                                                    self.loadTasks()
                                                    DispatchQueue.main.async{
                                                        self.collectionView!.reloadData()
                                                    }
                                                }
                                            }
                                        }
                                        offTask.resume()
                                        break
                                    default:
                                        print("GoPro Hero3 Status(Auth) Unchecked Status Code: \(response.statusCode)")
                                        if (self.actionCamIsRecording){
                                            print("Changed to NOT Recording")
                                            self.actionCamIsRecording = false
                                            self.loadTasks()
                                            DispatchQueue.main.async{
                                                self.collectionView!.reloadData()
                                            }
                                        }
                                    }
                                }
                                passwordTask.resume()
                                break
                            default:
                                print("GoPro Hero3 Off Unchecked Status Code: \(response.statusCode)")
                                if (self.actionCamIsRecording){
                                    print("Changed to NOT Recording")
                                    self.actionCamIsRecording = false
                                    self.loadTasks()
                                    DispatchQueue.main.async{
                                        self.collectionView!.reloadData()
                                    }
                                }
                            }
                        }
                        offTask.resume()
                    } else {
                        //On
                        var onUrl = URL(string: "http://10.5.5.9/bacpac/SH?p=%01")!
                        if (hero3NeedsPass){
                            let goProPassword = UserDefaults.standard.string(forKey: "ACTIONCAM_GOPRO3_PWD")
                            onUrl = URL(string: "http://10.5.5.9/bacpac/SH?t=\(goProPassword ?? "")&p=%01")!
                        }
                        let onTask = URLSession.shared.dataTask(with: onUrl) { (data, response, error) in
                            guard let data = data, let response = response as? HTTPURLResponse else {
                                print("GoPro Hero3 On: No Response")
                                self.actionCamIsOnline = false
                                if (self.actionCamIsRecording){
                                    self.actionCamIsRecording = false
                                    self.loadTasks()
                                    DispatchQueue.main.async{
                                        self.collectionView!.reloadData()
                                    }
                                }
                                return
                            }
                            
                            switch response.statusCode {
                            case 200:
                                print("GoPro Hero3 On Response: \(String(data: data, encoding: .utf8)!)")
                                self.actionCamIsOnline = true
                                self.actionCamIsRecording = true
                                self.loadTasks()
                                DispatchQueue.main.async{
                                    self.collectionView!.reloadData()
                                }
                                break
                            case 403:
                                //Bad Pass
                                print("GoPro Hero3 On: Bad Password")
                                let passwordUrl = URL(string: "http://10.5.5.9/bacpac/sd")!
                                let passwordTask = URLSession.shared.dataTask(with: passwordUrl) { (data, response, error) in
                                    guard let data = data, let response = response as? HTTPURLResponse else {
                                        print("GoPro Hero 3 Get Password: No Response")
                                        self.actionCamIsOnline = false
                                        if (self.actionCamIsRecording){
                                            self.actionCamIsRecording = false
                                            self.loadTasks()
                                            DispatchQueue.main.async{
                                                self.collectionView!.reloadData()
                                            }
                                        }
                                        return
                                    }
                                    
                                    switch response.statusCode {
                                    case 200:
                                        //Write password into preference
                                        self.actionCamIsOnline = true
                                        let goProPassword = (String(data: data, encoding: .utf8)!).dropFirst(2)
                                        print("GoPro Hero 3 Password: \(goProPassword)")
                                        UserDefaults.standard.set(goProPassword, forKey: "ACTIONCAM_GOPRO3_PWD")
                                        let onUrl = URL(string: "http://10.5.5.9/bacpac/SH?t=\(goProPassword )&p=%01")!
                                        let onTask = URLSession.shared.dataTask(with: onUrl) { (data, response, error) in
                                            guard let data = data, let response = response as? HTTPURLResponse else {
                                                print("GoPro Hero3 On(ReAuth): No Response")
                                                self.actionCamIsOnline = false
                                                if (self.actionCamIsRecording){
                                                    self.actionCamIsRecording = false
                                                    self.loadTasks()
                                                    DispatchQueue.main.async{
                                                        self.collectionView!.reloadData()
                                                    }
                                                }
                                                return
                                            }
                                            
                                            switch response.statusCode {
                                            case 200:
                                                print("GoPro Hero3 On(ReAuth) Response: \(data)")
                                                self.actionCamIsOnline = true
                                                break
                                            case 403:
                                                //Bad Pass
                                                print("GoPro Hero3 On(ReAuth): Bad Password")
                                                break
                                            default:
                                                print("GoPro Hero3 On(ReAuth) Unchecked Status Code: \(response.statusCode)")
                                                if (self.actionCamIsRecording){
                                                    print("Changed to NOT Recording")
                                                    self.actionCamIsRecording = false
                                                    self.loadTasks()
                                                    DispatchQueue.main.async{
                                                        self.collectionView!.reloadData()
                                                    }
                                                }
                                            }
                                        }
                                        onTask.resume()
                                        break
                                    default:
                                        print("GoPro Hero3 Status(Auth) Unchecked Status Code: \(response.statusCode)")
                                        if (self.actionCamIsRecording){
                                            print("Changed to NOT Recording")
                                            self.actionCamIsRecording = false
                                            self.loadTasks()
                                            DispatchQueue.main.async{
                                                self.collectionView!.reloadData()
                                            }
                                        }
                                    }
                                }
                                passwordTask.resume()
                                break
                            case 410:
                                //Camera Off
                                //Turn Camera On
                                var powerOnUrl = URL(string: "http://10.5.5.9/bacpac/PW?p=%01")!
                                if (hero3NeedsPass){
                                    let goProPassword = UserDefaults.standard.string(forKey: "ACTIONCAM_GOPRO3_PWD")
                                    powerOnUrl = URL(string: "http://10.5.5.9/bacpac/PW?t=\(goProPassword ?? "")&p=%01")!
                                }
                                let powerOnTask = URLSession.shared.dataTask(with: powerOnUrl) { (data, response, error) in
                                    guard let data = data, let response = response as? HTTPURLResponse else {
                                        print("GoPro Hero 3 Power On: No Response")
                                        self.actionCamIsOnline = false
                                        if (self.actionCamIsRecording){
                                            self.actionCamIsRecording = false
                                            self.loadTasks()
                                            DispatchQueue.main.async{
                                                self.collectionView!.reloadData()
                                            }
                                        }
                                        return
                                    }
                                    switch response.statusCode {
                                    case 200:
                                        print("GoPro Hero 3 Power On Response: \(String(data: data, encoding: .utf8)!)")
                                        self.actionCamIsOnline = true
                                        self.actionCamIsRecording = false
                                        self.loadTasks()
                                        DispatchQueue.main.async{
                                            self.collectionView!.reloadData()
                                        }
                                        break
                                    default:
                                        print("GoPro Hero 3 Power On Unchecked Status Code: \(response.statusCode)")
                                        if (self.actionCamIsRecording){
                                            print("Changed to NOT Recording")
                                            self.actionCamIsRecording = false
                                            self.loadTasks()
                                            DispatchQueue.main.async{
                                                self.collectionView!.reloadData()
                                            }
                                        }
                                    }
                                }
                                powerOnTask.resume()
                                break
                            default:
                                print("GoPro Hero3 On Unchecked Status Code: \(response.statusCode)")
                                if (self.actionCamIsRecording){
                                    print("Changed to NOT Recording")
                                    self.actionCamIsRecording = false
                                    self.loadTasks()
                                    DispatchQueue.main.async{
                                        self.collectionView!.reloadData()
                                    }
                                }
                            }
                        }
                        onTask.resume()
                    }
                    break
                case 2:
                    //GoPro Hero4+
                    if (self.actionCamIsRecording){
                        //Off
                        let url = URL(string: "http://10.5.5.9/gp/gpControl/command/shutter?p=0")!
                        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                            guard let data = data, let response = response as? HTTPURLResponse else {
                                print("GoPro Hero 4+ Off: No Response")
                                self.actionCamIsOnline = false
                                if (self.actionCamIsRecording){
                                    self.actionCamIsRecording = false
                                    self.loadTasks()
                                    DispatchQueue.main.async{
                                        self.collectionView!.reloadData()
                                    }
                                }
                                return
                            }
                            switch response.statusCode {
                            case 200:
                                if let body = String(data: data, encoding: .utf8){
                                    print("GoPro Hero 4+ Off Recording Response: \(body)")
                                    self.actionCamIsOnline = true
                                    self.actionCamIsRecording = false
                                    self.loadTasks()
                                    DispatchQueue.main.async{
                                        self.collectionView!.reloadData()
                                    }
                                }
                                break
                            default:
                                print("GoPro Hero 4+ Off Unchecked Status Code: \(response.statusCode)")
                                if (self.actionCamIsRecording){
                                    print("Changed to NOT Recording")
                                    self.actionCamIsRecording = false
                                    self.loadTasks()
                                    DispatchQueue.main.async{
                                        self.collectionView!.reloadData()
                                    }
                                }
                            }
                        }
                        task.resume()
                    } else {
                        //On
                        let url = URL(string: "http://10.5.5.9/gp/gpControl/command/shutter?p=1")!
                        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                            guard let data = data, let response = response as? HTTPURLResponse else {
                                print("GoPro Hero 4+ On Recording No Response")
                                self.actionCamIsOnline = false
                                if (self.actionCamIsRecording){
                                    self.actionCamIsRecording = false
                                    self.loadTasks()
                                    DispatchQueue.main.async{
                                        self.collectionView!.reloadData()
                                    }
                                }
                                return
                            }
                            switch response.statusCode {
                            case 200:
                                if let body = String(data: data, encoding: .utf8){
                                    print("GoPro Hero 4+ On Recording Response: \(body)")
                                    self.actionCamIsOnline = true
                                    self.actionCamIsRecording = true
                                    self.loadTasks()
                                    DispatchQueue.main.async{
                                        self.collectionView!.reloadData()
                                    }
                                }
                                break
                            default:
                                print("GoPro Hero 4+ On Recording Unchecked Status Code: \(response.statusCode)")
                                if (self.actionCamIsRecording){
                                    print("Changed to NOT Recording")
                                    self.actionCamIsRecording = false
                                    self.loadTasks()
                                    DispatchQueue.main.async{
                                        self.collectionView!.reloadData()
                                    }
                                }
                            }
                        }
                        task.resume()
                    }
                    break
                default:
                    self.showToast(message: NSLocalizedString("toast_actioncam_notset", comment: ""))
                    break
                }
            } else {
                self.showToast(message: NSLocalizedString("toast_actioncam_notconnected", comment: ""))
            }
            break
        case 12:
            //Weather Map
            performSegue(withIdentifier: "taskGridToWeatherMap", sender: self)
            break
        default:
            print("Unknown Task")
        }
        loadTasks()
        self.collectionView!.reloadData()
    }
    
    // MARK: - Handling User Interaction
    
    override var keyCommands: [UIKeyCommand]? {
        let commands = [
            UIKeyCommand(input: "\u{d}", modifierFlags:[], action: #selector(selectItem), discoverabilityTitle: "Select item"),
            UIKeyCommand(input: UIKeyCommand.inputUpArrow, modifierFlags:[], action: #selector(upRow), discoverabilityTitle: "Go up"),
            UIKeyCommand(input: UIKeyCommand.inputDownArrow, modifierFlags:[], action: #selector(downRow), discoverabilityTitle: "Go down"),
            UIKeyCommand(input: UIKeyCommand.inputLeftArrow, modifierFlags:[], action: #selector(leftScreen), discoverabilityTitle: "Go left"),
            UIKeyCommand(input: UIKeyCommand.inputRightArrow, modifierFlags:[], action: #selector(rightScreen), discoverabilityTitle: "Go right")
        ]
        return commands
    }
    
    @objc func selectItem() {
        execute_task(taskID: mapping[itemRow])
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
        _ = navigationController?.popViewController(animated: true)
        //performSegue(withIdentifier: "tasksToMusic", sender: [])
        
    }
    
    @objc func rightScreen() {
        navigationController?.popToRootViewController(animated: true)
        //performSegue(withIdentifier: "taskGridTomotorcycle", sender: [])
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func forward(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "unwindToContainerVC", sender: self)
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizer.Direction.right {
             _ = navigationController?.popViewController(animated: true)
            //performSegue(withIdentifier: "tasksToMusic", sender: [])
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.left {
            navigationController?.popToRootViewController(animated: true)
            //performSegue(withIdentifier: "taskGridTomotorcycle", sender: [])
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
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Check for Location Services
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        
        // ActionCam Status Check
        let actionCamType = UserDefaults.standard.integer(forKey: "actioncam_preference")
        switch (actionCamType){
        case 1:
            //GoPro Hero3
            var hero3NeedsPass = false
            if let actionCamPassword = UserDefaults.standard.string(forKey: "ACTIONCAM_GOPRO3_PWD"){
                if (actionCamPassword != ""){
                    hero3NeedsPass = true
                } else {
                    hero3NeedsPass = false
                }
            } else {
                hero3NeedsPass = false
            }
            var statusUrl = URL(string: "http://10.5.5.9/camera/sx")!
            if (hero3NeedsPass){
                let goProPassword = UserDefaults.standard.string(forKey: "ACTIONCAM_GOPRO3_PWD")
                statusUrl = URL(string: "http://10.5.5.9/camera/sx?t=\(goProPassword ?? "")")!
            }
            let statusTask = URLSession.shared.dataTask(with: statusUrl) { (data, response, error) in
                guard let data = data, let response = response as? HTTPURLResponse else {
                    print("GoPro Hero3 Status: No Response")
                    self.actionCamIsOnline = false
                    if (self.actionCamIsRecording){
                        self.actionCamIsRecording = false
                        self.loadTasks()
                        DispatchQueue.main.async{
                            self.collectionView!.reloadData()
                        }
                    }
                    return
                }
                
                switch response.statusCode {
                case 200:
                    print("GoPro Hero3 Status Response: \(data)")
                    self.actionCamIsOnline = true
                    break
                case 403:
                    //Bad Pass
                    //Get Pass
                    print("GoPro Hero3 Status: Bad Pass")
                    let passwordUrl = URL(string: "http://10.5.5.9/bacpac/sd")!
                    let passwordTask = URLSession.shared.dataTask(with: passwordUrl) { (data, response, error) in
                        guard let data = data, let response = response as? HTTPURLResponse else {
                            print("GoPro Hero 3 Get Password: No Response")
                            self.actionCamIsOnline = false
                            if (self.actionCamIsRecording){
                                self.actionCamIsRecording = false
                                self.loadTasks()
                                DispatchQueue.main.async{
                                    self.collectionView!.reloadData()
                                }
                            }
                            return
                        }
                        
                        switch response.statusCode {
                        case 200:
                            //Write password into preference
                            let goProPassword = (String(data: data, encoding: .utf8)!).dropFirst(2)
                            print("GoPro Hero 3 Password: \(goProPassword)")
                            self.actionCamIsOnline = true
                            UserDefaults.standard.set(goProPassword, forKey: "ACTIONCAM_GOPRO3_PWD")
                            let statusUrl = URL(string: "http://10.5.5.9/camera/sx?t=\(goProPassword)")!
                            let statusTask = URLSession.shared.dataTask(with: statusUrl) { (data, response, error) in
                                guard let data = data, let response = response as? HTTPURLResponse else {
                                    print("GoPro Hero3 Status(ReAuth): No Response")
                                    if (self.actionCamIsRecording){
                                        self.actionCamIsRecording = false
                                        self.loadTasks()
                                        DispatchQueue.main.async{
                                            self.collectionView!.reloadData()
                                        }
                                    }
                                    return
                                }
                                
                                switch response.statusCode {
                                case 200:
                                    print("GoPro Hero3 Status(ReAuth) Response: \(data)")
                                    self.actionCamIsOnline = true
                                    break
                                case 403:
                                    //Bad Pass
                                    print("GoPro Hero3 Status(ReAuth): Bad Password")
                                    break
                                default:
                                    print("GoPro Hero3 Status(ReAuth) Unchecked Status Code: \(response.statusCode)")
                                    if (self.actionCamIsRecording){
                                        print("Changed to NOT Recording")
                                        self.actionCamIsRecording = false
                                        self.loadTasks()
                                        DispatchQueue.main.async{
                                            self.collectionView!.reloadData()
                                        }
                                    }
                                }
                            }
                            statusTask.resume()
                            break
                        default:
                            print("GoPro Hero3 Status(Auth) Unchecked Status Code: \(response.statusCode)")
                            if (self.actionCamIsRecording){
                                print("Changed to NOT Recording")
                                self.actionCamIsRecording = false
                                self.loadTasks()
                                DispatchQueue.main.async{
                                    self.collectionView!.reloadData()
                                }
                            }
                        }
                    }
                    passwordTask.resume()
                    break
                default:
                    print("GoPro Hero3 Status Unchecked Status Code: \(response.statusCode)")
                    if (self.actionCamIsRecording){
                        print("Changed to NOT Recording")
                        self.actionCamIsRecording = false
                        self.loadTasks()
                        DispatchQueue.main.async{
                            self.collectionView!.reloadData()
                        }
                    }
                }
            }
            statusTask.resume()
            
            break
        case 2:
            //GoPro Hero4+
            //Get Status
            let url = URL(string: "http://10.5.5.9/gp/gpControl/status")!
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                guard let data = data, let response = response as? HTTPURLResponse else {
                    print("GoPro Hero4+ Status: No Response")
                    self.actionCamIsOnline = false
                    if (self.actionCamIsRecording){
                        self.actionCamIsRecording = false
                        self.loadTasks()
                        DispatchQueue.main.async{
                            self.collectionView!.reloadData()
                        }
                    }
                    return
                }
                
                switch response.statusCode {
                case 200:
                    //print(String(data: data, encoding: .utf8) as Any)
                    if let body = String(data: data, encoding: .utf8){
                        print(body)
                        let json = String(data: data, encoding: .utf8)!
                        let jsonData = Data(json.utf8)
                        do {
                            if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                                let currentStatus = json["status"] as! [String:Any]
                                print("\(String(describing: currentStatus["8"]))")
                                self.actionCamIsOnline = true
                                let recordingStatus:Int = currentStatus["8"] as! Int
                                if (recordingStatus == 1){
                                    print("GoPro Hero4+ is Recording")
                                    if (!self.actionCamIsRecording){
                                        print("Changed to Recording")
                                        self.actionCamIsRecording = true
                                        self.loadTasks()
                                        DispatchQueue.main.async{
                                            self.collectionView!.reloadData()
                                        }
                                    }
                                } else {
                                    print("GoPro Hero4+ is NOT Recording")
                                    if (self.actionCamIsRecording){
                                        print("Changed to NOT Recording")
                                        self.actionCamIsRecording = false
                                        self.loadTasks()
                                        DispatchQueue.main.async{
                                            self.collectionView!.reloadData()
                                        }
                                    }
                                }
                            }
                        } catch let parseError {
                            print("parsing error: \(parseError)")
                            let responseString = String(data: data, encoding: .utf8)
                            print("raw response: \(responseString!)")
                        }
                    }
                    break
                default:
                    print("Status Code: \(response.statusCode)")
                    if (self.actionCamIsRecording){
                        print("Changed to NOT Recording")
                        self.actionCamIsRecording = false
                        self.loadTasks()
                        DispatchQueue.main.async{
                            self.collectionView!.reloadData()
                        }
                    }
                }
            }
            task.resume()
            
            //Keep Wifi from going to sleep
            //"http://10.5.5.9/gp/gpControl/execute?p1=gpStream&a1=proto_v2&c1=restart"
            //"http://10.5.5.9/gp/gpControl/execute?p1=gpStream&a1=proto_v2&c1=stop"
            if (self.actionCamIsOnline){
                print("Trying GoPro Hero4+ KeepAlive Hack")
                let restartUrl = URL(string: "http://10.5.5.9/gp/gpControl/execute?p1=gpStream&a1=proto_v2&c1=restart")!
                let restartTask = URLSession.shared.dataTask(with: restartUrl) { (data, response, error) in
                    guard let data = data, let response = response as? HTTPURLResponse else {
                        print("No Response")
                        if (self.actionCamIsRecording){
                            self.actionCamIsRecording = false
                            self.loadTasks()
                            DispatchQueue.main.async{
                                self.collectionView!.reloadData()
                            }
                        }
                        return
                    }
                    
                    switch response.statusCode {
                    case 200:
                        print("Restart Stream Response: \(String(data: data, encoding: .utf8)!)")
                        break
                    default:
                        print("Status Code: \(response.statusCode)")
                        if (self.actionCamIsRecording){
                            print("Changed to NOT Recording")
                            self.actionCamIsRecording = false
                            self.loadTasks()
                            DispatchQueue.main.async{
                                self.collectionView!.reloadData()
                            }
                        }
                    }
                }
                restartTask.resume()
                let stopUrl = URL(string: "http://10.5.5.9/gp/gpControl/execute?p1=gpStream&a1=proto_v2&c1=stop")!
                let stopTask = URLSession.shared.dataTask(with: stopUrl) { (data, response, error) in
                    guard let data = data, let response = response as? HTTPURLResponse else {
                        print("No Response")
                        if (self.actionCamIsRecording){
                            self.actionCamIsRecording = false
                            self.loadTasks()
                            DispatchQueue.main.async{
                                self.collectionView!.reloadData()
                            }
                        }
                        return
                    }
                    
                    switch response.statusCode {
                    case 200:
                        print("Stop Stream Response: \(String(data: data, encoding: .utf8)!)")
                        break
                    default:
                        print("Status Code: \(response.statusCode)")
                        if (self.actionCamIsRecording){
                            print("Changed to NOT Recording")
                            self.actionCamIsRecording = false
                            self.loadTasks()
                            DispatchQueue.main.async{
                                self.collectionView!.reloadData()
                            }
                        }
                    }
                }
                stopTask.resume()
                //Get MAC
                /*
                 let infoUrl = URL(string: "http://10.5.5.9/gp/gpControl/info")!
                 let infoTask = URLSession.shared.dataTask(with: infoUrl) { (data, response, error) in
                 guard let data = data, let response = response as? HTTPURLResponse else {
                 print("GoPro Hero 4+ Info: No Response")
                 self.actionCamIsOnline = false
                 if (self.actionCamIsRecording){
                 self.actionCamIsRecording = false
                 self.loadTasks()
                 DispatchQueue.main.async{
                 self.collectionView!.reloadData()
                 }
                 }
                 return
                 }
                 switch response.statusCode {
                 case 200:
                 self.actionCamIsOnline = true
                 if let body = String(data: data, encoding: .utf8){
                 print(body)
                 let json = body
                 let jsonData = Data(json.utf8)
                 do {
                 if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                 let currentStatus = json["info"] as! [String:Any]
                 print("\(String(describing: currentStatus["ap_mac"]))")
                 }
                 } catch let parseError {
                 print("parsing error: \(parseError)")
                 let responseString = String(data: data, encoding: .utf8)
                 print("raw response: \(responseString!)")
                 }
                 }
                 break
                 default:
                 print("Status Code: \(response.statusCode)")
                 if (self.actionCamIsRecording){
                 print("Changed to NOT Recording")
                 self.actionCamIsRecording = false
                 self.loadTasks()
                 DispatchQueue.main.async{
                 self.collectionView!.reloadData()
                 }
                 }
                 }
                 }
                 infoTask.resume()
                 */
            }
            break
        default:
            break
        }
    }
    
    // MARK - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        do { currentLocation = locations.last }
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        if UserDefaults.standard.bool(forKey: "nightmode_preference") {
            return .lightContent
        } else {
            return .default
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.loadTasks()
        coordinator.animate(alongsideTransition: nil) { _ in
            
            self.collectionView!.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isTimerRunning == false {
            runTimer()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        timer.invalidate()
        seconds = 0
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
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
        itemRow = indexPath.row
        //self.collectionView!.scrollToItem(at: IndexPath(row: itemRow, section: 0), at: .centeredVertically, animated: true)
        //self.collectionView!.reloadData()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        if isTimerRunning == false {
            runTimer()
        }
        execute_task(taskID: mapping[indexPath.row])
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        if ( collectionView.bounds.width > collectionView.bounds.height){
            let cellSize = CGSize(width: (collectionView.bounds.width - (3 * 10))/3, height: 80)
            return cellSize
        } else {
            let cellSize = CGSize(width: (collectionView.bounds.width - (3 * 10))/2, height: 80)
            return cellSize
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    {
        let sectionInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        return sectionInset
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
    
    func saveWaypoint(){
        // Waypoint stuff below
        let currentLocation = motorcycleData.getLocation()
        
        let databaseURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("waypoints.sqlite")
        //opening the database
        if sqlite3_open(databaseURL.path, &db) != SQLITE_OK {
            print("error opening database")
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
        let label : String = ""
        
        if sqlite3_bind_text(stmt, 1, date.utf8String, -1, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        if sqlite3_bind_double(stmt, 2, (currentLocation.coordinate.latitude)) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        if sqlite3_bind_double(stmt, 3, (currentLocation.coordinate.longitude)) != SQLITE_OK{
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
    }
    
    func setupCamera(position: AVCaptureDevice.Position) {
        // tweak delay
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera],
                                                               mediaType: AVMediaType(rawValue: convertFromAVMediaType(AVMediaType.video)),
                                                               position: position)
        device = discoverySession.devices[0]
        
        let input: AVCaptureDeviceInput
        do {
            input = try AVCaptureDeviceInput(device: device!)
        } catch {
            return
        }
        
        let output = AVCaptureVideoDataOutput()
        output.alwaysDiscardsLateVideoFrames = true
        
        let queue = DispatchQueue(label: "cameraQueue")
        output.setSampleBufferDelegate(self, queue: queue)
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable: kCVPixelFormatType_32BGRA] as? [String : Any]
        
        captureSession = AVCaptureSession()
        captureSession?.addInput(input)
        captureSession?.addOutput(output)
        captureSession?.sessionPreset = AVCaptureSession.Preset(rawValue: convertFromAVCaptureSessionPreset(AVCaptureSession.Preset.photo))
        //Testing line below
        let connection = output.connection(with: AVMediaType.video)
        connection?.videoOrientation = AVCaptureVideoOrientation(rawValue: UIDevice.current.orientation.rawValue)!
        
        captureSession?.startRunning()
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
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
    
    @objc func snapshot() {
        captureSession?.stopRunning()
        if ( cameraImage == nil ){
            print("No Image")
        } else {
            addAsset(image: cameraImage!, location: currentLocation)
        }
        //captureSession?.stopRunning()
    }
    
    //MARK: - Add image to Library
    func addAsset(image: UIImage, location: CLLocation? = nil) {
        PHPhotoLibrary.shared().performChanges({
            // Request creating an asset from the image.
            let creationRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            // Set metadata location
            if let location = location {
                creationRequest.location = location
            }
        }, completionHandler: { success, error in
            if !success {
                print("Picture not Saved, error")
            } else {
                print("Picture Saved")
                if (UserDefaults.standard.bool(forKey: "photo_preview_enable_preference")){
                    self.performSegue(withIdentifier: "tasksToAlert", sender: [])
                }
            }
        })
    }
    
    //MARK:- Setup Camera
    
    func setupSession() -> Bool {
        
        videoCaptureSession.sessionPreset = AVCaptureSession.Preset(rawValue: convertFromAVCaptureSessionPreset(AVCaptureSession.Preset.high))
        
        // Setup Camera
        let camera = AVCaptureDevice.default(for: AVMediaType(rawValue: convertFromAVMediaType(AVMediaType.video)))
        
        do {
            let input = try AVCaptureDeviceInput(device: camera!)
            if videoCaptureSession.canAddInput(input) {
                videoCaptureSession.addInput(input)
                activeInput = input
            }
        } catch {
            print("Error setting device video input: \(error)")
            return false
        }
        
        // Setup Microphone
        let microphone = AVCaptureDevice.default(for: AVMediaType(rawValue: convertFromAVMediaType(AVMediaType.audio)))
        
        do {
            let micInput = try AVCaptureDeviceInput(device: microphone!)
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
            let connection = movieOutput.connection(with: AVMediaType(rawValue: convertFromAVMediaType(AVMediaType.video)))
            if (connection?.isVideoOrientationSupported)! {
                connection?.videoOrientation = currentVideoOrientation()
            }
            
            if (connection?.isVideoStabilizationSupported)! {
                connection?.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
            }
            
            let device = activeInput.device
            if (device.isSmoothAutoFocusSupported) {
                do {
                    try device.lockForConfiguration()
                    device.isSmoothAutoFocusEnabled = false
                    device.unlockForConfiguration()
                } catch {
                    print("Error setting configuration: \(error)")
                }
                
            }
            
            outputURL = tempURL()
            movieOutput.startRecording(to: outputURL, recordingDelegate: self)
            
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
    
    func fileOutput(_ captureOutput: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        
    }
    
    func fileOutput(_ captureOutput: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
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
                    self.present(alert, animated: false, completion: nil)
                    
                    // change to desired number of seconds (in this case 2 seconds)
                    let when = DispatchTime.now() + 3
                    DispatchQueue.main.asyncAfter(deadline: when){
                        // your code with delay
                        alert.dismiss(animated: false, completion: nil)
                    }
                } else {
                    print("In capture didfinish, didn't save")
                }
            }
            
        }
        outputURL = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navigationController = segue.destination as? UINavigationController,
            let alertViewController = navigationController.viewControllers.first as? AlertViewController {
            alertViewController.ID = 2
            alertViewController.PHOTO = cameraImage
        }
    }
    
    @objc func onTouch() {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        if isTimerRunning == false {
            runTimer()
        }
    }
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
        isTimerRunning = true
    }
    
    @objc func updateTimer() {
        if seconds < 1 {
            timer.invalidate()
            //Send alert to indicate "time's up!"
            isTimerRunning = false
            seconds = 10
            // Hide the navigation bar on the this view controller
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        } else {
            seconds -= 1
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVMediaType(_ input: AVMediaType) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVCaptureSessionPreset(_ input: AVCaptureSession.Preset) -> String {
	return input.rawValue
}
