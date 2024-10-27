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

class StandardDashboard {

    // Main function to update the dashboard
    class func updateDashboard(_ infoLine: Int, _ isPortrait: Bool, _ height: CGFloat, _ width: CGFloat) -> XMLNode? {
        
        let motorcycleData = MotorcycleData.shared
        let faults = Faults.shared
        
        var temperatureUnit = "C"
        var distanceUnit = "km"
        var heightUnit = "m"
        var distanceTimeUnit = "KMH"
        var pressureUnit = "psi"

        var dashboardSVG = "standard-dashboard"
        if isPortrait {
            dashboardSVG = dashboardSVG + "-portrait"
        }
        // Load the XML file from the project bundle
        guard let url = Bundle.main.url(forResource: dashboardSVG, withExtension: "svg"),
              let xml = XML(contentsOf: url) else {
            os_log("Error: Unable to load or parse the XML file.")
            return nil
        }
        
        if let svgTag = findElement(byID: "standard-dashboard", in: xml) {
            svgTag.attributes["height"] = "\(height)"
            svgTag.attributes["width"] = "\(width)"
        } else {
            os_log("svgTag not found.")
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
            os_log("StandardDashboard: Unknown speed unit setting")
        }
        if (speedValue != nil){
            if let speedTag = findElement(byID: "speed", in: xml) {
                speedTag.text = "\(Utils.toZeroDecimalString(speedValue!))"
            } else {
                os_log("speedTag not found.")
            }
        }
        
        if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
            distanceTimeUnit = "MPH"
        }
        if let speedUnitTag = findElement(byID: "speedUnit", in: xml) {
            speedUnitTag.text = distanceTimeUnit
        } else {
            os_log("speedUnitTag not found.")
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
                os_log("gearTag not found.")
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
                os_log("ambientTempTag not found.")
            }
        }
        
        // Engine Temperature
        var engineTempValue = "-"
        if motorcycleData.engineTemperature != nil {
            if let engineTempTag = findElement(byID: "engineTemp", in: xml) {
                var engineTemp:Double = motorcycleData.engineTemperature!
                if (engineTemp >= 104.0){
                    let style = engineTempTag.attributes["style"]
                    let regex = try! NSRegularExpression(pattern: "fill:([^<]*);", options: NSRegularExpression.Options.caseInsensitive)
                    let range = NSMakeRange(0, style!.count)
                    let modString = regex.stringByReplacingMatches(in: style!, options: [], range: range, withTemplate: "fill:#e20505;")
                    engineTempTag.attributes["style"] = modString
                }
                if (UserDefaults.standard.integer(forKey: "temperature_unit_preference") == 1 ){
                    temperatureUnit = "F"
                    engineTemp = Utils.celciusToFahrenheit(engineTemp)
                }
                engineTempValue = "\(Utils.toZeroDecimalString(engineTemp))\(temperatureUnit)"
                engineTempTag.text = engineTempValue
            } else  {
                os_log("engineTempTag not found.")
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
                            os_log("dataValueTag not found.")
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
                os_log("clockTag not found.")
            }
        }
        
        // Front Tire Pressure
        if let rdcFTag = findElement(byID: "rdcF", in: xml) {
            var rdcFValue = "-"
            if motorcycleData.frontTirePressure != nil {
                var frontPressure:Double = motorcycleData.frontTirePressure!
                switch UserDefaults.standard.integer(forKey: "pressure_unit_preference"){
                case 1:
                    pressureUnit = "kPa"
                    frontPressure = Utils.barTokPa(frontPressure)
                case 2:
                    pressureUnit = "kgf"
                    frontPressure = Utils.barTokgf(frontPressure)
                case 3:
                    pressureUnit = "psi"
                    frontPressure = Utils.barToPsi(frontPressure)
                default:
                    pressureUnit = "bar"
                    break
                }
                rdcFValue = Utils.toOneDecimalString(frontPressure)
            }
            rdcFTag.text = "\(rdcFValue)\(pressureUnit)"
            
            if(faults.getFrontTirePressureCriticalActive()){
                let style = rdcFTag.attributes["style"]
                let regex = try! NSRegularExpression(pattern: "fill:([^<]*);", options: NSRegularExpression.Options.caseInsensitive)
                let range = NSMakeRange(0, style!.count)
                let modString = regex.stringByReplacingMatches(in: style!, options: [], range: range, withTemplate: "fill:#e20505;")
                rdcFTag.attributes["style"] = modString
            } else if(faults.getRearTirePressureWarningActive()){
                let style = rdcFTag.attributes["style"]
                let regex = try! NSRegularExpression(pattern: "fill:([^<]*);", options: NSRegularExpression.Options.caseInsensitive)
                let range = NSMakeRange(0, style!.count)
                let modString = regex.stringByReplacingMatches(in: style!, options: [], range: range, withTemplate: "fill:#fcc914;")
                rdcFTag.attributes["style"] = modString
            }
        } else {
            os_log("rdcFTag not found.")
        }
        
        // Rear Tire Pressure
        if let rdcRTag = findElement(byID: "rdcR", in: xml) {
            var rdcRValue = "-"
            if motorcycleData.rearTirePressure != nil {
                var rearPressure:Double = motorcycleData.rearTirePressure!
                switch UserDefaults.standard.integer(forKey: "pressure_unit_preference"){
                case 1:
                    pressureUnit = "kPa"
                    rearPressure = Utils.barTokPa(rearPressure)
                case 2:
                    pressureUnit = "kgf"
                    rearPressure = Utils.barTokgf(rearPressure)
                case 3:
                    pressureUnit = "psi"
                    rearPressure = Utils.barToPsi(rearPressure)
                default:
                    pressureUnit = "bar"
                    break
                }
                rdcRValue = Utils.toOneDecimalString(rearPressure)
            }
            rdcRTag.text = "\(rdcRValue)\(pressureUnit)"
            
            if(faults.getRearTirePressureCriticalActive()){
                let style = rdcRTag.attributes["style"]
                let regex = try! NSRegularExpression(pattern: "fill:([^<]*);", options: NSRegularExpression.Options.caseInsensitive)
                let range = NSMakeRange(0, style!.count)
                let modString = regex.stringByReplacingMatches(in: style!, options: [], range: range, withTemplate: "fill:#e20505;")
                rdcRTag.attributes["style"] = modString
            } else if(faults.getRearTirePressureWarningActive()){
                let style = rdcRTag.attributes["style"]
                let regex = try! NSRegularExpression(pattern: "fill:([^<]*);", options: NSRegularExpression.Options.caseInsensitive)
                let range = NSMakeRange(0, style!.count)
                let modString = regex.stringByReplacingMatches(in: style!, options: [], range: range, withTemplate: "fill:#fcc914;")
                rdcRTag.attributes["style"] = modString
            }
        } else {
            os_log("rdcRTag not found.")
        }
        
        // Fault icon
        if(!faults.getallActiveDesc().isEmpty){
            if let iconFaultTag = findElement(byID: "iconFault", in: xml) {
                iconFaultTag.attributes["style"] = "display:inline"
            } else {
                os_log("iconFaultTag not found.")
            }
        }
        
        //Fuel Icon
        if(faults.getFuelFaultActive()){
            if let iconFuelTag = findElement(byID: "iconFuel", in: xml) {
                iconFuelTag.attributes["style"] = "display:inline"
            } else {
                os_log("iconFuelTag not found.")
            }
        }

        //RPM Digits
        if let rpmTilesTag = findElement(byID: "rpmTiles", in: xml) {
            switch UserDefaults.standard.integer(forKey: "max_rpm_preference"){
            case 0:
                //10000
                if (motorcycleData.rpm != nil){
                    if (motorcycleData.getRPM() >= 333) {
                        rpmTilesTag[1].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 666) {
                        rpmTilesTag[2].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 1000) {
                        rpmTilesTag[3].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 1333) {
                        rpmTilesTag[4].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 1666) {
                        rpmTilesTag[5].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 2000) {
                        rpmTilesTag[6].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 2333) {
                        rpmTilesTag[7].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 2666) {
                        rpmTilesTag[8].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 3000) {
                        rpmTilesTag[9].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 3333) {
                        rpmTilesTag[10].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 3666) {
                        rpmTilesTag[11].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 4000) {
                        rpmTilesTag[12].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 4333) {
                        rpmTilesTag[13].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 4666) {
                        rpmTilesTag[14].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 5000) {
                        rpmTilesTag[15].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 5333) {
                        rpmTilesTag[16].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 5666) {
                        rpmTilesTag[17].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 6000) {
                        rpmTilesTag[18].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 6333) {
                        rpmTilesTag[19].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 6666) {
                        rpmTilesTag[20].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 7000) {
                        rpmTilesTag[21].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 7333) {
                        rpmTilesTag[22].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 7666) {
                        rpmTilesTag[23].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 8000) {
                        rpmTilesTag[24].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 8333) {
                        rpmTilesTag[25].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 8666) {
                        rpmTilesTag[26].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 9000) {
                        rpmTilesTag[27].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 9333) {
                        rpmTilesTag[28].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 9666) {
                        rpmTilesTag[29].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 10000) {
                        rpmTilesTag[30].attributes["style"] = "display:inline"
                    }
                }
                break
            case 1:
                //12000
                if let rpmGaugeDigitsTag = findElement(byID: "rpmGaugeDigits", in: xml) {
                    rpmGaugeDigitsTag["rpmDialDigit1"]?.text = "2"
                    rpmGaugeDigitsTag["rpmDialDigit2"]?.text = "4"
                    rpmGaugeDigitsTag["rpmDialDigit3"]?.text = "5"
                    rpmGaugeDigitsTag["rpmDialDigit4"]?.text = "6"
                    rpmGaugeDigitsTag["rpmDialDigit5"]?.text = "7"
                    rpmGaugeDigitsTag["rpmDialDigit6"]?.text = "8"
                    rpmGaugeDigitsTag["rpmDialDigit7"]?.text = "9"
                    rpmGaugeDigitsTag["rpmDialDigit8"]?.text = "10"
                    rpmGaugeDigitsTag["rpmDialDigit9"]?.text = "11"
                    rpmGaugeDigitsTag["rpmDialDigit10"]?.text = "12"
                } else {
                    os_log("Could not find rpmGaugeDigitsTag")
                }
                
                if (motorcycleData.rpm != nil){
                    if (motorcycleData.getRPM() >= 666) {
                        rpmTilesTag[1].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 1333) {
                        rpmTilesTag[2].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 2000) {
                        rpmTilesTag[3].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 2666) {
                        rpmTilesTag[4].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 3333) {
                        rpmTilesTag[5].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 4000) {
                        rpmTilesTag[6].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 4333) {
                        rpmTilesTag[7].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 4666) {
                        rpmTilesTag[8].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 5000) {
                        rpmTilesTag[9].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 5333) {
                        rpmTilesTag[10].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 5666) {
                        rpmTilesTag[11].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 6000) {
                        rpmTilesTag[12].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 6333) {
                        rpmTilesTag[13].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 6666) {
                        rpmTilesTag[14].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 7000) {
                        rpmTilesTag[15].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 7333) {
                        rpmTilesTag[16].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 7666) {
                        rpmTilesTag[17].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 8000) {
                        rpmTilesTag[18].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 8333) {
                        rpmTilesTag[19].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 8666) {
                        rpmTilesTag[20].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 9000) {
                        rpmTilesTag[21].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 9333) {
                        rpmTilesTag[22].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 9666) {
                        rpmTilesTag[23].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 10000) {
                        rpmTilesTag[24].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 10333) {
                        rpmTilesTag[25].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 10666) {
                        rpmTilesTag[26].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 11000) {
                        rpmTilesTag[27].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 11333) {
                        rpmTilesTag[28].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 11666) {
                        rpmTilesTag[29].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 12000) {
                        rpmTilesTag[30].attributes["style"] = "display:inline"
                    }
                }
                break
            case 2:
                //15000
                if let rpmGaugeDigitsTag = findElement(byID: "rpmGaugeDigits", in: xml) {
                    rpmGaugeDigitsTag["rpmDialDigit1"]?.text = "2"
                    rpmGaugeDigitsTag["rpmDialDigit2"]?.text = "4"
                    rpmGaugeDigitsTag["rpmDialDigit3"]?.text = "6"
                    rpmGaugeDigitsTag["rpmDialDigit4"]?.text = "8"
                    rpmGaugeDigitsTag["rpmDialDigit5"]?.text = "9"
                    rpmGaugeDigitsTag["rpmDialDigit6"]?.text = "10"
                    rpmGaugeDigitsTag["rpmDialDigit7"]?.text = "11"
                    rpmGaugeDigitsTag["rpmDialDigit8"]?.text = "12"
                    rpmGaugeDigitsTag["rpmDialDigit9"]?.text = "13"
                    rpmGaugeDigitsTag["rpmDialDigit10"]?.text = "15"
                } else {
                    os_log("Could not find rpmGaugeDigitsTag")
                }
                
                if (motorcycleData.rpm != nil){
                    if (motorcycleData.getRPM() >= 666) {
                        rpmTilesTag[1].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 1333) {
                        rpmTilesTag[2].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 2000) {
                        rpmTilesTag[3].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 2666) {
                        rpmTilesTag[4].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 3333) {
                        rpmTilesTag[5].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 4000) {
                        rpmTilesTag[6].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 4666) {
                        rpmTilesTag[7].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 5333) {
                        rpmTilesTag[8].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 6000) {
                        rpmTilesTag[9].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 6666) {
                        rpmTilesTag[10].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 7333) {
                        rpmTilesTag[11].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 8000) {
                        rpmTilesTag[12].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 8333) {
                        rpmTilesTag[3].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 8666) {
                        rpmTilesTag[14].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 9000) {
                        rpmTilesTag[15].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 9333) {
                        rpmTilesTag[16].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 9666) {
                        rpmTilesTag[17].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 10000) {
                        rpmTilesTag[18].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 10333) {
                        rpmTilesTag[19].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 10666) {
                        rpmTilesTag[20].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 11000) {
                        rpmTilesTag[21].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 11333) {
                        rpmTilesTag[22].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 11666) {
                        rpmTilesTag[23].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 12000) {
                        rpmTilesTag[24].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 12333) {
                        rpmTilesTag[25].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 12666) {
                        rpmTilesTag[26].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 13000) {
                        rpmTilesTag[27].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 13666) {
                        rpmTilesTag[28].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 14333) {
                        rpmTilesTag[29].attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 15000) {
                        rpmTilesTag[30].attributes["style"] = "display:inline"
                    }
                }
                break
            default:
                os_log("StandardDashboard: Unknown or default RPM Setting for standard dashboard")
                break
            }
        } else {
            os_log("rpmTilesTag not found.")
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
