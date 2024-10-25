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
import os.log

class ADVDashboard {
    
    class func updateDashboard(_ infoLine: Int) -> XML{
        let motorcycleData = MotorcycleData.shared
        let faults = Faults.shared
        
        var temperatureUnit = "C"
        var distanceUnit = "km"
        var heightUnit = "m"
        var distanceTimeUnit = "KMH"
        
        let url = Bundle.main.url(forResource: "adv-dashboard", withExtension: "svg")!
        let xml = XML(contentsOf: url)

        //Speed
        var speedValue:Double?
        switch UserDefaults.standard.integer(forKey: "dashboard_speed_source_preference"){
        case 0:
            if motorcycleData.speed != nil {
                speedValue = motorcycleData.speed!
                if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                    speedValue = Utils.kmToMiles(speedValue!)
                }
            }
        case 1:
            if motorcycleData.rearSpeed != nil {
                speedValue = motorcycleData.rearSpeed!
                if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                    speedValue = Utils.kmToMiles(speedValue!)
                }
            }
        case 2:
            if let currentLocation = motorcycleData.getLocation() {
                speedValue = currentLocation.speed * 3.6
                if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                    speedValue = Utils.kmToMiles(speedValue!)
                }
            }
        default:
            os_log("ADVDashboard: Unknown speed unit setting")
        }
        if (speedValue != nil){
            xml?[0]["dashboard"]?["values"]?["speed"]?.text = "\(Utils.toZeroDecimalString(speedValue!))"
        }
        if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
            distanceTimeUnit = "MPH"
        }
        xml?[0]["dashboard"]?["labels"]?["speedUnit"]?.text = distanceTimeUnit
        
        //Gear
        var gearValue = "-"
        if motorcycleData.gear != nil {
            gearValue = motorcycleData.getgear()
            if gearValue == "N"{
                let style = xml?[0]["dashboard"]?["values"]?["gear"]?.attributes["class"]
                let regex = try! NSRegularExpression(pattern: "st34", options: NSRegularExpression.Options.caseInsensitive)
                let range = NSMakeRange(0, style!.count)
                let modString = regex.stringByReplacingMatches(in: style!, options: [], range: range, withTemplate: "st14")
                xml?[0]["dashboard"]?["values"]?["gear"]?.attributes["class"] = modString
            }
        }
        xml?[0]["dashboard"]?["values"]?["gear"]?.text = gearValue
        
        // Ambient Temperature
        var ambientTempValue = "-"
        if motorcycleData.ambientTemperature != nil {
            var ambientTemp:Double = motorcycleData.ambientTemperature!
            if(ambientTemp <= 0){
                //Freezing
            }
            if UserDefaults.standard.integer(forKey: "temperature_unit_preference") == 1 {
                temperatureUnit = "F"
                ambientTemp = Utils.celciusToFahrenheit(ambientTemp)
            }
            ambientTempValue = "\(Utils.toZeroDecimalString(ambientTemp))\(temperatureUnit)"
        }
        xml?[0]["dashboard"]?["values"]?["ambientTemp"]?.text = ambientTempValue
        
        // Engine Temperature
        var engineTempValue = "-"
        if motorcycleData.engineTemperature != nil {
            var engineTemp:Double = motorcycleData.engineTemperature!
            if (engineTemp >= 104.0){
                let style = xml?[0]["dashboard"]?["values"]?["engineTemp"]?.attributes["style"]
                if (style != nil) {
                    let regex = try! NSRegularExpression(pattern: "fill:([^<]*);", options: NSRegularExpression.Options.caseInsensitive)
                    let range = NSMakeRange(0, style!.count)
                    let modString = regex.stringByReplacingMatches(in: style!, options: [], range: range, withTemplate: "fill:#e20505;")
                    xml?[0]["dashboard"]?["values"]?["engineTemp"]?.attributes["style"] = modString
                }
            }
            if (UserDefaults.standard.integer(forKey: "temperature_unit_preference") == 1 ){
                temperatureUnit = "F"
                engineTemp = Utils.celciusToFahrenheit(engineTemp)
            }
            engineTempValue = "\(Utils.toZeroDecimalString(engineTemp))\(temperatureUnit)"
        }
        xml?[0]["dashboard"]?["values"]?["engineTemp"]?.text = engineTempValue
        
        //Info Line
        var dataLabel = ""
        var dataValue = ""
        var dataUnit = ""
        switch (infoLine){
            case 1://Trip1
                if motorcycleData.tripOne != nil {
                    var trip1:Double = motorcycleData.tripOne!
                    if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                        trip1 = Utils.kmToMiles(trip1)
                        distanceUnit = "mi"
                    }
                    dataValue = "\(Utils.toOneDecimalString(trip1))"
                    dataUnit = distanceUnit
                    dataLabel = "dash_trip1_label".localized(forLanguageCode: "Base")
                }
                break
            case 2://Trip2
                if motorcycleData.tripTwo != nil {
                    var trip2:Double = motorcycleData.tripTwo!
                    if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                        trip2 = Utils.kmToMiles(trip2)
                        distanceUnit = "mi"
                    }
                    dataValue = "\(Utils.toOneDecimalString(trip2))"
                    dataUnit = distanceUnit
                    dataLabel = "dash_trip2_label".localized(forLanguageCode: "Base")
                }
                break
            case 3://Range
                if motorcycleData.fuelRange != nil {
                    var fuelRange:Double = motorcycleData.fuelRange!
                    if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                        fuelRange = Utils.kmToMiles(fuelRange)
                        distanceUnit = "mi"
                    }
                    dataValue = "\(Utils.toZeroDecimalString(fuelRange))"
                    dataUnit = distanceUnit
                    dataLabel = "dash_range_label".localized(forLanguageCode: "Base")
                }
                break
            case 4://Altitude
                if motorcycleData.location != nil {
                    var altitude:Double = motorcycleData.location!.altitude
                    if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                        altitude = Utils.mtoFeet(motorcycleData.location!.altitude)
                        heightUnit = "ft"
                    }
                    dataValue = "\(Utils.toZeroDecimalString(altitude))"
                    dataUnit = heightUnit
                    dataLabel = "dash_altitude_label".localized(forLanguageCode: "Base")
                }
                break
            default:
                break
        }
        xml?[0]["dashboard"]?["values"]?["dataValue"]?.text = dataValue
        xml?[0]["dashboard"]?["labels"]?["dataLabel"]?.text = dataLabel
        xml?[0]["dashboard"]?["labels"]?["dataUnit"]?.text = dataUnit
        
        //Time
        var timeValue = ":"
        if motorcycleData.time != nil {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm"
            if UserDefaults.standard.integer(forKey: "time_format_preference") > 0 {
                formatter.dateFormat = "HH:mm"
            }
            timeValue = ("\(formatter.string(from: motorcycleData.time!))")
        }
        xml?[0]["dashboard"]?["values"]?["clock"]?.text = timeValue
        
        //Trip Logging
        //xml?[0]["dashboard"]?["icons"]?["iconTrip"]?.attributes["style"] = "display:inline"
        //Camera
        //xml?[0]["dashboard"]?["icons"]?["iconVideo"]?.attributes["style"] = "display:inline"
        
        // Fault icon
        if(!faults.getallActiveDesc().isEmpty){
            xml?[0]["dashboard"]?["icons"]?["iconFault"]?.attributes["style"] = "display:inline"
        }
        
        //Fuel Icon
        if(faults.getFuelFaultActive()){
            xml?[0]["dashboard"]?["icons"]?["iconFuel"]?.attributes["style"] = "display:inline"
        }
    
        //Compass
        if motorcycleData.bearing != nil {
            xml?[0]["dashboard"]?["compass"]?.attributes["transform"] = "translate(200,340) scale(3.0) rotate(\(motorcycleData.getbearing()),250,246)"
        }
        
        return xml!
    }
}
