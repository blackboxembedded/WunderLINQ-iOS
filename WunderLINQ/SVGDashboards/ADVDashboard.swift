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

    // Main function to update the dashboard
    class func updateDashboard(_ infoLine: Int, _ isPortrait: Bool, _ height: CGFloat, _ width: CGFloat) -> XMLNode? {
        
        let motorcycleData = MotorcycleData.shared
        let faults = Faults.shared
        
        var temperatureUnit = "C"
        var distanceUnit = "km"
        var heightUnit = "m"
        var distanceTimeUnit = "KMH"

        var dashboardSVG = "adv-dashboard"
        if isPortrait {
            dashboardSVG = dashboardSVG + "-portrait"
        }
        // Load the XML file from the project bundle
        guard let url = Bundle.main.url(forResource: dashboardSVG, withExtension: "svg"),
              let xml = XML(contentsOf: url) else {
            NSLog("Error: Unable to load or parse the XML file.")
            return nil
        }
        
        if let svgTag = findElement(byID: "adv-dashboard", in: xml) {
            svgTag.attributes["height"] = "\(height)"
            svgTag.attributes["width"] = "\(width)"
        } else {
            NSLog("svgTag not found.")
        }

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
            if motorcycleData.location != nil {
                let currentLocation = motorcycleData.location
                speedValue = currentLocation!.speed * 3.6
                if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                    speedValue = Utils.kmToMiles(speedValue!)
                }
            }
        default:
            NSLog("StandardDashboard: Unknown speed unit setting")
        }
        if (speedValue != nil){
            if let speedTag = findElement(byID: "speed", in: xml) {
                speedTag.text = "\(Utils.toZeroDecimalString(speedValue!))"
            } else {
                NSLog("speedTag not found.")
            }
        }
        
        if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
            distanceTimeUnit = "MPH"
        }
        if let speedUnitTag = findElement(byID: "speedUnit", in: xml) {
            speedUnitTag.text = distanceTimeUnit
        } else {
            NSLog("speedUnitTag not found.")
        }
        
        //Gear
        var gearValue = "-"
        if motorcycleData.gear != nil {
            if let gearTag = findElement(byID: "gear", in: xml) {
                gearValue = motorcycleData.getgear()
                if gearValue == "N"{
                    let style = gearTag.attributes["style"]
                    let regex = try! NSRegularExpression(pattern: "fill:([^<]*);", options: NSRegularExpression.Options.caseInsensitive)
                    let range = NSMakeRange(0, style!.count)
                    let modString = regex.stringByReplacingMatches(in: style!, options: [], range: range, withTemplate: "fill:#03ae1e;")
                    gearTag.attributes["style"] = modString
                }
                gearTag.text = gearValue
            } else {
                NSLog("gearTag not found.")
            }
        }
        
        // Ambient Temperature
        var ambientTempValue = "-"
        if motorcycleData.ambientTemperature != nil {
            if let ambientTempTag = findElement(byID: "ambientTemp", in: xml) {
                var ambientTemp:Double = motorcycleData.ambientTemperature!
                if(ambientTemp <= 0){
                    //Freezing
                }
                if UserDefaults.standard.integer(forKey: "temperature_unit_preference") == 1 {
                    temperatureUnit = "F"
                    ambientTemp = Utils.celciusToFahrenheit(ambientTemp)
                }
                ambientTempValue = "\(Utils.toZeroDecimalString(ambientTemp))\(temperatureUnit)"
                ambientTempTag.text = ambientTempValue
            } else {
                NSLog("ambientTempTag not found.")
            }
        }
        
        //Info Line
        var dataLabel = ""
        var dataValue = ""
        switch (infoLine){
            case 1://Trip1
                if motorcycleData.tripOne != nil {
                    var trip1:Double = motorcycleData.tripOne!
                    if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                        distanceUnit = "mls"
                        trip1 = Utils.kmToMiles(trip1)
                    }
                    dataValue = "\(Utils.toOneDecimalString(trip1))\(distanceUnit)"
                }
                dataLabel = "dash_trip1_label".localized(forLanguageCode: "Base")
                break
            case 2://Trip2
                if motorcycleData.tripTwo != nil {
                    var trip2:Double = motorcycleData.tripTwo!
                    if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                        distanceUnit = "mls"
                        trip2 = Utils.kmToMiles(trip2)
                    }
                    dataValue = "\(Utils.toOneDecimalString(trip2))\(distanceUnit)"
                }
                dataLabel = "dash_trip2_label".localized(forLanguageCode: "Base")
                break
            case 3://Range
                if motorcycleData.fuelRange != nil {
                    var fuelRange:Double = motorcycleData.fuelRange!
                    if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                        distanceUnit = "mls"
                        fuelRange = Utils.kmToMiles(fuelRange)
                    }
                    dataValue = "\(Utils.toZeroDecimalString(fuelRange))\(distanceUnit)"
                    if(faults.getFuelFaultActive()){
                        if let dataValueTag = findElement(byID: "dataValue", in: xml) {
                            let style = dataValueTag.attributes["style"]
                            let regex = try! NSRegularExpression(pattern: "fill:([^<]*);", options: NSRegularExpression.Options.caseInsensitive)
                            let range = NSMakeRange(0, style!.count)
                            let modString = regex.stringByReplacingMatches(in: style!, options: [], range: range, withTemplate: "fill:#e20505;")
                            dataValueTag.attributes["style"] = modString
                        } else {
                            NSLog("dataValueTag not found.")
                        }
                    }
                }
                dataLabel = "dash_range_label".localized(forLanguageCode: "Base")
                break
            case 4://Altitude
                if motorcycleData.location != nil {
                    var altitude = motorcycleData.location!.altitude
                    if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                        altitude = Utils.mtoFeet(motorcycleData.location!.altitude)
                        heightUnit = "ft"
                    }
                    dataValue = "\(Utils.toZeroDecimalString(altitude))\(heightUnit)"
                }
                dataLabel = "dash_altitude_label".localized(forLanguageCode: "Base")
                break
            default:
                break
        }
        if let dataValueTag = findElement(byID: "dataValue", in: xml) {
            dataValueTag.text = dataValue
        }
        if let dataLabelTag = findElement(byID: "dataLabel", in: xml) {
            dataLabelTag.text = dataLabel
        }
        
        //Time
        var timeValue = ":"
        if motorcycleData.time != nil {
            if let clockTag = findElement(byID: "clock", in: xml) {
                let formatter = DateFormatter()
                formatter.dateFormat = "h:mm"
                if UserDefaults.standard.integer(forKey: "time_format_preference") > 0 {
                    formatter.dateFormat = "HH:mm"
                }
                timeValue = ("\(formatter.string(from: motorcycleData.time!))")
                clockTag.text = timeValue
            } else {
                NSLog("clockTag not found.")
            }
        }
        
        // Fault icon
        if(!faults.getallActiveDesc().isEmpty){
            if let iconFaultTag = findElement(byID: "iconFault", in: xml) {
                iconFaultTag.attributes["style"] = "display:inline"
            } else {
                NSLog("iconFaultTag not found.")
            }
        }
        
        //Fuel Icon
        if(faults.getFuelFaultActive()){
            if let iconFuelTag = findElement(byID: "iconFuel", in: xml) {
                iconFuelTag.attributes["style"] = "display:inline"
            } else {
                NSLog("iconFuelTag not found.")
            }
        }
        
        //Compass
        var centerRadius = ",960,1080)"
        var bearing = "0"
        if let compassTag = findElement(byID: "compass", in: xml) {
            if motorcycleData.bearing != nil {
                bearing = "\(motorcycleData.bearing! * -1)"
            }
            if (isPortrait) {
                centerRadius = ",528,960)"
            }
            compassTag.attributes["transform"] = "rotate(" + bearing + centerRadius
        } else {
            NSLog("compassTag not found.")
        }

        return xml // Return the modified XML object
    }

    // Recursive function to search for an element by its 'id' attribute
    class func findElement(byID id: String, in element: XMLNode) -> XMLNode? {
        // Check if the current element has the matching 'id' attribute
        if let elementID = element.id, elementID == id {
            return element
        }

        // Traverse child elements recursively
        for child in element.children {
            if let found = findElement(byID: id, in: child) {
                return found // Return if the element is found
            }
        }

        return nil // Return nil if the element isn't found
    }

}
