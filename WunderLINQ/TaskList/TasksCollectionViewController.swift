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
import UIKit
import MapKit
import CoreLocation
import AVFoundation
import SQLite3
import Photos
import os.log

class TasksCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureFileOutputRecordingDelegate {

    private let notificationCenter = NotificationCenter.default
    var faultsBtn: UIButton!
    var faultsButton: UIBarButtonItem!
    
    let flowLayout = ZoomAndSnapFlowLayout()
    
    var tasks:[Tasks] = [Tasks]()
    
    var mapping = [Int]()
    
    var device: AVCaptureDevice?
    var captureSession: AVCaptureSession?
    var cameraImage: UIImage?
    
    var videoCaptureSession = AVCaptureSession()
    let movieOutput = AVCaptureMovieFileOutput()
    var activeInput: AVCaptureDeviceInput!
    var outputURL: URL!
    var isRecording = false

    var db: OpaquePointer?
    var waypoints = [Waypoint]()
    
    var itemRow = 0
    
    var seconds = 10
    var timer = Timer()
    var isTimerRunning = false
    
    let scenic = ScenicAPI()
    
    let motorcycleData = MotorcycleData.shared
    let wlqData = WLQ.shared
    let faults = Faults.shared
    
    let emptyTask = 16
    
    private func loadRows() {
        let taskRow1 = UserDefaults.standard.integer(forKey: "task_one_preference")
        if (taskRow1 != emptyTask){
            mapping.append(taskRow1)
        }
        let taskRow2 = UserDefaults.standard.integer(forKey: "task_two_preference")
        if (taskRow2 != emptyTask){
            mapping.append(taskRow2)
        }
        let taskRow3 = UserDefaults.standard.integer(forKey: "task_three_preference")
        if (taskRow3 != emptyTask){
            mapping.append(taskRow3)
        }
        let taskRow4 = UserDefaults.standard.integer(forKey: "task_four_preference")
        if (taskRow4 != emptyTask){
            mapping.append(taskRow4)
        }
        let taskRow5 = UserDefaults.standard.integer(forKey: "task_five_preference")
        if (taskRow5 != emptyTask){
            mapping.append(taskRow5)
        }
        let taskRow6 = UserDefaults.standard.integer(forKey: "task_six_preference")
        if (taskRow6 != emptyTask){
            mapping.append(taskRow6)
        }
        let taskRow7 = UserDefaults.standard.integer(forKey: "task_seven_preference")
        if (taskRow7 != emptyTask){
            mapping.append(taskRow7)
        }
        let taskRow8 = UserDefaults.standard.integer(forKey: "task_eight_preference")
        if (taskRow8 != emptyTask){
            mapping.append(taskRow8)
        }
        let taskRow9 = UserDefaults.standard.integer(forKey: "task_nine_preference")
        if (taskRow9 != emptyTask){
            mapping.append(taskRow9)
        }
        let taskRow10 = UserDefaults.standard.integer(forKey: "task_ten_preference")
        if (taskRow10 != emptyTask){
            mapping.append(taskRow10)
        }
        let taskRow11 = UserDefaults.standard.integer(forKey: "task_eleven_preference")
        if (taskRow11 != emptyTask){
            mapping.append(taskRow11)
        }
        let taskRow12 = UserDefaults.standard.integer(forKey: "task_twelve_preference")
        if (taskRow12 != emptyTask){
            mapping.append(taskRow12)
        }
        let taskRow13 = UserDefaults.standard.integer(forKey: "task_thirteen_preference")
        if (taskRow13 != emptyTask){
            mapping.append(taskRow13)
        }
        let taskRow14 = UserDefaults.standard.integer(forKey: "task_fourteen_preference")
        if (taskRow14 != emptyTask){
            mapping.append(taskRow14)
        }
        let taskRow15 = UserDefaults.standard.integer(forKey: "task_fifteen_preference")
        if (taskRow15 != emptyTask){
            mapping.append(taskRow15)
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
        guard let task5 = Tasks(label: NSLocalizedString("task_title_selfie", comment: ""), icon: UIImage(named: "Portrait")?.withRenderingMode(.alwaysTemplate)) else {
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
        // GoPro Remote Task
        guard let task11 = Tasks(label: NSLocalizedString("task_title_gopro", comment: ""), icon: UIImage(named: "Action-Camera")?.withRenderingMode(.alwaysTemplate)) else {
            fatalError("Unable to instantiate Settings Task")
        }
        // WeatherMap Task
        guard let task12 = Tasks(label: NSLocalizedString("task_title_weathermap", comment: ""), icon: UIImage(named: "CloudSun")?.withRenderingMode(.alwaysTemplate)) else {
            fatalError("Unable to instantiate Settings Task")
        }
        // Road Book Task
        guard let task13 = Tasks(label: NSLocalizedString("task_title_roadbook", comment: ""), icon: UIImage(named: "RoadBook")?.withRenderingMode(.alwaysTemplate)) else {
            fatalError("Unable to instantiate Settings Task")
        }
        // System Volume Task
        guard let task14 = Tasks(label: NSLocalizedString("task_title_systemvolume", comment: ""), icon: UIImage(named: "Speaker")?.withRenderingMode(.alwaysTemplate)) else {
            fatalError("Unable to instantiate Settings Task")
        }
        // Insta360 Remote Task
        guard let task15 = Tasks(label: NSLocalizedString("task_title_insta360", comment: ""), icon: UIImage(named: "Spherical-Camera")?.withRenderingMode(.alwaysTemplate)) else {
            fatalError("Unable to instantiate Settings Task")
        }
        //Empty
        guard let task16 = Tasks(label: NSLocalizedString("task_title_empty", comment: ""), icon: UIImage(named: "Cog")?.withRenderingMode(.alwaysTemplate)) else {
            fatalError("Unable to instantiate Settings Task")
        }
        // Front Camera Recording Task
        var frontRecLabel = NSLocalizedString("task_title_front_start_record", comment: "")
        if isRecording{
            frontRecLabel = NSLocalizedString("task_title_stop_record", comment: "")
        }
        guard let task17 = Tasks(label: frontRecLabel, icon: UIImage(named: "VideoCamera")?.withRenderingMode(.alwaysTemplate)) else {
            fatalError("Unable to instantiate Video Recording Task")
        }
        // Fuel Task
        guard let task18 = Tasks(label: NSLocalizedString("task_title_fuel", comment: ""), icon: UIImage(named: "Gas-pump")?.withRenderingMode(.alwaysTemplate)) else {
            fatalError("Unable to instantiate Settings Task")
        }
        // Active Faults
        guard let task19 = Tasks(label: NSLocalizedString("task_title_faults", comment: ""), icon: UIImage(named: "Alert")?.withRenderingMode(.alwaysTemplate)) else {
            fatalError("Unable to instantiate Settings Task")
        }
        self.tasks = [task0, task1, task2, task3, task4, task5, task6, task7, task8, task9, task10, task11, task12, task13, task14, task15, task16, task17, task18, task19]
    }
    
    private func execute_task(taskID:Int) {
        switch taskID {
        case 0:
            //Navigation
            NavAppHelper().open()
            break
        case 1:
            //Go Home
            if let homeAddress = UserDefaults.standard.string(forKey: "gohome_address_preference"){
                if homeAddress != "" {
                    let geocoder = CLGeocoder()
                    geocoder.geocodeAddressString(homeAddress,
                                                  completionHandler: { (placemarks, error) in
                                                    if error == nil {
                                                        let placemark = placemarks?.first
                                                        let lat = placemark?.location?.coordinate.latitude
                                                        let lon = placemark?.location?.coordinate.longitude
                                                        let destLatitude: CLLocationDegrees = lat!
                                                        let destLongitude: CLLocationDegrees = lon!
                                                        if let currentLocation = self.motorcycleData.getLocation() {
                                                            if (!NavAppHelper.navigateTo(destLatitude: destLatitude, destLongitude: destLongitude, destLabel: NSLocalizedString("home", comment: ""), currentLatitude: currentLocation.coordinate.latitude, currentLongitude: currentLocation.coordinate.longitude)){
                                                                self.showToast(message: NSLocalizedString("nav_app_feature_not_supported", comment: ""))
                                                            }
                                                        }
                                                        
                                                    }
                                                    else {
                                                        // An error occurred during geocoding.
                                                        self.showToast(message: NSLocalizedString("geocode_error", comment: ""))
                                                    }
                                                  })
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
                            UIApplication.shared.open(phoneCallURL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
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
            //Rear Video Recording
            if movieOutput.isRecording {
                stopRecording()
                isRecording = false
            } else {
                videoCaptureSession = AVCaptureSession()
                if setupSession(position: .back) {
                    startSession(orientation: currentVideoOrientation())
                    isRecording = true
                }
            }
            break
        case 7:
            //Trip Log
            let loggingStatus = UserDefaults.standard.string(forKey: "loggingStatus")
            if loggingStatus != nil {
                // Check for auto-trip logging
                if UserDefaults.standard.bool(forKey: "autotrip_enable_preference") {
                    self.showToast(message: NSLocalizedString("toast_auto_trip_logging", comment: ""))
                } else {
                    //Stop Logging
                    UserDefaults.standard.set(nil, forKey: "loggingStatus")
                }
            } else {
                //Start Logging
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyyMMdd-HH-mm-ss"
                let dateString = dateFormatter.string(from: Date())
                UserDefaults.standard.set(dateString, forKey: "loggingStatus")
            }
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
            //GoPro Remote
            let wlqGoProURL = "wunderlinqgp://"
            if let uRL = URL(string: wlqGoProURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                if (UIApplication.shared.canOpenURL(uRL)) {
                    UIApplication.shared.open(uRL, options: [:], completionHandler: nil)
                } else {
                    let alert = UIAlertController(title: NSLocalizedString("nogpremote_alert_title", comment: ""), message: NSLocalizedString("nogpremote_alert_body", comment: ""), preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("alert_message_exit_ok", comment: ""), style: UIAlertAction.Style.default, handler: { action in
                        if let url = URL(string: "itms-apps://itunes.apple.com/app/id1661727055") {
                            UIApplication.shared.open(url)
                        }
                    }))
                    alert.addAction(UIAlertAction(title: NSLocalizedString("negative_alert_btn_cancel", comment: ""), style: UIAlertAction.Style.cancel, handler: { action in }))
                    self.present(alert, animated: true, completion: nil)
                    
                }
            }
            break
        case 12:
            //Weather Map
            performSegue(withIdentifier: "taskGridToWeatherMap", sender: self)
            break
        case 13:
            //Road Book
            let roadbookAppValue = UserDefaults.standard.integer(forKey: "roadbook_app_preference")
            switch roadbookAppValue {
                case 0: //Rabbit Rally
                    let urlString = "rabbitrally://app?back_url=wunderlinq://app"
                    if let uRL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                        if (UIApplication.shared.canOpenURL(uRL)) {
                            UIApplication.shared.open(uRL, options: [:], completionHandler: nil)
                        }
                    }
                    break
                default:
                    break
            }
        case 14:
            //System Volume
            performSegue(withIdentifier: "taskGridToVolume", sender: self)
            break
        case 15:
            //Insta360 Remote
            let wlqInsta360URL = "wunderlinqi360://"
            if let uRL = URL(string: wlqInsta360URL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                if (UIApplication.shared.canOpenURL(uRL)) {
                    UIApplication.shared.open(uRL, options: [:], completionHandler: nil)
                } else {
                    let alert = UIAlertController(title: NSLocalizedString("no360remote_alert_title", comment: ""), message: NSLocalizedString("no360remote_alert_body", comment: ""), preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("alert_message_exit_ok", comment: ""), style: UIAlertAction.Style.default, handler: { action in
                        if let url = URL(string: "itms-apps://itunes.apple.com/app/id1671376660") {
                            UIApplication.shared.open(url)
                        }
                    }))
                    alert.addAction(UIAlertAction(title: NSLocalizedString("negative_alert_btn_cancel", comment: ""), style: UIAlertAction.Style.cancel, handler: { action in }))
                    self.present(alert, animated: true, completion: nil)
                    
                }
            }
            break
        case 17:
            //Front Video Recording
            if movieOutput.isRecording {
                stopRecording()
                isRecording = false
            } else {
                videoCaptureSession = AVCaptureSession()
                if setupSession(position: .front) {
                    startSession(orientation: currentVideoOrientation())
                    isRecording = true
                }
            }
            break
        case 18:
            //Fuel
            if let currentLocation = motorcycleData.getLocation() {
                if (!NavAppHelper.navigateToFuel(currentLatitude: currentLocation.coordinate.latitude, currentLongitude: currentLocation.coordinate.longitude)){
                    self.showToast(message: NSLocalizedString("nav_app_feature_not_supported", comment: ""))
                }
            }
            break
        case 19:
            //Active Faults
            performSegue(withIdentifier: "taskGridToFaults", sender: self)
            break
        default:
            NSLog("TasksCollectionViewController: Unknown Task")
        }
        loadTasks()
        self.collectionView!.reloadData()
    }
    
    override var keyCommands: [UIKeyCommand]? {
        let commands = [
            UIKeyCommand(input: "\u{d}", modifierFlags:[], action: #selector(selectItem)),
            UIKeyCommand(input: UIKeyCommand.inputUpArrow, modifierFlags:[], action: #selector(upRow)),
            UIKeyCommand(input: "+", modifierFlags:[], action: #selector(upRow)),
            UIKeyCommand(input: UIKeyCommand.inputDownArrow, modifierFlags:[], action: #selector(downRow)),
            UIKeyCommand(input: "-", modifierFlags:[], action: #selector(downRow)),
            UIKeyCommand(input: UIKeyCommand.inputLeftArrow, modifierFlags:[], action: #selector(leftScreen)),
            UIKeyCommand(input: UIKeyCommand.inputRightArrow, modifierFlags:[], action: #selector(rightScreen))
        ]
        if #available(iOS 15, *) {
            commands.forEach { $0.wantsPriorityOverSystemBehavior = true }
        }
        return commands
    }
    
    @objc func selectItem() {
        SoundManager().playSoundEffect("enter")
        execute_task(taskID: mapping[itemRow])
    }
    
    @objc func upRow() {
        SoundManager().playSoundEffect("directional")
        if (itemRow < mapping.count && itemRow >= 1){
            let nextRow = itemRow - 1
            itemRow = nextRow
            self.setOffset(itemRow: itemRow)
        }
    }
    
    @objc func downRow() {
        SoundManager().playSoundEffect("directional")
        if (itemRow < (mapping.count - 1)){
            let nextRow = itemRow + 1
            itemRow = nextRow
            self.setOffset(itemRow: itemRow)
        }
    }
    
    private func setOffset(itemRow: Int){
        //Scroll to the offset calculated
        UIView.animate(withDuration: 0.5, animations: {
            let itemIndex = IndexPath(item: itemRow, section: 0)
            if UIApplication.shared.statusBarOrientation.isLandscape {
                self.collectionView.scrollToItem(at: itemIndex, at: .centeredHorizontally, animated: true)
            } else {
                self.collectionView.scrollToItem(at: itemIndex, at: .centeredVertically, animated: true)
            }
            self.view.layoutIfNeeded()
        })
        self.collectionView!.reloadData()
    }
    
    @objc func onTouch(recognizer: UITapGestureRecognizer){
        DispatchQueue.main.async(){
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
        if isTimerRunning == false {
            runTimer()
        }
    }
    
    @objc func leftScreen() {
        SoundManager().playSoundEffect("directional")
        if UserDefaults.standard.bool(forKey: "display_music_preference"){
            performSegue(withIdentifier: "tasksToMusic", sender: [])
        } else if UserDefaults.standard.bool(forKey: "display_dashboard_preference"){
            performSegue(withIdentifier: "tasksToDash", sender: [])
        } else {
            navigationController?.popToRootViewController(animated: true)
        }
    }
    
    @objc func rightScreen() {
        SoundManager().playSoundEffect("directional")
        if (WLQ.initialized){
            if (wlqData.getStatus() != nil){
                let secondViewController = self.storyboard!.instantiateViewController(withIdentifier: "AccessoryViewController") as! AccessoryViewController
                if let viewControllers = self.navigationController?.viewControllers
                {
                    if viewControllers.contains(where: {
                        return $0 is AccessoryViewController
                    })
                    {
                        _ = navigationController?.popViewController(animated: true)
                        return
                        
                    } else {
                        self.navigationController!.pushViewController(secondViewController, animated: true)
                        return
                    }
                }
            }
        }
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func forward(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "unwindToContainerVC", sender: self)
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizer.Direction.right {
            leftScreen()
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.left {
            rightScreen()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserDefaults.standard.bool(forKey: "display_brightness_preference") {
            UIScreen.main.brightness = CGFloat(1.0)
        } else {
            UIScreen.main.brightness = CGFloat(UserDefaults.standard.float(forKey: "systemBrightness"))
        }
        
        let backBtn = UIButton()
        backBtn.setImage(UIImage(named: "Left")?.withRenderingMode(.alwaysTemplate), for: .normal)
        backBtn.tintColor = UIColor(named: "imageTint")
        backBtn.addTarget(self, action: #selector(leftScreen), for: .touchUpInside)
        let backButton = UIBarButtonItem(customView: backBtn)
        let backButtonWidth = backButton.customView?.widthAnchor.constraint(equalToConstant: 30)
        backButtonWidth?.isActive = true
        let backButtonHeight = backButton.customView?.heightAnchor.constraint(equalToConstant: 30)
        backButtonHeight?.isActive = true
        
        let forwardBtn = UIButton()
        forwardBtn.setImage(UIImage(named: "Right")?.withRenderingMode(.alwaysTemplate), for: .normal)
        forwardBtn.tintColor = UIColor(named: "imageTint")
        forwardBtn.addTarget(self, action: #selector(rightScreen), for: .touchUpInside)
        let forwardButton = UIBarButtonItem(customView: forwardBtn)
        let forwardButtonWidth = forwardButton.customView?.widthAnchor.constraint(equalToConstant: 30)
        forwardButtonWidth?.isActive = true
        let forwardButtonHeight = forwardButton.customView?.heightAnchor.constraint(equalToConstant: 30)
        forwardButtonHeight?.isActive = true
        faultsBtn = UIButton(type: .custom)
        let faultsImage = UIImage(named: "Alert")?.withRenderingMode(.alwaysTemplate)
        faultsBtn.setImage(faultsImage, for: .normal)
        faultsBtn.tintColor = UIColor.clear
        faultsBtn.accessibilityIgnoresInvertColors = true
        faultsBtn.addTarget(self, action: #selector(self.faultsButtonTapped), for: .touchUpInside)
        faultsButton = UIBarButtonItem(customView: faultsBtn)
        faultsButton.accessibilityRespondsToUserInteraction = false
        faultsButton.isAccessibilityElement = false
        let faultsButtonWidth = faultsButton.customView?.widthAnchor.constraint(equalToConstant: 30)
        faultsButtonWidth?.isActive = true
        let faultsButtonHeight = faultsButton.customView?.heightAnchor.constraint(equalToConstant: 30)
        faultsButtonHeight?.isActive = true
        // Update Buttons
        if (faults.getallActiveDesc().isEmpty){
            faultsBtn.tintColor = UIColor.clear
            faultsButton.isEnabled = false
        } else {
            faultsBtn.tintColor = UIColor.red
            faultsButton.isEnabled = true
        }
        self.navigationItem.title = NSLocalizedString("quicktask_title", comment: "")
        self.navigationItem.leftBarButtonItems = [backButton, faultsButton]
        self.navigationItem.rightBarButtonItems = [forwardButton]
        
        self.collectionView.collectionViewLayout = flowLayout
        self.collectionView.allowsMultipleSelection = true
        self.collectionView.contentInsetAdjustmentBehavior = .always
        let touchRecognizer = UITapGestureRecognizer(target: self, action:  #selector(onTouch))
        touchRecognizer.cancelsTouchesInView = false
        self.collectionView.isUserInteractionEnabled = true
        self.collectionView.addGestureRecognizer(touchRecognizer)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeLeft.direction = .left
        self.collectionView.addGestureRecognizer(swipeLeft)
            
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.collectionView.addGestureRecognizer(swipeRight)
        
        if UserDefaults.standard.bool(forKey: "display_brightness_preference") {
            UIScreen.main.brightness = CGFloat(1.0)
        } else {
            UIScreen.main.brightness = CGFloat(UserDefaults.standard.float(forKey: "systemBrightness"))
        }
        
        loadTasks();
        loadRows();
        
        // Waypoint Database
        let databaseURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("waypoints.sqlite")
        // Opening the database
        if sqlite3_open(databaseURL.path, &db) != SQLITE_OK {
            NSLog("TasksCollectionViewController: error opening database")
        }
        // Creating table
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS records (id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT, latitude TEXT, longitude TEXT, elevation TEXT, label TEXT)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            NSLog("TasksCollectionViewController: error creating table: \(errmsg)")
        }
        // Update table if needed
        let updateStatementString = "ALTER TABLE records ADD COLUMN elevation TEXT"
        var updateStatement: OpaquePointer?
        if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                NSLog("TasksCollectionViewController: Table updated successfully")
            } else {
                NSLog("TasksCollectionViewController: Error updating table")
            }
        } else {
            NSLog("TasksCollectionViewController: Error preparing update statement")
        }
        
        updateDisplay()
        
        notificationCenter.addObserver(self, selector:#selector(self.launchAccPage), name: NSNotification.Name("StatusUpdate"), object: nil)
    }
    
    private func setupScreenOrientation() {
        self.collectionView.transform = CGAffineTransform.identity
        switch (currentVideoOrientation()){
        case .portrait:
            if let layout = self.collectionView.collectionViewLayout as? ZoomAndSnapFlowLayout {
                layout.scrollDirection = .vertical
            }
        case .portraitUpsideDown:
            if let layout = self.collectionView.collectionViewLayout as? ZoomAndSnapFlowLayout {
                layout.scrollDirection = .vertical
            }
        case .landscapeLeft:
            if let layout = self.collectionView.collectionViewLayout as? ZoomAndSnapFlowLayout {
                layout.scrollDirection = .horizontal
            }
        case .landscapeRight:
            if let layout = self.collectionView.collectionViewLayout as? ZoomAndSnapFlowLayout {
                layout.scrollDirection = .horizontal
            }
        default:
            if let layout = self.collectionView.collectionViewLayout as? ZoomAndSnapFlowLayout {
                layout.scrollDirection = .horizontal
            }
        }
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        NSLog("TasksCollectionViewController: viewWillTransition")
        self.loadTasks()
        coordinator.animate(alongsideTransition: nil) { _ in
            self.setupScreenOrientation()
            self.collectionView!.reloadData()
            self.setOffset(itemRow: self.itemRow)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NSLog("TasksCollectionViewController: viewWillAppear")
        if isTimerRunning == false {
            runTimer()
        }
        setupScreenOrientation()
        self.collectionView!.reloadData()
        self.setOffset(itemRow: self.itemRow)
        updateDisplay()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        timer.invalidate()
        seconds = 0
        // Show the navigation bar on other view controllers
        DispatchQueue.main.async(){
            self.navigationController?.setNavigationBarHidden(false, animated: animated)
        }
        notificationCenter.removeObserver(self, name: NSNotification.Name("StatusUpdate"), object: nil)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }

    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mapping.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TaskCollectionViewCell", for: indexPath) as! TaskCollectionViewCell
        // Configure the cell
        if (indexPath.row < self.tasks.count ){
            let tasks = self.tasks[mapping[indexPath.row]]
            cell.displayContent(icon: tasks.icon!,label: tasks.label)
            if (itemRow == indexPath.row){
                cell.highlightEffect()
            } else {
                cell.removeHighlight()
            }
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        itemRow = indexPath.row
        DispatchQueue.main.async(){
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
        if isTimerRunning == false {
            runTimer()
        }
        execute_task(taskID: mapping[indexPath.row])
    }
    
    // MARK: - Updating UI
    func updateDisplay() {
        // Update Buttons
        if (faults.getallActiveDesc().isEmpty){
            faultsBtn.tintColor = UIColor.clear
            faultsButton.isEnabled = false
        } else {
            faultsBtn.tintColor = UIColor(named: "motorrad_red")
            faultsButton.isEnabled = true
        }
    }
    
    func saveWaypoint(){
        // Waypoint stuff below
        if let currentLocation = motorcycleData.getLocation() {
            // Waypoint Database
            let databaseURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                .appendingPathComponent("waypoints.sqlite")
            // Opening the database
            if sqlite3_open(databaseURL.path, &db) != SQLITE_OK {
                NSLog("TasksCollectionViewController: error opening database")
            }
            
            // Creating a statement
            var stmt: OpaquePointer?
            
            //the insert query
            let queryString = "INSERT INTO records (date, latitude, longitude, elevation, label) VALUES (?,?,?,?,?)"
            
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                NSLog("TasksCollectionViewController: error preparing insert: \(errmsg)")
                return
            }
            
            let date = Date().toString() as NSString
            let label : String = ""
            
            if sqlite3_bind_text(stmt, 1, date.utf8String, -1, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                NSLog("TasksCollectionViewController: failure binding name: \(errmsg)")
                return
            }
            if sqlite3_bind_double(stmt, 2, (currentLocation.coordinate.latitude)) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                NSLog("TasksCollectionViewController: failure binding name: \(errmsg)")
                return
            }
            if sqlite3_bind_double(stmt, 3, (currentLocation.coordinate.longitude)) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                NSLog("TasksCollectionViewController: failure binding name: \(errmsg)")
                return
            }
            if sqlite3_bind_double(stmt, 4, (currentLocation.altitude)) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                NSLog("TasksCollectionViewController: failure binding name: \(errmsg)")
                return
            }
            if sqlite3_bind_text(stmt, 5, label, -1, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                NSLog("TasksCollectionViewController: failure binding name: \(errmsg)")
                return
            }
            
            //executing the query to insert values
            if sqlite3_step(stmt) != SQLITE_DONE {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                NSLog("TasksCollectionViewController: failure inserting wapoint: \(errmsg)")
                return
            }
            self.showToast(message: NSLocalizedString("toast_waypoint_saved", comment: ""))
        }
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
        connection?.videoOrientation = AVCaptureVideoOrientation(rawValue: UIApplication.shared.statusBarOrientation.rawValue)!
        
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
            NSLog("TasksCollectionViewController: No Image")
        } else {
            addAsset(image: cameraImage!, location: motorcycleData.getLocation())
        }
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
                NSLog("TasksCollectionViewController: Picture not Saved, error")
            } else {
                NSLog("TasksCollectionViewController: Picture Saved")
                if (UserDefaults.standard.bool(forKey: "photo_preview_enable_preference")){
                    DispatchQueue.main.async(){
                        [unowned self] in
                        self.performSegue(withIdentifier: "tasksToAlert", sender: [])
                    }
                }
            }
        })
    }
    
    //MARK:- Setup Camera
    func setupSession(position: AVCaptureDevice.Position) -> Bool {
        videoCaptureSession.sessionPreset = AVCaptureSession.Preset(rawValue: convertFromAVCaptureSessionPreset(AVCaptureSession.Preset.high))
        // Setup Camera
        if let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position) {
            do {
                let input = try AVCaptureDeviceInput(device: camera)
                if videoCaptureSession.canAddInput(input) {
                    videoCaptureSession.addInput(input)
                    activeInput = input
                }
            } catch {
                NSLog("TasksCollectionViewController: Error setting device video input: \(error)")
                return false
            }
        }
        else {
            NSLog("TasksCollectionViewController: Front camera not available")
        }
        
        // Setup Microphone
        let microphone = AVCaptureDevice.default(for: AVMediaType(rawValue: convertFromAVMediaType(AVMediaType.audio)))
        
        do {
            let micInput = try AVCaptureDeviceInput(device: microphone!)
            if videoCaptureSession.canAddInput(micInput) {
                videoCaptureSession.addInput(micInput)
            }
        } catch {
            NSLog("TasksCollectionViewController: Error setting device audio input: \(error)")
            return false
        }
        
        // Movie output
        if videoCaptureSession.canAddOutput(movieOutput) {
            videoCaptureSession.addOutput(movieOutput)
        }
        
        return true
    }
    
    //MARK:- Camera Session
    func startSession(orientation: AVCaptureVideoOrientation) {
        NSLog("TasksCollectionViewController: startSession()")
        if !videoCaptureSession.isRunning {
            videoQueue().async { [self] in
                self.videoCaptureSession.startRunning()
                self.startCapture(orientation: orientation)
                isRecording = true
            }
        }
    }
    
    func stopSession() {
        NSLog("TasksCollectionViewController: stopSession()")
        if videoCaptureSession.isRunning {
            videoQueue().async {
                self.videoCaptureSession.stopRunning()
            }
        }
    }
    
    func videoQueue() -> DispatchQueue {
        return DispatchQueue.global(qos: .userInitiated)
    }
    
    func currentVideoOrientation() -> AVCaptureVideoOrientation {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return AVCaptureVideoOrientation.landscapeRight
        }

        let interfaceOrientation = windowScene.interfaceOrientation
        var orientation: AVCaptureVideoOrientation
        switch interfaceOrientation {
        case .portrait:
            orientation = AVCaptureVideoOrientation.portrait
        case .portraitUpsideDown:
            orientation = AVCaptureVideoOrientation.portraitUpsideDown
        case .landscapeLeft:
            orientation = AVCaptureVideoOrientation.landscapeLeft
        case .landscapeRight:
            orientation = AVCaptureVideoOrientation.landscapeRight
        default:
            orientation = AVCaptureVideoOrientation.landscapeRight
        }
        
        return orientation
    }
    
    func startCapture(orientation: AVCaptureVideoOrientation) {
        NSLog("TasksCollectionViewController: startCapture()")
        startRecording(orientation: orientation)
    }
    
    func tempURL() -> URL? {
        let directory = NSTemporaryDirectory() as NSString
        if directory != "" {
            let path = directory.appendingPathComponent(NSUUID().uuidString + ".mp4")
            return URL(fileURLWithPath: path)
        }
        return nil
    }
    
    func startRecording(orientation: AVCaptureVideoOrientation) {
        NSLog("TasksCollectionViewController: startRecording()")
        if movieOutput.isRecording == false {
            let connection = movieOutput.connection(with: AVMediaType(rawValue: convertFromAVMediaType(AVMediaType.video)))
            if (connection?.isVideoOrientationSupported)! {
                connection?.videoOrientation = orientation
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
                    NSLog("TasksCollectionViewController: Error setting configuration: \(error)")
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
        NSLog("TasksCollectionViewController: stopRecording()")
        if movieOutput.isRecording == true {
            videoQueue().async {
                self.movieOutput.stopRecording()
            }
        }
    }
    
    func fileOutput(_ captureOutput: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        
    }
    
    func fileOutput(_ captureOutput: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if (error != nil) {
            NSLog("TasksCollectionViewController: Error recording movie: \(error!.localizedDescription)")
        } else {
            let fileURL = outputURL as URL
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: fileURL as URL)
            }) { saved, error in
                if saved {
                    // the alert view
                    let alert = UIAlertController(title: "", message: "Video Saved", preferredStyle: .alert)
                    DispatchQueue.main.sync {
                        self.present(alert, animated: false, completion: nil)
                    }
                    
                    // change to desired number of seconds (in this case 2 seconds)
                    let when = DispatchTime.now() + 3
                    DispatchQueue.main.asyncAfter(deadline: when){
                        // your code with delay
                        alert.dismiss(animated: false, completion: nil)
                    }
                } else {
                    NSLog("TasksCollectionViewController: In capture didfinish, didn't save")
                }
            }
            
        }
        stopSession()
        outputURL = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navigationController = segue.destination as? UINavigationController,
            let alertViewController = navigationController.viewControllers.first as? AlertViewController {
            alertViewController.ID = 2
            alertViewController.PHOTO = cameraImage
        }
    }
    
    func runTimer() {
        if UserDefaults.standard.bool(forKey: "hide_navbar_preference") {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
            isTimerRunning = true
        }
    }
    
    @objc func updateTimer() {
        if seconds < 1 {
            timer.invalidate()
            isTimerRunning = false
            seconds = 10
            // Hide the navigation bar on the this view controller
            DispatchQueue.main.async(){
                self.navigationController?.setNavigationBarHidden(true, animated: true)
                self.navigationController?.navigationBar.setNeedsLayout()
            }
        } else {
            seconds -= 1
        }
    }
    
    @objc func launchAccPage(){
        if self.viewIfLoaded?.window != nil {
            let secondViewController = self.storyboard!.instantiateViewController(withIdentifier: "AccessoryViewController") as! AccessoryViewController
            self.navigationController!.pushViewController(secondViewController, animated: true)
        }
    }
    
    @objc func faultsButtonTapped() {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "FaultsTableViewController") as! FaultsTableViewController
        self.navigationController?.pushViewController(viewController, animated: true)
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
