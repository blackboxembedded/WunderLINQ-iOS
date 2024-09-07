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

class Utility {

    private static func convert<T: Dimension>(value: Double, from: T, to: T) -> Double {
        let measurement = Measurement(value: value, unit: from)
        return measurement.converted(to: to).value
    }

    // MARK: - Utility Methods
    // Unit Conversion Functions
    // bar to psi
    static func barToPsi(_ bar:Double) -> Double {
        return convert(value: bar, from: UnitPressure.bars,
                       to: UnitPressure.poundsForcePerSquareInch)
    }

    // bar to kpa
    static func barTokPa(_ bar: Double) -> Double {
        convert(value: bar, from: UnitPressure.bars,
                       to: UnitPressure.kilopascals)
    }
    // bar to kg-f
    static func barTokgf(_ bar: Double) -> Double {
        let kgf = bar * 1.0197162129779
        return kgf
    }
    // kilometers to miles
    class func kmToMiles(_ kilometers: Double) -> Double {
        convert(value: kilometers, from: UnitLength.kilometers,
                to: UnitLength.miles)
    }

    // Celsius to Fahrenheit
    static func celciusToFahrenheit(_ celcius:Double) -> Double {
        convert(value: celcius, from: UnitTemperature.celsius, to: UnitTemperature.fahrenheit)
    }
    // L/100 to mpg
    class func l100ToMpg(_ l100:Double) -> Double {
        convert(value: l100, from: UnitFuelEfficiency.litersPer100Kilometers,
                to: UnitFuelEfficiency.milesPerGallon)
    }

    // L/100 to mpg Imperial
    class func l100ToMpgi(_ l100:Double) -> Double {
        convert(value: l100, from: UnitFuelEfficiency.litersPer100Kilometers,
                to: UnitFuelEfficiency.milesPerImperialGallon)
    }
    // L/100 to km/L
    class func l100Tokml(_ l100: Double) -> Double {
        let kml = l100 / 100.0
        return kml
    }
    // meters to feet
    class func mtoFeet(_ meters:Double) -> Double {
        convert(value: meters, from: UnitLength.meters, to: UnitLength.feet)
    }

    //radians to degrees
    class func degrees(radians:Double) -> Double {
        convert(value: radians, from: UnitAngle.radians, to: UnitAngle.degrees)
    }
    
    // Calculate time duration
    class func calculateDuration(dateFormat: String, start:String, end:String) -> String {
        var dateFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateFormat = dateFormat
            formatter.locale = Locale(identifier: "en_US")
            formatter.timeZone = TimeZone.current
            return formatter
        }
        let startDate = dateFormatter.date(from:start)!
        let endDate = dateFormatter.date(from:end)!
        let difference = Calendar.current.dateComponents([.hour, .minute, .second], from: startDate, to: endDate)
        
        return "\(difference.hour!) \(NSLocalizedString("hours", comment: "")), \(difference.minute!) \(NSLocalizedString("minutes", comment: "")), \(difference.second!) \(NSLocalizedString("seconds", comment: ""))"
    }
    
    // Pads a string equally in the beginning and end for a given length
    class func padString(_ input: String, length: Int) -> String {
        let minimumLength = length
        
        // If the string is already of sufficient length, return it as is
        if input.count >= minimumLength {
            return input
        }
        
        // Calculate the number of spaces needed
        let totalPadding = minimumLength - input.count
        let leadingPadding = totalPadding / 2
        let trailingPadding = totalPadding - leadingPadding
        
        // Create the padded string
        let paddedString = String(repeating: " ", count: leadingPadding) + input + String(repeating: " ", count: trailingPadding)
        
        return paddedString
    }
}
