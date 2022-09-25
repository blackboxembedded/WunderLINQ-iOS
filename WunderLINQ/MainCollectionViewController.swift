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

import AVFoundation
import Contacts
import CoreBluetooth
import CoreLocation
import CoreMotion
import MediaPlayer
import Photos
import UIKit
import UserNotifications
import CommonCrypto
import InAppSettingsKit 

private let reuseIdentifier = "MainCollectionViewCell"

class MainCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, CBCentralManagerDelegate, CBPeripheralDelegate, UNUserNotificationCenterDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var mainUIView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let altimeter = CMAltimeter()
    
    var backBtn: UIButton!
    var backButton: UIBarButtonItem!
    var disconnectBtn: UIButton!
    var disconnectButton: UIBarButtonItem!
    var faultsBtn: UIButton!
    var faultsButton: UIBarButtonItem!
    var menuBtn: UIButton!
    var menuButton: UIBarButtonItem!
    
    var centralManager:CBCentralManager!
    var wunderLINQ:CBPeripheral?
    var hwRevCharacteristic:CBCharacteristic?
    var messageCharacteristic:CBCharacteristic?
    var commandCharacteristic:CBCharacteristic?
    var numServices:Int = 0
    var numServicesChecked:Int = 0
    
    let deviceName = "WunderLINQ"
    
    var hardwareVersion:String = ""
    
    // define our scanning interval times
    let timerPauseInterval:TimeInterval = 5
    let timerScanInterval:TimeInterval = 2
    
    var keepScanning = false
    
    var lastMessage = [UInt8]()
    
    //let wlqData = WLQ_OLD.shared
    var wlqData: WLQ!
    let bleData = BLE.shared
    let motorcycleData = MotorcycleData.shared
    let faults = Faults.shared
    var prevBrakeValue = 0
    
    let motionManager = CMMotionManager()
    var referenceAttitude: CMAttitude?
    
    var menuSelected = 0
    fileprivate var popoverMenuList = [NSLocalizedString("bike_info_label", comment: ""),NSLocalizedString("geodata_label", comment: ""),NSLocalizedString("appsettings_label", comment: ""), NSLocalizedString("about_label", comment: ""), NSLocalizedString("close_label", comment: "")]
    fileprivate var popover: Popover!
    fileprivate var popoverOptions: [PopoverOption] = [
        .type(.auto),
        .color(UIColor(named: "backgrounds")!),
        .blackOverlayColor(UIColor(white: 0.0, alpha: 0.6))
    ]
    
    var seconds = 10
    var timer = Timer()
    var timeTimer = Timer()
    var isTimerRunning = false
    
    let inset: CGFloat = 5
    let minimumLineSpacing: CGFloat = 5
    let minimumInteritemSpacing: CGFloat = 6
    var cellsPerRow = 5
    var rowCount = 3
    var selectedCell = 0
    var selectedDataPoint = 0
    var dataPointList:[String] = [NSLocalizedString("gear_header", comment: ""),
                         NSLocalizedString("enginetemp_header", comment: ""),
                         NSLocalizedString("ambienttemp_header", comment: ""),
                         NSLocalizedString("frontpressure_header", comment: ""),
                         NSLocalizedString("rearpressure_header", comment: ""),
                         NSLocalizedString("odometer_header", comment: ""),
                         NSLocalizedString("voltage_header", comment: ""),
                         NSLocalizedString("throttle_header", comment: ""),
                         NSLocalizedString("frontbrakes_header", comment: ""),
                         NSLocalizedString("rearbrakes_header", comment: ""),
                         NSLocalizedString("ambientlight_header", comment: ""),
                         NSLocalizedString("tripone_header", comment: ""),
                         NSLocalizedString("triptwo_header", comment: ""),
                         NSLocalizedString("tripauto_header", comment: ""),
                         NSLocalizedString("speed_header", comment: ""),
                         NSLocalizedString("avgspeed_header", comment: ""),
                         NSLocalizedString("cconsumption_header", comment: ""),
                         NSLocalizedString("fueleconomyone_header", comment: ""),
                         NSLocalizedString("fueleconomytwo_header", comment: ""),
                         NSLocalizedString("fuelrange_header", comment: ""),
                         NSLocalizedString("shifts_header", comment: ""),
                         NSLocalizedString("leanangle_header", comment: ""),
                         NSLocalizedString("gforce_header", comment: ""),
                         NSLocalizedString("bearing_header", comment: ""),
                         NSLocalizedString("time_header", comment: ""),
                         NSLocalizedString("barometric_header", comment: ""),
                         NSLocalizedString("gpsspeed_header", comment: ""),
                         NSLocalizedString("altitude_header", comment: ""),
                         NSLocalizedString("sunrisesunset_header", comment: ""),
                         NSLocalizedString("rpm_header", comment: ""),
                         NSLocalizedString("leanangle_bike_header", comment: ""),
                         NSLocalizedString("rearwheel_speed_header", comment: "")
    ]
    
    let locationDelegate = LocationDelegate()
    var latestLocation: CLLocation? = nil
    var yourLocationBearing: CGFloat { return latestLocation?.bearingToLocationRadian(self.yourLocation) ?? 0 }
    var yourLocation: CLLocation {
        get { return UserDefaults.standard.currentLocation }
        set { UserDefaults.standard.currentLocation = newValue }
    }

    let locationManager: CLLocationManager = {
        $0.requestAlwaysAuthorization()
        $0.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        $0.activityType = .automotiveNavigation
        $0.allowsBackgroundLocationUpdates = true
        $0.pausesLocationUpdatesAutomatically = false
        $0.startUpdatingLocation()
        $0.startUpdatingHeading()
        return $0
    }(CLLocationManager())
    
    private func orientationAdjustment() -> CGFloat {
        let isFaceDown: Bool = {
            switch UIDevice.current.orientation {
            case .faceDown: return true
            default: return false
            }
        }()
        
        let adjAngle: CGFloat = {
            switch UIApplication.shared.statusBarOrientation {
            case .landscapeLeft:
                return 90
            case .landscapeRight:
                return -90
            case .portrait, .unknown: return 0
            case .portraitUpsideDown: return isFaceDown ? 180 : -180
            default:
                return 0
            }
        }()
        return adjAngle
    }

    override var preferredStatusBarStyle : UIStatusBarStyle {
        switch(UserDefaults.standard.integer(forKey: "darkmode_preference")){
        case 0:
            //OFF
            if(self.navigationController?.isToolbarHidden ?? false){
                return .lightContent
            } else {
                return .default
            }
        case 1:
            //On
            if(self.navigationController?.isToolbarHidden ?? false){
                return .default
            } else {
                return .lightContent
            }
        default:
            //Default
            if #available(iOS 13.0, *) {
                if traitCollection.userInterfaceStyle == .light {
                    //OFF
                    if(self.navigationController?.isToolbarHidden ?? false){
                        return .lightContent
                    } else {
                        return .darkContent
                    }
                } else {
                    //On
                    if(self.navigationController?.isToolbarHidden ?? false){
                        return .darkContent
                    } else {
                        return .lightContent
                    }
                }
            } else {
                if(self.navigationController?.isToolbarHidden ?? false){
                    return .lightContent
                } else {
                    return .default
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NSLog("IN MainCollectionViewController viewWillAppear")
        super.viewWillAppear(animated)
        referenceAttitude = nil
        if isTimerRunning == false {
            runTimer()
        }
        if (wlqData != nil){
            let writeData =  Data(_: wlqData.GET_CONFIG_CMD())
            if ( self.wunderLINQ != nil && self.commandCharacteristic != nil){
                self.wunderLINQ!.writeValue(writeData, for: self.commandCharacteristic!, type: CBCharacteristicWriteType.withResponse)
                self.wunderLINQ!.readValue(for: self.commandCharacteristic!)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        NSLog("IN MainCollectionViewController viewDidLayoutSubviews")
        super.viewDidLayoutSubviews()
        updateCollectionViewLayout(with: self.view.frame.size)
    }

    override func viewDidLoad() {
        NSLog("IN MainCollectionViewController viewDidLoad()")
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        registerSettingsBundle()
        NotificationCenter.default.addObserver(self, selector: #selector(self.defaultsChanged), name: UserDefaults.didChangeNotification, object: nil)
        
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
        
        if UserDefaults.standard.bool(forKey: "display_brightness_preference") {
            UIScreen.main.brightness = CGFloat(1.0)
        } else {
            UIScreen.main.brightness = CGFloat(UserDefaults.standard.float(forKey: "systemBrightness"))
        }
        
        //centralManager = CBCentralManager(delegate: self, queue: nil)
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionRestoreIdentifierKey: "com.blackboxembedded.wunderlinq"])
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeUp.direction = .up
        self.view.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(MainCollectionViewController.longPress(longPressGestureRecognizer:)))
        self.view.addGestureRecognizer(longPressRecognizer)
        
        let touchRecognizer = UITapGestureRecognizer(target: self, action:  #selector(MainCollectionViewController.onTouch))
        self.view.addGestureRecognizer(touchRecognizer)
        
        // Setup Buttons
        backBtn = UIButton()
        backBtn.setImage(UIImage(named: "Left")?.withRenderingMode(.alwaysTemplate), for: .normal)
        if #available(iOS 13.0, *) {
            backBtn.tintColor = UIColor(named: "imageTint")
        }
        backBtn.addTarget(self, action: #selector(leftScreen), for: .touchUpInside)
        backButton = UIBarButtonItem(customView: backBtn)
        let backButtonWidth = backButton.customView?.widthAnchor.constraint(equalToConstant: 30)
        backButtonWidth?.isActive = true
        let backButtonHeight = backButton.customView?.heightAnchor.constraint(equalToConstant: 30)
        backButtonHeight?.isActive = true
        
        disconnectBtn = UIButton(type: .custom)
        let disconnectImage = UIImage(named: "Bluetooth")?.withRenderingMode(.alwaysTemplate)
        disconnectBtn.setImage(disconnectImage, for: .normal)
        disconnectBtn.tintColor = UIColor.red
        if #available(iOS 11.0, *) {
            disconnectBtn.accessibilityIgnoresInvertColors = true
        }
        disconnectBtn.addTarget(self, action: #selector(btButtonTapped), for: .touchUpInside)
        disconnectButton = UIBarButtonItem(customView: disconnectBtn)
        let disconnectButtonWidth = disconnectButton.customView?.widthAnchor.constraint(equalToConstant: 30)
        disconnectButtonWidth?.isActive = true
        let disconnectButtonHeight = disconnectButton.customView?.heightAnchor.constraint(equalToConstant: 30)
        disconnectButtonHeight?.isActive = true
        
        faultsBtn = UIButton(type: .custom)
        let faultsImage = UIImage(named: "Alert")?.withRenderingMode(.alwaysTemplate)
        faultsBtn.setImage(faultsImage, for: .normal)
        faultsBtn.tintColor = UIColor.clear
        if #available(iOS 11.0, *) {
            faultsBtn.accessibilityIgnoresInvertColors = true
        }
        faultsBtn.addTarget(self, action: #selector(self.faultsButtonTapped), for: .touchUpInside)
        faultsButton = UIBarButtonItem(customView: faultsBtn)
        let faultsButtonWidth = faultsButton.customView?.widthAnchor.constraint(equalToConstant: 30)
        faultsButtonWidth?.isActive = true
        let faultsButtonHeight = faultsButton.customView?.heightAnchor.constraint(equalToConstant: 30)
        faultsButtonHeight?.isActive = true
        faultsButton.isEnabled = false
        
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
        
        let forwardBtn = UIButton()
        forwardBtn.setImage(UIImage(named: "Right")?.withRenderingMode(.alwaysTemplate), for: .normal)
        if #available(iOS 13.0, *) {
            forwardBtn.tintColor = UIColor(named: "imageTint")
        }
        forwardBtn.addTarget(self, action: #selector(rightScreen), for: .touchUpInside)
        let forwardButton = UIBarButtonItem(customView: forwardBtn)
        let forwardButtonWidth = forwardButton.customView?.widthAnchor.constraint(equalToConstant: 30)
        forwardButtonWidth?.isActive = true
        let forwardButtonHeight = forwardButton.customView?.heightAnchor.constraint(equalToConstant: 30)
        forwardButtonHeight?.isActive = true
        
        self.navigationItem.title = NSLocalizedString("main_title", comment: "")
        self.navigationItem.leftBarButtonItems = [backButton, disconnectButton, faultsButton]
        self.navigationItem.rightBarButtonItems = [forwardButton, menuButton]
        
        let dateFormat = "yyyyMMdd"
        var dateFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateFormat = dateFormat
            formatter.locale = Locale.current
            formatter.timeZone = TimeZone.current
            return formatter
        }
        let today = dateFormatter.string(from: Date())
        let launchedLast = UserDefaults.standard.string(forKey: "launchedLast")
        if launchedLast != nil {
            if (launchedLast!.contains(today)) {
            } else {
                let alert = UIAlertController(title: NSLocalizedString("disclaimer_alert_title", comment: ""), message: NSLocalizedString("disclaimer_alert_body", comment: ""), preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("disclaimer_ok", comment: ""), style: UIAlertAction.Style.default, handler: { action in
                    UserDefaults.standard.set(today, forKey: "launchedLast")
                }))
                alert.addAction(UIAlertAction(title: NSLocalizedString("disclaimer_quit", comment: ""), style: UIAlertAction.Style.cancel, handler: { action in
                    // quit app
                    exit(0)
                }))
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            let alert = UIAlertController(title: NSLocalizedString("disclaimer_alert_title", comment: ""), message: NSLocalizedString("disclaimer_alert_body", comment: ""), preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("disclaimer_ok", comment: ""), style: UIAlertAction.Style.default, handler: { action in
                UserDefaults.standard.set(today, forKey: "launchedLast")
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("disclaimer_quit", comment: ""), style: UIAlertAction.Style.cancel, handler: { action in
                // quit app
                exit(0)
            }))
            self.present(alert, animated: true, completion: nil)
        }
        let cellCount = UserDefaults.standard.integer(forKey: "GRIDCOUNT")
        if ( self.view.bounds.width > self.view.bounds.height){
            switch (cellCount){
            case 1:
                cellsPerRow = 1
                rowCount = 1
            case 2:
                cellsPerRow = 2
                rowCount = 1
            case 4:
                cellsPerRow = 2
                rowCount = 2
            case 8:
                cellsPerRow = 4
                rowCount = 2
            case 10:
                cellsPerRow = 5
                rowCount = 2
            case 12:
                cellsPerRow = 4
                rowCount = 3
            case 15:
                cellsPerRow = 5
                rowCount = 3
            default:
                cellsPerRow = 5
                rowCount = 3
                UserDefaults.standard.set(15, forKey: "GRIDCOUNT")
            }
        } else {
            switch (cellCount){
            case 1:
                cellsPerRow = 1
                rowCount = 1
            case 2:
                cellsPerRow = 1
                rowCount = 2
            case 4:
                cellsPerRow = 1
                rowCount = 4
            case 8:
                cellsPerRow = 2
                rowCount = 4
            case 10:
                cellsPerRow = 2
                rowCount = 5
            case 12:
                cellsPerRow = 3
                rowCount = 4
            case 15:
                cellsPerRow = 3
                rowCount = 5
            default:
                cellsPerRow = 3
                rowCount = 5
                UserDefaults.standard.set(15, forKey: "GRIDCOUNT")
            }
        }
        if #available(iOS 11.0, *) {
            collectionView?.contentInsetAdjustmentBehavior = .always
        } else {
            // Fallback on earlier versions
        }
        
        if motionManager.isDeviceMotionAvailable {
            //do something interesting
            print("Motion Device Available")
        }
        motionManager.startDeviceMotionUpdates()
        motionManager.deviceMotionUpdateInterval = 1.0 / 50.0
        
        referenceAttitude = nil
        
        locationManager.delegate = locationDelegate
        
        locationDelegate.locationCallback = { location in
            self.latestLocation = location
        }
        
        locationDelegate.headingCallback = { newHeading in
            
            func computeNewAngle(with newAngle: CGFloat) -> CGFloat {
                let heading: CGFloat = {
                    let originalHeading = self.yourLocationBearing - newAngle.degreesToRadians
                    switch UIDevice.current.orientation {
                    case .faceDown: return -originalHeading
                    default: return originalHeading
                    }
                }()
                
                return CGFloat(self.orientationAdjustment().degreesToRadians + heading)
            }
            let angle = computeNewAngle(with: CGFloat(newHeading.trueHeading))
            
            var fixedHeading = abs(angle.radiansToDegrees)
            if fixedHeading > 360 {
                fixedHeading = fixedHeading - 360
            } else if fixedHeading < 0 {
                fixedHeading = fixedHeading + 360
            }
            
            let degrees = abs(Int(fixedHeading))
            //print("degrees: \(degrees) fixedHeading: \(fixedHeading)) newHeading: \(newHeading) angle(degrees): \(angle.radiansToDegrees) ")
            if (!UserDefaults.standard.bool(forKey: "bearing_override_preference")){
                self.motorcycleData.setbearing(bearing: degrees)
            }
        }
        
        updateTimeTimer()
        
        if CMAltimeter.isRelativeAltitudeAvailable() {
            altimeter.startRelativeAltitudeUpdates(to: OperationQueue.main) { (data, error) in
                let pressure:Double = (data?.pressure as? Double)! * 10.0
                self.motorcycleData.setBarometricPressure(barometricPressure: pressure)
            }
        }
        updateMessageDisplay()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        NSLog("IN MainCollectionViewController viewWillTransition")
        super.viewWillTransition(to: size, with: coordinator)
        referenceAttitude = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NSLog("IN MainCollectionViewController viewWillDisappear")
        super.viewWillDisappear(animated)
        
        timer.invalidate()
        seconds = 0
        // Show the navigation bar on other view controllers
        DispatchQueue.main.async(){
            self.navigationController?.setNavigationBarHidden(false, animated: animated)
        }
    }
    
    private func updateCollectionViewLayout(with size: CGSize) {
        NSLog("IN MainCollectionViewController updateCollectionViewLayout")
        if (collectionView != nil){
            if let layout = collectionView!.collectionViewLayout as? UICollectionViewFlowLayout {
                var cellCount = UserDefaults.standard.integer(forKey: "GRIDCOUNT");
                var height:CGFloat
                var width:CGFloat
                var widthMarginsAndInsets:CGFloat
                var heightMarginsAndInsets:CGFloat
                
                if ( collectionView!.bounds.width > collectionView!.bounds.height){
                    switch (cellCount){
                        case 1:
                            cellsPerRow = 1
                            rowCount = 1
                        case 2:
                            cellsPerRow = 2
                            rowCount = 1
                        case 4:
                            cellsPerRow = 2
                            rowCount = 2
                        case 8:
                            cellsPerRow = 4
                            rowCount = 2
                        case 10:
                            cellsPerRow = 5
                            rowCount = 2
                        case 12:
                            cellsPerRow = 4
                            rowCount = 3
                        case 15:
                            cellsPerRow = 5
                            rowCount = 3
                        default:
                            cellsPerRow = 5
                            rowCount = 3
                            UserDefaults.standard.set(15, forKey: "GRIDCOUNT")
                        }
                    } else {
                        switch (cellCount){
                        case 1:
                            cellsPerRow = 1
                            rowCount = 1
                        case 2:
                            cellsPerRow = 1
                            rowCount = 2
                        case 4:
                            cellsPerRow = 1
                            rowCount = 4
                        case 8:
                            cellsPerRow = 2
                            rowCount = 4
                        case 10:
                            cellsPerRow = 2
                            rowCount = 5
                        case 12:
                            cellsPerRow = 3
                            rowCount = 4
                        case 15:
                            cellsPerRow = 3
                            rowCount = 5
                        default:
                            cellsPerRow = 3
                            rowCount = 5
                            UserDefaults.standard.set(15, forKey: "GRIDCOUNT")
                        }
                }

                if #available(iOS 11.0, *) {
                    widthMarginsAndInsets = inset * 2 + collectionView!.safeAreaInsets.left + collectionView!.safeAreaInsets.right + minimumInteritemSpacing * CGFloat(cellsPerRow - 1)
                    heightMarginsAndInsets = inset * 2 + collectionView!.safeAreaInsets.top + collectionView!.safeAreaInsets.bottom + minimumInteritemSpacing * CGFloat(rowCount - 1)
                } else {
                    // Fallback on earlier versions
                    widthMarginsAndInsets = inset * 2 + collectionView!.layoutMargins.left + collectionView!.layoutMargins.right + minimumInteritemSpacing * CGFloat(cellsPerRow - 1)
                    heightMarginsAndInsets = inset * 2 + (collectionView?.layoutMargins.top)! + collectionView!.layoutMargins.bottom + minimumInteritemSpacing * CGFloat(rowCount - 1)
                }

                if ( size.width > size.height){
                    switch (cellCount){
                    case 1:
                        height = (size.height - (heightMarginsAndInsets))
                        width = (size.width - widthMarginsAndInsets)
                    case 2:
                        height = (size.height - (heightMarginsAndInsets))
                        width = ((size.width - widthMarginsAndInsets) / CGFloat(2)).rounded(.down)
                    case 4:
                        height = ((size.height - (heightMarginsAndInsets)) / CGFloat(2)).rounded(.down)
                        width = ((size.width - widthMarginsAndInsets) / CGFloat(2)).rounded(.down)
                    case 8:
                        height = ((size.height - (heightMarginsAndInsets)) / CGFloat(2)).rounded(.down)
                        width = ((size.width - (widthMarginsAndInsets * 2)) / CGFloat(4)).rounded(.down)
                    case 10:
                        height = ((size.height - (heightMarginsAndInsets)) / CGFloat(2)).rounded(.down)
                        width = ((size.width - (widthMarginsAndInsets * 2)) / CGFloat(5)).rounded(.down)
                    case 12:
                        height = ((size.height - (heightMarginsAndInsets)) / CGFloat(3)).rounded(.down)
                        width = ((size.width - (widthMarginsAndInsets * 2)) / CGFloat(4)).rounded(.down)
                    case 15:
                        height = ((size.height - (heightMarginsAndInsets)) / CGFloat(3)).rounded(.down)
                        width = ((size.width - (widthMarginsAndInsets * 2)) / CGFloat(5)).rounded(.down)
                    default:
                        cellCount = 15
                        UserDefaults.standard.set(15, forKey: "GRIDCOUNT")
                        height = ((size.height - (heightMarginsAndInsets)) / CGFloat(3)).rounded(.down)
                        width = ((size.width - (widthMarginsAndInsets * 2)) / CGFloat(5)).rounded(.down)
                    }
                } else {
                    switch (cellCount){
                    case 1:
                        height = (size.height - (heightMarginsAndInsets))
                        width = (size.width - widthMarginsAndInsets)
                    case 2:
                        height = ((size.height - (heightMarginsAndInsets)) / CGFloat(2)).rounded(.down)
                        width = (size.width - widthMarginsAndInsets)
                    case 4:
                        height = ((size.height - (heightMarginsAndInsets)) / CGFloat(4)).rounded(.down)
                        width = (size.width - widthMarginsAndInsets)
                    case 8:
                        height = ((size.height - (heightMarginsAndInsets)) / CGFloat(4)).rounded(.down)
                        width = ((size.width - widthMarginsAndInsets) / CGFloat(2)).rounded(.down)
                    case 10:
                        height = ((size.height - (heightMarginsAndInsets)) / CGFloat(5)).rounded(.down)
                        width = ((size.width - widthMarginsAndInsets) / CGFloat(2)).rounded(.down)
                    case 12:
                        height = ((size.height - (heightMarginsAndInsets)) / CGFloat(4)).rounded(.down)
                        width = ((size.width - widthMarginsAndInsets) / CGFloat(3)).rounded(.down)
                    case 15:
                        height = ((size.height - (heightMarginsAndInsets)) / CGFloat(5)).rounded(.down)
                        width = ((size.width - widthMarginsAndInsets) / CGFloat(3)).rounded(.down)
                    default:
                        cellCount = 15
                        UserDefaults.standard.set(15, forKey: "GRIDCOUNT")
                        height = ((size.height - (heightMarginsAndInsets)) / CGFloat(5)).rounded(.down)
                        width = ((size.width - widthMarginsAndInsets) / CGFloat(3)).rounded(.down)
                    }
                }
                let cellSize = CGSize(width: width, height: height)
                layout.itemSize = cellSize
                layout.invalidateLayout()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return minimumLineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return minimumInteritemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        var height:CGFloat
        var width:CGFloat
        var widthMarginsAndInsets:CGFloat
        var heightMarginsAndInsets:CGFloat
        if #available(iOS 11.0, *) {
            widthMarginsAndInsets = inset * 2 + self.view.safeAreaInsets.left + self.view.safeAreaInsets.right + minimumInteritemSpacing * CGFloat(cellsPerRow - 1)
            heightMarginsAndInsets = inset * 2 + self.view.safeAreaInsets.top + self.view.safeAreaInsets.bottom + minimumInteritemSpacing * CGFloat(rowCount - 1)
        } else {
            // Fallback on earlier versions
            widthMarginsAndInsets = inset * 2 + collectionView.layoutMargins.left + collectionView.layoutMargins.right + minimumInteritemSpacing * CGFloat(cellsPerRow - 1)
            heightMarginsAndInsets = inset * 2 + collectionView.layoutMargins.top + collectionView.layoutMargins.bottom + minimumInteritemSpacing * CGFloat(rowCount - 1)
        }

        var cellCount = UserDefaults.standard.integer(forKey: "GRIDCOUNT");
        if ( mainUIView.bounds.width > mainUIView.bounds.height){
            switch (cellCount){
            case 1:
                height = (self.view.bounds.size.height - (heightMarginsAndInsets))
                width = (self.view.bounds.size.width - widthMarginsAndInsets)
            case 2:
                height = (self.view.bounds.size.height - (heightMarginsAndInsets))
                width = ((self.view.bounds.size.width - widthMarginsAndInsets) / CGFloat(2)).rounded(.down)
            case 4:
                height = ((self.view.bounds.size.height - (heightMarginsAndInsets)) / CGFloat(2)).rounded(.down)
                width = ((self.view.bounds.size.width - widthMarginsAndInsets) / CGFloat(2)).rounded(.down)
            case 8:
                height = ((self.view.bounds.size.height - (heightMarginsAndInsets)) / CGFloat(2)).rounded(.down)
                width = ((self.view.bounds.size.width - (widthMarginsAndInsets)) / CGFloat(4)).rounded(.down)
            case 10:
                height = ((self.view.bounds.size.height - (heightMarginsAndInsets)) / CGFloat(2)).rounded(.down)
                width = ((self.view.bounds.size.width - (widthMarginsAndInsets)) / CGFloat(5)).rounded(.down)
            case 12:
                height = ((self.view.bounds.size.height - (heightMarginsAndInsets)) / CGFloat(3)).rounded(.down)
                width = ((self.view.bounds.size.width - (widthMarginsAndInsets)) / CGFloat(4)).rounded(.down)
            case 15:
                height = ((self.view.bounds.size.height - (heightMarginsAndInsets)) / CGFloat(3)).rounded(.down)
                width = ((self.view.bounds.size.width - (widthMarginsAndInsets)) / CGFloat(5)).rounded(.down)
            default:
                cellCount = 15
                UserDefaults.standard.set(15, forKey: "GRIDCOUNT")
                height = ((self.view.bounds.size.height - (heightMarginsAndInsets)) / CGFloat(3)).rounded(.down)
                width = ((self.view.bounds.size.width - (widthMarginsAndInsets)) / CGFloat(5)).rounded(.down)
            }
        } else {
            switch (cellCount){
            case 1:
                height = (self.view.bounds.size.height - (heightMarginsAndInsets))
                width = (self.view.bounds.size.width - widthMarginsAndInsets)
            case 2:
                height = ((self.view.bounds.size.height - (heightMarginsAndInsets)) / CGFloat(2)).rounded(.down)
                width = (self.view.bounds.size.width - widthMarginsAndInsets)
            case 4:
                height = ((self.view.bounds.size.height - (heightMarginsAndInsets)) / CGFloat(4)).rounded(.down)
                width = (self.view.bounds.size.width - widthMarginsAndInsets)
            case 8:
                height = ((self.view.bounds.size.height - (heightMarginsAndInsets)) / CGFloat(4)).rounded(.down)
                width = ((self.view.bounds.size.width - widthMarginsAndInsets) / CGFloat(2)).rounded(.down)
            case 10:
                height = ((self.view.bounds.size.height - (heightMarginsAndInsets)) / CGFloat(5)).rounded(.down)
                width = ((self.view.bounds.size.width - widthMarginsAndInsets) / CGFloat(2)).rounded(.down)
            case 12:
                height = ((self.view.bounds.size.height - (heightMarginsAndInsets)) / CGFloat(4)).rounded(.down)
                width = ((self.view.bounds.size.width - widthMarginsAndInsets) / CGFloat(3)).rounded(.down)
            case 15:
                height = ((self.view.bounds.size.height - (heightMarginsAndInsets)) / CGFloat(5)).rounded(.down)
                width = ((self.view.bounds.size.width - widthMarginsAndInsets) / CGFloat(3)).rounded(.down)
            default:
                cellCount = 15
                UserDefaults.standard.set(15, forKey: "GRIDCOUNT")
                height = ((self.view.bounds.size.height - (heightMarginsAndInsets)) / CGFloat(5)).rounded(.down)
                width = ((self.view.bounds.size.width - widthMarginsAndInsets) / CGFloat(3)).rounded(.down)
            }
        }
        let cellSize = CGSize(width: width, height: height)
        return cellSize
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
/*
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        
        return 1
    }
 */


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        var cellCount = UserDefaults.standard.integer(forKey: "GRIDCOUNT")
        switch (cellCount){
        case 1:
            print("cellCount:1")
        case 2:
            print("cellCount:2")
        case 4:
            print("cellCount:4")
        case 8:
            print("cellCount:8")
        case 10:
            print("cellCount:10")
        case 12:
            print("cellCount:12")
        case 15:
            print("cellCount:15")
        default:
            print("cellCount:default(15)")
            cellCount = 15
            UserDefaults.standard.set(15, forKey: "GRIDCOUNT")
        }
        return cellCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MainCollectionViewCell

        if #available(iOS 13.0, *) {
            //Nothing to do
        } else {
            switch(UserDefaults.standard.integer(forKey: "darkmode_preference")){
            case 0:
                //OFF
                cell.setColors(backgroundColor: .white, textColor: .black)
            case 1:
                //On
                cell.setColors(backgroundColor: .black, textColor: .white)
            default:
                //Default
                cell.setColors(backgroundColor: .white, textColor: .black)
            }
        }

        let label = getLabel(cell: indexPath.row + 1)
        cell.setLabel(label: label)
        let icon = getIcon(cell: indexPath.row + 1)
        cell.setIcon(icon: icon)
    
        return cell
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
    
    @objc func faultsButtonTapped() {
        performSegue(withIdentifier: "motorcycleToFaults", sender: [])
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
    
    @objc func menuButtonTapped() {
        popUpMenu()
    }
    
    @objc func btButtonTapped(_ sender: UIBarButtonItem) {
        // if we don't have a WunderLINQ, start scanning for one...
        print("btButtonTapped()")
        keepScanning = true
        resumeScan()
    }
    
    func disconnect() {
        if let wunderLINQ = self.wunderLINQ {
            if let mc = self.messageCharacteristic {
                wunderLINQ.setNotifyValue(false, for: mc)
            }
            
            /*
             NOTE: The cancelPeripheralConnection: method is nonblocking, and any CBPeripheral class commands
             that are still pending to the peripheral you’re trying to disconnect may or may not finish executing.
             Because other apps may still have a connection to the peripheral, canceling a local connection
             does not guarantee that the underlying physical link is immediately disconnected.
             
             From your app’s perspective, however, the peripheral is considered disconnected, and the central manager
             object calls the centralManager:didDisconnectPeripheral:error: method of its delegate object.
             */
            centralManager.cancelPeripheralConnection(wunderLINQ)
        }
        messageCharacteristic = nil
        bleData.setcmdCharacteristic(cmdCharacteristic: nil)
    }
    
    
    // MARK: - Bluetooth scanning
    
    @objc func pauseScan() {
        // Scanning uses up battery on phone, so pause the scan process for the designated interval.
        NSLog("PAUSING SCAN...")
        disconnectButton.isEnabled = true
        self.centralManager?.stopScan()
        Timer.scheduledTimer(timeInterval: timerPauseInterval, target: self, selector: #selector(self.resumeScan), userInfo: nil, repeats: false)
        
    }
    
    @objc func resumeScan() {
        let lastPeripherals = centralManager.retrieveConnectedPeripherals(withServices: [CBUUID(string: Device.WunderLINQServiceUUID)])
        
        if lastPeripherals.count > 0{
            NSLog("FOUND WunderLINQ")
            let device = lastPeripherals.last!;
            wunderLINQ = device;
            bleData.setPeripheral(peripheral: device)
            centralManager?.connect(wunderLINQ!, options: nil)
        } else {
            if keepScanning {
                // Start scanning again...
                NSLog("RESUMING SCAN!")
                disconnectButton.isEnabled = false
                centralManager.scanForPeripherals(withServices: [CBUUID(string: Device.WunderLINQAdvertisingUUID)], options: nil)
                Timer.scheduledTimer(timeInterval: timerScanInterval, target: self, selector: #selector(self.pauseScan), userInfo: nil, repeats: false)
            } else {
                disconnectButton.isEnabled = true
            }
        }
    }
    
    func getCellDataPoint(cell: Int) -> Int {
        var cellDataPoint:Int = 0
        switch (cell) {
        case 1:
            cellDataPoint = UserDefaults.standard.integer(forKey: "grid_one_preference")
        case 2:
            cellDataPoint = UserDefaults.standard.integer(forKey: "grid_two_preference")
        case 3:
            cellDataPoint = UserDefaults.standard.integer(forKey: "grid_three_preference")
        case 4:
            cellDataPoint = UserDefaults.standard.integer(forKey: "grid_four_preference")
        case 5:
            cellDataPoint = UserDefaults.standard.integer(forKey: "grid_five_preference")
        case 6:
            cellDataPoint = UserDefaults.standard.integer(forKey: "grid_six_preference")
        case 7:
            cellDataPoint = UserDefaults.standard.integer(forKey: "grid_seven_preference")
        case 8:
            cellDataPoint = UserDefaults.standard.integer(forKey: "grid_eight_preference")
        case 9:
            cellDataPoint = UserDefaults.standard.integer(forKey: "grid_nine_preference")
        case 10:
            cellDataPoint = UserDefaults.standard.integer(forKey: "grid_ten_preference")
        case 11:
            cellDataPoint = UserDefaults.standard.integer(forKey: "grid_eleven_preference")
        case 12:
            cellDataPoint = UserDefaults.standard.integer(forKey: "grid_twelve_preference")
        case 13:
            cellDataPoint = UserDefaults.standard.integer(forKey: "grid_thirteen_preference")
        case 14:
            cellDataPoint = UserDefaults.standard.integer(forKey: "grid_fourteen_preference")
        case 15:
            cellDataPoint = UserDefaults.standard.integer(forKey: "grid_fifteen_preference")
        default:
            print("Unknown cell")
        }
        return cellDataPoint
    }
    
    func getLabel(cell: Int) -> String {
        var label:String = ""
        let cellDataPoint = getCellDataPoint(cell: cell)
        var temperatureUnit = "C"
        var heightUnit = "m"
        var distanceUnit = "km"
        var distanceTimeUnit = "kmh"
        var consumptionUnit = "L/100"
        var pressureUnit = "psi"
        // Pressure Unit
        switch UserDefaults.standard.integer(forKey: "pressure_unit_preference"){
        case 0:
            pressureUnit = "bar"
        case 1:
            pressureUnit = "kPa"
        case 2:
            pressureUnit = "kg-f"
        case 3:
            pressureUnit = "psi"
        default:
            print("Unknown pressure unit setting")
        }
        if UserDefaults.standard.integer(forKey: "temperature_unit_preference") == 1 {
            temperatureUnit = "F"
        }
        if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
            distanceUnit = "mi"
            distanceTimeUnit = "mph"
            heightUnit = "ft"
        }
        switch UserDefaults.standard.integer(forKey: "consumption_unit_preference"){
        case 0:
            consumptionUnit = "L/100"
        case 1:
            consumptionUnit = "mpg"
        case 2:
            consumptionUnit = "mpg"
        case 3:
            consumptionUnit = "km/L"
        default:
            print("Unknown consumption unit setting")
        }
        
        switch (cellDataPoint){
        case 0:
            // Gear
            label = NSLocalizedString("gear_header", comment: "")
        case 1:
            // Engine Temperature
            label = NSLocalizedString("enginetemp_header", comment: "") + " (" + temperatureUnit + ")"
        case 2:
            // Ambient Temperature
            label = NSLocalizedString("ambienttemp_header", comment: "") + " (" + temperatureUnit + ")"
        case 3:
            // Front Tire Pressure
            label = NSLocalizedString("frontpressure_header", comment: "") + " (" + pressureUnit + ")"
        case 4:
            // Rear Tire Pressure
            label = NSLocalizedString("rearpressure_header", comment: "") + " (" + pressureUnit + ")"
        case 5:
            // Odometer
            label = NSLocalizedString("odometer_header", comment: "") + " (" + distanceUnit + ")"
        case 6:
            // Voltage
            label = NSLocalizedString("voltage_header", comment: "") + " (V)"
        case 7:
            // Trottle
            label = NSLocalizedString("throttle_header", comment: "") + " (%)"
        case 8:
            // Front Brakes
            label = NSLocalizedString("frontbrakes_header", comment: "")
        case 9:
            // Rear Brakes
            label = NSLocalizedString("rearbrakes_header", comment: "")
        case 10:
            // Ambient Light
            label = NSLocalizedString("ambientlight_header", comment: "")
        case 11:
            // Trip 1
            label = NSLocalizedString("tripone_header", comment: "") + " (" + distanceUnit + ")"
        case 12:
            // Trip 2
            label = NSLocalizedString("triptwo_header", comment: "") + " (" + distanceUnit + ")"
        case 13:
            // Trip Auto
            label = NSLocalizedString("tripauto_header", comment: "") + " (" + distanceUnit + ")"
        case 14:
            // Speed
            label = NSLocalizedString("speed_header", comment: "") + " (" + distanceTimeUnit + ")"
        case 15:
            //Average Speed
            label = NSLocalizedString("avgspeed_header", comment: "") + " (" + distanceTimeUnit + ")"
        case 16:
            //Current Consumption
            label = NSLocalizedString("cconsumption_header", comment: "") + " (" + consumptionUnit + ")"
        case 17:
            //Fuel Economy One
            label = NSLocalizedString("fueleconomyone_header", comment: "") + " (" + consumptionUnit + ")"
        case 18:
            //Fuel Economy Two
            label = NSLocalizedString("fueleconomytwo_header", comment: "") + " (" + consumptionUnit + ")"
        case 19:
            //Fuel Range
            label = NSLocalizedString("fuelrange_header", comment: "") + " (" + distanceUnit + ")"
        case 20:
            //Shifts
            label = NSLocalizedString("shifts_header", comment: "")
        case 21:
            //Lean Angle
            label = NSLocalizedString("leanangle_header", comment: "")
        case 22:
            //g-force
            label = NSLocalizedString("gforce_header", comment: "")
        case 23:
            //bearing
            label = NSLocalizedString("bearing_header", comment: "")
        case 24:
            //time
            label = NSLocalizedString("time_header", comment: "")
        case 25:
            //barometric pressure
            label = NSLocalizedString("barometric_header", comment: "") + " (mBar)"
        case 26:
            //GPS Speed
            label = NSLocalizedString("gpsspeed_header", comment: "") + " (" + distanceTimeUnit + ")"
        case 27:
            //altitude
            label = NSLocalizedString("altitude_header", comment: "") + " (" + heightUnit + ")"
        case 28:
            //Sunrise/Sunset
            label = NSLocalizedString("sunrisesunset_header", comment: "")
        case 29:
            //RPM
            label = NSLocalizedString("rpm_header", comment: "")
        case 30:
            //Lean Angle
            label = NSLocalizedString("leanangle_bike_header", comment: "")
        case 31:
            //Rear Wheel Speed
            label = NSLocalizedString("rearwheel_speed_header", comment: "")
        default:
            print("Unknown : \(cellDataPoint)")
        }
        
        return label
    }
    
    func getIcon(cell: Int) -> UIImage {
        var icon:UIImage = (UIImage(named: "Cog")?.withRenderingMode(.alwaysTemplate))!
        let cellDataPoint = getCellDataPoint(cell: cell)
        switch (cellDataPoint){
        case 0:
            // Gear
            icon = (UIImage(named: "Cog")?.withRenderingMode(.alwaysTemplate))!
        case 1:
            // Engine Temperature
            icon = (UIImage(named: "Engine-Temp")?.withRenderingMode(.alwaysTemplate))!
        case 2:
            // Ambient Temperature
            icon = (UIImage(named: "Thermometer")?.withRenderingMode(.alwaysTemplate))!
        case 3:
            // Front Tire Pressure
            icon = (UIImage(named: "Tire")?.withRenderingMode(.alwaysTemplate))!
        case 4:
            // Rear Tire Pressure
            icon = (UIImage(named: "Tire")?.withRenderingMode(.alwaysTemplate))!
        case 5:
            // Odometer
            icon = (UIImage(named: "Odometer")?.withRenderingMode(.alwaysTemplate))!
        case 6:
            // Voltage
            icon = (UIImage(named: "Battery")?.withRenderingMode(.alwaysTemplate))!
        case 7:
            // Trottle
            icon = (UIImage(named: "Signature")?.withRenderingMode(.alwaysTemplate))!
        case 8:
            // Front Brakes
            icon = (UIImage(named: "Brakes")?.withRenderingMode(.alwaysTemplate))!
        case 9:
            // Rear Brakes
            icon = (UIImage(named: "Brakes")?.withRenderingMode(.alwaysTemplate))!
        case 10:
            // Ambient Light
            icon = (UIImage(named: "Light-bulb")?.withRenderingMode(.alwaysTemplate))!
        case 11:
            // Trip 1
            icon = (UIImage(named: "Suitcase")?.withRenderingMode(.alwaysTemplate))!
        case 12:
            // Trip 2
            icon = (UIImage(named: "Suitcase")?.withRenderingMode(.alwaysTemplate))!
        case 13:
            // Trip Auto
            icon = (UIImage(named: "Suitcase")?.withRenderingMode(.alwaysTemplate))!
        case 14:
            // Speed
            icon = (UIImage(named: "Tachometer")?.withRenderingMode(.alwaysTemplate))!
        case 15:
            //Average Speed
            icon = (UIImage(named: "Tachometer")?.withRenderingMode(.alwaysTemplate))!
        case 16:
            //Current Consumption
            icon = (UIImage(named: "Gas-pump")?.withRenderingMode(.alwaysTemplate))!
        case 17:
            //Fuel Economy One
            icon = (UIImage(named: "Gas-pump")?.withRenderingMode(.alwaysTemplate))!
        case 18:
            //Fuel Economy Two
            icon = (UIImage(named: "Gas-pump")?.withRenderingMode(.alwaysTemplate))!
        case 19:
            //Fuel Range
            icon = (UIImage(named: "Gas-pump")?.withRenderingMode(.alwaysTemplate))!
        case 20:
            //Shifts
            icon = (UIImage(named: "Arrows-alt")?.withRenderingMode(.alwaysTemplate))!
        case 21:
            //Lean Angle
            icon = (UIImage(named: "Angle")?.withRenderingMode(.alwaysTemplate))!
        case 22:
            //g-force
            icon = (UIImage(named: "Accelerometer")?.withRenderingMode(.alwaysTemplate))!
        case 23:
            //bearing
            icon = (UIImage(named: "Compass")?.withRenderingMode(.alwaysTemplate))!
        case 24:
            //time
            icon = (UIImage(named: "Clock")?.withRenderingMode(.alwaysTemplate))!
        case 25:
            //barometric pressure
            icon = (UIImage(named: "Barometer")?.withRenderingMode(.alwaysTemplate))!
        case 26:
            //GPS Speed
            icon = (UIImage(named: "Tachometer")?.withRenderingMode(.alwaysTemplate))!
        case 27:
            //altitude
            icon = (UIImage(named: "Mountain")?.withRenderingMode(.alwaysTemplate))!
        case 28:
            //Sunrise/Sunset
            icon = (UIImage(named: "Sun")?.withRenderingMode(.alwaysTemplate))!
        case 29:
            //RPM
            icon = (UIImage(named: "Tachometer")?.withRenderingMode(.alwaysTemplate))!
        case 30:
            //Lean Angle Bike
            icon = (UIImage(named: "Angle")?.withRenderingMode(.alwaysTemplate))!
        default:
            print("Unknown : \(cellDataPoint)")
        }
        
        return icon
    }
    
    // MARK: - Updating UI
    func updateMessageDisplay() {
        NSLog("IN MainCollectionViewController updateMessageDisplay()")
        // Update Buttons
        if (faults.getallActiveDesc().isEmpty){
            faultsBtn.tintColor = UIColor.clear
            faultsButton.isEnabled = false
        } else {
            faultsBtn.tintColor = UIColor.red
            faultsButton.isEnabled = true
        }
        self.navigationItem.leftBarButtonItems = [backButton, disconnectButton, faultsButton]
        
        // Update main display
        let cellCount = UserDefaults.standard.integer(forKey: "GRIDCOUNT")
        switch (cellCount){
        case 15:
            let cell1 = UserDefaults.standard.integer(forKey: "grid_one_preference")
            let cell2 = UserDefaults.standard.integer(forKey: "grid_two_preference")
            let cell3 = UserDefaults.standard.integer(forKey: "grid_three_preference")
            let cell4 = UserDefaults.standard.integer(forKey: "grid_four_preference")
            let cell5 = UserDefaults.standard.integer(forKey: "grid_five_preference")
            let cell6 = UserDefaults.standard.integer(forKey: "grid_six_preference")
            let cell7 = UserDefaults.standard.integer(forKey: "grid_seven_preference")
            let cell8 = UserDefaults.standard.integer(forKey: "grid_eight_preference")
            let cell9 = UserDefaults.standard.integer(forKey: "grid_nine_preference")
            let cell10 = UserDefaults.standard.integer(forKey: "grid_ten_preference")
            let cell11 = UserDefaults.standard.integer(forKey: "grid_eleven_preference")
            let cell12 = UserDefaults.standard.integer(forKey: "grid_twelve_preference")
            let cell13 = UserDefaults.standard.integer(forKey: "grid_thirteen_preference")
            let cell14 = UserDefaults.standard.integer(forKey: "grid_fourteen_preference")
            let cell15 = UserDefaults.standard.integer(forKey: "grid_fifteen_preference")
            setCellText(1, dataPoint: cell1)
            setCellText(2, dataPoint: cell2)
            setCellText(3, dataPoint: cell3)
            setCellText(4, dataPoint: cell4)
            setCellText(5, dataPoint: cell5)
            setCellText(6, dataPoint: cell6)
            setCellText(7, dataPoint: cell7)
            setCellText(8, dataPoint: cell8)
            setCellText(9, dataPoint: cell9)
            setCellText(10, dataPoint: cell10)
            setCellText(11, dataPoint: cell11)
            setCellText(12, dataPoint: cell12)
            setCellText(13, dataPoint: cell13)
            setCellText(14, dataPoint: cell14)
            setCellText(15, dataPoint: cell15)
        case 12:
            let cell1 = UserDefaults.standard.integer(forKey: "grid_one_preference")
            let cell2 = UserDefaults.standard.integer(forKey: "grid_two_preference")
            let cell3 = UserDefaults.standard.integer(forKey: "grid_three_preference")
            let cell4 = UserDefaults.standard.integer(forKey: "grid_four_preference")
            let cell5 = UserDefaults.standard.integer(forKey: "grid_five_preference")
            let cell6 = UserDefaults.standard.integer(forKey: "grid_six_preference")
            let cell7 = UserDefaults.standard.integer(forKey: "grid_seven_preference")
            let cell8 = UserDefaults.standard.integer(forKey: "grid_eight_preference")
            let cell9 = UserDefaults.standard.integer(forKey: "grid_nine_preference")
            let cell10 = UserDefaults.standard.integer(forKey: "grid_ten_preference")
            let cell11 = UserDefaults.standard.integer(forKey: "grid_eleven_preference")
            let cell12 = UserDefaults.standard.integer(forKey: "grid_twelve_preference")
            setCellText(1, dataPoint: cell1)
            setCellText(2, dataPoint: cell2)
            setCellText(3, dataPoint: cell3)
            setCellText(4, dataPoint: cell4)
            setCellText(5, dataPoint: cell5)
            setCellText(6, dataPoint: cell6)
            setCellText(7, dataPoint: cell7)
            setCellText(8, dataPoint: cell8)
            setCellText(9, dataPoint: cell9)
            setCellText(10, dataPoint: cell10)
            setCellText(11, dataPoint: cell11)
            setCellText(12, dataPoint: cell12)
        case 10:
            let cell1 = UserDefaults.standard.integer(forKey: "grid_one_preference")
            let cell2 = UserDefaults.standard.integer(forKey: "grid_two_preference")
            let cell3 = UserDefaults.standard.integer(forKey: "grid_three_preference")
            let cell4 = UserDefaults.standard.integer(forKey: "grid_four_preference")
            let cell5 = UserDefaults.standard.integer(forKey: "grid_five_preference")
            let cell6 = UserDefaults.standard.integer(forKey: "grid_six_preference")
            let cell7 = UserDefaults.standard.integer(forKey: "grid_seven_preference")
            let cell8 = UserDefaults.standard.integer(forKey: "grid_eight_preference")
            let cell9 = UserDefaults.standard.integer(forKey: "grid_nine_preference")
            let cell10 = UserDefaults.standard.integer(forKey: "grid_ten_preference")
            setCellText(1, dataPoint: cell1)
            setCellText(2, dataPoint: cell2)
            setCellText(3, dataPoint: cell3)
            setCellText(4, dataPoint: cell4)
            setCellText(5, dataPoint: cell5)
            setCellText(6, dataPoint: cell6)
            setCellText(7, dataPoint: cell7)
            setCellText(8, dataPoint: cell8)
            setCellText(9, dataPoint: cell9)
            setCellText(10, dataPoint: cell10)
        case 8:
            let cell1 = UserDefaults.standard.integer(forKey: "grid_one_preference")
            let cell2 = UserDefaults.standard.integer(forKey: "grid_two_preference")
            let cell3 = UserDefaults.standard.integer(forKey: "grid_three_preference")
            let cell4 = UserDefaults.standard.integer(forKey: "grid_four_preference")
            let cell5 = UserDefaults.standard.integer(forKey: "grid_five_preference")
            let cell6 = UserDefaults.standard.integer(forKey: "grid_six_preference")
            let cell7 = UserDefaults.standard.integer(forKey: "grid_seven_preference")
            let cell8 = UserDefaults.standard.integer(forKey: "grid_eight_preference")
            setCellText(1, dataPoint: cell1)
            setCellText(2, dataPoint: cell2)
            setCellText(3, dataPoint: cell3)
            setCellText(4, dataPoint: cell4)
            setCellText(5, dataPoint: cell5)
            setCellText(6, dataPoint: cell6)
            setCellText(7, dataPoint: cell7)
            setCellText(8, dataPoint: cell8)
        case 4:
            let cell1 = UserDefaults.standard.integer(forKey: "grid_one_preference")
            let cell2 = UserDefaults.standard.integer(forKey: "grid_two_preference")
            let cell3 = UserDefaults.standard.integer(forKey: "grid_three_preference")
            let cell4 = UserDefaults.standard.integer(forKey: "grid_four_preference")
            setCellText(1, dataPoint: cell1)
            setCellText(2, dataPoint: cell2)
            setCellText(3, dataPoint: cell3)
            setCellText(4, dataPoint: cell4)
        case 2:
            let cell1 = UserDefaults.standard.integer(forKey: "grid_one_preference")
            let cell2 = UserDefaults.standard.integer(forKey: "grid_two_preference")
            setCellText(1, dataPoint: cell1)
            setCellText(2, dataPoint: cell2)
        case 1:
            let cell1 = UserDefaults.standard.integer(forKey: "grid_one_preference")
            setCellText(1, dataPoint: cell1)
        default:
            let cell1 = UserDefaults.standard.integer(forKey: "grid_one_preference")
            let cell2 = UserDefaults.standard.integer(forKey: "grid_two_preference")
            let cell3 = UserDefaults.standard.integer(forKey: "grid_three_preference")
            let cell4 = UserDefaults.standard.integer(forKey: "grid_four_preference")
            let cell5 = UserDefaults.standard.integer(forKey: "grid_five_preference")
            let cell6 = UserDefaults.standard.integer(forKey: "grid_six_preference")
            let cell7 = UserDefaults.standard.integer(forKey: "grid_seven_preference")
            let cell8 = UserDefaults.standard.integer(forKey: "grid_eight_preference")
            let cell9 = UserDefaults.standard.integer(forKey: "grid_nine_preference")
            let cell10 = UserDefaults.standard.integer(forKey: "grid_ten_preference")
            let cell11 = UserDefaults.standard.integer(forKey: "grid_eleven_preference")
            let cell12 = UserDefaults.standard.integer(forKey: "grid_twelve_preference")
            let cell13 = UserDefaults.standard.integer(forKey: "grid_thirteen_preference")
            let cell14 = UserDefaults.standard.integer(forKey: "grid_fourteen_preference")
            let cell15 = UserDefaults.standard.integer(forKey: "grid_fifteen_preference")
            setCellText(1, dataPoint: cell1)
            setCellText(2, dataPoint: cell2)
            setCellText(3, dataPoint: cell3)
            setCellText(4, dataPoint: cell4)
            setCellText(5, dataPoint: cell5)
            setCellText(6, dataPoint: cell6)
            setCellText(7, dataPoint: cell7)
            setCellText(8, dataPoint: cell8)
            setCellText(9, dataPoint: cell9)
            setCellText(10, dataPoint: cell10)
            setCellText(11, dataPoint: cell11)
            setCellText(12, dataPoint: cell12)
            setCellText(13, dataPoint: cell13)
            setCellText(14, dataPoint: cell14)
            setCellText(15, dataPoint: cell15)
        }
    }
    
    func setCellText(_ cellNumber: Int, dataPoint: Int){
        
        let label = getLabel(cell: cellNumber)
        var value:String = NSLocalizedString("blank_field", comment: "")
        var icon: UIImage = getIcon(cell: cellNumber)
        
        switch (dataPoint){
        case 0:
            // Gear
            icon = (UIImage(named: "Cog")?.withRenderingMode(.alwaysTemplate))!
            if motorcycleData.gear != nil {
                value = motorcycleData.getgear()
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case 1:
            // Engine Temperature
            icon = (UIImage(named: "Engine-Temp")?.withRenderingMode(.alwaysTemplate))!
            if motorcycleData.engineTemperature != nil {
                var engineTemp:Double = motorcycleData.engineTemperature!
                if (engineTemp >= 104.0){
                    icon = icon.imageWithColor(color1: UIColor.red)
                }
                if (UserDefaults.standard.integer(forKey: "temperature_unit_preference") == 1 ){
                    engineTemp = Utility.celciusToFahrenheit(engineTemp)
                }
                value = "\(engineTemp.rounded(toPlaces: 1))"
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case 2:
            // Ambient Temperature
            icon = (UIImage(named: "Thermometer")?.withRenderingMode(.alwaysTemplate))!
            if motorcycleData.ambientTemperature != nil {
                var ambientTemp:Double = motorcycleData.ambientTemperature!
                if(ambientTemp <= 0){
                    icon = (UIImage(named: "Snowflake")?.withRenderingMode(.alwaysTemplate))!
                }
                if UserDefaults.standard.integer(forKey: "temperature_unit_preference") == 1 {
                    ambientTemp = Utility.celciusToFahrenheit(ambientTemp)
                }
                value = "\(ambientTemp.rounded(toPlaces: 1))"
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case 3:
            // Front Tire Pressure
            icon = (UIImage(named: "Tire")?.withRenderingMode(.alwaysTemplate))!
            if motorcycleData.frontTirePressure != nil {
                var frontPressure:Double = motorcycleData.frontTirePressure!
                switch UserDefaults.standard.integer(forKey: "pressure_unit_preference"){
                case 1:
                    frontPressure = Utility.barTokPa(frontPressure)
                case 2:
                    frontPressure = Utility.barTokgf(frontPressure)
                case 3:
                    frontPressure = Utility.barToPsi(frontPressure)
                default:
                    break
                }
                value = "\(frontPressure.rounded(toPlaces: 1))"
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
            if(faults.getFrontTirePressureCriticalActive()){
                icon = (UIImage(named: "Tire-Alert")?.withRenderingMode(.alwaysTemplate))!
                icon = icon.imageWithColor(color1: UIColor.red)
            } else if(faults.getRearTirePressureWarningActive()){
                icon = (UIImage(named: "Tire-Alert")?.withRenderingMode(.alwaysTemplate))!
                icon = icon.imageWithColor(color1: UIColor.yellow)
            }
        case 4:
            // Rear Tire Pressure
            icon = (UIImage(named: "Tire")?.withRenderingMode(.alwaysTemplate))!
            if motorcycleData.rearTirePressure != nil {
                var rearPressure:Double = motorcycleData.rearTirePressure!
                switch UserDefaults.standard.integer(forKey: "pressure_unit_preference"){
                case 1:
                    rearPressure = Utility.barTokPa(rearPressure)
                case 2:
                    rearPressure = Utility.barTokgf(rearPressure)
                case 3:
                    rearPressure = Utility.barToPsi(rearPressure)
                default:
                    break
                }
                value = "\(rearPressure.rounded(toPlaces: 1))"
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
            if(faults.getRearTirePressureCriticalActive()){
                icon = (UIImage(named: "Tire-Alert")?.withRenderingMode(.alwaysTemplate))!
                icon = icon.imageWithColor(color1: UIColor.red)
            } else if(faults.getRearTirePressureWarningActive()){
                icon = (UIImage(named: "Tire-Alert")?.withRenderingMode(.alwaysTemplate))!
                icon = icon.imageWithColor(color1: UIColor.yellow)
            }
        case 5:
            // Odometer
            icon = (UIImage(named: "Odometer")?.withRenderingMode(.alwaysTemplate))!
            if motorcycleData.odometer != nil {
                var odometer:Double = motorcycleData.odometer!
                if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                    odometer = Double(Utility.kmToMiles(Double(odometer)))
                }
                value = "\(Int(odometer))"
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case 6:
            // Voltage
            icon = (UIImage(named: "Battery")?.withRenderingMode(.alwaysTemplate))!
            if motorcycleData.voltage != nil {
                value = "\(motorcycleData.voltage!)"
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case 7:
            // Trottle
            icon = (UIImage(named: "Signature")?.withRenderingMode(.alwaysTemplate))!
            if motorcycleData.throttlePosition != nil {
                value = "\(Int(round(motorcycleData.throttlePosition!)))"
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case 8:
            // Front Brakes
            icon = (UIImage(named: "Brakes")?.withRenderingMode(.alwaysTemplate))!
            if ((motorcycleData.frontBrake != nil) && motorcycleData.frontBrake != 0) {
                value = "\(motorcycleData.frontBrake!)"
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case 9:
            // Rear Brakes
            icon = (UIImage(named: "Brakes")?.withRenderingMode(.alwaysTemplate))!
            if ((motorcycleData.rearBrake != nil) && motorcycleData.rearBrake != 0)  {
                value = "\(motorcycleData.rearBrake!)"
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case 10:
            // Ambient Light
            icon = (UIImage(named: "Light-bulb")?.withRenderingMode(.alwaysTemplate))!
            if motorcycleData.ambientLight != nil {
                value = "\(motorcycleData.ambientLight!)"
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case 11:
            // Trip 1
            icon = (UIImage(named: "Suitcase")?.withRenderingMode(.alwaysTemplate))!
            if motorcycleData.tripOne != nil {
                var tripOne:Double = motorcycleData.tripOne!
                if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                    tripOne = Double(Utility.kmToMiles(Double(tripOne)))
                }
                value = "\(tripOne.rounded(toPlaces: 1))"
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case 12:
            // Trip 2
            icon = (UIImage(named: "Suitcase")?.withRenderingMode(.alwaysTemplate))!
            if motorcycleData.tripTwo != nil {
                var tripTwo:Double = motorcycleData.gettripTwo()
                if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                    tripTwo = Double(Utility.kmToMiles(Double(tripTwo)))
                }
                value = "\(tripTwo.rounded(toPlaces: 1))"
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case 13:
            // Trip Auto
            icon = (UIImage(named: "Suitcase")?.withRenderingMode(.alwaysTemplate))!
            if motorcycleData.tripAuto != nil {
                var tripAuto:Double = motorcycleData.gettripAuto()
                if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                    tripAuto = Double(Utility.kmToMiles(Double(tripAuto)))
                }
                value = "\(tripAuto.rounded(toPlaces: 1))"
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case 14:
            // Speed
            icon = (UIImage(named: "Tachometer")?.withRenderingMode(.alwaysTemplate))!
            if motorcycleData.speed != nil {
                let speedValue = motorcycleData.speed!
                value = "\(Int(speedValue))"
                if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                    value = "\(Int(round(Utility.kmToMiles(speedValue))))"
                }
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case 15:
            //Average Speed
            icon = (UIImage(named: "Tachometer")?.withRenderingMode(.alwaysTemplate))!
            if motorcycleData.averageSpeed != nil {
                let avgSpeedValue:Double = motorcycleData.averageSpeed!
                value = "\(Int(avgSpeedValue))"
                if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                    value = "\(Int(round(Utility.kmToMiles(avgSpeedValue))))"
                }
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case 16:
            //Current Consumption
            icon = (UIImage(named: "Gas-pump")?.withRenderingMode(.alwaysTemplate))!
            if motorcycleData.currentConsumption != nil {
                let currentConsumptionValue:Double = motorcycleData.currentConsumption!
                value = "\(currentConsumptionValue.rounded(toPlaces: 1))"
                switch UserDefaults.standard.integer(forKey: "consumption_unit_preference"){
                case 1:
                    value = "\(Utility.l100ToMpg(currentConsumptionValue).rounded(toPlaces: 1))"
                case 2:
                    value = "\(Utility.l100ToMpgi(currentConsumptionValue).rounded(toPlaces: 1))"
                case 3:
                    value = "\(Utility.l100Tokml(currentConsumptionValue).rounded(toPlaces: 1))"
                default:
                    value = "\(currentConsumptionValue.rounded(toPlaces: 1))"
                }
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case 17:
            //Fuel Economy One
            icon = (UIImage(named: "Gas-pump")?.withRenderingMode(.alwaysTemplate))!
            if motorcycleData.fuelEconomyOne != nil {
                let fuelEconomyOneValue:Double = motorcycleData.fuelEconomyOne!
                value = "\(fuelEconomyOneValue.rounded(toPlaces: 1))"
                switch UserDefaults.standard.integer(forKey: "consumption_unit_preference"){
                case 1:
                    value = "\(Utility.l100ToMpg(fuelEconomyOneValue).rounded(toPlaces: 1))"
                case 2:
                    value = "\(Utility.l100ToMpgi(fuelEconomyOneValue).rounded(toPlaces: 1))"
                case 3:
                    value = "\(Utility.l100Tokml(fuelEconomyOneValue).rounded(toPlaces: 1))"
                default:
                    value = "\(fuelEconomyOneValue.rounded(toPlaces: 1))"
                }
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case 18:
            //Fuel Economy Two
            icon = (UIImage(named: "Gas-pump")?.withRenderingMode(.alwaysTemplate))!
            if motorcycleData.fuelEconomyTwo != nil {
                let fuelEconomyTwoValue:Double = motorcycleData.fuelEconomyTwo!
                value = "\(fuelEconomyTwoValue.rounded(toPlaces: 1))"
                switch UserDefaults.standard.integer(forKey: "consumption_unit_preference"){
                case 1:
                    value = "\(Utility.l100ToMpg(fuelEconomyTwoValue).rounded(toPlaces: 1))"
                case 2:
                    value = "\(Utility.l100ToMpgi(fuelEconomyTwoValue).rounded(toPlaces: 1))"
                case 3:
                    value = "\(Utility.l100Tokml(fuelEconomyTwoValue).rounded(toPlaces: 1))"
                default:
                    value = "\(fuelEconomyTwoValue.rounded(toPlaces: 1))"
                }
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case 19:
            //Fuel Range
            icon = (UIImage(named: "Gas-pump")?.withRenderingMode(.alwaysTemplate))!
            if motorcycleData.fuelRange != nil {
                let fuelRangeValue:Double = motorcycleData.fuelRange!
                value = "\(Int(fuelRangeValue))"
                if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                    value = "\(Int(round(Utility.kmToMiles(fuelRangeValue))))"
                }
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case 20:
            //Shifts
            icon = (UIImage(named: "Gas-pump")?.withRenderingMode(.alwaysTemplate))!
            if motorcycleData.shifts != nil {
                value = "\(motorcycleData.shifts!)"
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case 21:
            //Lean Angle
            icon = (UIImage(named: "Angle")?.withRenderingMode(.alwaysTemplate))!
            if motorcycleData.leanAngle != nil {
                value = "\(Int(round(motorcycleData.leanAngle!)))"
            }
        case 22:
            //g-force
            icon = (UIImage(named: "Accelerometer")?.withRenderingMode(.alwaysTemplate))!
            if motorcycleData.gForce != nil {
                value = "\(motorcycleData.gForce!.rounded(toPlaces: 1))"
            }
        case 23:
            //Bearing
            icon = (UIImage(named: "Compass")?.withRenderingMode(.alwaysTemplate))!
            if motorcycleData.bearing != nil {
                value = "\(motorcycleData.bearing!)"
                if UserDefaults.standard.integer(forKey: "bearing_unit_preference") != 0 {
                    let bearing = motorcycleData.bearing!
                    var cardinal = "-";
                    if bearing > 331 || bearing <= 28 {
                        cardinal = NSLocalizedString("north", comment: "")
                    } else if bearing > 28 && bearing <= 73 {
                        cardinal = NSLocalizedString("north_east", comment: "")
                    } else if bearing > 73 && bearing <= 118 {
                        cardinal = NSLocalizedString("east", comment: "")
                    } else if bearing > 118 && bearing <= 163 {
                        cardinal = NSLocalizedString("south_east", comment: "")
                    } else if bearing > 163 && bearing <= 208 {
                        cardinal = NSLocalizedString("south", comment: "")
                    } else if bearing > 208 && bearing <= 253 {
                        cardinal = NSLocalizedString("south_west", comment: "")
                    } else if bearing > 253 && bearing <= 298 {
                        cardinal = NSLocalizedString("west", comment: "")
                    } else if bearing > 298 && bearing <= 331 {
                        cardinal = NSLocalizedString("north_west", comment: "")
                    } else {
                        cardinal = "-"
                    }
                    value = cardinal
                }
            }
        case 24:
            //Time
            icon = (UIImage(named: "Clock")?.withRenderingMode(.alwaysTemplate))!
            if motorcycleData.time != nil {
                let formatter = DateFormatter()
                formatter.dateFormat = "h:mm a"
                if UserDefaults.standard.integer(forKey: "time_format_preference") > 0 {
                    formatter.dateFormat = "HH:mm"
                }
                value = ("\(formatter.string(from: motorcycleData.time!))")
            }
        case 25:
            //Barometric Pressure
            icon = (UIImage(named: "Barometer")?.withRenderingMode(.alwaysTemplate))!
            if motorcycleData.barometricPressure != nil {
                value = "\(Int(round(motorcycleData.barometricPressure!)))"
            }
        case 26:
            //GPS speed
            icon = (UIImage(named: "Tachometer")?.withRenderingMode(.alwaysTemplate))!
            if motorcycleData.location != nil {
                var gpsSpeed:String = "0"
                if motorcycleData.location!.speed >= 0{
                    gpsSpeed = "\(motorcycleData.location!.speed * 3.6)"
                    let gpsSpeedValue:Double = motorcycleData.location!.speed * 3.6
                    gpsSpeed = "\(Int(round(gpsSpeedValue)))"
                    if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                        gpsSpeed = "\(Int(round(Utility.kmToMiles(gpsSpeedValue))))"
                    }
                    value = gpsSpeed
                }
            }
        case 27:
            //Altitude
            icon = (UIImage(named: "Mountain")?.withRenderingMode(.alwaysTemplate))!
            if motorcycleData.location != nil {
                var altitude:String = "\(Int(round(motorcycleData.location!.altitude)))"
                if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                    altitude = "\(Int(round(Utility.mtoFeet(motorcycleData.location!.altitude))))"
                }
                value = altitude
            }
        case 28:
            //Sunrise/Sunset
            icon = (UIImage(named: "Sun")?.withRenderingMode(.alwaysTemplate))!
            if motorcycleData.location != nil {
                let today = Date()
                let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
                let solar = Solar(for: yesterday, coordinate: motorcycleData.location!.coordinate)
                let sunrise = solar?.sunrise
                let sunset = solar?.sunset
                
                if(today > sunset!){
                    icon = (UIImage(named: "Moon")?.withRenderingMode(.alwaysTemplate))!
                }
                let formatter = DateFormatter()
                formatter.dateFormat = "h:mm a"
                if UserDefaults.standard.integer(forKey: "time_format_preference") > 0 {
                    formatter.dateFormat = "HH:mm"
                }
                value = ("\(formatter.string(from: sunrise!))/\(formatter.string(from: sunset!))")
            }
        case 29:
            //RPM
            icon = (UIImage(named: "Tachometer")?.withRenderingMode(.alwaysTemplate))!
            if ((motorcycleData.rpm != nil) && motorcycleData.rpm != 0) {
                value = "\(motorcycleData.rpm!)"
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case 30:
            //Lean Angle Bike
            icon = (UIImage(named: "Angle")?.withRenderingMode(.alwaysTemplate))!
            if motorcycleData.leanAngleBike != nil {
                value = "\(Int(round(motorcycleData.leanAngleBike!)))"
            }
        case 31:
            // Rear Wheel Speed
            icon = (UIImage(named: "Tachometer")?.withRenderingMode(.alwaysTemplate))!
            if motorcycleData.rearSpeed != nil {
                let speedValue = motorcycleData.rearSpeed!
                value = "\(Int(speedValue))"
                if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                    value = "\(Int(round(Utility.kmToMiles(speedValue))))"
                }
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        default:
            print("Unknown : \(dataPoint)")
        }
        if let cell = self.collectionView.cellForItem(at: IndexPath(row: cellNumber - 1, section: 0) as IndexPath) as? MainCollectionViewCell{
            cell.setLabel(label: label)
            cell.setValue(value: value)
            cell.setIcon(icon: icon)
        }
    }
    
    func parseCommandResponse(_ data:Data) {
        let dataLength = data.count / MemoryLayout<UInt8>.size
        var dataArray = [UInt8](repeating: 0, count: dataLength)
        (data as NSData).getBytes(&dataArray, length: dataLength * MemoryLayout<Int16>.size)
        
        var messageHexString = ""
        for i in 0 ..< dataLength {
            messageHexString += String(format: "%02X", dataArray[i])
            if i < dataLength - 1 {
                messageHexString += ","
            }
        }
        //print("Command Response Received: \(messageHexString)")
        switch (dataArray[0]){
        case 0x57:
            switch (dataArray[1]){
            case 0x52:
                switch (dataArray[2]){
                case 0x56:
                    print("Received WRV command response")
                    wlqData.setfirmwareVersion(firmwareVersion: "\(dataArray[3]).\(dataArray[4])");
                    break
                case 0x57:
                    print("Received WRW command response")
                    print("Command Response Received: \(messageHexString)")
                    wlqData.parseConfig(bytes: dataArray)
                    popoverMenuList = [NSLocalizedString("bike_info_label", comment: ""), NSLocalizedString("geodata_label", comment: ""),NSLocalizedString("appsettings_label", comment: ""), NSLocalizedString("hwsettings_label", comment: ""), NSLocalizedString("about_label", comment: ""), NSLocalizedString("close_label", comment: "")]
                    break
                default:
                    break;
                }
                break
            default:
                break;
            }
            break
        default:
            break;
        }
    }
    
    // MARK: - CBCentralManagerDelegate methods
    
    // Invoked when the central manager’s state is updated.
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        var showAlert = true
        var message = ""
        
        switch central.state {
        case .poweredOff:
            message = NSLocalizedString("bt_powered_off", comment: "")
        case .unsupported:
            message = NSLocalizedString("bt_not_supported", comment: "")
        case .unauthorized:
            message = NSLocalizedString("bt_not_authorized", comment: "")
        case .resetting:
            message = NSLocalizedString("bt_resetting", comment: "")
        case .unknown:
            message = NSLocalizedString("bt_unknown", comment: "")
        case .poweredOn:
            showAlert = false
            message = NSLocalizedString("bt_ready", comment: "")
            print(message)
            resumeScan()
        default:
            message = NSLocalizedString("bt_unknown", comment: "")
        }
        
        if showAlert {
            NSLog("IN centralManagerDidUpdateState         if showAlert ")
            // Display Alert
            let alertController = UIAlertController(title: NSLocalizedString("bt_alert_title", comment: ""), message: message, preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: NSLocalizedString("alert_message_exit_ok", comment: ""), style: .default, handler: nil)
            alertController.addAction(defaultAction)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    /*
     Invoked when the central manager discovers a peripheral while scanning.
     
     The advertisement data can be accessed through the keys listed in Advertisement Data Retrieval Keys.
     You must retain a local copy of the peripheral if any command is to be performed on it.
     In use cases where it makes sense for your app to automatically connect to a peripheral that is
     located within a certain range, you can use RSSI data to determine the proximity of a discovered
     peripheral device.
     
     central - The central manager providing the update.
     peripheral - The discovered peripheral.
     advertisementData - A dictionary containing any advertisement data.
     RSSI - The current received signal strength indicator (RSSI) of the peripheral, in decibels.
     
     */
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Retrieve the peripheral name from the advertisement data using the "kCBAdvDataLocalName" key
        if let peripheralName = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            if peripheralName.contains(deviceName) {
                print("WunderLINQ FOUND! ADDING NOW!!!")
                // to save power, stop scanning for other devices
                keepScanning = false
                disconnectButton.isEnabled = true
                
                // save a reference to the WunderLINQ
                wunderLINQ = peripheral
                wunderLINQ!.delegate = self
                
                // Request a connection to the peripheral
                centralManager?.connect(wunderLINQ!, options: nil)
            }
        }
    }
    
    /*
     Invoked when a connection is successfully created with a peripheral.
     
     This method is invoked when a call to connectPeripheral:options: is successful.
     You typically implement this method to set the peripheral’s delegate and to discover its services.
     */
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("SUCCESSFULLY CONNECTED TO WunderLINQ!")
        disconnectBtn.tintColor = UIColor.blue
        
        print("Peripheral info: \(peripheral)")
        peripheral.delegate = self
        
        // Now that we've successfully connected to the WunderLINQ, let's discover the services.
        // - NOTE:  we pass nil here to request ALL services be discovered.
        //          If there was a subset of services we were interested in, we could pass the UUIDs here.
        //          Doing so saves battery life and saves time.
        peripheral.discoverServices([CBUUID(string: Device.WunderLINQServiceUUID)])
    }
    
    
    /*
     Invoked when the central manager fails to create a connection with a peripheral.
     
     This method is invoked when a connection initiated via the connectPeripheral:options: method fails to complete.
     Because connection attempts do not time out, a failed connection usually indicates a transient issue,
     in which case you may attempt to connect to the peripheral again.
     */
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("CONNECTION TO WunderLINQ FAILED!")
        disconnectBtn.tintColor = UIColor.red
    }
    
    
    /*
     Invoked when an existing connection with a peripheral is torn down.
     
     This method is invoked when a peripheral connected via the connectPeripheral:options: method is disconnected.
     If the disconnection was not initiated by cancelPeripheralConnection:, the cause is detailed in error.
     After this method is called, no more methods are invoked on the peripheral device’s CBPeripheralDelegate object.
     
     Note that when a peripheral is disconnected, all of its services, characteristics, and characteristic descriptors are invalidated.
     */
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("DISCONNECTED FROM WunderLINQ!")
        disconnectBtn.tintColor = UIColor.red
        motorcycleData.clear()
        updateMessageDisplay()
        if error != nil {
            print("DISCONNECTION DETAILS: \(error!.localizedDescription)")
        }
        wunderLINQ = nil
        popoverMenuList = [NSLocalizedString("bike_info_label", comment: ""),NSLocalizedString("geodata_label", comment: ""),NSLocalizedString("appsettings_label", comment: ""), NSLocalizedString("about_label", comment: ""), NSLocalizedString("close_label", comment: "")]
        
        // Start trying to reconnect
        keepScanning = true
        resumeScan()
    }
    
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
      if let peripheralsObject = dict[CBCentralManagerRestoredStatePeripheralsKey] {
        let peripherals = peripheralsObject as! Array<CBPeripheral>
        if peripherals.count > 0 {
            wunderLINQ = peripherals[0]
            wunderLINQ?.delegate = self
        }
      }
    }
    
    //MARK: - CBPeripheralDelegate methods
    
    /*
     Invoked when you discover the peripheral’s available services.
     
     This method is invoked when your app calls the discoverServices: method.
     If the services of the peripheral are successfully discovered, you can access them
     through the peripheral’s services property.
     
     If successful, the error parameter is nil.
     If unsuccessful, the error parameter returns the cause of the failure.
     */
    // When the specified services are discovered, the peripheral calls the peripheral:didDiscoverServices: method of its delegate object.
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if error != nil {
            print("ERROR DISCOVERING SERVICES: \(error?.localizedDescription ?? "Unknown Error")")
            return
        }
        
        // Core Bluetooth creates an array of CBService objects —- one for each service that is discovered on the peripheral.
        if let services = peripheral.services {
            for service in services {
                print("DISCOVERED SERVICE: \(service)")
                // discover the characteristic.
                if (service.uuid == CBUUID(string: Device.DeviceInformationServiceUUID)) {
                    numServices = numServices + 1
                    peripheral.discoverCharacteristics(nil, for: service)
                } else if (service.uuid == CBUUID(string: Device.WunderLINQServiceUUID)) {
                    numServices = numServices + 1
                    peripheral.discoverCharacteristics(nil, for: service)
                }
            }
        }
        
    }
    
    /*
     Invoked when you discover the characteristics of a specified service.
     
     If the characteristics of the specified service are successfully discovered, you can access
     them through the service's characteristics property.
     
     If successful, the error parameter is nil.
     If unsuccessful, the error parameter returns the cause of the failure.
     */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if error != nil {
            print("ERROR DISCOVERING CHARACTERISTICS: \(error?.localizedDescription ?? "Unknown Error")")
            return
        }
        numServicesChecked = numServicesChecked + 1;
        print("numServicesChecked: \(numServicesChecked)")
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                print("DISCOVERED CHAR: \(characteristic)")
                // Message Data Characteristic
                if characteristic.uuid == CBUUID(string: Device.HWRevisionCharacteristicUUID) {
                    hwRevCharacteristic = characteristic
                } else if characteristic.uuid == CBUUID(string: Device.UUID_WUNDERLINQ_LINMESSAGE_CHARACTERISTIC) {
                    print("Navigator FOUND")
                    wlqData = WLQ_N()
                    // Enable the message notifications
                    messageCharacteristic = characteristic
                    wunderLINQ?.setNotifyValue(true, for: characteristic)
                } else if characteristic.uuid == CBUUID(string: Device.UUID_WUNDERLINQ_CANMESSAGE_CHARACTERISTIC) {
                    print("Commander FOUND")
                    // Enable the message notifications
                    wlqData = WLQ_C()
                    messageCharacteristic = characteristic
                    wunderLINQ?.setNotifyValue(true, for: characteristic)
                } else if characteristic.uuid == CBUUID(string: Device.CommandCharacteristicUUID) {
                    print("COMMAND INTERFACE FOUND")
                    commandCharacteristic = characteristic
                    bleData.setcmdCharacteristic(cmdCharacteristic: characteristic)
                    if(wlqData != nil){
                        print("Sending Command")
                        let writeData =  Data(_: wlqData.GET_CONFIG_CMD())
                        peripheral.writeValue(writeData, for: commandCharacteristic!, type: CBCharacteristicWriteType.withResponse)
                        peripheral.readValue(for: commandCharacteristic!)
                    }
                }
                peripheral.discoverDescriptors(for: characteristic)
            }
            if(numServicesChecked == numServices){
                print("Done Checking")
                if (hwRevCharacteristic != nil){
                    peripheral.readValue(for: hwRevCharacteristic!)
                }
            }
            
        }
    }
    
    
    /*
     Invoked when you retrieve a specified characteristic’s value,
     or when the peripheral device notifies your app that the characteristic’s value has changed.
     
     This method is invoked when your app calls the readValueForCharacteristic: method,
     or when the peripheral notifies your app that the value of the characteristic for
     which notifications and indications are enabled has changed.
     
     If successful, the error parameter is nil.
     If unsuccessful, the error parameter returns the cause of the failure.
     */
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            print("ERROR ON UPDATING VALUE FOR CHARACTERISTIC: \(characteristic) - \(error?.localizedDescription ?? "Unknown Error")")
            return
        }
        
        // extract the data from the characteristic's value property and display the value based on the characteristic type
        if let dataBytes = characteristic.value {
            if characteristic.uuid == CBUUID(string: Device.HWRevisionCharacteristicUUID) {
                if let versionString = String(bytes: dataBytes, encoding: .utf8) {
                    print("HW Version: \(versionString)")
                    hardwareVersion = versionString
                    if (wlqData != nil){
                        wlqData.sethardwareVersion(hardwareVersion: versionString)
                    }
                }
            } else if characteristic.uuid == CBUUID(string: Device.UUID_WUNDERLINQ_LINMESSAGE_CHARACTERISTIC) {
                LINbus.parseMessage(dataBytes)
            } else if characteristic.uuid == CBUUID(string: Device.UUID_WUNDERLINQ_CANMESSAGE_CHARACTERISTIC) {
                CANbus.parseMessage(dataBytes)
            } else if characteristic.uuid == CBUUID(string: Device.CommandCharacteristicUUID) {
                parseCommandResponse(dataBytes)
            }
            
            updatePhoneSensorData()
            if (UserDefaults.standard.bool(forKey: "notification_preference")){
                updateNotification()
            }
            if UserDefaults.standard.bool(forKey: "fuel_routing_enable_preference") && faults.getFuelFaultActive(){
                if !faults.getFuelStationAlertSent(){
                    faults.setFuelStationAlertSent(active:true)
                    
                    if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AlertViewControllerID") as? AlertViewController {
                        viewController.ID = 1
                        if let navigator = navigationController {
                            navigator.pushViewController(viewController, animated: true)
                        }
                    }
                }
                
            }
            if (UIApplication.shared.applicationState == .active) {
                updateMessageDisplay()
            }
        }
    }
    
    @objc func defaultsChanged(notification:NSNotification){
        NSLog("IN maincollectionviewcontroller defaultsChanged")
        if let defaults = notification.object as? UserDefaults {
            if defaults.integer(forKey: "darkmode_lastSet") != defaults.integer(forKey: "darkmode_preference"){
                UserDefaults.standard.set(defaults.integer(forKey: "darkmode_preference"), forKey: "darkmode_lastSet")
                // quit app
                exit(0)
            }
            if UserDefaults.standard.bool(forKey: "display_brightness_preference") {
                UIScreen.main.brightness = CGFloat(1.0)
            } else {
                UIScreen.main.brightness = CGFloat(UserDefaults.standard.float(forKey: "systemBrightness"))
            }
            if (self.collectionView != nil){
                self.collectionView!.reloadData()
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        //displaying the ios local notification when app is in foreground
        completionHandler([.alert, .badge, .sound])
    }
    
    func registerSettingsBundle(){
        let appDefaults = [String:AnyObject]()
        UserDefaults.standard.register(defaults: appDefaults)
    }
    
    private func updateNotification(){
        var alertBody: String = ""
        if(faults.getFrontTirePressureCriticalActive()){
            alertBody += NSLocalizedString("fault_TIREFCF", comment: "") + "\n"
        }
        if(faults.getRearTirePressureCriticalActive()){
            alertBody += NSLocalizedString("fault_TIRERCF", comment: "") + "\n"
        }
        if(faults.getGeneralFlashingRedActive()){
            alertBody += NSLocalizedString("fault_GENWARNFSRED", comment: "") + "\n"
        }
        if(faults.getGeneralShowsRedActive()){
            alertBody += NSLocalizedString("fault_GENWARNSHRED", comment: "") + "\n"
        }
        if(alertBody != ""){
            sendAlert(message: alertBody)
        } else {
            clearNotifications()
        }
    }
    
    private func clearNotifications(){
        NSLog("IN maincollectionviewcontroller clearNotifications")
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications() // To remove all delivered notifications
        center.removeAllPendingNotificationRequests()
    }
    
    private func sendAlert(message:String){
        //creating the notification content
        let content = UNMutableNotificationContent()
        
        //adding title, subtitle, body and badge
        content.title = NSLocalizedString("fault_title", comment: "")
        //content.subtitle = "Sub Title"
        content.body = message
        //content.badge = 1
        content.sound = UNNotificationSound.default
        
        //getting the notification trigger
        //it will be called after 1 second
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        //getting the notification request
        let request = UNNotificationRequest(identifier: "FaultNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().delegate = self
        
        //adding the notification to notification center
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizer.Direction.right {
            rightScreen()
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.left {
            leftScreen()
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.up {
            //UP
            upScreen()
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.down {
            //DOWN
            downScreen()
        }
    }
    
    @objc func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        
        if longPressGestureRecognizer.state == UIGestureRecognizer.State.began {
            let touchPoint = longPressGestureRecognizer.location(in: self.view)
            if let indexPath = collectionView.indexPathForItem(at: touchPoint) {
                showPickerInActionSheet(cell: indexPath.row)
            }
        }
    }
    
    override var keyCommands: [UIKeyCommand]? {
        
        let commands = [
            UIKeyCommand(input: UIKeyCommand.inputLeftArrow, modifierFlags:[], action: #selector(leftScreen), discoverabilityTitle: "Go left"),
            UIKeyCommand(input: UIKeyCommand.inputRightArrow, modifierFlags:[], action: #selector(rightScreen), discoverabilityTitle: "Go right"),
            UIKeyCommand(input: UIKeyCommand.inputUpArrow, modifierFlags:[], action: #selector(upScreen), discoverabilityTitle: "Increase Cell Count"),
            UIKeyCommand(input: UIKeyCommand.inputDownArrow, modifierFlags:[], action: #selector(downScreen), discoverabilityTitle: "Decrease Cell Count")
        ]
        return commands
    }
    
    @objc func leftScreen() {
        performSegue(withIdentifier: "motorcycleToTaskGrid", sender: [])
    }
    
    @objc func rightScreen() {
        if UserDefaults.standard.bool(forKey: "display_dashboard_preference") {
            performSegue(withIdentifier: "motorcycleToDash", sender: [])
        } else {
            performSegue(withIdentifier: "motorcycleToMusic", sender: [])
        }
    }
    
    @objc func upScreen() {
        let cellCount = UserDefaults.standard.integer(forKey: "GRIDCOUNT")
        var nextCellCount = 1
        if ( collectionView!.bounds.width > collectionView!.bounds.height){
            switch (cellCount){
            case 1:
                cellsPerRow = 2
                rowCount = 1
                nextCellCount = 2
            case 2:
                cellsPerRow = 2
                rowCount = 2
                nextCellCount = 4
            case 4:
                cellsPerRow = 4
                rowCount = 2
                nextCellCount = 8
            case 8:
                cellsPerRow = 5
                rowCount = 2
                nextCellCount = 10
            case 10:
                cellsPerRow = 4
                rowCount = 3
                nextCellCount = 12
            case 12:
                cellsPerRow = 5
                rowCount = 3
                nextCellCount = 15
            case 15:
                cellsPerRow = 1
                rowCount = 1
                nextCellCount = 1
            default:
                print("Unknown Cell Count")
            }
        } else {
            switch (cellCount){
            case 1:
                cellsPerRow = 1
                rowCount = 2
                nextCellCount = 2
            case 2:
                cellsPerRow = 1
                rowCount = 4
                nextCellCount = 4
            case 4:
                cellsPerRow = 2
                rowCount = 4
                nextCellCount = 8
            case 8:
                cellsPerRow = 2
                rowCount = 5
                nextCellCount = 10
            case 10:
                cellsPerRow = 3
                rowCount = 4
                nextCellCount = 12
            case 12:
                cellsPerRow = 3
                rowCount = 5
                nextCellCount = 15
            case 15:
                cellsPerRow = 1
                rowCount = 1
                nextCellCount = 1
            default:
                print("Unknown Cell Count")
            }
        }
        UserDefaults.standard.set(nextCellCount, forKey: "GRIDCOUNT")
        
        self.collectionView!.collectionViewLayout.invalidateLayout()
        self.collectionView!.reloadData()
    }
    
    @objc func downScreen() {
        let cellCount = UserDefaults.standard.integer(forKey: "GRIDCOUNT")
        var nextCellCount = 1
        if ( collectionView!.bounds.width > collectionView!.bounds.height){
            switch (cellCount){
            case 1:
                cellsPerRow = 5
                rowCount = 3
                nextCellCount = 15
            case 2:
                cellsPerRow = 1
                rowCount = 1
                nextCellCount = 1
            case 4:
                cellsPerRow = 2
                rowCount = 1
                nextCellCount = 2
            case 8:
                cellsPerRow = 2
                rowCount = 2
                nextCellCount = 4
            case 10:
                cellsPerRow = 4
                rowCount = 2
                nextCellCount = 8
            case 12:
                cellsPerRow = 5
                rowCount = 2
                nextCellCount = 10
            case 15:
                cellsPerRow = 4
                rowCount = 3
                nextCellCount = 12
            default:
                print("Unknown Cell Count")
            }
        } else {
            switch (cellCount){
            case 1:
                cellsPerRow = 3
                rowCount = 5
                nextCellCount = 15
            case 2:
                cellsPerRow = 1
                rowCount = 1
                nextCellCount = 1
            case 4:
                cellsPerRow = 1
                rowCount = 2
                nextCellCount = 2
            case 8:
                cellsPerRow = 1
                rowCount = 4
                nextCellCount = 4
            case 10:
                cellsPerRow = 2
                rowCount = 4
                nextCellCount = 8
            case 12:
                cellsPerRow = 2
                rowCount = 5
                nextCellCount = 10
            case 15:
                cellsPerRow = 3
                rowCount = 4
                nextCellCount = 12
            default:
                print("Unknown Cell Count")
            }
        }
        UserDefaults.standard.set(nextCellCount, forKey: "GRIDCOUNT")
        self.collectionView!.collectionViewLayout.invalidateLayout()
        self.collectionView!.reloadData()
    }
    
    func showPickerInActionSheet(cell: Int) {
        let title = ""
        let message = "\n\n\n\n\n\n\n\n\n\n";

        let width:CGFloat = 300
        let highth:CGFloat = 150
        
        let alertStyle = UIAlertController.Style.alert
        let alert = UIAlertController(title: title, message: message, preferredStyle: alertStyle);
        alert.isModalInPopover = true;

        // height constraint
        let constraintHeight = NSLayoutConstraint(
           item: alert.view!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute:
           NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: highth)
        alert.view.addConstraint(constraintHeight)

        // width constraint
        let constraintWidth = NSLayoutConstraint(
           item: alert.view!, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute:
           NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: width)
        alert.view.addConstraint(constraintWidth)
        
        //Create a frame (placeholder/wrapper) for the picker and then create the picker
        let pickerFrame = CGRect(x: 16, y: 0, width: width - (16 * 2), height: highth - 50)
        let picker: UIPickerView = UIPickerView(frame: pickerFrame)
        
        //set the pickers datasource and delegate
        picker.delegate   = self
        picker.dataSource = self
        picker.tag = cell
        
        var currentDataPoint = 0
        switch (cell){
        case 0:
            currentDataPoint = UserDefaults.standard.integer(forKey: "grid_one_preference")
        case 1:
            currentDataPoint = UserDefaults.standard.integer(forKey: "grid_two_preference")
        case 2:
            currentDataPoint = UserDefaults.standard.integer(forKey: "grid_three_preference")
        case 3:
            currentDataPoint = UserDefaults.standard.integer(forKey: "grid_four_preference")
        case 4:
            currentDataPoint = UserDefaults.standard.integer(forKey: "grid_five_preference")
        case 5:
            currentDataPoint = UserDefaults.standard.integer(forKey: "grid_six_preference")
        case 6:
            currentDataPoint = UserDefaults.standard.integer(forKey: "grid_seven_preference")
        case 7:
            currentDataPoint = UserDefaults.standard.integer(forKey: "grid_eight_preference")
        case 8:
            currentDataPoint = UserDefaults.standard.integer(forKey: "grid_nine_preference")
        case 9:
            currentDataPoint = UserDefaults.standard.integer(forKey: "grid_ten_preference")
        case 10:
            currentDataPoint = UserDefaults.standard.integer(forKey: "grid_eleven_preference")
        case 11:
            currentDataPoint = UserDefaults.standard.integer(forKey: "grid_twelve_preference")
        case 12:
            currentDataPoint = UserDefaults.standard.integer(forKey: "grid_thirteen_preference")
        case 13:
            currentDataPoint = UserDefaults.standard.integer(forKey: "grid_fourteen_preference")
        case 14:
            currentDataPoint = UserDefaults.standard.integer(forKey: "grid_fifteen_preference")
        default:
            currentDataPoint = 0
        }
        
        picker.selectRow(currentDataPoint, inComponent: 0, animated: true)
        selectedCell = cell
        
        //Add the picker to the alert controller
        alert.view.addSubview(picker)

        let okAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("select_bt", comment: ""), style: .default) { action -> Void in
            self.saveCellPref()
        }

        let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("cancel_bt", comment: ""), style: .default) { action -> Void in }

        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        if let presenter = alert.popoverPresentationController {
            presenter.sourceView = self.view
                presenter.sourceRect = self.view.bounds
        }
        present(alert, animated: true, completion: nil)
    }
    
    // returns number of rows in each component..
    func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.dataPointList.count
    }
    
    // Return the title of each row in your picker ... In my case that will be the profile name or the username string
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.dataPointList[row]
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedDataPoint = row
    }
    
    @objc func saveCellPref() {
        self.dismiss(animated: true, completion: nil)
        switch (selectedCell){
        case 0:
            UserDefaults.standard.set(selectedDataPoint, forKey: "grid_one_preference")
        case 1:
            UserDefaults.standard.set(selectedDataPoint, forKey: "grid_two_preference")
        case 2:
            UserDefaults.standard.set(selectedDataPoint, forKey: "grid_three_preference")
        case 3:
            UserDefaults.standard.set(selectedDataPoint, forKey: "grid_four_preference")
        case 4:
            UserDefaults.standard.set(selectedDataPoint, forKey: "grid_five_preference")
        case 5:
            UserDefaults.standard.set(selectedDataPoint, forKey: "grid_six_preference")
        case 6:
            UserDefaults.standard.set(selectedDataPoint, forKey: "grid_seven_preference")
        case 7:
            UserDefaults.standard.set(selectedDataPoint, forKey: "grid_eight_preference")
        case 8:
            UserDefaults.standard.set(selectedDataPoint, forKey: "grid_nine_preference")
        case 9:
            UserDefaults.standard.set(selectedDataPoint, forKey: "grid_ten_preference")
        case 10:
            UserDefaults.standard.set(selectedDataPoint, forKey: "grid_eleven_preference")
        case 11:
            UserDefaults.standard.set(selectedDataPoint, forKey: "grid_twelve_preference")
        case 12:
            UserDefaults.standard.set(selectedDataPoint, forKey: "grid_thirteen_preference")
        case 13:
            UserDefaults.standard.set(selectedDataPoint, forKey: "grid_fourteen_preference")
        case 14:
            UserDefaults.standard.set(selectedDataPoint, forKey: "grid_fifteen_preference")
        default:
            print("Unknown Cell")
        }
        let _ = UserDefaults.standard.synchronize()
    }
    
    func updatePhoneSensorData() {
        let data = motionManager.deviceMotion
        if (data != nil){
            let attitude = data!.attitude
            if (referenceAttitude != nil){
                attitude.multiply(byInverseOf: referenceAttitude!)
            } else {
                referenceAttitude = attitude
            }
            let leanAngle = Utility.degrees(radians: attitude.yaw)
            //Filter out impossible values, max sport bike lean is +/-60
            if ((leanAngle >= -60.0) && (leanAngle <= 60.0)) {
                motorcycleData.setleanAngle(leanAngle: Utility.degrees(radians: attitude.yaw))
                //Store Max L and R lean angle
                if (leanAngle < 0) {
                    if (motorcycleData.leanAngleMaxR != nil) {
                        if (abs(leanAngle) > motorcycleData.getleanAngleMaxR()) {
                            motorcycleData.setleanAngleMaxR(leanAngleMaxR: abs(leanAngle))
                        }
                    } else {
                        motorcycleData.setleanAngleMaxR(leanAngleMaxR: abs(leanAngle));
                    }
                } else if (leanAngle > 0) {
                    if (motorcycleData.leanAngleMaxL != nil) {
                        if (leanAngle > motorcycleData.getleanAngleMaxL()) {
                            motorcycleData.setleanAngleMaxL(leanAngleMaxL: leanAngle);
                        }
                    } else {
                        motorcycleData.setleanAngleMaxL(leanAngleMaxL: leanAngle);
                    }
                }
            }
            //g force
            motorcycleData.setgForce(gForce: sqrt (pow(data!.userAcceleration.x,2) + pow(data!.userAcceleration.y,2) + pow(data!.userAcceleration.z,2)))
        }
    }

    @objc func onTouch() {
        DispatchQueue.main.async(){
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
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
            isTimerRunning = false
            seconds = 10
            // Hide the navigation bar on the this view controller
            NSLog("IN maincollectionviewcontroller updateTimer")
            DispatchQueue.main.async(){
                self.navigationController?.setNavigationBarHidden(true, animated: true)
                self.navigationController?.setStatusBar(backgroundColor: .black)
                self.navigationController?.navigationBar.setNeedsLayout()
                if (self.collectionView != nil){
                    self.collectionView!.reloadData()
                }
            }
        } else {
            seconds -= 1
        }
    }
    
    func updateTimeTimer(){
        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
        timeTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTime), userInfo: nil, repeats: true)
    }
    
    @objc func updateTime(){
        if (wlqData != nil){
            if (wlqData.gethardwareType() == wlqData.TYPE_NAVIGATOR()){
                // get the current date and time
                let currentDateTime = Date()
                // get the date time String from the date object
                motorcycleData.setTime(time: currentDateTime)
                updateMessageDisplay()
                
                //Update CLuster Clock
                let calendar = Calendar.current
                let yearInt = calendar.component(.year, from: currentDateTime)
                let monthInt = calendar.component(.month, from: currentDateTime)
                let dayInt = calendar.component(.day, from: currentDateTime)
                let hourInt = calendar.component(.hour, from: currentDateTime)
                let minuteInt = calendar.component(.minute, from: currentDateTime)
                let secondInt = calendar.component(.second, from: currentDateTime)
                let yearByte: UInt16 = UInt16(yearInt)
                let yearHByte:UInt8 = UInt8(yearByte >> 4)
                let yearLByte:UInt8 = UInt8(yearByte & 0x00ff)
                let yearNibble:UInt8 = (yearLByte & 0x0F)
                let monthNibble:UInt8 = UInt8(monthInt)
                let monthYearByte:UInt8 = ((yearNibble & 0x0F) << 4 | (monthNibble & 0x0F))
                let clockCommand:[UInt8] = [0x57, 0x57, 0x44, 0x43, UInt8(secondInt), UInt8(minuteInt), UInt8(hourInt), UInt8(dayInt), monthYearByte, yearHByte]
                let writeData =  Data(_: clockCommand)
                if (self.commandCharacteristic != nil){
                    self.wunderLINQ?.writeValue(writeData, for: self.commandCharacteristic!, type: CBCharacteristicWriteType.withResponse)
                }
            } else {
                timeTimer.invalidate()
            }
        }
    }
}

extension MainCollectionViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch(indexPath.row) {
        case 0:
            //Bike Info
            performSegue(withIdentifier: "motorcycleToBikeInfo", sender: self)
        case 1:
            //Geo Data
            performSegue(withIdentifier: "motorcycleToGeoData", sender: self)
        case 2:
            //App Settings
            performSegue(withIdentifier: "motorcycleToSettings", sender: self)
        case 3:
            if (popoverMenuList.count == 6){
                //HW Settings
                performSegue(withIdentifier: "motorcycleToHWSettings", sender: self)
            } else {
                //About
                performSegue(withIdentifier: "motorcycleToAbout", sender: self)   
            }
        case 4:
            if (popoverMenuList.count == 6){
                //About
                performSegue(withIdentifier: "motorcycleToAbout", sender: self)
            } else {
                exit(0)
            }
        case 5:
            exit(0)
        default:
            print("Unknown option")
        }
        self.popover.dismiss()
    }
    
}

extension MainCollectionViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return popoverMenuList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = self.popoverMenuList[(indexPath as NSIndexPath).row]
        return cell
    }
}

extension UIImage {
    func imageWithColor(color1: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        color1.setFill()

        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        context?.setBlendMode(CGBlendMode.normal)

        let rect = CGRect(origin: .zero, size: CGSize(width: self.size.width, height: self.size.height))
        context?.clip(to: rect, mask: self.cgImage!)
        context?.fill(rect)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
}
