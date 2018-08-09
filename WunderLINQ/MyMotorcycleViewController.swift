//
//  MyMotorcycleViewController.swift
//  WunderLINQ
//
//  Created by Keith Conger on 8/13/17.
//  Copyright © 2017 Black Box Embedded, LLC. All rights reserved.
//

import UIKit
import CoreBluetooth
import UserNotifications

class MyMotorcycleViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate, UNUserNotificationCenterDelegate {
    @IBOutlet weak var frontPressureLabel: UILabel!
    @IBOutlet weak var rearPressureLabel: UILabel!
    @IBOutlet weak var engineTempLabel: UILabel!
    @IBOutlet weak var ambientTempLabel: UILabel!
    @IBOutlet weak var gearLabel: UILabel!
    @IBOutlet weak var odometerLabel: UILabel!
    @IBOutlet weak var tripOneLabel: UILabel!
    @IBOutlet weak var tripTwoLabel: UILabel!
    @IBOutlet weak var mainUIView: UIView!
    @IBOutlet weak var frontTireStackView: UIStackView!
    @IBOutlet weak var rearTireStackView: UIStackView!
    @IBOutlet weak var engineTempStackView: UIStackView!
    @IBOutlet weak var ambientTempStackView: UIStackView!
    @IBOutlet weak var gearStackView: UIStackView!
    @IBOutlet weak var odometerStackView: UIStackView!
    @IBOutlet weak var tripOneStackView: UIStackView!
    @IBOutlet weak var tripTwoStackView: UIStackView!
    
    var backBtn: UIButton!
    var backButton: UIBarButtonItem!
    var disconnectBtn: UIButton!
    var disconnectButton: UIBarButtonItem!
    var faultsBtn: UIButton!
    var faultsButton: UIBarButtonItem!
    var dataBtn: UIButton!
    var dataButton: UIBarButtonItem!
    
    var centralManager:CBCentralManager!
    var wunderLINQ:CBPeripheral?
    var messageCharacteristic:CBCharacteristic?
    
    let deviceName = "WunderLINQ"
    
    // define our scanning interval times
    let timerPauseInterval:TimeInterval = 5
    let timerScanInterval:TimeInterval = 2
    
    var keepScanning = false
    
    var lastMessage = [UInt8]()
    
    let motorcycleData = MotorcycleData.shared
    let faults = Faults.shared
    var prevBrakeValue = 0
    
    fileprivate var popoverList = [NSLocalizedString("trip_logs_label", comment: ""), NSLocalizedString("waypoints_label", comment: "")]
    
    fileprivate var popover: Popover!
    fileprivate var popoverOptions: [PopoverOption] = [
        .type(.auto),
        .blackOverlayColor(UIColor(white: 0.0, alpha: 0.6))
    ]

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UserDefaults.standard.integer(forKey: "motorcycle_type_preference") != 4 {
            self.view.setNeedsLayout()
        } else {
            self.viewDidLoad()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerSettingsBundle()
        NotificationCenter.default.addObserver(self, selector: #selector(self.defaultsChanged), name: UserDefaults.didChangeNotification, object: nil)
        
        // Add Borders
        if frontTireStackView != nil {
        pinBackground(createView(UIColor.black), to: frontTireStackView)
        pinBackground(createView(UIColor.black), to: rearTireStackView)
        pinBackground(createView(UIColor.black), to: engineTempStackView)
        pinBackground(createView(UIColor.black), to: ambientTempStackView)
        pinBackground(createView(UIColor.black), to: gearStackView)
        pinBackground(createView(UIColor.black), to: odometerStackView)
        pinBackground(createView(UIColor.black), to: tripOneStackView)
        pinBackground(createView(UIColor.black), to: tripTwoStackView)
        }

        if UserDefaults.standard.integer(forKey: "motorcycle_type_preference") == 4 {
            for mainUIView in self.mainUIView.subviews {
                mainUIView.removeFromSuperview()
            }
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.mainUIView.bounds.width, height: 75))
            label.center = self.view.center
            label.textAlignment = .center
            label.textColor = .black
            label.font = UIFont.boldSystemFont(ofSize: 40)
            label.text = NSLocalizedString("product", comment: "")
            mainUIView.addSubview(label)
        }
        
        centralManager = CBCentralManager(delegate: self,
                                          queue: nil)
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)

        // Setup Buttons
        backBtn = UIButton()
        backBtn.setImage(UIImage(named: "Left"), for: .normal)
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
        faultsBtn.addTarget(self, action: #selector(self.faultsButtonTapped), for: .touchUpInside)
        faultsButton = UIBarButtonItem(customView: faultsBtn)
        let faultsButtonWidth = faultsButton.customView?.widthAnchor.constraint(equalToConstant: 30)
        faultsButtonWidth?.isActive = true
        let faultsButtonHeight = faultsButton.customView?.heightAnchor.constraint(equalToConstant: 30)
        faultsButtonHeight?.isActive = true
        faultsButton.isEnabled = false

        dataBtn = UIButton()
        dataBtn.setImage(UIImage(named: "Chart"), for: .normal)
        dataBtn.addTarget(self, action: #selector(dataButtonTapped), for: .touchUpInside)
        dataButton = UIBarButtonItem(customView: dataBtn)
        let dataButtonWidth = dataButton.customView?.widthAnchor.constraint(equalToConstant: 30)
        dataButtonWidth?.isActive = true
        let dataButtonHeight = dataButton.customView?.heightAnchor.constraint(equalToConstant: 30)
        dataButtonHeight?.isActive = true

        let settingsBtn = UIButton()
        settingsBtn.setImage(UIImage(named: "Cog"), for: .normal)
        settingsBtn.addTarget(self, action: #selector(settingsButtonTapped), for: .touchUpInside)
        let settingsButton = UIBarButtonItem(customView: settingsBtn)
        let settingsButtonWidth = settingsButton.customView?.widthAnchor.constraint(equalToConstant: 30)
        settingsButtonWidth?.isActive = true
        let settingsButtonHeight = settingsButton.customView?.heightAnchor.constraint(equalToConstant: 30)
        settingsButtonHeight?.isActive = true

        let forwardBtn = UIButton()
        forwardBtn.setImage(UIImage(named: "Right"), for: .normal)
        forwardBtn.addTarget(self, action: #selector(rightScreen), for: .touchUpInside)
        let forwardButton = UIBarButtonItem(customView: forwardBtn)
        let forwardButtonWidth = forwardButton.customView?.widthAnchor.constraint(equalToConstant: 30)
        forwardButtonWidth?.isActive = true
        let forwardButtonHeight = forwardButton.customView?.heightAnchor.constraint(equalToConstant: 30)
        forwardButtonHeight?.isActive = true
        
        self.navigationItem.leftBarButtonItems = [backButton, disconnectButton, faultsButton]
        self.navigationItem.rightBarButtonItems = [forwardButton, settingsButton, dataButton]
        
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
                let alert = UIAlertController(title: NSLocalizedString("disclaimer_alert_title", comment: ""), message: NSLocalizedString("disclaimer_alert_body", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("disclaimer_ok", comment: ""), style: UIAlertActionStyle.default, handler: { action in
                    UserDefaults.standard.set(today, forKey: "launchedLast")
                }))
                alert.addAction(UIAlertAction(title: NSLocalizedString("disclaimer_quit", comment: ""), style: UIAlertActionStyle.cancel, handler: { action in
                    // quit app
                    exit(0)
                }))
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            let alert = UIAlertController(title: NSLocalizedString("disclaimer_alert_title", comment: ""), message: NSLocalizedString("disclaimer_alert_body", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("disclaimer_ok", comment: ""), style: UIAlertActionStyle.default, handler: { action in
                UserDefaults.standard.set(today, forKey: "launchedLast")
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("disclaimer_quit", comment: ""), style: UIAlertActionStyle.cancel, handler: { action in
                // quit app
                exit(0)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func defaultsChanged(notification:NSNotification){
        if let defaults = notification.object as? UserDefaults {
            //get the value for key here
            print("Type: \(defaults.value(forKey: "motorcycle_type_preference") ?? "Unknown")")
            if UserDefaults.standard.integer(forKey: "motorcycle_type_preference") != 4 {
                self.view.setNeedsLayout()
            } else {
                self.viewDidLoad()
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        //displaying the ios local notification when app is in foreground
        completionHandler([.alert, .badge, .sound])
    }

    func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizerDirection.right {
            performSegue(withIdentifier: "motorcycleToTasks", sender: [])
        }
        else if gesture.direction == UISwipeGestureRecognizerDirection.left {
            performSegue(withIdentifier: "motorcycleToCompass", sender: [])
        }
    }
    
    override var keyCommands: [UIKeyCommand]? {
        
        let commands = [
            UIKeyCommand(input: UIKeyInputLeftArrow, modifierFlags:[], action: #selector(leftScreen), discoverabilityTitle: "Go left"),
            UIKeyCommand(input: UIKeyInputRightArrow, modifierFlags:[], action: #selector(rightScreen), discoverabilityTitle: "Go right")
        ]
        return commands
    }
    
    @objc func leftScreen() {
        // your code here
        performSegue(withIdentifier: "motorcycleToTasks", sender: [])
    }
    
    @objc func rightScreen() {
        // your code here
        performSegue(withIdentifier: "motorcycleToCompass", sender: [])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToContainerVC(segue: UIStoryboardSegue) {
        
    }
    
    func registerSettingsBundle(){
        let appDefaults = [String:AnyObject]()
        UserDefaults.standard.register(defaults: appDefaults)
    }
    
    // MARK: - Handling User Interaction
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        
    }
    
    func faultsButtonTapped() {
        // your code here
        performSegue(withIdentifier: "motorcycleToFaults", sender: [])
    }
    
    func dataButtonTapped() {
        // your code here
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width / 2, height: 90))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        self.popover = Popover(options: self.popoverOptions)
        self.popover.willShowHandler = {
            print("willShowHandler")
        }
        self.popover.didShowHandler = {
            print("didDismissHandler")
        }
        self.popover.willDismissHandler = {
            print("willDismissHandler")
        }
        self.popover.didDismissHandler = {
            print("didDismissHandler")
        }
        self.popover.show(tableView, fromView: self.dataBtn)
    }
    
    @IBAction func settingsButtonTapped(_ sender: UIBarButtonItem) {
        if let appSettings = URL(string: UIApplicationOpenSettingsURLString + Bundle.main.bundleIdentifier!) {
            if UIApplication.shared.canOpenURL(appSettings) {
                UIApplication.shared.open(appSettings)
            }
        }
    }
    
    @IBAction func btButtonTapped(_ sender: UIBarButtonItem) {
        // if we don't have a WunderLINQ, start scanning for one...
        if wunderLINQ == nil {
            keepScanning = true
            resumeScan()
            return
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
    }
    
    
    // MARK: - Bluetooth scanning
    
    func pauseScan() {
        // Scanning uses up battery on phone, so pause the scan process for the designated interval.
        print("*** PAUSING SCAN...")
        disconnectButton.isEnabled = true
        self.centralManager?.stopScan()
        Timer.scheduledTimer(timeInterval: timerPauseInterval, target: self, selector: #selector(self.resumeScan), userInfo: nil, repeats: false)
        
    }
    
    func resumeScan() {
        let lastPeripherals = centralManager.retrieveConnectedPeripherals(withServices: [CBUUID(string: Device.WunderLINQServiceUUID)])
        
        if lastPeripherals.count > 0{
            print("FOUND WunderLINQ")
            let device = lastPeripherals.last!;
            wunderLINQ = device;
            centralManager?.connect(wunderLINQ!, options: nil)
        } else {
            if keepScanning {
                // Start scanning again...
                print("RESUMING SCAN!")
                disconnectButton.isEnabled = false
                centralManager.scanForPeripherals(withServices: [CBUUID(string: Device.WunderLINQAdvertisingUUID)], options: nil)
                Timer.scheduledTimer(timeInterval: timerScanInterval, target: self, selector: #selector(self.pauseScan), userInfo: nil, repeats: false)
            } else {
                disconnectButton.isEnabled = true
            }
        }
    }
    
    // MARK: - Updating UI
    func updateMessageDisplay() {
        // Update Buttons
        disconnectBtn.tintColor = UIColor.blue
        if (faults.getallActiveDesc().isEmpty){
            faultsBtn.tintColor = UIColor.clear
            faultsButton.isEnabled = false
        } else {
            faultsBtn.tintColor = UIColor.red
            faultsButton.isEnabled = true
        }
        self.navigationItem.leftBarButtonItems = [backButton, disconnectButton, faultsButton]
        
        if UserDefaults.standard.integer(forKey: "motorcycle_type_preference") != 4 && frontPressureLabel != nil {
            // Update main display
            var temperatureUnit = "C"
            var distanceUnit = "km"
            var pressureUnit = "psi"
            
            // Tire Pressure
            if motorcycleData.frontTirePressure != nil {
                var frontPressure:Double = motorcycleData.frontTirePressure!
                switch UserDefaults.standard.integer(forKey: "pressure_unit_preference"){
                case 0:
                    pressureUnit = "bar"
                case 1:
                    pressureUnit = "kPa"
                    frontPressure = barTokPa(frontPressure)
                case 2:
                    pressureUnit = "kg-f"
                    frontPressure = barTokgf(frontPressure)
                case 3:
                    pressureUnit = "psi"
                    frontPressure = barToPsi(frontPressure)
                default:
                    print("Unknown pressure unit setting")
                }
                frontPressureLabel.text = "\(Int(frontPressure)) \(pressureUnit)"
            }
            
            if motorcycleData.rearTirePressure != nil {
                var rearPressure:Double = motorcycleData.rearTirePressure!
                switch UserDefaults.standard.integer(forKey: "pressure_unit_preference"){
                case 0:
                    pressureUnit = "bar"
                case 1:
                    pressureUnit = "kPa"
                    rearPressure = barTokPa(rearPressure)
                case 2:
                    pressureUnit = "kg-f"
                    rearPressure = barTokgf(rearPressure)
                case 3:
                    pressureUnit = "psi"
                    rearPressure = barToPsi(rearPressure)
                default:
                    print("Unknown pressure unit setting")
                }
                rearPressureLabel.text = "\(Int(rearPressure)) \(pressureUnit)"
            }
            
            // Gear
            if motorcycleData.gear != "" {
                gearLabel.text = motorcycleData.getgear()
            }
            
            // Engine Temperature
            if motorcycleData.engineTemperature != nil {
                var engineTemp:Double = motorcycleData.engineTemperature!
                if UserDefaults.standard.integer(forKey: "temperature_unit_preference") == 1 {
                    engineTemp = celciusToFahrenheit(engineTemp)
                    temperatureUnit = "F"
                }
                engineTempLabel.text = "\(Int(engineTemp)) \(temperatureUnit)"
            }
            
            // Ambient Temperature
            if motorcycleData.ambientTemperature != nil {
                var ambientTemp:Double = motorcycleData.ambientTemperature!
                if UserDefaults.standard.integer(forKey: "temperature_unit_preference") == 1 {
                    ambientTemp = celciusToFahrenheit(ambientTemp)
                    temperatureUnit = "F"
                }
                ambientTempLabel.text = "\(Int(ambientTemp)) \(temperatureUnit)"
            }
            
            // Odometer
            if motorcycleData.odometer != nil {
                var odometer:Double = motorcycleData.odometer!
                if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                    odometer = Double(kmToMiles(Double(odometer)))
                    distanceUnit = "mi"
                }
                odometerLabel.text = "\(odometer) \(distanceUnit)"
            }
            
            // Trip 1
            if motorcycleData.tripOne != nil {
                var tripOne:Double = motorcycleData.tripOne!
                if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                    tripOne = Double(kmToMiles(Double(tripOne)))
                    distanceUnit = "mi"
                }
                tripOneLabel.text = "\(tripOne) \(distanceUnit)"
            }
            
            // Trip 2
            if motorcycleData.tripOne != nil {
                var tripTwo:Double = motorcycleData.gettripTwo()
                if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                    tripTwo = Double(kmToMiles(Double(tripTwo)))
                    distanceUnit = "mi"
                }
                tripTwoLabel.text = "\(tripTwo) \(distanceUnit)"
            }
        }
    }
    
    func parseMessage(_ data:Data) {
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
        
        //print(messageHexString)
        
        // Log raw messages
        if UserDefaults.standard.bool(forKey: "raw_logging_preference") {
            Logger.log(fileName: "WunderLINQ-raw.csv", entry: messageHexString)
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
                let frontPressure:Double = Double(lastMessage[4]) / 50
                let rearPressure:Double = Double(lastMessage[5]) / 50
                motorcycleData.setfrontTirePressure(frontTirePressure: frontPressure)
                motorcycleData.setrearTirePressure(rearTirePressure: rearPressure)
            }
            
            // Tire Pressure Faults
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
            
        case 0x06:
            //print("Message ID: 6")
            // Gear
            var gear = "-"
            switch lastMessage[2] {
            case 0x10:
                gear = "1"
            case 0x20:
                gear = "N"
            case 0x40:
                gear = "2"
            case 0x70:
                gear = "3"
            case 0x80:
                gear = "4"
            case 0xB0:
                gear = "5"
            case 0xD0:
                gear = "6"
            case 0xF0:
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
            let minPosition = 36;
            let maxPosition = 236;
            let throttlePosition = Double(((lastMessage[3] - minPosition) * 100)) / Double((maxPosition - minPosition))
            motorcycleData.setthrottlePosition(throttlePosition: throttlePosition)
            
            // Engine Temperature
            let engineTemp:Double = Double(lastMessage[4]) * 0.75 - 25
            motorcycleData.setengineTemperature(engineTemperature: engineTemp)
            
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
            //Voltage
            let voltage = Double(lastMessage[4]) / 10
            motorcycleData.setvoltage(voltage: voltage)
            
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
            let ambientTemp:Double = Double(lastMessage[1]) * 0.50 - 40
            motorcycleData.setambientTemperature(ambientTemperature: ambientTemp)
            
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

                case 0x7:
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
 
                case 0xF:
                    faults.setAddDippedLightActive(active: true)
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
            
        case 0x0A:
            // Odometer
            let odometer:Double = Double(UInt16(lastMessage[1]) | UInt16(lastMessage[2]) << 8 | UInt16(lastMessage[3]) << 16)
            motorcycleData.setodometer(odometer: odometer)

            // Trip Auto
            let tripAuto:Double = Double((UInt32(lastMessage[4]) | UInt32(lastMessage[5]) << 8 | UInt32(lastMessage[6]) << 16) / 10)
            motorcycleData.settripAuto(tripAuto: tripAuto)
            
        case 0x0C:
            // Trip 1 & Trip 2
            let tripOne:Double = Double((UInt32(lastMessage[1]) | UInt32(lastMessage[2]) << 8 | UInt32(lastMessage[3]) << 16) / 10)
            let tripTwo:Double = Double((UInt32(lastMessage[4]) | UInt32(lastMessage[5]) << 8 | UInt32(lastMessage[6]) << 16) / 10)
            motorcycleData.settripOne(tripOne: tripOne)
            motorcycleData.settripTwo(tripTwo: tripTwo)

        case 0xFF:
            // WunderLINQ errors
            print("Error Recieved")
            faults.setUartErrorActive(active: true)
            if (lastMessage[7] == 0xF0){
                faults.setUartCommActive(active: true)
            }
            
        default:
            _ = 0
            //print("Unknown Message ID")
        }

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
            print(message)
            resumeScan()
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
        disconnectButton.tintColor = UIColor.blue
        
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
        disconnectButton.tintColor = UIColor.red
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
        disconnectButton.tintColor = UIColor.red
        if error != nil {
            print("DISCONNECTION DETAILS: \(error!.localizedDescription)")
        }
        wunderLINQ = nil
        
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
            print("ERROR DISCOVERING SERVICES: \(error?.localizedDescription ?? "Unknown Error")")
            return
        }
        
        // Core Bluetooth creates an array of CBService objects —- one for each service that is discovered on the peripheral.
        if let services = peripheral.services {
            for service in services {
                print("DISCOVERED SERVICE: \(service)")
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
            print("ERROR DISCOVERING CHARACTERISTICS: \(error?.localizedDescription ?? "Unknown Error")")
            return
        }
        
        if let characteristics = service.characteristics {
            
            for characteristic in characteristics {
                // Message Data Characteristic
                if characteristic.uuid == CBUUID(string: Device.MessageCharacteristicUUID) {
                    // Enable the message notifications
                    messageCharacteristic = characteristic
                    wunderLINQ?.setNotifyValue(true, for: characteristic)
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
            print("ERROR ON UPDATING VALUE FOR CHARACTERISTIC: \(characteristic) - \(error?.localizedDescription ?? "Unknown Error")")
            return
        }
        
        // extract the data from the characteristic's value property and display the value based on the characteristic type
        if let dataBytes = characteristic.value {
            if characteristic.uuid == CBUUID(string: Device.MessageCharacteristicUUID) {
                parseMessage(dataBytes)
            }
        }
    }
    
    // Add view for border
    private func createView(_ bdrColor: UIColor) -> UIView {
        let backgroundView: UIView = {
            let view = UIView()
            //view.backgroundColor = .purple
            view.layer.cornerRadius = 5.0
            view.layer.borderWidth = 3
            view.layer.borderColor = bdrColor.cgColor
            return view
        }()
        return backgroundView
    }
    private func pinBackground(_ view: UIView, to stackView: UIStackView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        stackView.insertSubview(view, at: 0)
        view.pin(to: stackView)
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
        //content.subtitle = "iOS Development is fun"
        content.body = message
        //content.badge = 1
        content.sound = UNNotificationSound.default()
        
        //getting the notification trigger
        //it will be called after 1 second
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        //getting the notification request
        let request = UNNotificationRequest(identifier: "FaultNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().delegate = self
        
        //adding the notification to notification center
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    // MARK: - Utility Methods
    // Unit Conversion Functions
    // bar to psi
    func barToPsi(_ bar:Double) -> Double {
        let psi = bar * 14.5037738
        return psi
    }
    // bar to kpa
    func barTokPa(_ bar:Double) -> Double {
        let kpa = bar * 100.0
        return kpa
    }
    // bar to kg-f
    func barTokgf(_ bar:Double) -> Double {
        let kgf = bar * 1.0197162129779
        return kgf
    }
    // kilometers to miles
    func kmToMiles(_ kilometers:Double) -> Double {
        let miles = kilometers * 0.6214
        return miles
    }
    // Celsius to Fahrenheit
    func celciusToFahrenheit(_ celcius:Double) -> Double {
        let fahrenheit = (celcius * 1.8) + Double(32)
        return fahrenheit
    }
    
}

extension MyMotorcycleViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch(indexPath.row) {
        case 0:
            performSegue(withIdentifier: "motorcycleToTrips", sender: self)
        case 1:
            performSegue(withIdentifier: "motorcycleToWaypoints", sender: self)
        default:
            print("Unknown option")
        }
        self.popover.dismiss()
    }
}

extension MyMotorcycleViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return popoverList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = self.popoverList[(indexPath as NSIndexPath).row]
        return cell
    }
}

public extension UIView {
    public func pin(to view: UIView) {
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topAnchor.constraint(equalTo: view.topAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
    }
}
