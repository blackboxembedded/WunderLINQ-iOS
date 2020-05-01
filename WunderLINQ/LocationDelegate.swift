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

import Foundation
import CoreLocation

class LocationDelegate: NSObject, CLLocationManagerDelegate {
    var locationCallback: ((CLLocation) -> ())? = nil
    var headingCallback: ((CLHeading) -> ())? = nil
    
    let motorcycleData = MotorcycleData.shared
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else { return }
        motorcycleData.setLocation(location: currentLocation)
        if (UserDefaults.standard.bool(forKey: "bearing_override_preference") && currentLocation.course >= 0){
            motorcycleData.setbearing(bearing: Int(currentLocation.course))
        }
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
