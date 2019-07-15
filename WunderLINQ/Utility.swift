//
//  Utility.swift
//  WunderLINQ
//
//  Created by Keith Conger on 7/14/19.
//  Copyright © 2019 Black Box Embedded, LLC. All rights reserved.
//

import Foundation

class Utility {
    // MARK: - Utility Methods
    // Unit Conversion Functions
    // bar to psi
    class func barToPsi(_ bar:Double) -> Double {
        let psi = bar * 14.5037738
        return psi
    }
    // bar to kpa
    class func barTokPa(_ bar:Double) -> Double {
        let kpa = bar * 100.0
        return kpa
    }
    // bar to kg-f
    class func barTokgf(_ bar:Double) -> Double {
        let kgf = bar * 1.0197162129779
        return kgf
    }
    // kilometers to miles
    class func kmToMiles(_ kilometers:Double) -> Double {
        let miles = kilometers * 0.62137
        return miles
    }
    // Celsius to Fahrenheit
    class func celciusToFahrenheit(_ celcius:Double) -> Double {
        let fahrenheit = (celcius * 1.8) + Double(32)
        return fahrenheit
    }
    // L/100 to mpg
    class func l100ToMpg(_ l100:Double) -> Double {
        let mpg = 235.215 / l100
        return mpg
    }
    // meters to feet
    class func mtoFeet(_ meters:Double) -> Double {
        let meters = meters / 0.3048
        return meters
    }
    //radians to degrees
    class func degrees(radians:Double) -> Double {
        return 180 / Double.pi * radians
    }
}
