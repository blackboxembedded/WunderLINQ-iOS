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
import os.log

private let reuseIdentifier = "MainCollectionViewCell"

class MainCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, CBCentralManagerDelegate, CBPeripheralDelegate, UNUserNotificationCenterDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var mainUIView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let altimeter = CMAltimeter()
    
    var backBtn: UIButton!
    var backButton: UIBarButtonItem!
    var bluetoothBtn: UIButton!
    var bluetoothButton: UIBarButtonItem!
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

    var wlqData: WLQ!
    let bleData = BLE.shared
    let motorcycleData = MotorcycleData.shared
    let faults = Faults.shared
    var messages = [UInt8: Data]()
    var lastNotification: [Bool]?
    var prevBrakeValue = 0
    var lastControlMessage = 0
    let motionManager = CMMotionManager()
    var referenceAttitude: CMAttitude?
    
    private let notificationCenter = NotificationCenter.default
    /*
    lazy var menu = Templates.UIKitMenu(sourceView: menuBtn!) {
        Templates.MenuButton(title: NSLocalizedString("bike_info_label", comment: ""), systemImage: nil) { self.openBikeInfo() }
        Templates.MenuButton(title: NSLocalizedString("geodata_label", comment: ""), systemImage: nil) { self.openGeoData() }
        Templates.MenuButton(title: NSLocalizedString("appsettings_label", comment: ""), systemImage: nil) { self.openAppSettings() }
        Templates.MenuButton(title: NSLocalizedString("hwsettings_label", comment: ""), systemImage: nil) { self.openHWSettings() }
        Templates.MenuButton(title: NSLocalizedString("about_label", comment: ""), systemImage: nil) { self.openAbout() }
        Templates.MenuButton(title: NSLocalizedString("close_label", comment: ""), systemImage: nil) { exit(0)}
    }
     */
    
    var navBarTimeout = 10
    var navBarTimer = Timer()
    var timeTimer = Timer()
    var sensorUpdateTimer = Timer()
    var countdownTimer: Timer?
    var remainingSeconds = 10 // Countdown duration
    var okAction: UIAlertAction?
    
    let gridInset: CGFloat = 5
    let minimumLineSpacing: CGFloat = 5
    let minimumInteritemSpacing: CGFloat = 5

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
                         NSLocalizedString("rearwheel_speed_header", comment: ""),
                         NSLocalizedString("local_battery_header", comment: ""),
                         NSLocalizedString("elevation_change_header", comment: "")
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
        //$0.desiredAccuracy = kCLLocationAccuracyReduced
        //$0.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        //$0.distanceFilter = 10
        //$0.activityType = .automotiveNavigation
        $0.allowsBackgroundLocationUpdates = true
        $0.pausesLocationUpdatesAutomatically = false
        //$0.startUpdatingLocation()
        $0.startUpdatingHeading()
        return $0
    }(CLLocationManager())
    
    func getQuickLocationUpdate() {
        // Request location authorization
        self.locationManager.requestWhenInUseAuthorization()
        
        // Request a location update
        self.locationManager.requestLocation()
        // Note: requestLocation may timeout and produce an error if authorization has not yet been granted by the user
    }
    
    private func orientationAdjustment() -> CGFloat {
        let isFaceDown: Bool = {
            switch UIDevice.current.orientation {
            case .faceDown: return true
            default: return false
            }
        }()
        
        let adjAngle: CGFloat = {
            switch UIApplication.shared.windows.first?.windowScene?.interfaceOrientation {
            case .landscapeLeft:
                return 90
            case .landscapeRight:
                return -90
            case .portrait, .unknown:
                return 0
            case .portraitUpsideDown:
                return isFaceDown ? 180 : -180
            case .none:
                return 0
            @unknown default:
                return 0
            }
        }()
        return adjAngle
    }

    override func viewWillAppear(_ animated: Bool) {
        os_log("MainCollectionViewController: viewWillAppear")
        super.viewWillAppear(animated)
        referenceAttitude = nil
        
        if UserDefaults.standard.integer(forKey: "darkmode_lastSet") != UserDefaults.standard.integer(forKey: "darkmode_preference"){
            UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "darkmode_preference"), forKey: "darkmode_lastSet")
            // quit app
            exit(0)
        }
        if UserDefaults.standard.bool(forKey: "display_brightness_preference") {
            UIScreen.main.brightness = CGFloat(1.0)
        } else {
            UIScreen.main.brightness = CGFloat(UserDefaults.standard.float(forKey: "systemBrightness"))
        }
        if !navBarTimer.isValid {
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
        os_log("MainCollectionViewController: viewDidLayoutSubviews")
        super.viewDidLayoutSubviews()
        //updateCollectionViewLayout(with: self.view.frame.size)
        //collectionView.reloadData()
        updateCollectionViewLayout()
    }

    override func viewDidLoad() {
        os_log("MainCollectionViewController: viewDidLoad()")
        super.viewDidLoad()
        
        registerSettingsBundle()
        
        if UserDefaults.standard.bool(forKey: "display_brightness_preference") {
            UIScreen.main.brightness = CGFloat(1.0)
        } else {
            UIScreen.main.brightness = CGFloat(UserDefaults.standard.float(forKey: "systemBrightness"))
        }
        
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
        backBtn.tintColor = UIColor(named: "imageTint")
        backBtn.addTarget(self, action: #selector(leftScreen), for: .touchUpInside)
        backButton = UIBarButtonItem(customView: backBtn)
        let backButtonWidth = backButton.customView?.widthAnchor.constraint(equalToConstant: 30)
        backButtonWidth?.isActive = true
        let backButtonHeight = backButton.customView?.heightAnchor.constraint(equalToConstant: 30)
        backButtonHeight?.isActive = true
        
        bluetoothBtn = UIButton(type: .custom)
        let disconnectImage = UIImage(named: "Bluetooth")?.withRenderingMode(.alwaysTemplate)
        bluetoothBtn.setImage(disconnectImage, for: .normal)
        bluetoothBtn.tintColor = UIColor(named: "motorrad_red")
        bluetoothBtn.accessibilityIgnoresInvertColors = true
        bluetoothBtn.addTarget(self, action: #selector(btButtonTapped), for: .touchUpInside)
        bluetoothButton = UIBarButtonItem(customView: bluetoothBtn)
        bluetoothButton.accessibilityRespondsToUserInteraction = false
        bluetoothButton.isAccessibilityElement = false
        let bluetoothButtonWidth = bluetoothButton.customView?.widthAnchor.constraint(equalToConstant: 30)
        bluetoothButtonWidth?.isActive = true
        let bluetoothButtonHeight = bluetoothButton.customView?.heightAnchor.constraint(equalToConstant: 30)
        bluetoothButtonHeight?.isActive = true
        
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
        faultsButton.isEnabled = false
        
        menuBtn = UIButton()
        menuBtn.setImage(UIImage(named: "Menu")?.withRenderingMode(.alwaysTemplate), for: .normal)
        menuBtn.tintColor = UIColor(named: "imageTint")
        let menuButton = UIBarButtonItem(customView: menuBtn)
        menuButton.accessibilityRespondsToUserInteraction = false
        menuButton.isAccessibilityElement = false
        let menuButtonWidth = menuButton.customView?.widthAnchor.constraint(equalToConstant: 30)
        menuButtonWidth?.isActive = true
        let menuButtonHeight = menuButton.customView?.heightAnchor.constraint(equalToConstant: 30)
        menuButtonHeight?.isActive = true
        
        let forwardBtn = UIButton()
        forwardBtn.setImage(UIImage(named: "Right")?.withRenderingMode(.alwaysTemplate), for: .normal)
        forwardBtn.tintColor = UIColor(named: "imageTint")
        forwardBtn.addTarget(self, action: #selector(rightScreen), for: .touchUpInside)
        let forwardButton = UIBarButtonItem(customView: forwardBtn)
        let forwardButtonWidth = forwardButton.customView?.widthAnchor.constraint(equalToConstant: 30)
        forwardButtonWidth?.isActive = true
        let forwardButtonHeight = forwardButton.customView?.heightAnchor.constraint(equalToConstant: 30)
        forwardButtonHeight?.isActive = true
        
        self.navigationItem.title = NSLocalizedString("main_title", comment: "")
        self.navigationItem.leftBarButtonItems = [backButton, bluetoothButton, faultsButton]
        self.navigationItem.rightBarButtonItems = [forwardButton, menuButton]
        
        // Menu creation
        let actionClosure: UIActionHandler = { action in
            print("Selected: \(action.title)")
        }
        // Data source: array of (title, action) tuples
        let dataSource: [(title: String, action: () -> Void)] = [
            (NSLocalizedString("bike_info_label", comment: ""), { self.openBikeInfo() }),
            (NSLocalizedString("geodata_label", comment: ""), { self.openGeoData() }),
            (NSLocalizedString("appsettings_label", comment: ""), { self.openAppSettings() }),
            (NSLocalizedString("hwsettings_label", comment: ""), { self.openHWSettings() }),
            (NSLocalizedString("about_label", comment: ""), { self.openAbout() }),
            (NSLocalizedString("close_label", comment: ""), { exit(0)}),
        ]

        // Create UIActions with unique closures
        let menuChildren: [UIAction] = dataSource.map { item in
            return UIAction(title: item.title) { _ in
                item.action()
            }
        }

        // Assign menu to button
        menuBtn.menu = UIMenu(title: "", options: .displayInline, children: menuChildren)
        menuBtn.showsMenuAsPrimaryAction = true

        // Position and display
        menuBtn.frame = CGRect(x: 150, y: 200, width: 150, height: 40)
        view.addSubview(menuBtn)
        
        // Configure the flow layout
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = minimumInteritemSpacing // Horizontal spacing
        layout.minimumLineSpacing = minimumLineSpacing // Vertical spacing
        layout.sectionInset = UIEdgeInsets(top: gridInset, left: gridInset, bottom: gridInset, right: gridInset) // Margins around the grid
        
        // Assign the layout to the collection view
        collectionView.collectionViewLayout = layout
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView?.contentInsetAdjustmentBehavior = .always
        
        // Sensor Setup
        if motionManager.isDeviceMotionAvailable {
            //do something interesting
            os_log("MainCollectionViewController: Motion Device Available")
        }
        motionManager.startDeviceMotionUpdates()
        motionManager.deviceMotionUpdateInterval = 1.0 / 50.0
        
        referenceAttitude = nil
        
        locationManager.delegate = locationDelegate
        
        locationDelegate.locationCallback = { [self] location in
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
            if (!UserDefaults.standard.bool(forKey: "bearing_override_preference")){
                self.motorcycleData.setbearing(bearing: degrees)
            }
        }
        
        if CMAltimeter.isRelativeAltitudeAvailable() {
            altimeter.startRelativeAltitudeUpdates(to: OperationQueue.main) { (data, error) in
                if data?.pressure != nil {
                    let pressure:Double = (data?.pressure as? Double)! * 10.0
                    self.motorcycleData.setBarometricPressure(barometricPressure: pressure)
                }
            }
        }
        
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionRestoreIdentifierKey: "com.blackboxembedded.wunderlinq"])
        
        // Scheduling timer to Call the function "updateTime" with the interval of 1 seconds
        timeTimer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(self.updatePhoneSensorData), userInfo: nil, repeats: true)
        
        updateDisplay()
        
        // Scheduling timer to Call the function "updateTime" with the interval of 1 seconds
        timeTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTime), userInfo: nil, repeats: true)
        
        showDisclaimerAlert()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        os_log("MainCollectionViewController: viewWillTransition")
        super.viewWillTransition(to: size, with: coordinator)
        referenceAttitude = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        os_log("MainCollectionViewController: viewWillDisappear")
        super.viewWillDisappear(animated)
        
        navBarTimer.invalidate()
        navBarTimeout = 0
        // Show the navigation bar on other view controllers
        DispatchQueue.main.async(){
            self.navigationController?.setNavigationBarHidden(false, animated: animated)
        }
    }
    private func updateCollectionViewLayout() {
        var columns = 1
        var rows = 1
        let cellCount = UserDefaults.standard.integer(forKey: "GRIDCOUNT");
        if (self.view.frame.size.width < self.view.frame.size.height){
            switch (cellCount){
                case 1:
                    rows = 1
                    columns = 1
                case 2:
                    rows = 2
                    columns = 1
                case 4:
                    rows = 2
                    columns = 2
                case 8:
                    rows = 4
                    columns = 2
                case 10:
                    rows = 5
                    columns = 2
                case 12:
                    rows = 4
                    columns = 3
                case 15:
                    rows = 5
                    columns = 3
                default:
                    rows = 5
                    columns = 3
                    UserDefaults.standard.set(15, forKey: "GRIDCOUNT")
                }
            } else {
                switch (cellCount){
                case 1:
                    rows = 1
                    columns = 1
                case 2:
                    rows = 1
                    columns = 2
                case 4:
                    rows = 1
                    columns = 4
                case 8:
                    rows = 2
                    columns = 4
                case 10:
                    rows = 2
                    columns = 5
                case 12:
                    rows = 3
                    columns = 4
                case 15:
                    rows = 3
                    columns = 5
                default:
                    rows = 3
                    columns = 5
                    UserDefaults.standard.set(15, forKey: "GRIDCOUNT")
                }
        }
        // Calculate item size dynamically
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let totalHorizontalSpacing = layout.minimumInteritemSpacing * CGFloat(columns - 1) + layout.sectionInset.left + layout.sectionInset.right
            let totalVerticalSpacing = layout.minimumLineSpacing * CGFloat(rows - 1) + layout.sectionInset.top + layout.sectionInset.bottom

            let itemWidth = (collectionView.bounds.width - totalHorizontalSpacing) / CGFloat(columns)
            let itemHeight = (collectionView.bounds.height - totalVerticalSpacing) / CGFloat(rows)

            layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        var cellCount = UserDefaults.standard.integer(forKey: "GRIDCOUNT")
        switch (cellCount){
        case 1:
            os_log("MainCollectionViewController: cellCount:1")
        case 2:
            os_log("MainCollectionViewController: cellCount:2")
        case 4:
            os_log("MainCollectionViewController: cellCount:4")
        case 8:
            os_log("MainCollectionViewController: cellCount:8")
        case 10:
            os_log("MainCollectionViewController: cellCount:10")
        case 12:
            os_log("MainCollectionViewController: cellCount:12")
        case 15:
            os_log("MainCollectionViewController: cellCount:15")
        default:
            os_log("MainCollectionViewController: cellCount:default(15)")
            cellCount = 15
            UserDefaults.standard.set(15, forKey: "GRIDCOUNT")
        }
        return cellCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MainCollectionViewCell
        cell.accessibilityRespondsToUserInteraction = false
        cell.isAccessibilityElement = false
        let label = MotorcycleData.getLabel(dataPoint: getCellDataPoint(cell: indexPath.row + 1))
        cell.setHeader(label: label)
        let icon = MotorcycleData.getIcon(dataPoint: getCellDataPoint(cell: indexPath.row + 1))
        cell.setIcon(icon: icon)
        if let labelColor = MotorcycleData.getValueColor(dataPoint: getCellDataPoint(cell: indexPath.row + 1)){
            cell.setValueColor(labelColor: labelColor)
        }
        return cell
    }
    
    @objc func faultsButtonTapped() {
        performSegue(withIdentifier: "motorcycleToFaults", sender: [])
    }

    @objc func btButtonTapped(_ sender: UIBarButtonItem) {
        // if we don't have a WunderLINQ, start scanning for one...
        os_log("MainCollectionViewController: btButtonTapped()")
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
    
    @objc func launchAccPage(){
        // only run if this view is on screen
        guard self.viewIfLoaded?.window != nil else { return }

        // make sure we have a nav controller
        guard let nav = self.navigationController else { return }
        
        // Option A) Only push if the topVC isn’t already an AccessoryViewController
        if !(nav.topViewController is AccessoryViewController) {
            let accessoryVC = storyboard!
                .instantiateViewController(withIdentifier: "AccessoryViewController")
                as! AccessoryViewController
            nav.pushViewController(accessoryVC, animated: true)
        }
    }
    
    // MARK: - Bluetooth scanning
    
    @objc func pauseScan() {
        // Scanning uses up battery on phone, so pause the scan process for the designated interval.
        os_log("MainCollectionViewController: PAUSING SCAN...")
        bluetoothButton.isEnabled = true
        self.centralManager?.stopScan()
        Timer.scheduledTimer(timeInterval: timerPauseInterval, target: self, selector: #selector(self.resumeScan), userInfo: nil, repeats: false)
        
    }
    
    @objc func resumeScan() {
        let lastPeripherals = centralManager.retrieveConnectedPeripherals(withServices: [CBUUID(string: Device.WunderLINQServiceUUID)])
        
        if lastPeripherals.count > 0{
            os_log("MainCollectionViewController: FOUND WunderLINQ")
            let device = lastPeripherals.last!;
            wunderLINQ = device;
            bleData.setPeripheral(peripheral: device)
            centralManager?.connect(wunderLINQ!, options: nil)
        } else {
            if keepScanning {
                // Start scanning again...
                os_log("MainCollectionViewController: RESUMING SCAN!")
                bluetoothButton.isEnabled = false
                centralManager.scanForPeripherals(withServices: [CBUUID(string: Device.WunderLINQAdvertisingUUID)], options: nil)
                Timer.scheduledTimer(timeInterval: timerScanInterval, target: self, selector: #selector(self.pauseScan), userInfo: nil, repeats: false)
            } else {
                bluetoothButton.isEnabled = true
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
            os_log("MainCollectionViewController: Unknown cell")
        }
        return cellDataPoint
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
        self.navigationItem.leftBarButtonItems = [backButton, bluetoothButton, faultsButton]
        
        // Update main display
        let cellCount = UserDefaults.standard.integer(forKey: "GRIDCOUNT")
        let validCellCount = cellCount > 0 ? cellCount : 15 // Default to 15 if cellCount is 0
        for i in 1...validCellCount {
            setCell(i)
        }
        
    }
    
    func setCell(_ cellNumber: Int){
        let label = MotorcycleData.getLabel(dataPoint: getCellDataPoint(cell: cellNumber))
        let value:String = MotorcycleData.getValue(dataPoint: getCellDataPoint(cell: cellNumber))
        let icon: UIImage = MotorcycleData.getIcon(dataPoint: getCellDataPoint(cell: cellNumber))
        
        if let cell = self.collectionView.cellForItem(at: IndexPath(row: cellNumber - 1, section: 0) as IndexPath) as? MainCollectionViewCell{
            cell.setHeader(label: label)
            cell.setValue(value: value)
            cell.setIcon(icon: icon)
            if let labelColor = MotorcycleData.getValueColor(dataPoint: getCellDataPoint(cell: cellNumber)){
                cell.setValueColor(labelColor: labelColor)
            }
        }
    }
    
    func parseCommandResponse(_ data:Data) {
        let dataLength = data.count / MemoryLayout<UInt8>.size
        var dataArray = [UInt8](repeating: 0, count: dataLength)
        (data as NSData).getBytes(&dataArray, length: dataLength * MemoryLayout<Int16>.size)

        if UserDefaults.standard.bool(forKey: "debug_logging_preference") {
            var messageHexString = ""
            for i in 0 ..< dataLength {
                messageHexString += String(format: "%02X", dataArray[i])
                if i < dataLength - 1 {
                    messageHexString += ","
                }
            }
            os_log("MainCollectionViewController: Command Response Received: \(messageHexString)")
        }
        
        switch (dataArray[0]){
        case 0x57:
            switch (dataArray[1]){
            case 0x52:
                switch (dataArray[2]){
                case 0x41:
                    if (dataArray[3] == 0x50){
                        os_log("MainCollectionViewController: Received WRS command response")
                        if (wlqData != nil){
                            motorcycleData.setHasFocus(hasFocus: false)
                            if UserDefaults.standard.bool(forKey: "focus_indication_preference") {
                                os_log("Focus Gone")
                                // Return NavBar back to normal color
                                let navBarColor = UIColor(named: "backgrounds")
                                updateNavigationBar(color: navBarColor!)
                            }
                            WLQ.shared.setStatus(bytes: dataArray)
                            notificationCenter.post(name: Notification.Name("StatusUpdate"), object: nil)
                            launchAccPage()
                        }
                    }
                    break
                case 0x56:
                    os_log("MainCollectionViewController: Received WRV command response")
                    if (wlqData != nil){
                        UserDefaults.standard.set("\(dataArray[3]).\(dataArray[4])", forKey: "firmwareVersion")
                        wlqData.setfirmwareVersion(firmwareVersion: "\(dataArray[3]).\(dataArray[4])")
                    }
                    break
                case 0x57:
                    os_log("MainCollectionViewController: Received WRW command response")
                    if (wlqData != nil){
                        wlqData.parseConfig(bytes: dataArray)
                    }
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
        var showAlert = false
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
            message = NSLocalizedString("bt_ready", comment: "")
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
            if peripheralName.contains(deviceName) {
                os_log("MainCollectionViewController: WunderLINQ FOUND! ADDING NOW!!!")
                // to save power, stop scanning for other devices
                keepScanning = false
                bluetoothButton.isEnabled = true
                
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
        os_log("MainCollectionViewController: SUCCESSFULLY CONNECTED TO WunderLINQ!")
        bluetoothBtn.tintColor = UIColor(named: "motorrad_blue")
        
        os_log("MainCollectionViewController: Peripheral info: \(peripheral)")
        peripheral.delegate = self
        
        // Now that we've successfully connected to the WunderLINQ, let's discover the services.
        // - NOTE:  we pass nil here to request ALL services be discovered.
        //          If there was a subset of services we were interested in, we could pass the UUIDs here.
        //          Doing so saves battery life and saves time.
        peripheral.discoverServices([CBUUID(string: Device.WunderLINQServiceUUID)])
        
        // Send notification to open the app if a WunderLINQ connection is made in the background.
        if UIApplication.shared.applicationState == .background {
            sendConnectionNotification(for: peripheral)
        }
        
        // Check for auto-trip logging
        if UserDefaults.standard.bool(forKey: "autotrip_enable_preference") {
            let loggingStatus = UserDefaults.standard.string(forKey: "loggingStatus")
            if loggingStatus == nil {
                //Start Logging
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyyMMdd-HH-mm-ss"
                let dateString = dateFormatter.string(from: Date())
                UserDefaults.standard.set(dateString, forKey: "loggingStatus")
            }
        }
    }
    
    
    /*
     Invoked when the central manager fails to create a connection with a peripheral.
     
     This method is invoked when a connection initiated via the connectPeripheral:options: method fails to complete.
     Because connection attempts do not time out, a failed connection usually indicates a transient issue,
     in which case you may attempt to connect to the peripheral again.
     */
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        os_log("MainCollectionViewController: CONNECTION TO WunderLINQ FAILED!")
        bluetoothBtn.tintColor = UIColor(named: "motorrad_red")
    }
    
    
    /*
     Invoked when an existing connection with a peripheral is torn down.
     
     This method is invoked when a peripheral connected via the connectPeripheral:options: method is disconnected.
     If the disconnection was not initiated by cancelPeripheralConnection:, the cause is detailed in error.
     After this method is called, no more methods are invoked on the peripheral device’s CBPeripheralDelegate object.
     
     Note that when a peripheral is disconnected, all of its services, characteristics, and characteristic descriptors are invalidated.
     */
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        os_log("MainCollectionViewController: DISCONNECTED FROM WunderLINQ!")
        bluetoothBtn.tintColor = UIColor(named: "motorrad_red")
        motorcycleData.setHasFocus(hasFocus: false)
        if UserDefaults.standard.bool(forKey: "focus_indication_preference") {
            os_log("Focus Gone")
            // Return NavBar back to normal color
            let navBarColor = UIColor(named: "backgrounds")
            updateNavigationBar(color: navBarColor!)
        }
        
        // Check for auto-trip logging
        if UserDefaults.standard.bool(forKey: "autotrip_enable_preference") {
            let loggingStatus = UserDefaults.standard.string(forKey: "loggingStatus")
            if loggingStatus != nil {
                //Stop Logging
                UserDefaults.standard.set(nil, forKey: "loggingStatus")
            }
        }
        
        //Reset trend data
        motorcycleData.resetData()
        
        updateDisplay()
        if error != nil {
            os_log("MainCollectionViewController: DISCONNECTION DETAILS: \(error!.localizedDescription)")
        }
        wunderLINQ = nil
        
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
            os_log("MainCollectionViewController: ERROR DISCOVERING SERVICES: \(error?.localizedDescription ?? "Unknown Error")")
            return
        }
        
        // Core Bluetooth creates an array of CBService objects —- one for each service that is discovered on the peripheral.
        if let services = peripheral.services {
            for service in services {
                os_log("MainCollectionViewController: DISCOVERED SERVICE: \(service)")
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
            os_log("MainCollectionViewController: ERROR DISCOVERING CHARACTERISTICS: \(error?.localizedDescription ?? "Unknown Error")")
            return
        }
        numServicesChecked = numServicesChecked + 1;
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                os_log("MainCollectionViewController: DISCOVERED CHAR: \(characteristic)")
                // Message Data Characteristic
                if characteristic.uuid == CBUUID(string: Device.HWRevisionCharacteristicUUID) {
                    hwRevCharacteristic = characteristic
                } else if characteristic.uuid == CBUUID(string: Device.WunderLINQPerformanceCharacteristicUUID) {
                    os_log("MainCollectionViewController: Navigator FOUND")
                    // Enable the message notifications
                    messageCharacteristic = characteristic
                    wunderLINQ?.setNotifyValue(true, for: characteristic)
                } else if characteristic.uuid == CBUUID(string: Device.WunderLINQNCommandCharacteristicUUID) {
                    wlqData = WLQ_N()
                    // Enable the message notifications
                    os_log("MainCollectionViewController: COMMAND INTERFACE FOUND")
                    commandCharacteristic = characteristic
                    wunderLINQ?.setNotifyValue(true, for: characteristic)
                    bleData.setcmdCharacteristic(cmdCharacteristic: characteristic)
                    if(wlqData != nil){
                        os_log("MainCollectionViewController: REQUESTING CONFIG")
                        let writeData =  Data(_: wlqData.GET_CONFIG_CMD())
                        peripheral.writeValue(writeData, for: commandCharacteristic!, type: CBCharacteristicWriteType.withResponse)
                        peripheral.readValue(for: commandCharacteristic!)
                    }
                } else if characteristic.uuid == CBUUID(string: Device.WunderLINQXCommandCharacteristicUUID) {
                    wlqData = WLQ_X()
                    // Enable the message notifications
                    os_log("MainCollectionViewController: COMMAND INTERFACE FOUND")
                    commandCharacteristic = characteristic
                    wunderLINQ?.setNotifyValue(true, for: characteristic)
                    bleData.setcmdCharacteristic(cmdCharacteristic: characteristic)
                    if(wlqData != nil){
                        os_log("MainCollectionViewController: REQUESTING CONFIG")
                        let writeData =  Data(_: wlqData.GET_CONFIG_CMD())
                        peripheral.writeValue(writeData, for: commandCharacteristic!, type: CBCharacteristicWriteType.withResponse)
                        peripheral.readValue(for: commandCharacteristic!)
                    }
                } else if characteristic.uuid == CBUUID(string: Device.WunderLINQSCommandCharacteristicUUID) {
                    wlqData = WLQ_S()
                    // Enable the message notifications
                    os_log("MainCollectionViewController: COMMAND INTERFACE FOUND")
                    commandCharacteristic = characteristic
                    wunderLINQ?.setNotifyValue(true, for: characteristic)
                    bleData.setcmdCharacteristic(cmdCharacteristic: characteristic)
                    if(wlqData != nil){
                        os_log("MainCollectionViewController: REQUESTING CONFIG")
                        let writeData =  Data(_: wlqData.GET_CONFIG_CMD())
                        peripheral.writeValue(writeData, for: commandCharacteristic!, type: CBCharacteristicWriteType.withResponse)
                        peripheral.readValue(for: commandCharacteristic!)
                    }
                }
                peripheral.discoverDescriptors(for: characteristic)
            }
            if(numServicesChecked == numServices){
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
            os_log("MainCollectionViewController: ERROR ON UPDATING VALUE FOR CHARACTERISTIC: \(characteristic) - \(error?.localizedDescription ?? "Unknown Error")")
            return
        }
        
        // extract the data from the characteristic's value property and display the value based on the characteristic type
        if let dataBytes = characteristic.value {
            if characteristic.uuid == CBUUID(string: Device.HWRevisionCharacteristicUUID) {
                if let versionString = String(bytes: dataBytes, encoding: .utf8) {
                    os_log("MainCollectionViewController: HW Version: \(versionString)")
                    hardwareVersion = versionString
                    if (wlqData != nil){
                        wlqData.sethardwareVersion(hardwareVersion: versionString)
                    }
                }
            } else if characteristic.uuid == CBUUID(string: Device.WunderLINQPerformanceCharacteristicUUID) {
                let dataLength = dataBytes.count / MemoryLayout<UInt8>.size
                var dataArray = [UInt8](repeating: 0, count: dataLength)
                (dataBytes as NSData).getBytes(&dataArray, length: dataLength * MemoryLayout<Int16>.size)
                let msgID = dataArray[0]
                if (dataArray[0] == 0x04){
                    if (!motorcycleData.getHasFocus()){
                        // Set NavBar to highlight color
                        if UserDefaults.standard.bool(forKey: "focus_indication_preference") {
                            os_log("Focus Gained");
                            // Return back to normal NavBar color
                            var navBarColor: UIColor?
                            // Create a custom appearance for the navigation bar
                            if let colorData = UserDefaults.standard.data(forKey: "highlight_color_preference"){
                                navBarColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData)
                            } else {
                                navBarColor = UIColor(named: "accent")
                            }
                            updateNavigationBar(color: navBarColor!)
                        }
                        if (wlqData != nil){
                            wlqData.setAccActive(active: 1)
                        }
                        notificationCenter.post(name: Notification.Name("StatusUpdate"), object: nil)
                    }
                    motorcycleData.setHasFocus(hasFocus: true)
                    lastControlMessage = Int(Date().timeIntervalSince1970 * 1000)
                } else {
                    if (motorcycleData.getHasFocus() && ( Int(Date().timeIntervalSince1970 * 1000) - lastControlMessage > 500)){
                        if UserDefaults.standard.bool(forKey: "focus_indication_preference") {
                            os_log("Focus Gone")
                            // Return NavBar back to normal color
                            let navBarColor = UIColor(named: "backgrounds")
                            updateNavigationBar(color: navBarColor!)
                        }
                        motorcycleData.setHasFocus(hasFocus: false)
                    }
                    //Check if message changed
                    var process = false
                    if messages[msgID] == nil {
                        messages[msgID] = Data(dataArray)
                        process = true
                    } else {
                        if messages[msgID] != Data(dataArray) {
                            process = true
                        }
                    }
                    if (process) {
                        BLEBus.parseMessage(dataArray)
                        if self.viewIfLoaded?.window != nil {
                            updateDisplay()
                        }
                    }
                }
            } else if characteristic.uuid == CBUUID(string: Device.WunderLINQNCommandCharacteristicUUID) {
                parseCommandResponse(dataBytes)
            } else if characteristic.uuid == CBUUID(string: Device.WunderLINQSCommandCharacteristicUUID) {
                parseCommandResponse(dataBytes)
            } else if characteristic.uuid == CBUUID(string: Device.WunderLINQXCommandCharacteristicUUID) {
                parseCommandResponse(dataBytes)
            } else if characteristic.uuid == CBUUID(string: Device.WunderLINQUCommandCharacteristicUUID) {
                parseCommandResponse(dataBytes)
            }
            
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
            if motorcycleData.ignitionStatus != nil {
                if UserDefaults.standard.bool(forKey: "ignition_enable_preference") && !motorcycleData.getIgnitionStatus(){
                    if !faults.getIgnitionAlertSent(){
                        faults.setIgnitionAlertSent(active:true)
                        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AlertViewControllerID") as? AlertViewController {
                            viewController.ID = 3
                            if let navigator = navigationController {
                                navigator.pushViewController(viewController, animated: true)
                            }
                        }
                    }
                } else {
                    faults.setIgnitionAlertSent(active:false)
                }
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
        if (lastNotification != faults.getallCriticalFaults()){
            lastNotification = faults.getallCriticalFaults()
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
    }
    
    private func clearNotifications(){
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications() // To remove all delivered notifications
        center.removeAllPendingNotificationRequests()
    }
    
    private func sendAlert(message:String){
        let notificationCenter = UNUserNotificationCenter.current()
        // Create a unique identifier for your notification
        let notificationIdentifier = "FaultNotification"
        // Get the notification request with the identifier
        notificationCenter.getPendingNotificationRequests { requests in
            let requestToUpdate = requests.first { request in
                return request.identifier == notificationIdentifier
            }
            
            if let requestToUpdate = requestToUpdate {
                // Create a new notification content with the updated message
                let updatedNotificationContent = UNMutableNotificationContent()
                updatedNotificationContent.title = NSLocalizedString("fault_title", comment: "")
                updatedNotificationContent.body = message
                
                // Create a new notification request with the same identifier and the updated content
                let updatedNotificationRequest = UNNotificationRequest(identifier: notificationIdentifier,
                                                                        content: updatedNotificationContent,
                                                                        trigger: requestToUpdate.trigger)
                
                // Update the notification with the new request
                notificationCenter.add(updatedNotificationRequest) { error in
                    if let error = error {
                        os_log("MainCollectionViewController: Error updating notification: \(error)")
                    }
                }
            } else {
                os_log("MainCollectionViewController: Notification not found with identifier: \(notificationIdentifier)")
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
                let request = UNNotificationRequest(identifier: notificationIdentifier, content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().delegate = self
                
                //adding the notification to notification center
                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            }
        }
        
        
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizer.Direction.right {
            leftScreen()
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.left {
            rightScreen()
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
            UIKeyCommand(input: UIKeyCommand.inputLeftArrow, modifierFlags:[], action: #selector(leftScreen)),
            UIKeyCommand(input: UIKeyCommand.inputRightArrow, modifierFlags:[], action: #selector(rightScreen)),
            UIKeyCommand(input: UIKeyCommand.inputUpArrow, modifierFlags:[], action: #selector(upScreen)),
            UIKeyCommand(input: "+", modifierFlags:[], action: #selector(upScreen)),
            UIKeyCommand(input: UIKeyCommand.inputDownArrow, modifierFlags:[], action: #selector(downScreen)),
            UIKeyCommand(input: "-", modifierFlags:[], action: #selector(downScreen))
        ]
        if #available(iOS 15, *) {
            commands.forEach { $0.wantsPriorityOverSystemBehavior = true }
        }
        return commands
    }
    
    @objc func leftScreen() {
        SoundManager().playSoundEffect("directional")
        var identifier = "motorcycleToTaskGrid"
        if (wlqData != nil){
            if (wlqData.getStatus() != nil){
                identifier = "motorcycleToAccessory"
            }
        }
        performSegue(withIdentifier: identifier, sender: [])
    }
    
    @objc func rightScreen() {
        SoundManager().playSoundEffect("directional")
        if UserDefaults.standard.bool(forKey: "display_dashboard_preference") {
            performSegue(withIdentifier: "motorcycleToDash", sender: [])
        } else if UserDefaults.standard.bool(forKey: "display_music_preference"){
            performSegue(withIdentifier: "motorcycleToMusic", sender: [])
        } else {
            performSegue(withIdentifier: "motorcycleToTaskGrid", sender: [])
        }
    }
    
    @objc func upScreen() {
        SoundManager().playSoundEffect("directional")
        let cellCount = UserDefaults.standard.integer(forKey: "GRIDCOUNT")
        var nextCellCount = 1
        if ( collectionView!.bounds.width > collectionView!.bounds.height){
            switch (cellCount){
            case 1:
                nextCellCount = 2
            case 2:
                nextCellCount = 4
            case 4:
                nextCellCount = 8
            case 8:
                nextCellCount = 10
            case 10:
                nextCellCount = 12
            case 12:
                nextCellCount = 15
            case 15:
                nextCellCount = 1
            default:
                os_log("MainCollectionViewController: Unknown Cell Count")
            }
        } else {
            switch (cellCount){
            case 1:
                nextCellCount = 2
            case 2:
                nextCellCount = 4
            case 4:
                nextCellCount = 8
            case 8:
                nextCellCount = 10
            case 10:
                nextCellCount = 12
            case 12:
                nextCellCount = 15
            case 15:
                nextCellCount = 1
            default:
                os_log("MainCollectionViewController: Unknown Cell Count")
            }
        }
        UserDefaults.standard.set(nextCellCount, forKey: "GRIDCOUNT")
        DispatchQueue.main.async {
            self.updateCollectionViewLayout()
            // Reload data without animations
            UIView.performWithoutAnimation {
                self.collectionView.reloadData()
                self.collectionView.collectionViewLayout.invalidateLayout()
            }
            // Ensure layout updates are fully applied
            self.collectionView.layoutIfNeeded()
        }
    }
    
    @objc func downScreen() {
        SoundManager().playSoundEffect("directional")
        let cellCount = UserDefaults.standard.integer(forKey: "GRIDCOUNT")
        var nextCellCount = 1
        if ( collectionView!.bounds.width > collectionView!.bounds.height){
            switch (cellCount){
            case 1:
                nextCellCount = 15
            case 2:
                nextCellCount = 1
            case 4:
                nextCellCount = 2
            case 8:
                nextCellCount = 4
            case 10:
                nextCellCount = 8
            case 12:
                nextCellCount = 10
            case 15:
                nextCellCount = 12
            default:
                os_log("MainCollectionViewController: Unknown Cell Count")
            }
        } else {
            switch (cellCount){
            case 1:
                nextCellCount = 15
            case 2:
                nextCellCount = 1
            case 4:
                nextCellCount = 2
            case 8:
                nextCellCount = 4
            case 10:
                nextCellCount = 8
            case 12:
                nextCellCount = 10
            case 15:
                nextCellCount = 12
            default:
                os_log("MainCollectionViewController: Unknown Cell Count")
            }
        }
        UserDefaults.standard.set(nextCellCount, forKey: "GRIDCOUNT")
        DispatchQueue.main.async {
            self.updateCollectionViewLayout()
            // Reload data without animations
            UIView.performWithoutAnimation {
                self.collectionView.reloadData()
                self.collectionView.collectionViewLayout.invalidateLayout()
            }
            // Ensure layout updates are fully applied
            self.collectionView.layoutIfNeeded()
        }
    }
    
    func showPickerInActionSheet(cell: Int) {
        let title = ""
        let message = "\n\n\n\n\n\n\n\n\n\n";

        let width:CGFloat = 300
        let heigth:CGFloat = 200
        
        let alertStyle = UIAlertController.Style.alert
        let alert = UIAlertController(title: title, message: message, preferredStyle: alertStyle);
        alert.isModalInPresentation = true;

        // height constraint
        let constraintHeight = NSLayoutConstraint(
           item: alert.view!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute:
           NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: heigth)
        alert.view.addConstraint(constraintHeight)

        // width constraint
        let constraintWidth = NSLayoutConstraint(
           item: alert.view!, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute:
           NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: width)
        alert.view.addConstraint(constraintWidth)
        
        //Create a frame (placeholder/wrapper) for the picker and then create the picker
        let pickerFrame = CGRect(x: 16, y: 0, width: width - (16 * 2), height: heigth - 50)
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
            os_log("MainCollectionViewController: Unknown Cell")
        }
        let _ = UserDefaults.standard.synchronize()
    }
    
    @objc func updatePhoneSensorData() {
        let data = motionManager.deviceMotion
        if (data != nil){
            let attitude = data!.attitude
            if (referenceAttitude != nil){
                attitude.multiply(byInverseOf: referenceAttitude!)
            } else {
                referenceAttitude = attitude
            }
            let leanAngle = Utils.degrees(radians: attitude.yaw)
            //Filter out impossible values, max sport bike lean is +/-60
            if ((leanAngle >= -60.0) && (leanAngle <= 60.0)) {
                motorcycleData.setleanAngle(leanAngle: Utils.degrees(radians: attitude.yaw))
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
        
        // Request Location Update
        getQuickLocationUpdate()
        
        // Log if enabled
        let loggingStatus = UserDefaults.standard.string(forKey: "loggingStatus")
        if loggingStatus != nil {
            //Log
            Logger.log()
        }
    }

    @objc func onTouch() {
        DispatchQueue.main.async(){
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
        if !navBarTimer.isValid {
            runTimer()
        }
    }
    
    func runTimer() {
        if UserDefaults.standard.bool(forKey: "hide_navbar_preference") {
            navBarTimer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
        }
    }
    
    @objc func updateTimer() {
        if navBarTimeout < 1 {
            navBarTimer.invalidate()
            navBarTimeout = 10
            // Hide the navigation bar on the this view controller
            DispatchQueue.main.async(){
                self.navigationController?.setNavigationBarHidden(true, animated: true)
                self.navigationController?.navigationBar.setNeedsLayout()
                if (self.collectionView != nil){
                    self.collectionView!.reloadData()
                }
            }
        } else {
            navBarTimeout -= 1
        }
    }

    @objc func updateTime(){
        // get the current date and time
        let currentDateTime = Date()
        // get the date time String from the date object
        motorcycleData.setTime(time: currentDateTime)
        // get battery
        motorcycleData.setLocalBattery(localBattery: getBatteryPercentage())
        
        updateDisplay()
        
        if (wlqData != nil){
            if (wlqData.gethardwareType() == wlqData.TYPE_N() || wlqData.gethardwareType() == wlqData.TYPE_X()){
                //Update Cluster Clock
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
            }
        }
    }
    
    func getBatteryPercentage() -> Int? {
        UIDevice.current.isBatteryMonitoringEnabled = true
        let batteryLevel = UIDevice.current.batteryLevel
        
        if batteryLevel < 0 {
            return nil // Battery level is indeterminate or battery monitoring is disabled
        }
        
        return Int(batteryLevel * 100)
    }
    
    func sendConnectionNotification(for peripheral: CBPeripheral) {
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("toast_wlq_connected", comment: "")
        content.body = NSLocalizedString("toast_wlq_connected_body", comment: "")
        content.sound = .default

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    func openBikeInfo(){
        //Bike Info
        performSegue(withIdentifier: "motorcycleToBikeInfo", sender: self)
    }
    
    func openGeoData(){
        //Geo Data
        performSegue(withIdentifier: "motorcycleToGeoData", sender: self)
    }
    
    func openAppSettings(){
        //Geo Data
        performSegue(withIdentifier: "motorcycleToSettings", sender: self)
    }
    
    func openHWSettings(){
        //HW Settings
        if (wunderLINQ != nil){
            if (wlqData != nil){
                performSegue(withIdentifier: "motorcycleToHWSettings", sender: self)
            } else {
                //No status
                self.showToast(message: NSLocalizedString("toast_wlq_not_connected", comment: ""))
            }
        } else {
            //Not Connected
            self.showToast(message: NSLocalizedString("toast_wlq_not_connected", comment: ""))
        }
    }
    
    func openAbout(){
        //About
        performSegue(withIdentifier: "motorcycleToAbout", sender: self)
    }
    
    func showDisclaimerAlert() {
        let dateFormat = "yyyyMMdd"
        let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = dateFormat
            formatter.locale = Locale(identifier: "en_US")
            formatter.timeZone = TimeZone.current
            return formatter
        }()

        let today = dateFormatter.string(from: Date())
        let launchedLast = UserDefaults.standard.string(forKey: "launchedLast")
        
        if launchedLast?.contains(today) == true {
            // Already launched today, no alert needed
            return
        }

        // Create the alert controller
        let alert = UIAlertController(
            title: NSLocalizedString("disclaimer_alert_title", comment: ""),
            message: NSLocalizedString("disclaimer_alert_body", comment: ""),
            preferredStyle: .alert
        )

        // OK action with a placeholder title that will be updated
        okAction = UIAlertAction(
            title: "\(NSLocalizedString("disclaimer_ok", comment: "")) (\(remainingSeconds))",
            style: .default,
            handler: { action in
                UserDefaults.standard.set(today, forKey: "launchedLast")
                self.invalidateTimer()
            }
        )

        // Add the actions to the alert
        if let okAction = okAction {
            alert.addAction(okAction)
        }
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("disclaimer_quit", comment: ""),
            style: .cancel,
            handler: { action in
                self.invalidateTimer()
                exit(0)
            }
        ))

        // Present the alert and start the countdown
        self.present(alert, animated: true) {
            self.startCountdown()
        }
    }
    
    func updateNavigationBar(color: UIColor) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = color
        
        // Apply the appearance to the navigation bar
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }

    func startCountdown() {
        // Schedule the timer to fire every 1 second
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }

            if self.remainingSeconds > 0 {
                self.remainingSeconds -= 1
                // Update the OK button's title with the remaining time
                self.okAction?.setValue("\(NSLocalizedString("disclaimer_ok", comment: "")) (\(self.remainingSeconds))", forKey: "title")
            } else {
                // Dismiss the alert and stop the timer when time is up
                self.dismiss(animated: true) {
                    let dateFormat = "yyyyMMdd"
                    let dateFormatter: DateFormatter = {
                        let formatter = DateFormatter()
                        formatter.dateFormat = dateFormat
                        formatter.locale = Locale(identifier: "en_US")
                        formatter.timeZone = TimeZone.current
                        return formatter
                    }()

                    let today = dateFormatter.string(from: Date())
                    UserDefaults.standard.set(today, forKey: "launchedLast")
                    self.invalidateTimer()
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }

    func invalidateTimer() {
        countdownTimer?.invalidate()
        countdownTimer = nil
    }
}
