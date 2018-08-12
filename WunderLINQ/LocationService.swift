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
    
    static var dateFormat = "yyyyMMdd-HH-mm-ss"
    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        return formatter
    }
    
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
            let header = "Latitude,Longitude,Altitude (m),Speed (kmh),Gear,Engine Temperature (C)," +
                "Ambient Temperature (C),Front Tire Pressure (bar),Rear Tire Pressure (bar),Odometer (km),Voltage (V)," +
            "Throttle Position (%),Front Brakes,Rear Brakes,Shifts,VIN,Ambient Light,Trip1 (km),Trip2 (km),Trip Auto (km)"
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
            var speed:String = "0"
            if currentLocation!.speed >= 0{
                speed = "\(currentLocation!.speed)"
            }
            var gear: String = "null"
            if motorcycleData.gear != nil {
                gear = motorcycleData.gear!
            }
            var engineTemp:String = "null"
            if motorcycleData.engineTemperature != nil {
                engineTemp = "\(motorcycleData.engineTemperature!)"
            }
            var ambientTemp:String = "null"
            if motorcycleData.ambientTemperature != nil {
                ambientTemp = "\(motorcycleData.ambientTemperature!)"
            }
            var frontTirePressure:String = "null"
            if motorcycleData.frontTirePressure != nil {
                frontTirePressure = "\(motorcycleData.frontTirePressure!)"
            }
            var rearTirePressure:String = "null"
            if motorcycleData.rearTirePressure != nil {
                rearTirePressure = "\(motorcycleData.rearTirePressure!)"
            }
            var odometer:String = "null"
            if motorcycleData.odometer != nil {
                odometer = "\(motorcycleData.odometer!)"
            }
            var voltage:String = "null"
            if motorcycleData.voltage != nil {
                voltage = "\(motorcycleData.voltage!)"
            }
            var throttlePosition:String = "null"
            if motorcycleData.throttlePosition != nil {
                throttlePosition = "\(motorcycleData.throttlePosition!)"
            }
            var frontBrakes:String = "null"
            if motorcycleData.frontBrake != nil {
                frontBrakes = "\(motorcycleData.frontBrake!)"
            }
            var rearBrakes:String = "null"
            if motorcycleData.rearBrake != nil {
                rearBrakes = "\(motorcycleData.rearBrake!)"
            }
            var shifts:String = "null"
            if motorcycleData.shifts != nil {
                shifts = "\(motorcycleData.shifts!)"
            }
            var vin:String = "null"
            if motorcycleData.vin != nil {
                vin = "\(motorcycleData.vin!)"
            }
            var tripOne:String = "null"
            if motorcycleData.tripOne != nil {
                tripOne = "\(motorcycleData.tripOne!)"
            }
            var tripTwo:String = "null"
            if motorcycleData.tripTwo != nil {
                tripTwo = "\(motorcycleData.tripTwo!)"
            }
            var tripAuto:String = "null"
            if motorcycleData.tripAuto != nil {
                tripAuto = "\(motorcycleData.tripAuto!)"
            }
            var ambientLight:String = "null"
            if motorcycleData.ambientLight != nil {
                ambientLight = "\(motorcycleData.ambientLight!)"
            }

            let entry = "\(latitude),\(longitude),\(altitude),\(speed),\(gear),\(engineTemp),\(ambientTemp),\(frontTirePressure),\(rearTirePressure),\(odometer),\(voltage),\(throttlePosition),\(frontBrakes),\(rearBrakes),\(shifts),\(vin),\(ambientLight),\(tripOne),\(tripTwo),\(tripAuto)"
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
        
        //binding the parameters
        let dateFormat = "yyyy-MM-dd hh:mm"
        var dateFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateFormat = dateFormat
            formatter.locale = Locale.current
            formatter.timeZone = TimeZone.current
            return formatter
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
