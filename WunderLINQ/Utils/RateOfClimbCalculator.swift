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

// AltitudeData struct to store altitude and timestamp
struct AltitudeData {
    let altitude: Double // Altitude in meters
    let timestamp: Date  // Timestamp of the reading
}

class RateOfClimbCalculator {
    private var altitudeDataList = [AltitudeData]() // Sliding window for altitude data
    private let observationWindow: TimeInterval // Observation window in seconds
    
    init(observationWindow: TimeInterval = 60) {
        self.observationWindow = observationWindow // Default to 60 seconds
    }
    
    // Add a new altitude update
    func addAltitudeData(altitude: Double) {
        let newData = AltitudeData(altitude: altitude, timestamp: Date())
        altitudeDataList.append(newData)
        
        // Remove data outside the observation window
        cleanOldData()
    }
    
    // Calculate the rate of climb
    func calculateRateOfClimb() -> Double {
        guard altitudeDataList.count >= 2 else {
            return 0.0 // Not enough data to calculate
        }
        
        // Get the oldest and newest entries
        guard let firstData = altitudeDataList.first,
              let lastData = altitudeDataList.last else {
            return 0.0
        }
        
        // Calculate altitude change and time change
        let altitudeChange = lastData.altitude - firstData.altitude
        let timeChange = lastData.timestamp.timeIntervalSince(firstData.timestamp)
        
        // Avoid division by zero
        guard timeChange > 0 else { return 0.0 }
        
        // Calculate rate of climb in meters per second
        return altitudeChange / timeChange
    }
    
    // Remove outdated data outside the observation window
    private func cleanOldData() {
        let now = Date()
        altitudeDataList.removeAll { data in
            now.timeIntervalSince(data.timestamp) > observationWindow
        }
    }
}
