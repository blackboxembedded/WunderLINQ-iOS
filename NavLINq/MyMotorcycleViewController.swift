//
//  MyMotorcycleViewController.swift
//  NavLINq
//
//  Created by Keith Conger on 8/13/17.
//  Copyright © 2017 Keith Conger. All rights reserved.
//

import UIKit
import CoreBluetooth

class MyMotorcycleViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    @IBOutlet weak var disconnectButton: UIBarButtonItem!
    @IBOutlet weak var frontPressureLabel: UILabel!
    @IBOutlet weak var rearPressureLabel: UILabel!
    @IBOutlet weak var engineTempLabel: UILabel!
    @IBOutlet weak var ambientTempLabel: UILabel!
    @IBOutlet weak var gearLabel: UILabel!
    @IBOutlet weak var odometerLabel: UILabel!
    @IBOutlet weak var tripOneLabel: UILabel!
    @IBOutlet weak var tripTwoLabel: UILabel!
    
    var centralManager:CBCentralManager!
    var navLINq:CBPeripheral?
    var messageCharacteristic:CBCharacteristic?
    
    let deviceName = "NavLINq"
    
    // define our scanning interval times
    let timerPauseInterval:TimeInterval = 10.0
    let timerScanInterval:TimeInterval = 2.0
    
    var keepScanning = false
    
    var lastMessage = [UInt8]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerSettingsBundle()
        centralManager = CBCentralManager(delegate: self,
                                          queue: nil)
        print("Searching for NavLINq")
        
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
    
    @IBAction func handleDisconnectButtonTapped(_ sender: AnyObject) {
        // if we don't have a NavLINq, start scanning for one...
        if navLINq == nil {
            keepScanning = true
            resumeScan()
            return
        } else {
            disconnect()
        }
    }
    
    func disconnect() {
        if let navLINq = self.navLINq {
            if let mc = self.messageCharacteristic {
                navLINq.setNotifyValue(false, for: mc)
            }
            
            
            /*
             NOTE: The cancelPeripheralConnection: method is nonblocking, and any CBPeripheral class commands
             that are still pending to the peripheral you’re trying to disconnect may or may not finish executing.
             Because other apps may still have a connection to the peripheral, canceling a local connection
             does not guarantee that the underlying physical link is immediately disconnected.
             
             From your app’s perspective, however, the peripheral is considered disconnected, and the central manager
             object calls the centralManager:didDisconnectPeripheral:error: method of its delegate object.
             */
            centralManager.cancelPeripheralConnection(navLINq)
        }
        messageCharacteristic = nil
    }
    
    
    // MARK: - Bluetooth scanning
    
    func pauseScan() {
        // Scanning uses up battery on phone, so pause the scan process for the designated interval.
        print("*** PAUSING SCAN...")
        _ = Timer(timeInterval: timerPauseInterval, target: self, selector: #selector(resumeScan), userInfo: nil, repeats: false)
        centralManager.stopScan()
        disconnectButton.isEnabled = true
    }
    
    func resumeScan() {
        if keepScanning {
            // Start scanning again...
            print("*** RESUMING SCAN!")
            disconnectButton.isEnabled = false
            //messageLabel.text = "Searching"
            _ = Timer(timeInterval: timerScanInterval, target: self, selector: #selector(pauseScan), userInfo: nil, repeats: false)
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        } else {
            disconnectButton.isEnabled = true
        }
    }
    
    // MARK: - Updating UI
    
    func updateMessageDisplay() {
        
        disconnectButton.tintColor = UIColor.blue
        // MARK: - TODO: parse and display values
        var temperatureUnit = "C"
        var distanceUnit = "km"
        var pressureUnit = "psi"
        
        switch lastMessage[0] {
        case 0x00:
            print("Message ID: 0")
        case 0x01:
            print("Message ID: 1")
        case 0x02:
            print("Message ID: 2")
        case 0x03:
            print("Message ID: 3")
        case 0x04:
            print("Message ID: 4")
        case 0x05:
            print("Message ID: 5")
            // Tire Pressure
            var frontPressure:Double = Double(lastMessage[4]) / 50
            var rearPressure:Double = Double(lastMessage[5]) / 50
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
        case 0x06:
            print("Message ID: 6")
            // Gear
            switch lastMessage[2] {
            case 0x10:
                gearLabel.text = "1"
            case 0x20:
                gearLabel.text = "N"
            case 0x40:
                gearLabel.text = "2"
            case 0x70:
                gearLabel.text = "3"
            case 0x80:
                gearLabel.text = "4"
            case 0xB0:
                gearLabel.text = "5"
            case 0xD0:
                gearLabel.text = "6"
            case 0xF0:
                gearLabel.text = "-"
            default:
                print("Unknown Gear Value")
                gearLabel.text = "-"
            }
            // Engine Temperature
            var engineTemp:Double = Double(lastMessage[4]) * 0.75 - 25
            if UserDefaults.standard.integer(forKey: "temperature_unit_preference") == 1 {
                print("Fahrenheit selected")
                engineTemp = celciusToFahrenheit(engineTemp)
                temperatureUnit = "F"
            }
            engineTempLabel.text = "\(Int(engineTemp)) \(temperatureUnit)"
        case 0x07:
            print("Message ID: 7")
        case 0x08:
            print("Message ID: 8")
            // Ambient Temperature
            var ambientTemp:Double = Double(lastMessage[1]) * 0.50 - 40
            if UserDefaults.standard.integer(forKey: "temperature_unit_preference") == 1 {
                ambientTemp = celciusToFahrenheit(ambientTemp)
                temperatureUnit = "F"
            }
            ambientTempLabel.text = "\(Int(ambientTemp)) \(temperatureUnit)"
        case 0x09:
            print("Message ID: 9")
        case 0x0A:
            print("Message ID: 10")
            // Odometer
            var odometer:Int = Int(lastMessage[3]) + Int(lastMessage[2]) + Int(lastMessage[1])
            if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                odometer = Int(kmToMiles(Double(odometer)))
                distanceUnit = "miles"
            }
            odometerLabel.text = "\(odometer) \(distanceUnit)"
            
        case 0x0B:
            print("Message ID: 11")
        case 0x0C:
            print("Message ID: 12")
            // Trip 1 & Trip 2
            var tripOne:Int = Int(lastMessage[3]) + Int(lastMessage[2]) + Int(lastMessage[1])
            var tripTwo:Int = Int(lastMessage[6]) + Int(lastMessage[5]) + Int(lastMessage[4])
            if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                tripOne = Int(kmToMiles(Double(tripOne)))
                tripTwo = Int(kmToMiles(Double(tripTwo)))
                distanceUnit = "miles"
            }
            tripOneLabel.text = "\(tripOne) \(distanceUnit)"
            tripTwoLabel.text = "\(tripTwo) \(distanceUnit)"
        default:
            print("Message ID: Unknown")
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
        print(messageHexString)
        
        // Log raw messages
        if UserDefaults.standard.bool(forKey: "raw_logging_preference") {
            Logger.log(fileName: "NavLINq-raw.csv", entry: messageHexString)
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
            keepScanning = true
            _ = Timer(timeInterval: timerScanInterval, target: self, selector: #selector(pauseScan), userInfo: nil, repeats: false)
            
            // Initiate Scan for Peripherals
            //Option 1: Scan for all devices
            centralManager.scanForPeripherals(withServices: nil, options: nil)
            
            // Option 2: Scan for devices that have the service you're interested in...
            //let sensorTagAdvertisingUUID = CBUUID(string: Device.SensorTagAdvertisingUUID)
            //print("Scanning for SensorTag adverstising with UUID: \(sensorTagAdvertisingUUID)")
            //centralManager.scanForPeripheralsWithServices([sensorTagAdvertisingUUID], options: nil)
            
        }
        
        if showAlert {
            let alertController = UIAlertController(title: NSLocalizedString("Central Manager State", comment: ""), message: message, preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.cancel, handler: nil)
            alertController.addAction(okAction)
            self.show(alertController, sender: self)
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
        //print("centralManager didDiscoverPeripheral - CBAdvertisementDataLocalNameKey is \"\(CBAdvertisementDataLocalNameKey)\"")
        
        // Retrieve the peripheral name from the advertisement data using the "kCBAdvDataLocalName" key
        if let peripheralName = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            if peripheralName == deviceName {
                print("NavLINq FOUND! ADDING NOW!!!")
                // to save power, stop scanning for other devices
                keepScanning = false
                disconnectButton.isEnabled = true
                
                // save a reference to the sensor tag
                navLINq = peripheral
                navLINq!.delegate = self
                
                // Request a connection to the peripheral
                centralManager.connect(navLINq!, options: nil)
            }
        }
    }
    
    /*
     Invoked when a connection is successfully created with a peripheral.
     
     This method is invoked when a call to connectPeripheral:options: is successful.
     You typically implement this method to set the peripheral’s delegate and to discover its services.
     */
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("**** SUCCESSFULLY CONNECTED TO NavLINq!!!")
        
        //messageLabel.text = "Connected"
        disconnectButton.tintColor = UIColor.blue
        
        // Now that we've successfully connected to the SensorTag, let's discover the services.
        // - NOTE:  we pass nil here to request ALL services be discovered.
        //          If there was a subset of services we were interested in, we could pass the UUIDs here.
        //          Doing so saves battery life and saves time.
        peripheral.discoverServices(nil)
    }
    
    
    /*
     Invoked when the central manager fails to create a connection with a peripheral.
     
     This method is invoked when a connection initiated via the connectPeripheral:options: method fails to complete.
     Because connection attempts do not time out, a failed connection usually indicates a transient issue,
     in which case you may attempt to connect to the peripheral again.
     */
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("**** CONNECTION TO NavLINq FAILED!!!")
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
        print("**** DISCONNECTED FROM NavLINq!!!")
        //messageLabel.text = "Tap to search"
        disconnectButton.tintColor = UIColor.red
        if error != nil {
            print("****** DISCONNECTION DETAILS: \(error!.localizedDescription)")
        }
        navLINq = nil
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
                // If we found either the temperature or the humidity service, discover the characteristics for those services.
                if (service.uuid == CBUUID(string: Device.NavLINqServiceUUID)) {
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
                    navLINq?.setNotifyValue(true, for: characteristic)
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
