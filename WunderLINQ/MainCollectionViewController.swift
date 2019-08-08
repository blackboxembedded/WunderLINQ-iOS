//
//  MainCollectionViewController.swift
//  WunderLINQ
//
//  Created by Keith Conger on 1/27/19.
//  Copyright © 2019 Black Box Embedded, LLC. All rights reserved.
//

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
    var messageCharacteristic:CBCharacteristic?
    var commandCharacteristic:CBCharacteristic?
    
    let deviceName = "WunderLINQ"
    
    // define our scanning interval times
    let timerPauseInterval:TimeInterval = 5
    let timerScanInterval:TimeInterval = 2
    
    var keepScanning = false
    
    var lastMessage = [UInt8]()
    
    let wlqData = WLQ.shared
    let bleData = BLE.shared
    let motorcycleData = MotorcycleData.shared
    let faults = Faults.shared
    var prevBrakeValue = 0
    
    let motionManager = CMMotionManager()
    var referenceAttitude: CMAttitude?
    
    var menuSelected = 0
    fileprivate var popoverMenuList = [NSLocalizedString("geodata_label", comment: ""),NSLocalizedString("appsettings_label", comment: ""), NSLocalizedString("about_label", comment: ""), NSLocalizedString("close_label", comment: "")]
    fileprivate var popover: Popover!
    fileprivate var popoverOptions: [PopoverOption] = [
        .type(.auto),
        .blackOverlayColor(UIColor(white: 0.0, alpha: 0.6))
    ]
    
    var seconds = 10
    var timer = Timer()
    var timeTimer = Timer()
    var isTimerRunning = false
    
    let inset: CGFloat = 5
    let minimumLineSpacing: CGFloat = 5
    let minimumInteritemSpacing: CGFloat = 5
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
                         NSLocalizedString("sunrisesunset_header", comment: "")
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
        if UserDefaults.standard.bool(forKey: "nightmode_preference") {
            if(self.navigationController?.isToolbarHidden ?? false){
                return .default
            } else {
                return .lightContent
            }
        } else {
            if(self.navigationController?.isToolbarHidden ?? false){
                return .lightContent
            } else {
                return .default
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        referenceAttitude = nil
        checkPermissions()
        if isTimerRunning == false {
            runTimer()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        registerSettingsBundle()
        NotificationCenter.default.addObserver(self, selector: #selector(self.defaultsChanged), name: UserDefaults.didChangeNotification, object: nil)
        if UserDefaults.standard.bool(forKey: "nightmode_preference") {
            Theme.dark.apply()
            self.navigationController?.isNavigationBarHidden = true
            self.navigationController?.isNavigationBarHidden = false
        } else {
            Theme.default.apply()
            self.navigationController?.isNavigationBarHidden = true
            self.navigationController?.isNavigationBarHidden = false
        }
        
        if UserDefaults.standard.bool(forKey: "motorcycle_data_preference") {
            for mainUIView in self.mainUIView.subviews {
            }
            for mainUIView in self.mainUIView.subviews {
                mainUIView.removeFromSuperview()
            }
            
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.mainUIView.bounds.width, height: 75))
            label.center = self.view.center
            label.textAlignment = .center
            var imageName = "wunderlinq_logo-black"
            if UserDefaults.standard.bool(forKey: "nightmode_preference") {
                label.textColor = .white
                mainUIView.backgroundColor = .black
                imageName = "wunderlinq_logo-white"
                
            } else {
                label.textColor = .black
                mainUIView.backgroundColor = .white
                imageName = "wunderlinq_logo-black"
            }
            label.font = UIFont.boldSystemFont(ofSize: 40)
            label.text = NSLocalizedString("product", comment: "")
            let image = UIImage(named: imageName)
            let imageView = UIImageView(image: image!)
            imageView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 200)
            imageView.center = self.view.center
            imageView.contentMode = .scaleAspectFit
            mainUIView.addSubview(imageView)
        } else {
            if UserDefaults.standard.bool(forKey: "nightmode_preference") {
                collectionView.backgroundColor = .white
            } else {
                collectionView.backgroundColor = .black
            }
        }
        
        if UserDefaults.standard.bool(forKey: "display_brightness_preference") {
            UIScreen.main.brightness = CGFloat(1.0)
        } else {
            UIScreen.main.brightness = CGFloat(UserDefaults.standard.float(forKey: "systemBrightness"))
        }
        
        centralManager = CBCentralManager(delegate: self,
                                          queue: nil)
        
        /*
         centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionRestoreIdentifierKey : Device.restoreIdentifier])
         */
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
        menuBtn.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
        let menuButton = UIBarButtonItem(customView: menuBtn)
        let menuButtonWidth = menuButton.customView?.widthAnchor.constraint(equalToConstant: 30)
        menuButtonWidth?.isActive = true
        let menuButtonHeight = menuButton.customView?.heightAnchor.constraint(equalToConstant: 30)
        menuButtonHeight?.isActive = true
        
        let forwardBtn = UIButton()
        forwardBtn.setImage(UIImage(named: "Right")?.withRenderingMode(.alwaysTemplate), for: .normal)
        forwardBtn.addTarget(self, action: #selector(rightScreen), for: .touchUpInside)
        let forwardButton = UIBarButtonItem(customView: forwardBtn)
        let forwardButtonWidth = forwardButton.customView?.widthAnchor.constraint(equalToConstant: 30)
        forwardButtonWidth?.isActive = true
        let forwardButtonHeight = forwardButton.customView?.heightAnchor.constraint(equalToConstant: 30)
        forwardButtonHeight?.isActive = true
        
        self.navigationItem.title = NSLocalizedString("main_title", comment: "")
        self.navigationItem.leftBarButtonItems = [backButton, disconnectButton, faultsButton]
        self.navigationItem.rightBarButtonItems = [forwardButton, menuButton]
        
        var dateFormat = "yyyyMMdd"
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
            
            self.motorcycleData.setbearing(bearing: degrees)
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
        updateCollectionViewLayout(with: size)
        referenceAttitude = nil
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        timer.invalidate()
        seconds = 0
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func updateCollectionViewLayout(with size: CGSize) {
        if (collectionView != nil){
            if let layout = collectionView!.collectionViewLayout as? UICollectionViewFlowLayout {
                var cellCount = UserDefaults.standard.integer(forKey: "GRIDCOUNT");
                var height:CGFloat
                var width:CGFloat
                var widthMarginsAndInsets:CGFloat
                var heightMarginsAndInsets:CGFloat
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
            widthMarginsAndInsets = inset * 2 + collectionView.safeAreaInsets.left + collectionView.safeAreaInsets.right + minimumInteritemSpacing * CGFloat(cellsPerRow - 1)
            heightMarginsAndInsets = inset * 2 + collectionView.safeAreaInsets.top + collectionView.safeAreaInsets.bottom + minimumInteritemSpacing * CGFloat(rowCount - 1)
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
                width = ((self.view.bounds.size.width - (widthMarginsAndInsets * 2)) / CGFloat(4)).rounded(.down)
            case 12:
                height = ((self.view.bounds.size.height - (heightMarginsAndInsets)) / CGFloat(3)).rounded(.down)
                width = ((self.view.bounds.size.width - (widthMarginsAndInsets * 2)) / CGFloat(4)).rounded(.down)
            case 15:
                height = ((self.view.bounds.size.height - (heightMarginsAndInsets)) / CGFloat(3)).rounded(.down)
                width = ((self.view.bounds.size.width - (widthMarginsAndInsets * 2)) / CGFloat(5)).rounded(.down)
            default:
                cellCount = 15
                UserDefaults.standard.set(15, forKey: "GRIDCOUNT")
                height = ((self.view.bounds.size.height - (heightMarginsAndInsets)) / CGFloat(3)).rounded(.down)
                width = ((self.view.bounds.size.width - (widthMarginsAndInsets * 2)) / CGFloat(5)).rounded(.down)
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
        if UserDefaults.standard.bool(forKey: "nightmode_preference") {
            cell.setColors(backgroundColor: .black, textColor: .white)
        } else {
            cell.setColors(backgroundColor: .white, textColor: .black)
        }
        let label = getLabel(cell: indexPath.row + 1)
        cell.setLabel(label: label)
    
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
            //print("willShowHandler")
        }
        self.popover.didShowHandler = {
            //print("didDismissHandler")
        }
        self.popover.willDismissHandler = {
            //print("willDismissHandler")
        }
        self.popover.didDismissHandler = {
            //print("didDismissHandler")
        }
        self.popover.show(tableView, fromView: self.menuBtn)
    }
    
    @objc func menuButtonTapped() {
        popUpMenu()
    }
    
    @objc func btButtonTapped(_ sender: UIBarButtonItem) {
        // if we don't have a WunderLINQ, start scanning for one...
        print("btButtonTapped()")
        if wunderLINQ == nil {
            print("btButtonTapped() scan")
            keepScanning = true
            resumeScan()
        } else {
            disconnect()
        }
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
    
    func getLabel(cell: Int) -> String {
        var label:String = ""
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
            NSLog("Unknown cell")
        }
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
            NSLog("Unknown pressure unit setting")
        }
        if UserDefaults.standard.integer(forKey: "temperature_unit_preference") == 1 {
            temperatureUnit = "F"
        }
        if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
            distanceUnit = "mi"
            distanceTimeUnit = "mph"
            consumptionUnit = "mpg"
            heightUnit = "ft"
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
        default:
            NSLog("Unknown : \(cellDataPoint)")
        }
        
        return label
    }
    
    // MARK: - Updating UI
    func updateMessageDisplay() {
        // Update Buttons
        //disconnectBtn.tintColor = UIColor.blue
        if (faults.getallActiveDesc().isEmpty){
            faultsBtn.tintColor = UIColor.clear
            faultsButton.isEnabled = false
        } else {
            faultsBtn.tintColor = UIColor.red
            faultsButton.isEnabled = true
        }
        self.navigationItem.leftBarButtonItems = [backButton, disconnectButton, faultsButton]
        
        if !UserDefaults.standard.bool(forKey: "motorcycle_data_preference"){
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
    }
    
    func setCellText(_ cellNumber: Int, dataPoint: Int){
        
        let label = getLabel(cell: cellNumber)
        var value:String = NSLocalizedString("blank_field", comment: "")
        
        switch (dataPoint){
        case 0:
            // Gear
            if motorcycleData.gear != nil {
                value = motorcycleData.getgear()
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case 1:
            // Engine Temperature
            if motorcycleData.engineTemperature != nil {
                var engineTemp:Double = motorcycleData.engineTemperature!
                if UserDefaults.standard.integer(forKey: "temperature_unit_preference") == 1 {
                    engineTemp = Utility.celciusToFahrenheit(engineTemp)
                }
                value = "\(engineTemp.rounded(toPlaces: 1))"
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case 2:
            // Ambient Temperature
            if motorcycleData.ambientTemperature != nil {
                var ambientTemp:Double = motorcycleData.ambientTemperature!
                if UserDefaults.standard.integer(forKey: "temperature_unit_preference") == 1 {
                    ambientTemp = Utility.celciusToFahrenheit(ambientTemp)
                }
                value = "\(ambientTemp.rounded(toPlaces: 1))"
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case 3:
            // Front Tire Pressure
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
        case 4:
            // Rear Tire Pressure
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
        case 5:
            // Odometer
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
            if motorcycleData.voltage != nil {
                value = "\(motorcycleData.voltage!)"
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case 7:
            // Trottle
            if motorcycleData.throttlePosition != nil {
                value = "\(Int(round(motorcycleData.throttlePosition!)))"
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case 8:
            // Front Brakes
            if motorcycleData.frontBrake != nil {
                value = "\(motorcycleData.frontBrake!)"
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case 9:
            // Rear Brakes
            if motorcycleData.rearBrake != nil {
                value = "\(motorcycleData.rearBrake!)"
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case 10:
            // Ambient Light
            if motorcycleData.ambientLight != nil {
                value = "\(motorcycleData.ambientLight!)"
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case 11:
            // Trip 1
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
            if motorcycleData.currentConsumption != nil {
                let currentConsumptionValue:Double = motorcycleData.currentConsumption!
                value = "\(currentConsumptionValue.rounded(toPlaces: 1))"
                if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                    value = "\(Utility.l100ToMpg(currentConsumptionValue).rounded(toPlaces: 1))"
                }
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case 17:
            //Fuel Economy One
            if motorcycleData.fuelEconomyOne != nil {
                let fuelEconomyOneValue:Double = motorcycleData.fuelEconomyOne!
                value = "\(fuelEconomyOneValue.rounded(toPlaces: 1))"
                if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                    value = "\(Utility.l100ToMpg(fuelEconomyOneValue).rounded(toPlaces: 1))"
                }
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case 18:
            //Fuel Economy Two
            if motorcycleData.fuelEconomyTwo != nil {
                let fuelEconomyTwoValue:Double = motorcycleData.fuelEconomyTwo!
                value = "\(fuelEconomyTwoValue.rounded(toPlaces: 1))"
                if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                    value = "\(Utility.l100ToMpg(fuelEconomyTwoValue).rounded(toPlaces: 1))"
                }
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case 19:
            //Fuel Range
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
            if motorcycleData.shifts != nil {
                value = "\(motorcycleData.shifts!)"
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case 21:
            //Lean Angle
            if motorcycleData.leanAngle != nil {
                value = "\(Int(round(motorcycleData.leanAngle!)))"
            }
        case 22:
            //g-force
            if motorcycleData.gForce != nil {
                value = "\(motorcycleData.gForce!.rounded(toPlaces: 1))"
            }
        case 23:
            //Bearing
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
            if motorcycleData.time != nil {
                value = "\(motorcycleData.time!)"
            }
        case 25:
            //Barometric Pressure
            if motorcycleData.barometricPressure != nil {
                value = "\(Int(round(motorcycleData.barometricPressure!)))"
            }
        case 26:
            //GPS speed
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
            if motorcycleData.location != nil {
                //value = "\(motorcycleData.barometricPressure!.rounded(toPlaces: 2))"
                var altitude:String = "\(Int(round(motorcycleData.location!.altitude)))"
                if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                    altitude = "\(Int(round(Utility.mtoFeet(motorcycleData.location!.altitude))))"
                }
                value = altitude
            }
        case 28:
            //Sunrise/Sunset
            if motorcycleData.location != nil {
                let solar = Solar(coordinate: motorcycleData.location!.coordinate)
                let sunrise = solar?.sunrise
                let sunset = solar?.sunset
                
                let formatter = DateFormatter()
                formatter.dateFormat = "h:mm a"
                
                value = ("\(formatter.string(from: sunrise!))/\(formatter.string(from: sunset!))")
            }
        default:
            NSLog("Unknown : \(dataPoint)")
        }
        if let cell = self.collectionView.cellForItem(at: IndexPath(row: cellNumber - 1, section: 0) as IndexPath) as? MainCollectionViewCell{
            cell.setLabel(label: label)
            cell.setValue(value: value)
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
        //NSLog("Command Response Received: \(messageHexString)")
        
        switch (dataArray[0]){
        case 0x57:
            switch (dataArray[1]){
            case 0x52:
                switch (dataArray[2]){
                case 0x57:
                    print("Received WRW command response")
                    wlqData.setwwMode(wwMode: dataArray[26])
                    wlqData.setwwHoldSensitivity(wwHoldSensitivity: dataArray[34])
                    popoverMenuList = [NSLocalizedString("geodata_label", comment: ""),NSLocalizedString("appsettings_label", comment: ""), NSLocalizedString("hwsettings_label", comment: ""), NSLocalizedString("about_label", comment: ""), NSLocalizedString("close_label", comment: "")]
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
    
    func parseMessage(_ data:Data) {
        let dataLength = data.count / MemoryLayout<UInt8>.size
        var dataArray = [UInt8](repeating: 0, count: dataLength)
        (data as NSData).getBytes(&dataArray, length: dataLength * MemoryLayout<Int16>.size)
        
        //print(messageHexString)
        // Log raw messages
        if UserDefaults.standard.bool(forKey: "debug_logging_preference") {
            /*
             let message       = "Don´t try to read this text. Top Secret Stuff"
             let messageData   = Array(message.utf8)
             */
            let keyData       = Array("wTKkVwtrBbrZKmYj".utf8)
            let ivData        = Array("abcdefghijklmnop".utf8)
            let encryptedData = testCrypt(data:dataArray,   keyData:keyData, ivData:ivData, operation:kCCEncrypt)!
            //let decryptedData = testCrypt(data:encryptedData, keyData:keyData, ivData:ivData, operation:kCCDecrypt)!
            //var decrypted     = String(bytes:decryptedData, encoding:String.Encoding.utf8)!
            var messageHexString = ""
            for i in 0 ..< encryptedData.count {
                messageHexString += String(format: "%02X", encryptedData[i])
            }
            Logger.logDBG(entry: messageHexString)
        }
        
        lastMessage = dataArray
        switch lastMessage[0] {
        case 0x00:
            //print("Message ID: 0")
            let bytes: [UInt8] = [lastMessage[1],lastMessage[2],lastMessage[3],lastMessage[4],lastMessage[5],lastMessage[6],lastMessage[7]]
            let vin = String(bytes: bytes, encoding: .utf8)
            motorcycleData.setVIN(vin: vin)
        case 0x01:
            //print("Message ID: 1")
            // Fuel Range
            if ((lastMessage[4] != 0xFF) && (lastMessage[5] != 0xFF)){
                let firstNibble = Double((lastMessage[4] >> 4) & 0x0F)
                let secondNibble = Double((lastMessage[5] & 0x0F)) * 16
                let thirdNibble = Double(((lastMessage[5] >> 4) & 0x0F)) * 256
                let fuelRange = firstNibble + secondNibble + thirdNibble
                motorcycleData.setfuelRange(fuelRange: fuelRange)
            }
            // Ambient Light
            let ambientLightValue = lastMessage[6] & 0x0F
            motorcycleData.setambientLight(ambientLight: Double(ambientLightValue))
        case 0x05:
            //print("Message ID: 5")
            let brakes = (lastMessage[2] >> 4) & 0x0F // the highest 4 bits.
            if(prevBrakeValue == 0){
                prevBrakeValue = Int(brakes)
            }
            if (prevBrakeValue != brakes) {
                prevBrakeValue = Int(brakes);
                switch (brakes) {
                case 0x6:
                    //Front
                    motorcycleData.setfrontBrake(frontBrake: motorcycleData.frontBrake! + 1)
                    
                case 0x9:
                    //Back
                    motorcycleData.setrearBrake(rearBrake: motorcycleData.rearBrake! + 1)
                    
                case 0xA:
                    //Both
                    motorcycleData.setfrontBrake(frontBrake: motorcycleData.frontBrake! + 1)
                    motorcycleData.setrearBrake(rearBrake: motorcycleData.rearBrake! + 1)
                    
                default:
                    break
                }
            }
            // ABS Fault
            let absValue = lastMessage[3] & 0x0F // the lowest 4 bits
            switch (absValue){
            case 0x2:
                faults.setAbsSelfDiagActive(active: false)
                faults.setAbsSelfDiagActive(active: false)
                faults.setAbsDeactivatedActive(active: false)
                faults.setAbsErrorActive(active: true)
                
            case 0x3:
                faults.setAbsSelfDiagActive(active: true)
                faults.setAbsDeactivatedActive(active: false)
                faults.setAbsErrorActive(active: false)
                break;
            case 0x5:
                faults.setAbsSelfDiagActive(active: false)
                faults.setAbsDeactivatedActive(active: false)
                faults.setAbsErrorActive(active: true)
                
            case 0x6:
                faults.setAbsSelfDiagActive(active: false)
                faults.setAbsDeactivatedActive(active: false)
                faults.setAbsErrorActive(active: true)
                
            case 0x7:
                faults.setAbsSelfDiagActive(active: false)
                faults.setAbsDeactivatedActive(active: false)
                faults.setAbsErrorActive(active: true)
                
            case 0x8:
                faults.setAbsSelfDiagActive(active: false)
                faults.setAbsDeactivatedActive(active: true)
                faults.setAbsErrorActive(active: false)
                
            case 0xA:
                faults.setAbsSelfDiagActive(active: false)
                faults.setAbsDeactivatedActive(active: false)
                faults.setAbsErrorActive(active: true)
                
            case 0xB:
                faults.setAbsSelfDiagActive(active: true)
                faults.setAbsDeactivatedActive(active: false)
                faults.setAbsErrorActive(active: false)
                
            case 0xD:
                faults.setAbsSelfDiagActive(active: false)
                faults.setAbsDeactivatedActive(active: false)
                faults.setAbsErrorActive(active: true)
                
            case 0xE:
                faults.setAbsSelfDiagActive(active: false)
                faults.setAbsDeactivatedActive(active: false)
                faults.setAbsErrorActive(active: true)
                
            case 0xF:
                faults.setAbsSelfDiagActive(active: false)
                faults.setAbsDeactivatedActive(active: false)
                faults.setAbsErrorActive(active: false)
                
            default:
                faults.setAbsSelfDiagActive(active: false)
                faults.setAbsDeactivatedActive(active: false)
                faults.setAbsErrorActive(active: false)
                break;
            }
            
            // Tire Pressure
            if ((lastMessage[4] != 0xFF) && (lastMessage[5] != 0xFF)){
                var frontPressure:Double = Double(lastMessage[4]) / 50
                var rearPressure:Double = Double(lastMessage[5]) / 50
                motorcycleData.setfrontTirePressure(frontTirePressure: frontPressure)
                motorcycleData.setrearTirePressure(rearTirePressure: rearPressure)
                if UserDefaults.standard.bool(forKey: "custom_tpm_preference"){
                    switch UserDefaults.standard.integer(forKey: "pressure_unit_preference"){
                    case 1:
                        frontPressure = Utility.barTokPa(frontPressure)
                        rearPressure = Utility.barTokPa(rearPressure)
                    case 2:
                        frontPressure = Utility.barTokgf(frontPressure)
                        rearPressure = Utility.barTokgf(rearPressure)
                    case 3:
                        frontPressure = Utility.barToPsi(frontPressure)
                        rearPressure = Utility.barToPsi(rearPressure)
                    default:
                        print("Unknown pressure unit setting")
                    }
                    if frontPressure <= UserDefaults.standard.double(forKey: "tpm_threshold_preference"){
                        faults.setFrontTirePressureCriticalActive(active: true)
                        updateNotification()
                        faults.frontTirePressureCriticalNotificationActive = true
                    } else {
                        faults.setFrontTirePressureCriticalActive(active: false)
                        updateNotification()
                        faults.frontTirePressureCriticalNotificationActive = false
                    }
                    if rearPressure <= UserDefaults.standard.double(forKey: "tpm_threshold_preference"){
                        faults.setRearTirePressureCriticalActive(active: true)
                        updateNotification()
                        faults.rearTirePressureCriticalNotificationActive = true
                    } else {
                        faults.setRearTirePressureCriticalActive(active: false)
                        updateNotification()
                        faults.rearTirePressureCriticalNotificationActive = false
                    }
                }
            }
            
            // Tire Pressure Faults
            if !UserDefaults.standard.bool(forKey: "custom_tpm_preference"){
                switch (lastMessage[6]) {
                case 0xC9:
                    faults.setFrontTirePressureWarningActive(active: true)
                    faults.setRearTirePressureWarningActive(active: false)
                    faults.setFrontTirePressureCriticalActive(active: false)
                    faults.setRearTirePressureCriticalActive(active: false)
                    if(faults.frontTirePressureCriticalNotificationActive) {
                        updateNotification()
                        faults.frontTirePressureCriticalNotificationActive = false
                    }
                    if(faults.rearTirePressureCriticalNotificationActive) {
                        updateNotification()
                        faults.rearTirePressureCriticalNotificationActive = false
                    }
                    
                case 0xCA:
                    faults.setFrontTirePressureWarningActive(active: false)
                    faults.setRearTirePressureWarningActive(active: true)
                    faults.setFrontTirePressureCriticalActive(active: false)
                    faults.setRearTirePressureCriticalActive(active: false)
                    if(faults.frontTirePressureCriticalNotificationActive) {
                        updateNotification()
                        faults.frontTirePressureCriticalNotificationActive = false
                    }
                    if(faults.rearTirePressureCriticalNotificationActive) {
                        updateNotification()
                        faults.rearTirePressureCriticalNotificationActive = false
                    }
                    
                case 0xCB:
                    faults.setFrontTirePressureWarningActive(active: true)
                    faults.setRearTirePressureWarningActive(active: true)
                    faults.setFrontTirePressureCriticalActive(active: false)
                    faults.setRearTirePressureCriticalActive(active: false)
                    if(faults.frontTirePressureCriticalNotificationActive) {
                        updateNotification()
                        faults.frontTirePressureCriticalNotificationActive = false
                    }
                    if(faults.rearTirePressureCriticalNotificationActive) {
                        updateNotification()
                        faults.rearTirePressureCriticalNotificationActive = false
                    }
                    
                case 0xD1:
                    faults.setFrontTirePressureWarningActive(active: false)
                    faults.setRearTirePressureWarningActive(active: false)
                    faults.setFrontTirePressureCriticalActive(active: true)
                    faults.setRearTirePressureCriticalActive(active: false)
                    if(!faults.frontTirePressureCriticalNotificationActive) {
                        updateNotification()
                        faults.frontTirePressureCriticalNotificationActive = true
                    }
                    if(faults.rearTirePressureCriticalNotificationActive) {
                        updateNotification()
                        faults.rearTirePressureCriticalNotificationActive = false
                    }
                    
                case 0xD2:
                    faults.setFrontTirePressureWarningActive(active: false)
                    faults.setRearTirePressureWarningActive(active: false)
                    faults.setFrontTirePressureCriticalActive(active: false)
                    faults.setRearTirePressureCriticalActive(active: true)
                    if(faults.frontTirePressureCriticalNotificationActive) {
                        updateNotification()
                        faults.frontTirePressureCriticalNotificationActive = false
                    }
                    if(!faults.rearTirePressureCriticalNotificationActive) {
                        updateNotification()
                        faults.rearTirePressureCriticalNotificationActive = true
                    }
                    
                case 0xD3:
                    faults.setFrontTirePressureWarningActive(active: false)
                    faults.setRearTirePressureWarningActive(active: false)
                    faults.setFrontTirePressureCriticalActive(active: true)
                    faults.setRearTirePressureCriticalActive(active: true)
                    if(!faults.frontTirePressureCriticalNotificationActive) {
                        updateNotification()
                        faults.frontTirePressureCriticalNotificationActive = true
                    }
                    if(!faults.rearTirePressureCriticalNotificationActive) {
                        updateNotification()
                        faults.rearTirePressureCriticalNotificationActive = true
                    }
                    
                default:
                    faults.setFrontTirePressureWarningActive(active: false)
                    faults.setRearTirePressureWarningActive(active: false)
                    faults.setFrontTirePressureCriticalActive(active: false)
                    faults.setRearTirePressureCriticalActive(active: false)
                    if(faults.frontTirePressureCriticalNotificationActive) {
                        updateNotification()
                        faults.frontTirePressureCriticalNotificationActive = false
                    }
                    if(faults.rearTirePressureCriticalNotificationActive) {
                        updateNotification()
                        faults.rearTirePressureCriticalNotificationActive = false
                    }
                }
            }
            
        case 0x06:
            //print("Message ID: 6")
            // Gear
            var gear = "-"
            switch (lastMessage[2] >> 4) & 0x0F {
            case 0x1:
                gear = "1"
            case 0x2:
                gear = "N"
            case 0x4:
                gear = "2"
            case 0x7:
                gear = "3"
            case 0x8:
                gear = "4"
            case 0xB:
                gear = "5"
            case 0xD:
                gear = "6"
            case 0xF:
                gear = "-"
            default:
                print("Unknown Gear Value")
                gear = "-"
            }
            if (motorcycleData.gear != gear && gear != "-") {
                motorcycleData.setshifts(shifts: motorcycleData.shifts! + 1)
            }
            motorcycleData.setgear(gear: gear)
            
            // Throttle Position
            let minPosition:Double = 36;
            let maxPosition:Double = 236;
            let throttlePosition = ((Double(lastMessage[3]) - minPosition) * 100) / (maxPosition - minPosition)
            motorcycleData.setthrottlePosition(throttlePosition: throttlePosition)
            
            // Engine Temperature
            if (lastMessage[4] != 0xFF){
                let engineTemp:Double = Double(lastMessage[4]) * 0.75 - 25
                motorcycleData.setengineTemperature(engineTemperature: engineTemp)
            }
            
            // ASC Fault
            let ascValue = (lastMessage[5]  >> 4) & 0x0F // the highest 4 bits.
            switch (ascValue){
            case 0x1:
                faults.setAscSelfDiagActive(active: false)
                faults.setAscInterventionActive(active: true)
                faults.setAscDeactivatedActive(active: false)
                faults.setAscErrorActive(active: false)
                
            case 0x2:
                faults.setAscSelfDiagActive(active: false)
                faults.setAscInterventionActive(active: false)
                faults.setAscDeactivatedActive(active: false)
                faults.setAscErrorActive(active: true)
                
            case 0x3:
                faults.setAscSelfDiagActive(active: true)
                faults.setAscInterventionActive(active: false)
                faults.setAscDeactivatedActive(active: false)
                faults.setAscErrorActive(active: false)
                
            case 0x5:
                faults.setAscSelfDiagActive(active: false)
                faults.setAscInterventionActive(active: false)
                faults.setAscDeactivatedActive(active: false)
                faults.setAscErrorActive(active: true)
                
            case 0x6:
                faults.setAscSelfDiagActive(active: false)
                faults.setAscInterventionActive(active: false)
                faults.setAscDeactivatedActive(active: false)
                faults.setAscErrorActive(active: true)
                
            case 0x7:
                faults.setAscSelfDiagActive(active: false)
                faults.setAscInterventionActive(active: false)
                faults.setAscDeactivatedActive(active: false)
                faults.setAscErrorActive(active: true)
                
            case 0x8:
                faults.setAscSelfDiagActive(active: false)
                faults.setAscInterventionActive(active: false)
                faults.setAscDeactivatedActive(active: true)
                faults.setAscErrorActive(active: false)
                break;
            case 0x9:
                faults.setAscSelfDiagActive(active: false)
                faults.setAscInterventionActive(active: true)
                faults.setAscDeactivatedActive(active: false)
                faults.setAscErrorActive(active: false)
                
            case 0xA:
                faults.setAscSelfDiagActive(active: false)
                faults.setAscInterventionActive(active: false)
                faults.setAscDeactivatedActive(active: false)
                faults.setAscErrorActive(active: true)
                
            case 0xB:
                faults.setAscSelfDiagActive(active: true)
                faults.setAscInterventionActive(active: false)
                faults.setAscDeactivatedActive(active: false)
                faults.setAscErrorActive(active: false)
                
            case 0xD:
                faults.setAscSelfDiagActive(active: false)
                faults.setAscInterventionActive(active: false)
                faults.setAscDeactivatedActive(active: false)
                faults.setAscErrorActive(active: true)
                break;
            case 0xE:
                faults.setAscSelfDiagActive(active: false)
                faults.setAscInterventionActive(active: false)
                faults.setAscDeactivatedActive(active: false)
                faults.setAscErrorActive(active: true)
                
            default:
                faults.setAscSelfDiagActive(active: false)
                faults.setAscInterventionActive(active: false)
                faults.setAscDeactivatedActive(active: false)
                faults.setAscErrorActive(active: false)
                
            }
            
            //Oil Fault
            let oilValue = lastMessage[5] & 0x0F // the lowest 4 bits
            switch (oilValue){
            case 0x2:
                faults.setOilLowActive(active: true)
                
            case 0x6:
                faults.setOilLowActive(active: true)
                
            case 0xA:
                faults.setOilLowActive(active: true)
                
            case 0xE:
                faults.setOilLowActive(active: true)
                
            default:
                faults.setOilLowActive(active: false)
                
            }
            
        case 0x07:
            // Average Speed
            if ((lastMessage[1] != 0xFF) && (lastMessage[2] != 0xFF)){
                let firstNibble = Double((lastMessage[1] >> 4) & 0x0F) * 2
                let secondNibble = Double((lastMessage[1] & 0x0F)) * 0.125
                let thirdNibble = Double((lastMessage[2] & 0x0F)) * 32
                let avgSpeed = firstNibble + secondNibble + thirdNibble
                motorcycleData.setaverageSpeed(averageSpeed: avgSpeed)
            }
            
            // Speed
            if (lastMessage[3] != 0xFF){
                let speed = Double(lastMessage[3]) * 2
                motorcycleData.setspeed(speed: speed)
            }
            
            // Voltage
            if (lastMessage[4] != 0xFF){
                let voltage = Double(lastMessage[4]) / 10
                motorcycleData.setvoltage(voltage: voltage)
            }
            
            // Fuel Fault
            let fuelValue = (lastMessage[5] >> 4) & 0x0F // the highest 4 bits.
            switch (fuelValue){
            case 0x2:
                faults.setFuelFaultActive(active: true)
                
            case 0x6:
                faults.setFuelFaultActive(active: true)
                
            case 0xA:
                faults.setFuelFaultActive(active: true)
                
            case 0xE:
                faults.setFuelFaultActive(active: true)
                
            default:
                faults.setFuelFaultActive(active: false)
                
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
                    /*
                     if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AlertViewControllerID") as? AlertViewController
                     {
                     vc.ID = 1
                     present(vc, animated: true, completion: nil)
                     }
                     */
                    
                    //let alert = AlertViewController()
                    //present(alert, animated: true, completion: nil)
                    
                }
                
            }
            // General Fault
            let generalFault = lastMessage[5] & 0x0F // the lowest 4 bits
            switch (generalFault){
            case 0x1:
                faults.setGeneralFlashingYellowActive(active: true)
                faults.setGeneralShowsYellowActive(active: false)
                faults.setGeneralFlashingRedActive(active: false)
                faults.setGeneralShowsRedActive(active: false)
                if(faults.generalFlashingRedNotificationActive) {
                    updateNotification()
                    faults.generalFlashingRedNotificationActive = false
                }
                if(faults.generalShowsRedNotificationActive) {
                    updateNotification()
                    faults.generalShowsRedNotificationActive = false
                }
                
            case 0x2:
                faults.setGeneralFlashingYellowActive(active: false)
                faults.setGeneralShowsYellowActive(active: true)
                faults.setGeneralFlashingRedActive(active: false)
                faults.setGeneralShowsRedActive(active: false)
                if(faults.generalFlashingRedNotificationActive) {
                    updateNotification()
                    faults.generalFlashingRedNotificationActive = false
                }
                if(faults.generalShowsRedNotificationActive) {
                    updateNotification()
                    faults.generalShowsRedNotificationActive = false
                }
                
            case 0x4:
                faults.setGeneralFlashingYellowActive(active: false)
                faults.setGeneralShowsYellowActive(active: false)
                faults.setGeneralFlashingRedActive(active: true)
                faults.setGeneralShowsRedActive(active: false)
                if(!faults.generalFlashingRedNotificationActive) {
                    updateNotification()
                    faults.generalFlashingRedNotificationActive = true
                }
                if(faults.generalShowsRedNotificationActive) {
                    updateNotification()
                    faults.generalShowsRedNotificationActive = false
                }
                
            case 0x5:
                faults.setGeneralFlashingYellowActive(active: true)
                faults.setGeneralShowsYellowActive(active: false)
                faults.setGeneralFlashingRedActive(active: true)
                faults.setGeneralShowsRedActive(active: false)
                if(!faults.generalFlashingRedNotificationActive) {
                    updateNotification()
                    faults.generalFlashingRedNotificationActive = true
                }
                if(faults.generalShowsRedNotificationActive) {
                    updateNotification()
                    faults.generalShowsRedNotificationActive = false
                }
                
            case 0x6:
                faults.setGeneralFlashingYellowActive(active: false)
                faults.setGeneralShowsYellowActive(active: true)
                faults.setGeneralFlashingRedActive(active: true)
                faults.setGeneralShowsRedActive(active: false)
                if(!faults.generalFlashingRedNotificationActive) {
                    updateNotification()
                    faults.generalFlashingRedNotificationActive = true
                }
                if(faults.generalShowsRedNotificationActive) {
                    updateNotification()
                    faults.generalShowsRedNotificationActive = false
                }
                
            case 0x7:
                faults.setGeneralFlashingYellowActive(active: false)
                faults.setGeneralShowsYellowActive(active: false)
                faults.setGeneralFlashingRedActive(active: true)
                faults.setGeneralShowsRedActive(active: false)
                if(!faults.generalFlashingRedNotificationActive) {
                    updateNotification()
                    faults.generalFlashingRedNotificationActive = true
                }
                if(faults.generalShowsRedNotificationActive) {
                    updateNotification()
                    faults.generalShowsRedNotificationActive = false
                }
                
            case 0x8:
                faults.setGeneralFlashingYellowActive(active: false)
                faults.setGeneralShowsYellowActive(active: false)
                faults.setGeneralFlashingRedActive(active: false)
                faults.setGeneralShowsRedActive(active: true)
                if(faults.generalFlashingRedNotificationActive) {
                    updateNotification()
                    faults.generalFlashingRedNotificationActive = false
                }
                if(!faults.generalShowsRedNotificationActive) {
                    updateNotification()
                    faults.generalShowsRedNotificationActive = true
                }
                
            case 0x9:
                faults.setGeneralFlashingYellowActive(active: false)
                faults.setGeneralShowsYellowActive(active: false)
                faults.setGeneralFlashingRedActive(active: true)
                faults.setGeneralShowsRedActive(active: true)
                if(!faults.generalFlashingRedNotificationActive && !faults.generalShowsRedNotificationActive) {
                    updateNotification()
                    faults.generalFlashingRedNotificationActive = true
                    faults.generalShowsRedNotificationActive = true
                }
                
            case 0xA:
                faults.setGeneralFlashingYellowActive(active: false)
                faults.setGeneralShowsYellowActive(active: true)
                faults.setGeneralFlashingRedActive(active: false)
                faults.setGeneralShowsRedActive(active: true)
                if(faults.generalFlashingRedNotificationActive) {
                    updateNotification()
                    faults.generalFlashingRedNotificationActive = false
                }
                if(!faults.generalShowsRedNotificationActive) {
                    updateNotification()
                    faults.generalShowsRedNotificationActive = true
                }
                
            case 0xB:
                faults.setGeneralFlashingYellowActive(active: false)
                faults.setGeneralShowsYellowActive(active: false)
                faults.setGeneralFlashingRedActive(active: false)
                faults.setGeneralShowsRedActive(active: true)
                if(faults.generalFlashingRedNotificationActive) {
                    updateNotification()
                    faults.generalFlashingRedNotificationActive = false
                }
                if(!faults.generalShowsRedNotificationActive) {
                    updateNotification()
                    faults.generalShowsRedNotificationActive = true
                }
                
            case 0xD:
                faults.setGeneralFlashingYellowActive(active: true)
                faults.setGeneralShowsYellowActive(active: false)
                faults.setGeneralFlashingRedActive(active: false)
                faults.setGeneralShowsRedActive(active: false)
                if(faults.generalFlashingRedNotificationActive) {
                    updateNotification()
                    faults.generalFlashingRedNotificationActive = false
                }
                if(faults.generalShowsRedNotificationActive) {
                    updateNotification()
                    faults.generalShowsRedNotificationActive = false
                }
                
            case 0xE:
                faults.setGeneralFlashingYellowActive(active: false)
                faults.setGeneralShowsYellowActive(active: true)
                faults.setGeneralFlashingRedActive(active: false)
                faults.setGeneralShowsRedActive(active: false)
                if(faults.generalFlashingRedNotificationActive) {
                    updateNotification()
                    faults.generalFlashingRedNotificationActive = false
                }
                if(faults.generalShowsRedNotificationActive) {
                    updateNotification()
                    faults.generalShowsRedNotificationActive = false
                }
                
            default:
                faults.setGeneralFlashingYellowActive(active: false)
                faults.setGeneralShowsYellowActive(active: false)
                faults.setGeneralFlashingRedActive(active: false)
                faults.setGeneralShowsRedActive(active: false)
                if(faults.generalFlashingRedNotificationActive) {
                    updateNotification()
                    faults.generalFlashingRedNotificationActive = false
                }
                if(faults.generalShowsRedNotificationActive) {
                    updateNotification()
                    faults.generalShowsRedNotificationActive = false
                }
                
            }
        case 0x08:
            //print("Message ID: 8")
            // Ambient Temperature
            if (lastMessage[1] != 0xFF){
                let ambientTemp:Double = Double(lastMessage[1]) * 0.50 - 40
                motorcycleData.setambientTemperature(ambientTemperature: ambientTemp)
            }
            
            // LAMP Faults
            if (lastMessage[3] != 0xFF) {
                // LAMPF 1
                let lampfOneValue = (lastMessage[3]  >> 4) & 0x0F // the highest 4 bits.
                switch (lampfOneValue) {
                case 0x1:
                    faults.setAddFrontLightOneActive(active: true)
                    faults.setAddFrontLightTwoActive(active: false)
                    
                case 0x2:
                    faults.setAddFrontLightOneActive(active: false)
                    faults.setAddFrontLightTwoActive(active: true)
                    
                case 0x3:
                    faults.setAddFrontLightOneActive(active: true)
                    faults.setAddFrontLightTwoActive(active: true)
                    
                case 0x5:
                    faults.setAddFrontLightOneActive(active: true)
                    faults.setAddFrontLightTwoActive(active: false)
                    
                case 0x6:
                    faults.setAddFrontLightOneActive(active: false)
                    faults.setAddFrontLightTwoActive(active: true)
                    
                case 0x9:
                    faults.setAddFrontLightOneActive(active: true)
                    faults.setAddFrontLightTwoActive(active: false)
                    
                case 0xA:
                    faults.setAddFrontLightOneActive(active: false)
                    faults.setAddFrontLightTwoActive(active: true)
                    
                case 0xB:
                    faults.setAddFrontLightOneActive(active: true)
                    faults.setAddFrontLightTwoActive(active: true)
                    
                case 0xD:
                    faults.setAddFrontLightOneActive(active: true)
                    faults.setAddFrontLightTwoActive(active: false)
                    
                case 0xE:
                    faults.setAddFrontLightOneActive(active: false)
                    faults.setAddFrontLightTwoActive(active: true)
                    
                default:
                    faults.setAddFrontLightOneActive(active: false)
                    faults.setAddFrontLightTwoActive(active: false)
                    
                }
            }
            // LAMPF 2
            if (lastMessage[4] != 0xFF) {
                let lampfTwoHighValue = (lastMessage[4] >> 4) & 0x0F // the highest 4 bits.
                switch (lampfTwoHighValue) {
                case 0x1:
                    faults.setDaytimeRunningActive(active: true)
                    faults.setFrontLeftSignalActive(active: false)
                    faults.setFrontRightSignalActive(active: false)
                    
                case 0x2:
                    faults.setDaytimeRunningActive(active: false)
                    faults.setFrontLeftSignalActive(active: true)
                    faults.setFrontRightSignalActive(active: false)
                    
                case 0x3:
                    faults.setDaytimeRunningActive(active: true)
                    faults.setFrontLeftSignalActive(active: true)
                    faults.setFrontRightSignalActive(active: false)
                    
                case 0x4:
                    faults.setDaytimeRunningActive(active: false)
                    faults.setFrontLeftSignalActive(active: false)
                    faults.setFrontRightSignalActive(active: true)
                    
                case 0x5:
                    faults.setDaytimeRunningActive(active: true)
                    faults.setFrontLeftSignalActive(active: false)
                    faults.setFrontRightSignalActive(active: true)
                    
                case 0x6:
                    faults.setDaytimeRunningActive(active: false)
                    faults.setFrontLeftSignalActive(active: true)
                    faults.setFrontRightSignalActive(active: true)
                    
                case 0x7:
                    faults.setDaytimeRunningActive(active: true)
                    faults.setFrontLeftSignalActive(active: true)
                    faults.setFrontRightSignalActive(active: true)
                    
                case 0x9:
                    faults.setDaytimeRunningActive(active: true)
                    faults.setFrontLeftSignalActive(active: false)
                    faults.setFrontRightSignalActive(active: false)
                    
                case 0xA:
                    faults.setDaytimeRunningActive(active: false)
                    faults.setFrontLeftSignalActive(active: true)
                    faults.setFrontRightSignalActive(active: false)
                    
                case 0xB:
                    faults.setDaytimeRunningActive(active: true)
                    faults.setFrontLeftSignalActive(active: true)
                    faults.setFrontRightSignalActive(active: false)
                    
                case 0xC:
                    faults.setDaytimeRunningActive(active: false)
                    faults.setFrontLeftSignalActive(active: false)
                    faults.setFrontRightSignalActive(active: true)
                    
                case 0xD:
                    faults.setDaytimeRunningActive(active: true);
                    faults.setFrontLeftSignalActive(active: false);
                    faults.setFrontRightSignalActive(active: true);
                    
                case 0xE:
                    faults.setDaytimeRunningActive(active: false)
                    faults.setFrontLeftSignalActive(active: true)
                    faults.setFrontRightSignalActive(active: true)
                    
                case 0xF:
                    faults.setDaytimeRunningActive(active: true)
                    faults.setFrontLeftSignalActive(active: true)
                    faults.setFrontRightSignalActive(active: true)
                    
                default:
                    faults.setDaytimeRunningActive(active: false)
                    faults.setFrontLeftSignalActive(active: false)
                    faults.setFrontRightSignalActive(active: false)
                    
                }
                let lampfTwoLowValue = data[4] & 0x0F // the lowest 4 bits
                switch (lampfTwoLowValue) {
                case 0x1:
                    faults.setFrontParkingLightOneActive(active: true)
                    faults.setFrontParkingLightTwoActive(active: false)
                    faults.setLowBeamActive(active: false)
                    faults.setHighBeamActive(active: false)
                    
                case 0x2:
                    faults.setFrontParkingLightOneActive(active: false)
                    faults.setFrontParkingLightTwoActive(active: true)
                    faults.setLowBeamActive(active: false)
                    faults.setHighBeamActive(active: false)
                    
                case 0x3:
                    faults.setFrontParkingLightOneActive(active: true)
                    faults.setFrontParkingLightTwoActive(active: true)
                    faults.setLowBeamActive(active: false)
                    faults.setHighBeamActive(active: false)
                    
                case 0x4:
                    faults.setFrontParkingLightOneActive(active: false)
                    faults.setFrontParkingLightTwoActive(active: false)
                    faults.setLowBeamActive(active: true)
                    faults.setHighBeamActive(active: false)
                    
                case 0x5:
                    faults.setFrontParkingLightOneActive(active: true);
                    faults.setFrontParkingLightTwoActive(active: false)
                    faults.setLowBeamActive(active: true)
                    faults.setHighBeamActive(active: false)
                    
                case 0x6:
                    faults.setFrontParkingLightOneActive(active: false)
                    faults.setFrontParkingLightTwoActive(active: true)
                    faults.setLowBeamActive(active: true)
                    faults.setHighBeamActive(active: false)
                    
                case 0x7:
                    faults.setFrontParkingLightOneActive(active: true)
                    faults.setFrontParkingLightTwoActive(active: true)
                    faults.setLowBeamActive(active: true)
                    faults.setHighBeamActive(active: false)
                    
                case 0x8:
                    faults.setFrontParkingLightOneActive(active: false)
                    faults.setFrontParkingLightTwoActive(active: false)
                    faults.setLowBeamActive(active: false)
                    faults.setHighBeamActive(active: true)
                    
                case 0x9:
                    faults.setFrontParkingLightOneActive(active: true)
                    faults.setFrontParkingLightTwoActive(active: false)
                    faults.setLowBeamActive(active: false)
                    faults.setHighBeamActive(active: true)
                    
                case 0xA:
                    faults.setFrontParkingLightOneActive(active: false)
                    faults.setFrontParkingLightTwoActive(active: true)
                    faults.setLowBeamActive(active: false)
                    faults.setHighBeamActive(active: true)
                    
                case 0xB:
                    faults.setFrontParkingLightOneActive(active: true)
                    faults.setFrontParkingLightTwoActive(active: true)
                    faults.setLowBeamActive(active: false)
                    faults.setHighBeamActive(active: true)
                    
                case 0xC:
                    faults.setFrontParkingLightOneActive(active: false)
                    faults.setFrontParkingLightTwoActive(active: false)
                    faults.setLowBeamActive(active: true)
                    faults.setHighBeamActive(active: true)
                    
                case 0xD:
                    faults.setFrontParkingLightOneActive(active: true)
                    faults.setFrontParkingLightTwoActive(active: false)
                    faults.setLowBeamActive(active: true)
                    faults.setHighBeamActive(active: true)
                    
                case 0xE:
                    faults.setFrontParkingLightOneActive(active: false)
                    faults.setFrontParkingLightTwoActive(active: true)
                    faults.setLowBeamActive(active: true)
                    faults.setHighBeamActive(active: true)
                    
                case 0xF:
                    faults.setFrontParkingLightOneActive(active: true)
                    faults.setFrontParkingLightTwoActive(active: true)
                    faults.setLowBeamActive(active: true)
                    faults.setHighBeamActive(active: true)
                    
                default:
                    faults.setFrontParkingLightOneActive(active: false)
                    faults.setFrontParkingLightTwoActive(active: false)
                    faults.setLowBeamActive(active: false)
                    faults.setHighBeamActive(active: false)
                    
                }
            }
            
            // LAMPF 3
            if (lastMessage[5] != 0xFF) {
                let lampfThreeHighValue = (lastMessage[5] >> 4) & 0x0F // the highest 4 bits.
                switch (lampfThreeHighValue) {
                case 0x1:
                    faults.setRearRightSignalActive(active: true)
                    
                case 0x3:
                    faults.setRearRightSignalActive(active: true)
                    
                case 0x5:
                    faults.setRearRightSignalActive(active: true)
                    
                case 0x7:
                    faults.setRearRightSignalActive(active: true)
                    
                case 0x9:
                    faults.setRearRightSignalActive(active: true)
                    
                case 0xB:
                    faults.setRearRightSignalActive(active: true)
                    
                case 0xD:
                    faults.setRearRightSignalActive(active: true)
                    
                case 0xF:
                    faults.setRearRightSignalActive(active: true)
                    
                default:
                    faults.setRearRightSignalActive(active: false)
                    
                }
                let lampfThreeLowValue = lastMessage[5] & 0x0F // the lowest 4 bits
                switch (lampfThreeLowValue) {
                case 0x1:
                    faults.setRearLeftSignalActive(active: false)
                    faults.setRearLightActive(active: true)
                    faults.setBrakeLightActive(active: false)
                    faults.setLicenseLightActive(active: false)
                    
                case 0x2:
                    faults.setRearLeftSignalActive(active: false)
                    faults.setRearLightActive(active: false)
                    faults.setBrakeLightActive(active: true)
                    faults.setLicenseLightActive(active: false)
                    
                case 0x3:
                    faults.setRearLeftSignalActive(active: false)
                    faults.setRearLightActive(active: true)
                    faults.setBrakeLightActive(active: true)
                    faults.setLicenseLightActive(active: false)
                    
                case 0x4:
                    faults.setRearLeftSignalActive(active: false)
                    faults.setRearLightActive(active: false)
                    faults.setBrakeLightActive(active: false)
                    faults.setLicenseLightActive(active: true)
                    
                case 0x5:
                    faults.setRearLeftSignalActive(active: true)
                    faults.setRearLightActive(active: false)
                    faults.setBrakeLightActive(active: false)
                    faults.setLicenseLightActive(active: true)
                    
                case 0x6:
                    faults.setRearLeftSignalActive(active: false)
                    faults.setRearLightActive(active: false)
                    faults.setBrakeLightActive(active: true)
                    faults.setLicenseLightActive(active: true)
                    
                case 0x7:
                    faults.setRearLeftSignalActive(active: false)
                    faults.setRearLightActive(active: true)
                    faults.setBrakeLightActive(active: true)
                    faults.setLicenseLightActive(active: true)
                    
                case 0x8:
                    faults.setRearLeftSignalActive(active: true)
                    faults.setRearLightActive(active: false)
                    faults.setBrakeLightActive(active: false)
                    faults.setLicenseLightActive(active: false)
                    
                case 0x9:
                    faults.setRearLeftSignalActive(active: true)
                    faults.setRearLightActive(active: true)
                    faults.setBrakeLightActive(active: false)
                    faults.setLicenseLightActive(active: false)
                    
                case 0xA:
                    faults.setRearLeftSignalActive(active: true)
                    faults.setRearLightActive(active: false)
                    faults.setBrakeLightActive(active: true)
                    faults.setLicenseLightActive(active: false)
                    
                case 0xC:
                    faults.setRearLeftSignalActive(active: true)
                    faults.setRearLightActive(active: false)
                    faults.setBrakeLightActive(active: false)
                    faults.setLicenseLightActive(active: true)
                    
                case 0xD:
                    faults.setRearLeftSignalActive(active: true)
                    faults.setRearLightActive(active: true)
                    faults.setBrakeLightActive(active: true)
                    faults.setLicenseLightActive(active: false)
                    
                case 0xE:
                    faults.setRearLeftSignalActive(active: true)
                    faults.setRearLightActive(active: false)
                    faults.setBrakeLightActive(active: true)
                    faults.setLicenseLightActive(active: true)
                    
                case 0xF:
                    faults.setRearLeftSignalActive(active: true)
                    faults.setRearLightActive(active: true)
                    faults.setBrakeLightActive(active: true)
                    faults.setLicenseLightActive(active: true)
                    
                default:
                    faults.setRearLeftSignalActive(active: false)
                    faults.setRearLightActive(active: false)
                    faults.setBrakeLightActive(active: false)
                    faults.setLicenseLightActive(active: false)
                    
                }
            }
            
            // LAMPF 4
            if (lastMessage[6] != 0xFF) {
                let lampfFourHighValue = (lastMessage[6] >> 4) & 0x0F // the highest 4 bits.
                switch (lampfFourHighValue) {
                case 0x1:
                    faults.setRearFogLightActive(active: true)
                    
                case 0x3:
                    faults.setRearFogLightActive(active: true)
                    
                case 0x5:
                    faults.setRearFogLightActive(active: true)
                    
                case 0x9:
                    faults.setRearFogLightActive(active: true)
                    
                case 0xB:
                    faults.setRearFogLightActive(active: true)
                    
                case 0xD:
                    faults.setRearFogLightActive(active: true)
                    
                case 0xF:
                    faults.setRearFogLightActive(active: true)
                default:
                    faults.setRearFogLightActive(active: false)
                    
                }
                let lampfFourLowValue = lastMessage[6] & 0x0F // the lowest 4 bits
                switch (lampfFourLowValue) {
                case 0x1:
                    faults.setAddDippedLightActive(active: true)
                    faults.setAddBrakeLightActive(active: false)
                    faults.setFrontLampOneLightActive(active: false)
                    faults.setFrontLampTwoLightActive(active: false)
                    
                case 0x2:
                    faults.setAddDippedLightActive(active: false)
                    faults.setAddBrakeLightActive(active: true)
                    faults.setFrontLampOneLightActive(active: false)
                    faults.setFrontLampTwoLightActive(active: false)
                    
                case 0x3:
                    faults.setAddDippedLightActive(active: true)
                    faults.setAddBrakeLightActive(active: true)
                    faults.setFrontLampOneLightActive(active: false)
                    faults.setFrontLampTwoLightActive(active: false)
                    
                case 0x4:
                    faults.setAddDippedLightActive(active: false)
                    faults.setAddBrakeLightActive(active: false)
                    faults.setFrontLampOneLightActive(active: true)
                    faults.setFrontLampTwoLightActive(active: false)
                    
                case 0x5:
                    faults.setAddDippedLightActive(active: true)
                    faults.setAddBrakeLightActive(active: false)
                    faults.setFrontLampOneLightActive(active: true)
                    faults.setFrontLampTwoLightActive(active: false)
                    
                case 0x6:
                    faults.setAddDippedLightActive(active: false)
                    faults.setAddBrakeLightActive(active: true)
                    faults.setFrontLampOneLightActive(active: true)
                    faults.setFrontLampTwoLightActive(active: false)
                    
                case 0x7:
                    faults.setAddDippedLightActive(active: true)
                    faults.setAddBrakeLightActive(active: true)
                    faults.setFrontLampOneLightActive(active: true)
                    faults.setFrontLampTwoLightActive(active: false)
                    
                case 0x8:
                    faults.setAddDippedLightActive(active: false)
                    faults.setAddBrakeLightActive(active: false)
                    faults.setFrontLampOneLightActive(active: false)
                    faults.setFrontLampTwoLightActive(active: true)
                    
                case 0x9:
                    faults.setAddDippedLightActive(active: true)
                    faults.setAddBrakeLightActive(active: false)
                    faults.setFrontLampOneLightActive(active: false)
                    faults.setFrontLampTwoLightActive(active: true)
                    
                case 0xA:
                    faults.setAddDippedLightActive(active: false)
                    faults.setAddBrakeLightActive(active: true)
                    faults.setFrontLampOneLightActive(active: false)
                    faults.setFrontLampTwoLightActive(active: true)
                    
                case 0xB:
                    faults.setAddDippedLightActive(active: true)
                    faults.setAddBrakeLightActive(active: true)
                    faults.setFrontLampOneLightActive(active: false)
                    faults.setFrontLampTwoLightActive(active: true)
                    
                case 0xC:
                    faults.setAddDippedLightActive(active: false)
                    faults.setAddBrakeLightActive(active: false)
                    faults.setFrontLampOneLightActive(active: true)
                    faults.setFrontLampTwoLightActive(active: true)
                    
                case 0xD:
                    faults.setAddDippedLightActive(active: true)
                    faults.setAddBrakeLightActive(active: false)
                    faults.setFrontLampOneLightActive(active: true)
                    faults.setFrontLampTwoLightActive(active: true)
                    
                case 0xE:
                    faults.setAddDippedLightActive(active: false)
                    faults.setAddBrakeLightActive(active: true)
                    faults.setFrontLampOneLightActive(active: true)
                    faults.setFrontLampTwoLightActive(active: true)
                    
                default:
                    faults.setAddDippedLightActive(active: false)
                    faults.setAddBrakeLightActive(active: false)
                    faults.setFrontLampOneLightActive(active: false)
                    faults.setFrontLampTwoLightActive(active: false)
                }
            }
        case 0x09:
            // Fuel Economy 1
            if (lastMessage[2] != 0xFF){
                let firstNibble = Double((lastMessage[2] >> 4) & 0x0F) * 1.6
                let secondNibble = Double((lastMessage[2] & 0x0F)) * 0.1
                let fuelEconomyOne = firstNibble + secondNibble
                motorcycleData.setfuelEconomyOne(fuelEconomyOne: fuelEconomyOne)
            }
            
            // Fuel Economy 2
            if (lastMessage[3] != 0xFF){
                let firstNibble = Double((lastMessage[3] >> 4) & 0x0F) * 1.6
                let secondNibble = Double((lastMessage[3] & 0x0F)) * 0.1
                let fuelEconomyTwo = firstNibble + secondNibble
                motorcycleData.setfuelEconomyTwo(fuelEconomyTwo: fuelEconomyTwo)
            }
            
            // Current Consumption
            if (lastMessage[4] != 0xFF){
                let firstNibble = Double((lastMessage[4] >> 4) & 0x0F) * 1.6
                let secondNibble = Double((lastMessage[4] & 0x0F)) * 0.1
                let currentConsumption = firstNibble + secondNibble
                motorcycleData.setcurrentConsumption(currentConsumption: currentConsumption)
            }
            
        case 0x0A:
            // Odometer
            let odometer:Double = Double(UInt32((UInt32(lastMessage[1]) | UInt32(lastMessage[2]) << 8 | UInt32(lastMessage[3]) << 16)))
            motorcycleData.setodometer(odometer: (odometer * 1.0))
            
            // Trip Auto
            if ((lastMessage[4] != 0xFF) && (lastMessage[5] != 0xFF) && (lastMessage[6] != 0xFF)){
                let tripAuto:Double = Double(UInt32((UInt32(lastMessage[4]) | UInt32(lastMessage[5]) << 8 | UInt32(lastMessage[6]) << 16))) / 10.0
                motorcycleData.settripAuto(tripAuto: tripAuto)
            }
            
        case 0x0C:
            // Trip 1 & Trip 2
            if (!((lastMessage[1] == 0xFF) && (lastMessage[2] == 0xFF) && (lastMessage[3] == 0xFF))){
                let tripOne:Double = Double(UInt32((UInt32(lastMessage[1]) | UInt32(lastMessage[2]) << 8 | UInt32(lastMessage[3]) << 16))) / 10.0
                motorcycleData.settripOne(tripOne: tripOne)
            }
            if (!((lastMessage[4] == 0xFF) && (lastMessage[5] == 0xFF) && (lastMessage[6] == 0xFF))){
                let tripTwo:Double = Double(UInt32((UInt32(lastMessage[4]) | UInt32(lastMessage[5]) << 8 | UInt32(lastMessage[6]) << 16))) / 10.0
                motorcycleData.settripTwo(tripTwo: tripTwo)
            }
            
        default:
            _ = 0
            //print("Unknown Message ID")
        }
        
        updatePhoneSensorData()
        if (UIApplication.shared.applicationState == .active) {
            updateMessageDisplay()
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
            NSLog(message)
            resumeScan()
        default:
            message = NSLocalizedString("bt_unknown", comment: "")
        }
        
        if showAlert {
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
            if peripheralName == deviceName {
                NSLog("WunderLINQ FOUND! ADDING NOW!!!")
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
        NSLog("SUCCESSFULLY CONNECTED TO WunderLINQ!")
        disconnectBtn.tintColor = UIColor.blue
        
        NSLog("Peripheral info: \(peripheral)")
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
        NSLog("CONNECTION TO WunderLINQ FAILED!")
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
        NSLog("DISCONNECTED FROM WunderLINQ!")
        disconnectBtn.tintColor = UIColor.red
        motorcycleData.clear()
        updateMessageDisplay()
        if error != nil {
            NSLog("DISCONNECTION DETAILS: \(error!.localizedDescription)")
        }
        wunderLINQ = nil
        popoverMenuList = [NSLocalizedString("geodata_label", comment: ""),NSLocalizedString("appsettings_label", comment: ""), NSLocalizedString("about_label", comment: ""), NSLocalizedString("close_label", comment: "")]
        
        // Start trying to reconnect
        keepScanning = true
        resumeScan()
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
            NSLog("ERROR DISCOVERING SERVICES: \(error?.localizedDescription ?? "Unknown Error")")
            return
        }
        
        // Core Bluetooth creates an array of CBService objects —- one for each service that is discovered on the peripheral.
        if let services = peripheral.services {
            for service in services {
                NSLog("DISCOVERED SERVICE: \(service)")
                // discover the characteristic.
                if (service.uuid == CBUUID(string: Device.WunderLINQServiceUUID)) {
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
            NSLog("ERROR DISCOVERING CHARACTERISTICS: \(error?.localizedDescription ?? "Unknown Error")")
            return
        }
        
        if let characteristics = service.characteristics {
            
            for characteristic in characteristics {
                // Message Data Characteristic
                if characteristic.uuid == CBUUID(string: Device.MessageCharacteristicUUID) {
                    // Enable the message notifications
                    messageCharacteristic = characteristic
                    wunderLINQ?.setNotifyValue(true, for: characteristic)
                } else if characteristic.uuid == CBUUID(string: Device.CommandCharacteristicUUID) {
                    commandCharacteristic = characteristic
                    bleData.setcmdCharacteristic(cmdCharacteristic: characteristic)
                    
                    let getConfigCommand:[UInt8] = [0x57,0x52,0x57,0x0D,0x0A]
                    let writeData =  Data(_: getConfigCommand)
                    peripheral.writeValue(writeData, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                    peripheral.readValue(for: characteristic)
                }
                
                peripheral.discoverDescriptors(for: characteristic)
                
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
            NSLog("ERROR ON UPDATING VALUE FOR CHARACTERISTIC: \(characteristic) - \(error?.localizedDescription ?? "Unknown Error")")
            return
        }
        
        // extract the data from the characteristic's value property and display the value based on the characteristic type
        if let dataBytes = characteristic.value {
            if characteristic.uuid == CBUUID(string: Device.MessageCharacteristicUUID) {
                parseMessage(dataBytes)
            } else if characteristic.uuid == CBUUID(string: Device.CommandCharacteristicUUID) {
                parseCommandResponse(dataBytes)
            }
        }
    }
    
    @objc func defaultsChanged(notification:NSNotification){
        if let defaults = notification.object as? UserDefaults {
            if defaults.bool(forKey: "nightmode_lastSet") != defaults.bool(forKey: "nightmode_preference"){
                UserDefaults.standard.set(defaults.bool(forKey: "nightmode_preference"), forKey: "nightmode_lastSet")
                // quit app
                exit(0)
            }
            if defaults.bool(forKey: "motorcycle_data_lastSet") != defaults.bool(forKey: "motorcycle_data_preference"){
                UserDefaults.standard.set(defaults.bool(forKey: "motorcycle_data_preference"), forKey: "motorcycle_data_lastSet")
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
    
    private func checkPermissions(){
        // Camera
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType(rawValue: convertFromAVMediaType(AVMediaType.video))){
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType(rawValue: convertFromAVMediaType(AVMediaType.video)), completionHandler: { (granted: Bool) -> Void in
                if granted == true {
                    // Authorized
                    //Nothing to do
                    print("Allowed to access to Camera")
                } else {
                    // Not allowed
                    // Prompt with warning and button to settings
                    let alertController = UIAlertController(
                        title: NSLocalizedString("negative_alert_title", comment: ""),
                        message: NSLocalizedString("negative_camera_alert_body", comment: ""),
                        preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: NSLocalizedString("negative_alert_btn_cancel", comment: ""), style: .cancel, handler: nil)
                    alertController.addAction(cancelAction)
                    let openAction = UIAlertAction(title: NSLocalizedString("negative_alert_btn_ok", comment: ""), style: .default) { (action) in
                        if let appSettings = URL(string: UIApplication.openSettingsURLString + Bundle.main.bundleIdentifier!) {
                            if UIApplication.shared.canOpenURL(appSettings) {
                                UIApplication.shared.open(appSettings)
                            }
                        }
                    }
                    alertController.addAction(openAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            })
        case .restricted, .denied:
            // Not allowed
            // Prompt with warning and button to settings
            let alertController = UIAlertController(
                title: NSLocalizedString("negative_alert_title", comment: ""),
                message: NSLocalizedString("negative_camera_alert_body", comment: ""),
                preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: NSLocalizedString("negative_alert_btn_cancel", comment: ""), style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            let openAction = UIAlertAction(title: NSLocalizedString("negative_alert_btn_ok", comment: ""), style: .default) { (action) in
                if let appSettings = URL(string: UIApplication.openSettingsURLString + Bundle.main.bundleIdentifier!) {
                    if UIApplication.shared.canOpenURL(appSettings) {
                        UIApplication.shared.open(appSettings)
                    }
                }
            }
            alertController.addAction(openAction)
            self.present(alertController, animated: true, completion: nil)
        case .authorized:
            // Authorized
            //Nothing to do
            print("Allowed to access to Camera")
        @unknown default:
            print("Unknown to access to Camera")
        }
        
        //Microphone
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType(rawValue: convertFromAVMediaType(AVMediaType.audio))){
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType(rawValue: convertFromAVMediaType(AVMediaType.video)), completionHandler: { (granted: Bool) -> Void in
                if granted == true {
                    // Authorized
                    //Nothing to do
                    print("Allowed to access to Microphone")
                } else {
                    // Not allowed
                    // Prompt with warning and button to settings
                    let alertController = UIAlertController(
                        title: NSLocalizedString("negative_alert_title", comment: ""),
                        message: NSLocalizedString("negative_microphone_alert_body", comment: ""),
                        preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: NSLocalizedString("negative_alert_btn_cancel", comment: ""), style: .cancel, handler: nil)
                    alertController.addAction(cancelAction)
                    let openAction = UIAlertAction(title: NSLocalizedString("negative_alert_btn_ok", comment: ""), style: .default) { (action) in
                        if let appSettings = URL(string: UIApplication.openSettingsURLString + Bundle.main.bundleIdentifier!) {
                            if UIApplication.shared.canOpenURL(appSettings) {
                                UIApplication.shared.open(appSettings)
                            }
                        }
                    }
                    alertController.addAction(openAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            })
        case .restricted, .denied:
            // Not allowed
            // Prompt with warning and button to settings
            let alertController = UIAlertController(
                title: NSLocalizedString("negative_alert_title", comment: ""),
                message: NSLocalizedString("negative_microphone_alert_body", comment: ""),
                preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: NSLocalizedString("negative_alert_btn_cancel", comment: ""), style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            let openAction = UIAlertAction(title: NSLocalizedString("negative_alert_btn_ok", comment: ""), style: .default) { (action) in
                if let appSettings = URL(string: UIApplication.openSettingsURLString + Bundle.main.bundleIdentifier!) {
                    if UIApplication.shared.canOpenURL(appSettings) {
                        UIApplication.shared.open(appSettings)
                    }
                }
            }
            alertController.addAction(openAction)
            self.present(alertController, animated: true, completion: nil)
        case .authorized:
            // Authorized
            //Nothing to do
            print("Allowed to access to Microphone")
        @unknown default:
            print("Unknown to access to Microphone")
        }
        
        //Save to Photo Library
        switch PHPhotoLibrary.authorizationStatus() {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({status in
                if status == .authorized{
                    // Authorized
                    //Nothing to do
                    print("Allowed to access the Photo Library")
                } else {
                    let alertController = UIAlertController(
                        title: NSLocalizedString("negative_alert_title", comment: ""),
                        message: NSLocalizedString("negative_write_alert_body", comment: ""),
                        preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: NSLocalizedString("negative_alert_btn_cancel", comment: ""), style: .cancel, handler: nil)
                    alertController.addAction(cancelAction)
                    let openAction = UIAlertAction(title: NSLocalizedString("negative_alert_btn_ok", comment: ""), style: .default) { (action) in
                        if let appSettings = URL(string: UIApplication.openSettingsURLString + Bundle.main.bundleIdentifier!) {
                            if UIApplication.shared.canOpenURL(appSettings) {
                                UIApplication.shared.open(appSettings)
                            }
                        }
                    }
                    alertController.addAction(openAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            })
        case .restricted, .denied:
            let alertController = UIAlertController(
                title: NSLocalizedString("negative_alert_title", comment: ""),
                message: NSLocalizedString("negative_write_alert_body", comment: ""),
                preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: NSLocalizedString("negative_alert_btn_cancel", comment: ""), style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            let openAction = UIAlertAction(title: NSLocalizedString("negative_alert_btn_ok", comment: ""), style: .default) { (action) in
                if let appSettings = URL(string: UIApplication.openSettingsURLString + Bundle.main.bundleIdentifier!) {
                    if UIApplication.shared.canOpenURL(appSettings) {
                        UIApplication.shared.open(appSettings)
                    }
                }
            }
            alertController.addAction(openAction)
            self.present(alertController, animated: true, completion: nil)
        case .authorized:
            // Authorized
            //Nothing to do
            print("Allowed to access the Photo Library")
        @unknown default:
            print("Unknown to access to Photo Library")
        }
        
        //Play from Media Library
        switch MPMediaLibrary.authorizationStatus() {
        case .authorized:
            // Authorized
            //Nothing to do
            print("Allowed to access to Music Library")
        case .notDetermined:
            MPMediaLibrary.requestAuthorization() { status in
                switch status {
                case .notDetermined, .denied, .restricted:
                    let alertController = UIAlertController(
                        title: NSLocalizedString("negative_alert_title", comment: ""),
                        message: NSLocalizedString("negative_media_alert_body", comment: ""),
                        preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: NSLocalizedString("negative_alert_btn_cancel", comment: ""), style: .cancel, handler: nil)
                    alertController.addAction(cancelAction)
                    let openAction = UIAlertAction(title: NSLocalizedString("negative_alert_btn_ok", comment: ""), style: .default) { (action) in
                        if let appSettings = URL(string: UIApplication.openSettingsURLString + Bundle.main.bundleIdentifier!) {
                            if UIApplication.shared.canOpenURL(appSettings) {
                                UIApplication.shared.open(appSettings)
                            }
                        }
                    }
                    alertController.addAction(openAction)
                    self.present(alertController, animated: true, completion: nil)
                case .authorized:
                    // Authorized
                    //Nothing to do
                    print("Allowed to access to Music Library")
                @unknown default:
                    print("Unknown to access to Music Library")
                }
            }
        case .denied, .restricted:
            let alertController = UIAlertController(
                title: NSLocalizedString("negative_alert_title", comment: ""),
                message: NSLocalizedString("negative_media_alert_body", comment: ""),
                preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: NSLocalizedString("negative_alert_btn_cancel", comment: ""), style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            let openAction = UIAlertAction(title: NSLocalizedString("negative_alert_btn_ok", comment: ""), style: .default) { (action) in
                if let appSettings = URL(string: UIApplication.openSettingsURLString + Bundle.main.bundleIdentifier!) {
                    if UIApplication.shared.canOpenURL(appSettings) {
                        UIApplication.shared.open(appSettings)
                    }
                }
            }
            alertController.addAction(openAction)
            self.present(alertController, animated: true, completion: nil)
        @unknown default:
            print("Unknown to access to Music Library")
        }
        
        //Contacts
        let store = CNContactStore()
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            // Authorized
            //Nothing to do
            print("Allowed to access contacts")
        case .restricted, .denied:
            // Not allowed
            // Prompt with warning and button to settings
            let alertController = UIAlertController(
                title: NSLocalizedString("negative_alert_title", comment: ""),
                message: NSLocalizedString("negative_contacts_alert_body", comment: ""),
                preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: NSLocalizedString("negative_alert_btn_cancel", comment: ""), style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            let openAction = UIAlertAction(title: NSLocalizedString("negative_alert_btn_ok", comment: ""), style: .default) { (action) in
                if let appSettings = URL(string: UIApplication.openSettingsURLString + Bundle.main.bundleIdentifier!) {
                    if UIApplication.shared.canOpenURL(appSettings) {
                        UIApplication.shared.open(appSettings)
                    }
                }
            }
            alertController.addAction(openAction)
            self.present(alertController, animated: true, completion: nil)
        case .notDetermined:
            store.requestAccess(for: .contacts) { granted, error in
                if granted {
                    // Authorized
                    //Nothing to do
                    print("Allowed to access contacts")
                } else {
                    // Not allowed
                    // Prompt with warning and button to settings
                    let alertController = UIAlertController(
                        title: NSLocalizedString("negative_alert_title", comment: ""),
                        message: NSLocalizedString("negative_contacts_alert_body", comment: ""),
                        preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: NSLocalizedString("negative_alert_btn_cancel", comment: ""), style: .cancel, handler: nil)
                    alertController.addAction(cancelAction)
                    let openAction = UIAlertAction(title: NSLocalizedString("negative_alert_btn_ok", comment: ""), style: .default) { (action) in
                        if let appSettings = URL(string: UIApplication.openSettingsURLString + Bundle.main.bundleIdentifier!) {
                            if UIApplication.shared.canOpenURL(appSettings) {
                                UIApplication.shared.open(appSettings)
                            }
                        }
                    }
                    alertController.addAction(openAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        @unknown default:
            print("Unknown to access to Contacts")
        }
        
        // Notifications
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            switch settings.authorizationStatus {
            case .authorized:
                // Authorized
                //Nothing to do
                print("Allowed to use Notifications")
            case .provisional, .denied:
                // Not allowed
                // Prompt with warning and button to settings
                let alertController = UIAlertController(
                    title: NSLocalizedString("negative_alert_title", comment: ""),
                    message: NSLocalizedString("negative_notification_alert_body", comment: ""),
                    preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: NSLocalizedString("negative_alert_btn_cancel", comment: ""), style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                let openAction = UIAlertAction(title: NSLocalizedString("negative_alert_btn_ok", comment: ""), style: .default) { (action) in
                    if let appSettings = URL(string: UIApplication.openSettingsURLString + Bundle.main.bundleIdentifier!) {
                        if UIApplication.shared.canOpenURL(appSettings) {
                            UIApplication.shared.open(appSettings)
                        }
                    }
                }
                alertController.addAction(openAction)
                self.present(alertController, animated: true, completion: nil)
            case .notDetermined:
                // Not allowed
                // Prompt with warning and button to settings
                let center = UNUserNotificationCenter.current()
                center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
                    // Enable or disable features based on authorization.
                    if error != nil {
                        let alertController = UIAlertController(
                            title: NSLocalizedString("negative_alert_title", comment: ""),
                            message: NSLocalizedString("negative_notification_alert_body", comment: ""),
                            preferredStyle: .alert)
                        let cancelAction = UIAlertAction(title: NSLocalizedString("negative_alert_btn_cancel", comment: ""), style: .cancel, handler: nil)
                        alertController.addAction(cancelAction)
                        let openAction = UIAlertAction(title: NSLocalizedString("negative_alert_btn_ok", comment: ""), style: .default) { (action) in
                            if let appSettings = URL(string: UIApplication.openSettingsURLString + Bundle.main.bundleIdentifier!) {
                                if UIApplication.shared.canOpenURL(appSettings) {
                                    UIApplication.shared.open(appSettings)
                                }
                            }
                        }
                        alertController.addAction(openAction)
                        self.present(alertController, animated: true, completion: nil)
                    } else {
                        // Authorized
                        //Nothing to do
                        print("Allowed to use Notifications")
                    }
                }
            @unknown default:
                print("Unknown to access to Camera")
            }
        }
        
        //Location
        let locationManager = CLLocationManager()
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways:
            // Authorized
            //Nothing to do
            print("Allowed Location Access")
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        case .authorizedWhenInUse, .restricted, .denied:
            let alertController = UIAlertController(
                title: NSLocalizedString("negative_alert_title", comment: ""),
                message: NSLocalizedString("negative_location_alert_body", comment: ""),
                preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: NSLocalizedString("negative_alert_btn_cancel", comment: ""), style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            let openAction = UIAlertAction(title: NSLocalizedString("negative_alert_btn_ok", comment: ""), style: .default) { (action) in
                if let appSettings = URL(string: UIApplication.openSettingsURLString + Bundle.main.bundleIdentifier!) {
                    if UIApplication.shared.canOpenURL(appSettings) {
                        UIApplication.shared.open(appSettings)
                    }
                }
            }
            alertController.addAction(openAction)
            self.present(alertController, animated: true, completion: nil)
        @unknown default:
            print("Unknown to access to Location")
        }
    }
    
    // operation: kCCEncrypt or kCCDecrypt
    func testCrypt(data:[UInt8], keyData:[UInt8], ivData:[UInt8], operation:Int) -> [UInt8]? {
        let cryptLength  = size_t(data.count+kCCBlockSizeAES128)
        var cryptData    = [UInt8](repeating:0, count:cryptLength)
        
        let keyLength             = size_t(kCCKeySizeAES128)
        let algoritm: CCAlgorithm = UInt32(kCCAlgorithmAES128)
        let options:  CCOptions   = UInt32(kCCOptionPKCS7Padding)
        
        var numBytesEncrypted :size_t = 0
        
        let cryptStatus = CCCrypt(CCOperation(operation),
                                  algoritm,
                                  options,
                                  keyData, keyLength,
                                  ivData,
                                  data, data.count,
                                  &cryptData, cryptLength,
                                  &numBytesEncrypted)
        
        if UInt32(cryptStatus) == UInt32(kCCSuccess) {
            cryptData.removeSubrange(numBytesEncrypted..<cryptData.count)
            
        } else {
            NSLog("Error: \(cryptStatus)")
        }
        
        return cryptData;
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizer.Direction.right {
            performSegue(withIdentifier: "motorcycleToTaskGrid", sender: [])
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.left {
            performSegue(withIdentifier: "motorcycleToMusic", sender: [])
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.up {
            //UP
            if !UserDefaults.standard.bool(forKey: "motorcycle_data_preference") {
                upScreen()
            }
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.down {
            //DOWN
            if !UserDefaults.standard.bool(forKey: "motorcycle_data_preference") {
                downScreen()
            }
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
        // your code here
        performSegue(withIdentifier: "motorcycleToTaskGrid", sender: [])
    }
    
    @objc func rightScreen() {
        // your code here
        performSegue(withIdentifier: "motorcycleToMusic", sender: [])
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
                NSLog("Unknown Cell Count")
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
                NSLog("Unknown Cell Count")
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
            case 12:
                cellsPerRow = 4
                rowCount = 2
                nextCellCount = 8
            case 15:
                cellsPerRow = 4
                rowCount = 3
                nextCellCount = 12
            default:
                NSLog("Unknown Cell Count")
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
            case 12:
                cellsPerRow = 2
                rowCount = 4
                nextCellCount = 8
            case 15:
                cellsPerRow = 3
                rowCount = 4
                nextCellCount = 12
            default:
                NSLog("Unknown Cell Count")
            }
        }
        UserDefaults.standard.set(nextCellCount, forKey: "GRIDCOUNT")
        self.collectionView!.collectionViewLayout.invalidateLayout()
        self.collectionView!.reloadData()
    }
    
    func showPickerInActionSheet(cell: Int) {
        let title = ""
        let message = "\n\n\n\n\n\n\n\n\n\n";
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.actionSheet);
        alert.isModalInPopover = true;
        
        var width = self.view.bounds.width
        if (self.view.bounds.width > self.view.bounds.height){
            width = self.view.bounds.height
        }
        
        //Create a frame (placeholder/wrapper) for the picker and then create the picker
        let pickerFrame = CGRect(x: 0, y: 52, width: width, height: 100)
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
        
        //Create the toolbar view - the view witch will hold our 2 buttons
        let toolFrame = CGRect(x: 0, y: 5, width: width, height: 45)
        let toolView: UIView = UIView(frame: toolFrame)
        
        
        //add buttons to the view
        let buttonCancelFrame = CGRect(x: 0, y: 7, width: (width / 2), height: 30) //size & position of the button as placed on the toolView
        
        //Create the cancel button & set its title
        let buttonCancel: UIButton = UIButton(frame: buttonCancelFrame);
        buttonCancel.setTitle(NSLocalizedString("cancel_bt", comment: ""), for: .normal)
        buttonCancel.setTitleColor(UIColor.blue, for: .normal)
        toolView.addSubview(buttonCancel); //add it to the toolView
        
        //Add the target - target, function to call, the event witch will trigger the function call
        buttonCancel.addTarget(self, action: #selector(MainCollectionViewController.cancelSelection(sender:)), for: UIControl.Event.touchDown);
        
        
        //add buttons to the view
        
        let buttonOkFrame = CGRect(x: (width / 2), y: 7, width: (width / 2), height: 30)//size & position of the button as placed on the toolView
        
        //Create the Select button & set the title
        let buttonOk: UIButton = UIButton(frame: buttonOkFrame);
        buttonOk.setTitle(NSLocalizedString("select_bt", comment: ""), for: UIControl.State.normal);
        buttonOk.setTitleColor(UIColor.blue, for: UIControl.State.normal);
        toolView.addSubview(buttonOk); //add to the subview
        
        buttonOk.addTarget(self, action: #selector(MainCollectionViewController.saveCellPref), for: UIControl.Event.touchDown);
        
        //add the toolbar to the alert controller
        alert.view.addSubview(toolView);
        
        self.present(alert, animated: true, completion: nil);
    }
    
    @objc func cancelSelection(sender: UIButton){
        self.dismiss(animated: true, completion: nil)
        
        // We dismiss the alert. Here you can add your additional code to execute when cancel is pressed
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
            NSLog("Unknown Cell")
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
            motorcycleData.setleanAngle(leanAngle: Utility.degrees(radians: attitude.yaw))
            motorcycleData.setgForce(gForce: sqrt (pow(data!.userAcceleration.x,2) + pow(data!.userAcceleration.y,2) + pow(data!.userAcceleration.z,2)))
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
    
    func updateTimeTimer(){
        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
        timeTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTime), userInfo: nil, repeats: true)
    }
    
    @objc func updateTime(){
        // get the current date and time
        let currentDateTime = Date()
        
        // initialize the date formatter and set the style
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        //formatter.timeStyle = .long
        //formatter.dateStyle = .none
        
        // get the date time String from the date object
        motorcycleData.setTime(time: formatter.string(from: currentDateTime))
    }
}

extension MainCollectionViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch(indexPath.row) {
        case 0:
            //Geo Data
            performSegue(withIdentifier: "motorcycleToGeoData", sender: self)
        case 1:
            //App Settings
            if let appSettings = URL(string: UIApplication.openSettingsURLString + Bundle.main.bundleIdentifier!) {
                if UIApplication.shared.canOpenURL(appSettings) {
                    UIApplication.shared.open(appSettings)
                }
            }
        case 2:
            if (popoverMenuList.count == 5){
                //HW Settings
                performSegue(withIdentifier: "motorcycleToHWSettings", sender: self)
            } else {
                //About
                performSegue(withIdentifier: "motorcycleToAbout", sender: self)
            }
        case 3:
            if (popoverMenuList.count == 5){
                //About
                performSegue(withIdentifier: "motorcycleToAbout", sender: self)
            } else {
                exit(0)
            }
        case 4:
            exit(0)
        default:
            NSLog("Unknown option")
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

extension UINavigationController {
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        print("UINavigationController: preferredStatusBarStyle")
        if UserDefaults.standard.bool(forKey: "nightmode_preference") {
            return .lightContent
        } else {
            print("UINavigationController: preferredStatusBarStyle - light")
            return .default
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVMediaType(_ input: AVMediaType) -> String {
	return input.rawValue
}
