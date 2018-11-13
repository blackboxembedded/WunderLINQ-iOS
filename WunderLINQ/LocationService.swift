//
//  LocationService.swift
//  WunderLINQ
//
//  Created by Keith Conger on 7/11/18.
//  Copyright © 2018 Black Box Embedded, LLC. All rights reserved.
//

import Foundation
import CoreLocation
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
            
            let header = "\(latitudeHeader),\(longitudeHeader),\(altitudeHeader),\(gpsSpeedHeader),\(gearHeader),\(engineTemperatureHeader),\(ambientTemperatureHeader),\(frontPressureHeader),\(rearPressureHeader),\(odometerHeader),\(voltageHeader),\(throttlePositionHeader),\(frontBrakesHeader),\(rearBrakesHeader),\(shiftsHeader),\(vinHeader),\(ambientLightHeader),\(tripOneHeader),\(tripTwoHeader),\(tripAutoHeader),\(speedHeader),\(averageSpeedHeader),\(currentConsumptionHeader),\(fuelEconomyOneHeader),\(fuelEconomyTwoHeader),\(fuelRangeHeader)"
            
            Logger.log(fileName: fileName, entry: header, withDate: false)
        }
        
        print("Starting Location Updates")
        running = true
        self.locationManager?.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        print("Stop Location Updates")
        running = false
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
            let altitude:String = "\(currentLocation!.altitude)"
            var gpsSpeed:String = "0"
            if currentLocation!.speed >= 0{
                gpsSpeed = "\(currentLocation!.speed)"
            }
            var gear: String = ""
            if motorcycleData.gear != nil {
                gear = motorcycleData.gear!
            }
            var engineTemp:String = ""
            if motorcycleData.engineTemperature != nil {
                engineTemp = "\(motorcycleData.engineTemperature!)"
            }
            var ambientTemp:String = ""
            if motorcycleData.ambientTemperature != nil {
                ambientTemp = "\(motorcycleData.ambientTemperature!)"
            }
            var frontTirePressure:String = ""
            if motorcycleData.frontTirePressure != nil {
                frontTirePressure = "\(motorcycleData.frontTirePressure!)"
            }
            var rearTirePressure:String = ""
            if motorcycleData.rearTirePressure != nil {
                rearTirePressure = "\(motorcycleData.rearTirePressure!)"
            }
            var odometer:String = ""
            if motorcycleData.odometer != nil {
                odometer = "\(motorcycleData.odometer!)"
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
                tripOne = "\(motorcycleData.tripOne!)"
            }
            var tripTwo:String = ""
            if motorcycleData.tripTwo != nil {
                tripTwo = "\(motorcycleData.tripTwo!)"
            }
            var tripAuto:String = ""
            if motorcycleData.tripAuto != nil {
                tripAuto = "\(motorcycleData.tripAuto!)"
            }
            var ambientLight:String = ""
            if motorcycleData.ambientLight != nil {
                ambientLight = "\(motorcycleData.ambientLight!)"
            }
            var speed:String = ""
            if motorcycleData.speed != nil {
                speed = "\(motorcycleData.speed!)"
            }
            var avgSpeed:String = ""
            if motorcycleData.averageSpeed != nil {
                avgSpeed = "\(motorcycleData.averageSpeed!)"
            }
            var currentConsumption:String = ""
            if motorcycleData.currentConsumption != nil {
                currentConsumption = "\(motorcycleData.currentConsumption!)"
            }
            var fuelEconomyOne:String = ""
            if motorcycleData.fuelEconomyOne != nil {
                fuelEconomyOne = "\(motorcycleData.fuelEconomyOne!)"
            }
            var fuelEconomyTwo:String = ""
            if motorcycleData.fuelEconomyTwo != nil {
                fuelEconomyTwo = "\(motorcycleData.fuelEconomyTwo!)"
            }
            var fuelRange:String = ""
            if motorcycleData.fuelRange != nil {
                fuelRange = "\(motorcycleData.fuelRange!)"
            }

            let entry = "\(latitude),\(longitude),\(altitude),\(gpsSpeed),\(gear),\(engineTemp),\(ambientTemp),\(frontTirePressure),\(rearTirePressure),\(odometer),\(voltage),\(throttlePosition),\(frontBrakes),\(rearBrakes),\(shifts),\(vin),\(ambientLight),\(tripOne),\(tripTwo),\(tripAuto),\(speed),\(avgSpeed),\(currentConsumption),\(fuelEconomyOne),\(fuelEconomyTwo),\(fuelRange)"
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
}
