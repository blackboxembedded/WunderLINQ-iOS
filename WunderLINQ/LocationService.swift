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
        //locationManager.distanceFilter = 200 // The minimum distance (measured in meters) a device must move horizontally before an update event is generated.
        locationManager.delegate = self
    }
    
    func startUpdatingLocation(type: String) {
        self.type = type
        
        if type.contains("triplog"){
            fileName = "WunderLINQ-TripLog-" + Date().toString() + ".csv"
            let header = "Time,Latitude,Longitude,Altitude (m),Speed (kmh),Gear,Engine Temperature (C)," +
                "Ambient Temperature (C),Front Tire Pressure (bar),Rear Tire Pressure (bar),Odometer (km),Voltage (V)," +
            "Throttle Position (%),Front Brakes,Rear Brakes,Shifts,VIN,Ambient Light,Trip1 (km),Trip2 (km),Trip Auto (km)"
            Logger.log(fileName: fileName, entry: header)
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
        
        // TODO check for nil values like updateDisplay
        if type.contains("triplog"){
            let latitude:String = "\(currentLocation!.coordinate.latitude)"
            let longitude:String = "\(currentLocation!.coordinate.longitude)"
            let altitude:String = "\(currentLocation!.altitude)"
            let speed:String = "\(currentLocation!.speed)"
            
            let gear = motorcycleData.getgear()
            let engineTemp = motorcycleData.getengineTemperature()
            let ambientTemp = motorcycleData.getambientLight()
            let frontTirePressure = motorcycleData.getfrontTirePressure()
            let rearTirePressure = motorcycleData.getrearTirePressure()
            let odometer = motorcycleData.getodometer()
            let voltage = motorcycleData.getvoltage()
            let throttlePosition = motorcycleData.getthrottlePosition()
            let frontBrakes = motorcycleData.getfrontBrake()
            let rearBrakes = motorcycleData.getrearBrake()
            let shifts = motorcycleData.getshifts()
            let vin = motorcycleData.getVIN()
            let tripOne = motorcycleData.gettripOne()
            let tripTwo = motorcycleData.gettripTwo()
            let tripAuto = motorcycleData.gettripAuto()
            let ambientLight = motorcycleData.getambientLight()
            
            let entry = "\(latitude),\(longitude),\(altitude),\(speed),\(gear),\(engineTemp),\(ambientTemp),\(frontTirePressure),\(rearTirePressure),\(odometer),\(voltage),\(throttlePosition),\(frontBrakes),\(rearBrakes),\(shifts),\(vin),\(tripOne),\(tripTwo),\(tripAuto),\(ambientLight)"
            print(entry)
            Logger.log(fileName: fileName, entry: entry)
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
        var latitude : String
        latitude = "\(currentLocation?.coordinate.latitude ?? 0)"
        var longitude : String
        longitude = "\(currentLocation?.coordinate.longitude ?? 0)"
        let label : String = ""
        print("Before Database Lat: \(latitude)")
        print("Before Database Long: \(longitude)")
        
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
