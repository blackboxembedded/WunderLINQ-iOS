//
//  LocationService.swift
//  WunderLINQ
//
//  Created by Keith Conger on 7/11/18.
//  Copyright © 2018 Black Box Embedded, LLC. All rights reserved.
//

import Foundation
import CoreLocation
import CoreMotion
import SQLite3

protocol LocationServiceDelegate {
    func tracingLocation(_ currentLocation: CLLocation)
    func tracingLocationDidFailWithError(_ error: NSError)
}

class LocationService: NSObject, CLLocationManagerDelegate {
    static let sharedInstance: LocationService = {
        let instance = LocationService()
        return instance
    }()
    
    var locationManager: CLLocationManager?
    var currentLocation: CLLocation?
    var delegate: LocationServiceDelegate?
    var running = false
    
    var fileName = ""
    var type = ""
    
    var db: OpaquePointer?
    var waypoints = [Waypoint]()
    
    let motorcycleData = MotorcycleData.shared
    
    let motionManager = CMMotionManager()
    var referenceAttitude: CMAttitude?
    
    override init() {
        super.init()
        
        self.locationManager = CLLocationManager()
        guard let locationManager = self.locationManager else {
            return
        }
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        }
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.activityType = .automotiveNavigation
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.delegate = self
    }
    
    func startUpdatingLocation(type: String) {
        self.type = type
        
        if type.contains("triplog"){
            fileName = "WunderLINQ-TripLog-" + Date().toString() + ".csv"
            let latitudeHeader = NSLocalizedString("latitude_header", comment: "")
            let longitudeHeader = NSLocalizedString("longitude_header", comment: "")
            let altitudeHeader = NSLocalizedString("altitude_header", comment: "")
            let gpsSpeedHeader = NSLocalizedString("gpsspeed_header", comment: "")
            let gearHeader = NSLocalizedString("gear_header", comment: "")
            let engineTemperatureHeader = NSLocalizedString("enginetemp_header", comment: "")
            let ambientTemperatureHeader = NSLocalizedString("ambienttemp_header", comment: "")
            let frontPressureHeader = NSLocalizedString("frontpressure_header", comment: "")
            let rearPressureHeader = NSLocalizedString("rearpressure_header", comment: "")
            let odometerHeader = NSLocalizedString("odometer_header", comment: "")
            let voltageHeader = NSLocalizedString("voltage_header", comment: "")
            let throttlePositionHeader = NSLocalizedString("throttle_header", comment: "")
            let frontBrakesHeader = NSLocalizedString("frontbrakes_header", comment: "")
            let rearBrakesHeader = NSLocalizedString("rearbrakes_header", comment: "")
            let shiftsHeader = NSLocalizedString("shifts_header", comment: "")
            let vinHeader = NSLocalizedString("vin_header", comment: "")
            let ambientLightHeader = NSLocalizedString("ambientlight_header", comment: "")
            let tripOneHeader = NSLocalizedString("tripone_header", comment: "")
            let tripTwoHeader = NSLocalizedString("triptwo_header", comment: "")
            let tripAutoHeader = NSLocalizedString("tripauto_header", comment: "")
            let speedHeader = NSLocalizedString("speed_header", comment: "")
            let averageSpeedHeader = NSLocalizedString("avgspeed_header", comment: "")
            let currentConsumptionHeader = NSLocalizedString("cconsumption_header", comment: "")
            let fuelEconomyOneHeader = NSLocalizedString("fueleconomyone_header", comment: "")
            let fuelEconomyTwoHeader = NSLocalizedString("fueleconomytwo_header", comment: "")
            let fuelRangeHeader = NSLocalizedString("fuelrange_header", comment: "")
            let leanAngleHeader = NSLocalizedString("leanangle_header", comment: "")
            let gForceHeader = NSLocalizedString("gforce_header", comment: "")
            
            // Update main display
            var temperatureUnit = "C"
            var distanceUnit = "km"
            var altitudeUnit = "m"
            var pressureUnit = "bar"
            var speedUnit = "kmh"
            var consumptionUnit = "L/100"
            
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
                altitudeUnit = "ft"
                speedUnit = "mph"
                consumptionUnit = "mpg"
            }
            
            let header = "\(latitudeHeader),\(longitudeHeader),\(altitudeHeader) (\(altitudeUnit)),\(gpsSpeedHeader) (\(speedUnit)),\(gearHeader),\(engineTemperatureHeader) (\(temperatureUnit)),\(ambientTemperatureHeader) (\(temperatureUnit)),\(frontPressureHeader) (\(pressureUnit)),\(rearPressureHeader) (\(pressureUnit)),\(odometerHeader) (\(distanceUnit)),\(voltageHeader) (V),\(throttlePositionHeader) (%),\(frontBrakesHeader),\(rearBrakesHeader),\(shiftsHeader),\(vinHeader),\(ambientLightHeader),\(tripOneHeader) (\(distanceUnit)),\(tripTwoHeader) (\(distanceUnit)),\(tripAutoHeader) (\(distanceUnit)),\(speedHeader) (\(speedUnit)),\(averageSpeedHeader) (\(speedUnit)),\(currentConsumptionHeader) (\(consumptionUnit)),\(fuelEconomyOneHeader) (\(consumptionUnit)),\(fuelEconomyTwoHeader) (\(consumptionUnit)),\(fuelRangeHeader) (\(distanceUnit)),\(leanAngleHeader),\(gForceHeader)"
            
            Logger.log(fileName: fileName, entry: header, withDate: false)
        }
        
        print("Starting Location Updates")
        running = true
        if motionManager.isDeviceMotionAvailable {
            //do something interesting
            print("Motion Device Available")
        }
        motionManager.startDeviceMotionUpdates()
        referenceAttitude = nil
        self.locationManager?.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        print("Stop Location Updates")
        running = false
        motionManager.stopDeviceMotionUpdates()
        self.locationManager?.stopUpdatingLocation()
    }
    
    func isRunning() -> Bool {
        return running
    }
    
    // CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.last else {
            return
        }
        
        // singleton for get last(current) location
        currentLocation = location
        
        // use for real time update location
        updateLocation(location)
        
        if type.contains("triplog"){
            let latitude:String = "\(currentLocation!.coordinate.latitude)"
            let longitude:String = "\(currentLocation!.coordinate.longitude)"
            
            var altitude:String = "\(currentLocation!.altitude)"
            if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                altitude = "\(mtoFeet(currentLocation!.altitude))"
            }
            var gpsSpeed:String = "0"
            if currentLocation!.speed >= 0{
                gpsSpeed = "\(currentLocation!.speed)"
                let gpsSpeedValue:Double = currentLocation!.speed
                gpsSpeed = "\(gpsSpeedValue)"
                if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                    gpsSpeed = "\(kmToMiles(gpsSpeedValue))"
                }
            }
            var gear: String = ""
            if motorcycleData.gear != nil {
                gear = motorcycleData.gear!
            }
            var engineTemp:String = ""
            if motorcycleData.engineTemperature != nil {
                let engineTempValue:Double = motorcycleData.engineTemperature!
                engineTemp = "\(motorcycleData.engineTemperature!)"
                if UserDefaults.standard.integer(forKey: "temperature_unit_preference") == 1 {
                    engineTemp = "\(celciusToFahrenheit(engineTempValue))"
                }
            }
            var ambientTemp:String = ""
            if motorcycleData.ambientTemperature != nil {
                let ambientTempValue:Double = motorcycleData.ambientTemperature!
                ambientTemp = "\(motorcycleData.ambientTemperature!)"
                if UserDefaults.standard.integer(forKey: "temperature_unit_preference") == 1 {
                    ambientTemp = "\(celciusToFahrenheit(ambientTempValue))"
                }
            }
            var frontTirePressure:String = ""
            if motorcycleData.frontTirePressure != nil {
                let frontPressureValue:Double = motorcycleData.frontTirePressure!
                switch UserDefaults.standard.integer(forKey: "pressure_unit_preference"){
                case 1:
                    frontTirePressure = "\(barTokPa(frontPressureValue))"
                case 2:
                    frontTirePressure = "\(barTokgf(frontPressureValue))"
                case 3:
                    frontTirePressure = "\(barToPsi(frontPressureValue))"
                default:
                    frontTirePressure = "\(frontPressureValue)"
                }
            }
            var rearTirePressure:String = ""
            if motorcycleData.rearTirePressure != nil {
                let rearPressureValue:Double = motorcycleData.rearTirePressure!
                switch UserDefaults.standard.integer(forKey: "pressure_unit_preference"){
                case 1:
                    rearTirePressure = "\(barTokPa(rearPressureValue))"
                case 2:
                    rearTirePressure = "\(barTokgf(rearPressureValue))"
                case 3:
                    rearTirePressure = "\(barToPsi(rearPressureValue))"
                default:
                    rearTirePressure = "\(rearPressureValue)"
                }
            }
            var odometer:String = ""
            if motorcycleData.odometer != nil {
                let odometerValue:Double = motorcycleData.odometer!
                odometer = "\(odometerValue)"
                if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                    odometer = "\(kmToMiles(odometerValue))"
                }
                
            }
            var voltage:String = ""
            if motorcycleData.voltage != nil {
                voltage = "\(motorcycleData.voltage!)"
            }
            var throttlePosition:String = ""
            if motorcycleData.throttlePosition != nil {
                throttlePosition = "\(motorcycleData.throttlePosition!)"
            }
            var frontBrakes:String = ""
            if motorcycleData.frontBrake != nil {
                frontBrakes = "\(motorcycleData.frontBrake!)"
            }
            var rearBrakes:String = ""
            if motorcycleData.rearBrake != nil {
                rearBrakes = "\(motorcycleData.rearBrake!)"
            }
            var shifts:String = ""
            if motorcycleData.shifts != nil {
                shifts = "\(motorcycleData.shifts!)"
            }
            var vin:String = ""
            if motorcycleData.vin != nil {
                vin = "\(motorcycleData.vin!)"
            }
            var tripOne:String = ""
            if motorcycleData.tripOne != nil {
                let tripOneValue:Double = motorcycleData.tripOne!
                tripOne = "\(tripOneValue)"
                if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                    tripOne = "\(kmToMiles(tripOneValue))"
                }
            }
            var tripTwo:String = ""
            if motorcycleData.tripTwo != nil {
                let tripTwoValue:Double = motorcycleData.tripTwo!
                tripTwo = "\(tripTwoValue)"
                if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                    tripTwo = "\(kmToMiles(tripTwoValue))"
                }
            }
            var tripAuto:String = ""
            if motorcycleData.tripAuto != nil {
                let tripAutoValue:Double = motorcycleData.tripAuto!
                tripAuto = "\(tripAutoValue)"
                if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                    tripAuto = "\(kmToMiles(tripAutoValue))"
                }
            }
            var ambientLight:String = ""
            if motorcycleData.ambientLight != nil {
                ambientLight = "\(motorcycleData.ambientLight!)"
            }
            var speed:String = ""
            if motorcycleData.speed != nil {
                let speedValue:Double = motorcycleData.speed!
                speed = "\(speedValue)"
                if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                    speed = "\(kmToMiles(speedValue))"
                }
            }
            var avgSpeed:String = ""
            if motorcycleData.averageSpeed != nil {
                let avgSpeedValue:Double = motorcycleData.averageSpeed!
                avgSpeed = "\(avgSpeedValue)"
                if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                    avgSpeed = "\(kmToMiles(avgSpeedValue))"
                }
            }
            var currentConsumption:String = ""
            if motorcycleData.currentConsumption != nil {
                let currentConsumptionValue:Double = motorcycleData.currentConsumption!
                currentConsumption = "\(currentConsumptionValue)"
                if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                    currentConsumption = "\(l100ToMpg(currentConsumptionValue))"
                }
            }
            var fuelEconomyOne:String = ""
            if motorcycleData.fuelEconomyOne != nil {
                let fuelEconomyOneValue:Double = motorcycleData.fuelEconomyOne!
                fuelEconomyOne = "\(fuelEconomyOneValue)"
                if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                    fuelEconomyOne = "\(l100ToMpg(fuelEconomyOneValue))"
                }
            }
            var fuelEconomyTwo:String = ""
            if motorcycleData.fuelEconomyTwo != nil {
                fuelEconomyTwo = "\(motorcycleData.fuelEconomyTwo!)"
                let fuelEconomyTwoValue:Double = motorcycleData.fuelEconomyTwo!
                fuelEconomyTwo = "\(fuelEconomyTwoValue)"
                if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                    fuelEconomyTwo = "\(l100ToMpg(fuelEconomyTwoValue))"
                }
            }
            var fuelRange:String = ""
            if motorcycleData.fuelRange != nil {
                let fuelRangeValue:Double = motorcycleData.fuelRange!
                fuelRange = "\(fuelRangeValue)"
                if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                    fuelRange = "\(kmToMiles(fuelRangeValue))"
                }
            }
            let data = motionManager.deviceMotion
            var leanAngle:String = ""
            var gForce:String = ""
            if (data != nil){
                let attitude = data!.attitude
                if (referenceAttitude != nil){
                    attitude.multiply(byInverseOf: referenceAttitude!)
                } else {
                    referenceAttitude = attitude
                }
                leanAngle = "\(degrees(radians: attitude.pitch).rounded(toPlaces: 1))"
                gForce = "\(data!.gravity.x + data!.gravity.y + data!.gravity.z)"
            }

            let entry = "\(latitude),\(longitude),\(altitude),\(gpsSpeed),\(gear),\(engineTemp),\(ambientTemp),\(frontTirePressure),\(rearTirePressure),\(odometer),\(voltage),\(throttlePosition),\(frontBrakes),\(rearBrakes),\(shifts),\(vin),\(ambientLight),\(tripOne),\(tripTwo),\(tripAuto),\(speed),\(avgSpeed),\(currentConsumption),\(fuelEconomyOne),\(fuelEconomyTwo),\(fuelRange),\(leanAngle),\(gForce)"
            Logger.log(fileName: fileName, entry: entry, withDate: true)
        } else {
            print("waypoint saved")
            saveWaypoint()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        // do on error
        updateLocationDidFailWithError(error as NSError)
    }
    
    // Private function
    fileprivate func updateLocation(_ currentLocation: CLLocation){
        
        guard let delegate = self.delegate else {
            return
        }
        
        delegate.tracingLocation(currentLocation)
    }
    
    fileprivate func updateLocationDidFailWithError(_ error: NSError) {
        
        guard let delegate = self.delegate else {
            return
        }
        
        delegate.tracingLocationDidFailWithError(error)
    }
    
    func saveWaypoint(){
        // Waypoint stuff below
        let currentLocation = self.currentLocation
        
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
        if sqlite3_bind_double(stmt, 2, (currentLocation?.coordinate.latitude)!) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        if sqlite3_bind_double(stmt, 3, (currentLocation?.coordinate.longitude)!) != SQLITE_OK{
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
        if self.type.contains("waypoint"){
            stopUpdatingLocation()
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
        let miles = kilometers * 0.62137
        return miles
    }
    // Celsius to Fahrenheit
    func celciusToFahrenheit(_ celcius:Double) -> Double {
        let fahrenheit = (celcius * 1.8) + Double(32)
        return fahrenheit
    }
    // L/100 to mpg
    func l100ToMpg(_ l100:Double) -> Double {
        let mpg = 235.215 / l100
        return mpg
    }
    // meters to feet
    func mtoFeet(_ meters:Double) -> Double {
        let meters = meters / 0.3048
        return meters
    }
    //radians to degrees
    func degrees(radians:Double) -> Double {
        return 180 / Double.pi * radians
    }
}
