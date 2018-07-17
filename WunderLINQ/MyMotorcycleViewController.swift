//
//  MyMotorcycleViewController.swift
//  WunderLINQ
//
//  Created by Keith Conger on 8/13/17.
//  Copyright © 2017 Keith Conger. All rights reserved.
//

import UIKit
import CoreBluetooth

class MyMotorcycleViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    @IBOutlet weak var frontPressureLabel: UILabel!
    @IBOutlet weak var rearPressureLabel: UILabel!
    @IBOutlet weak var engineTempLabel: UILabel!
    @IBOutlet weak var ambientTempLabel: UILabel!
    @IBOutlet weak var gearLabel: UILabel!
    @IBOutlet weak var odometerLabel: UILabel!
    @IBOutlet weak var tripOneLabel: UILabel!
    @IBOutlet weak var tripTwoLabel: UILabel!
    @IBOutlet weak var mainView: UIView!
    
    var backBtn: UIButton!
    var backButton: UIBarButtonItem!
    var disconnectBtn: UIButton!
    var disconnectButton: UIBarButtonItem!
    var faultsBtn: UIButton!
    var faultsButton: UIBarButtonItem!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerSettingsBundle()
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

        let dataBtn = UIButton()
        dataBtn.setImage(UIImage(named: "Chart"), for: .normal)
        dataBtn.addTarget(self, action: #selector(dataButtonTapped), for: .touchUpInside)
        let dataButton = UIBarButtonItem(customView: dataBtn)
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


    }
    
    func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizerDirection.right {
            print("Swipe Right")
            performSegue(withIdentifier: "motorcycleToTasks", sender: [])
        }
        else if gesture.direction == UISwipeGestureRecognizerDirection.left {
            print("Swipe Left")
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
        print("leftScreen called")
        // your code here
        performSegue(withIdentifier: "motorcycleToTasks", sender: [])
    }
    
    @objc func rightScreen() {
        print("rightScreen called")
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
        print("faultsButtonTapped")
        performSegue(withIdentifier: "motorcycleToFaults", sender: [])
    }
    
    func dataButtonTapped() {
        // your code here
        print("dataButtonTapped")
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
                print("*** RESUMING SCAN!")
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

        disconnectBtn.tintColor = UIColor.blue
        
        // TODO Only show when faults are active
        faultsBtn.tintColor = UIColor.red
        faultsButton.isEnabled = true
        
        self.navigationItem.leftBarButtonItems = [backButton, disconnectButton, faultsButton]
        
        // MARK: - TODO:
        var temperatureUnit = "C"
        var distanceUnit = "km"
        var pressureUnit = "psi"
        
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
            // Tire Pressure
            if ((lastMessage[4] != 0xFF) && (lastMessage[5] != 0xFF)){
                var frontPressure:Double = Double(lastMessage[4]) / 50
                var rearPressure:Double = Double(lastMessage[5]) / 50
                motorcycleData.setfrontTirePressure(frontTirePressure: frontPressure)
                motorcycleData.setrearTirePressure(rearTirePressure: rearPressure)
                
                switch UserDefaults.standard.integer(forKey: "pressure_unit_preference"){
                case 0:
                    pressureUnit = "bar"
                case 1:
                    pressureUnit = "kPa"
                    frontPressure = barTokPa(frontPressure)
                    rearPressure = barTokPa(rearPressure)
                case 2:
                    pressureUnit = "kg-f"
                    frontPressure = barTokgf(frontPressure)
                    rearPressure = barTokgf(rearPressure)
                case 3:
                    pressureUnit = "psi"
                    frontPressure = barToPsi(frontPressure)
                    rearPressure = barToPsi(rearPressure)
                default:
                    print("Unknown pressure unit setting")
                }
                frontPressureLabel.text = "\(Int(frontPressure)) \(pressureUnit)"
                rearPressureLabel.text = "\(Int(rearPressure)) \(pressureUnit)"
            }
            
        case 0x06:
            //print("Message ID: 6")
            // Gear
            var gear = "--"
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
                gear = "--"
            }
            motorcycleData.setgear(gear: gear)
            gearLabel.text = gear
            
            // Throttle Position
            let minPosition = 36;
            let maxPosition = 236;
            let throttlePosition = Double(((lastMessage[3] - minPosition) * 100)) / Double((maxPosition - minPosition))
            motorcycleData.setthrottlePosition(throttlePosition: throttlePosition)
            
            // Engine Temperature
            var engineTemp:Double = Double(lastMessage[4]) * 0.75 - 25
            motorcycleData.setengineTemperature(engineTemperature: engineTemp)
            if UserDefaults.standard.integer(forKey: "temperature_unit_preference") == 1 {
                engineTemp = celciusToFahrenheit(engineTemp)
                temperatureUnit = "F"
            }
            engineTempLabel.text = "\(Int(engineTemp)) \(temperatureUnit)"
        case 0x07:
            //Voltage
            let voltage = Double(lastMessage[4]) / 10
            motorcycleData.setvoltage(voltage: voltage)
        case 0x08:
            //print("Message ID: 8")
            // Ambient Temperature
            var ambientTemp:Double = Double(lastMessage[1]) * 0.50 - 40
            motorcycleData.setambientTemperature(ambientTemperature: ambientTemp)
            if UserDefaults.standard.integer(forKey: "temperature_unit_preference") == 1 {
                ambientTemp = celciusToFahrenheit(ambientTemp)
                temperatureUnit = "F"
            }
            ambientTempLabel.text = "\(Int(ambientTemp)) \(temperatureUnit)"

        case 0x0A:
            // Odometer
            var odometer:Double = Double(UInt16(lastMessage[1]) | UInt16(lastMessage[2]) << 8 | UInt16(lastMessage[3]) << 16)
            motorcycleData.setodometer(odometer: odometer)
            if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                odometer = Double(kmToMiles(Double(odometer)))
                distanceUnit = "mi"
            }
            odometerLabel.text = "\(odometer) \(distanceUnit)"
            // Trip Auto
            let tripAuto:Double = Double((UInt32(lastMessage[4]) | UInt32(lastMessage[5]) << 8 | UInt32(lastMessage[6]) << 16) / 10)
            motorcycleData.settripAuto(tripAuto: tripAuto)
        case 0x0C:
            // Trip 1 & Trip 2
            var tripOne:Double = Double((UInt32(lastMessage[1]) | UInt32(lastMessage[2]) << 8 | UInt32(lastMessage[3]) << 16) / 10)
            var tripTwo:Double = Double((UInt32(lastMessage[4]) | UInt32(lastMessage[5]) << 8 | UInt32(lastMessage[6]) << 16) / 10)
            motorcycleData.settripOne(tripOne: tripOne)
            motorcycleData.settripTwo(tripTwo: tripTwo)
            if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                tripOne = Double(kmToMiles(Double(tripOne)))
                tripTwo = Double(kmToMiles(Double(tripTwo)))
                distanceUnit = "mi"
            }
            tripOneLabel.text = "\(tripOne) \(distanceUnit)"
            tripTwoLabel.text = "\(tripTwo) \(distanceUnit)"
        case 0xFF:
            // WunderLINQ errors
            print("Error Recieved")
        default:
            _ = 0
            //print("Unknown Message ID")
        }
    }
    
    func displayMessage(_ data:Data) {
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
        if UIApplication.shared.applicationState == .active {
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
            message = NSLocalizedString("Bluetooth on this device is currently powered off.", comment: "")
        case .unsupported:
            message = NSLocalizedString("This device does not support Bluetooth Low Energy.", comment: "")
        case .unauthorized:
            message = NSLocalizedString("This app is not authorized to use Bluetooth Low Energy.", comment: "")
        case .resetting:
            message = NSLocalizedString("The BLE Manager is resetting; a state update is pending.", comment: "")
        case .unknown:
            message = NSLocalizedString("The state of the BLE Manager is unknown.", comment: "")
        case .poweredOn:
            showAlert = false
            message = NSLocalizedString("Bluetooth LE is turned on and ready for communication.", comment: "")
            print(message)
            
            resumeScan()
        }
        
        if showAlert {
            // Display Alert
            let alertController = UIAlertController(title: NSLocalizedString("Central Manager State", comment: ""), message: message, preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil)
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
        print("**** SUCCESSFULLY CONNECTED TO WunderLINQ!!!")
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
        print("**** CONNECTION TO WunderLINQ FAILED!!!")
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
        print("**** DISCONNECTED FROM WunderLINQ!!!")
        disconnectButton.tintColor = UIColor.red
        if error != nil {
            print("****** DISCONNECTION DETAILS: \(error!.localizedDescription)")
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
            print("ERROR DISCOVERING SERVICES: \(error?.localizedDescription)")
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
            print("ERROR DISCOVERING CHARACTERISTICS: \(error?.localizedDescription)")
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
            print("ERROR ON UPDATING VALUE FOR CHARACTERISTIC: \(characteristic) - \(error?.localizedDescription)")
            return
        }
        
        // extract the data from the characteristic's value property and display the value based on the characteristic type
        if let dataBytes = characteristic.value {
            if characteristic.uuid == CBUUID(string: Device.MessageCharacteristicUUID) {
                displayMessage(dataBytes)
            }
        }
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
