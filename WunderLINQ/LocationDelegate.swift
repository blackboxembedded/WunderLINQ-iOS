//
//  LocationDelegate.swift
//  WunderLINQ
//
//  Created by Keith Conger on 8/13/17.
//  Copyright © 2017 Black Box Embedded, LLC. All rights reserved.
//

import Foundation
import CoreLocation

class LocationDelegate: NSObject, CLLocationManagerDelegate {
    var locationCallback: ((CLLocation) -> ())? = nil
    var headingCallback: ((CLHeading) -> ())? = nil
    
    let motorcycleData = MotorcycleData.shared
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else { return }
        motorcycleData.setLocation(location: currentLocation)
        let loggingStatus = UserDefaults.standard.string(forKey: "loggingStatus")
        if loggingStatus != nil {
            //Log
            Logger.log()
        }
        locationCallback?(currentLocation)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        headingCallback?(newHeading)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("⚠️ Error while updating location " + error.localizedDescription)
    }
}
