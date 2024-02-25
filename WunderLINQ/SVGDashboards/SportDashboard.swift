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

class SportDashboard {
    
    class func updateDashboard(_ infoLine: Int) -> XML{
        let motorcycleData = MotorcycleData.shared
        let faults = Faults.shared
        
        var temperatureUnit = "C"
        var distanceUnit = "km"
        var heightUnit = "m"
        var distanceTimeUnit = "KMH"

        
        let url = Bundle.main.url(forResource: "sport-dashboard", withExtension: "svg")!
        let xml = XML(contentsOf: url)

        //Speed
        var speedValue:Double?
        switch UserDefaults.standard.integer(forKey: "dashboard_speed_source_preference"){
        case 0:
            if motorcycleData.speed != nil {
                speedValue = motorcycleData.speed!
                if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                    speedValue = Utility.kmToMiles(speedValue!)
                }
            }
        case 1:
            if motorcycleData.rearSpeed != nil {
                speedValue = motorcycleData.rearSpeed!
                if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                    speedValue = Utility.kmToMiles(speedValue!)
                }
            }
        case 2:
            if let currentLocation = motorcycleData.getLocation() {
                speedValue = currentLocation.speed * 3.6
                if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                    speedValue = Utility.kmToMiles(speedValue!)
                }
            }
        default:
            NSLog("SportDashboard: Unknown speed unit setting")
        }
        if (speedValue != nil){
            if (speedValue! < 10){
                xml?[0]["dashboard"]?["values"]?["speed"]?.text = "\(String(format: "%02d",Int(round(speedValue!))))"
            } else {
                xml?[0]["dashboard"]?["values"]?["speed"]?.text = "\(Int(round(speedValue!)))"
            }
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
                ambientTemp = Utility.celciusToFahrenheit(ambientTemp)
            }
            ambientTempValue = "\(Int(round(ambientTemp)))\(temperatureUnit)"
        }
        xml?[0]["dashboard"]?["values"]?["ambientTemp"]?.text = ambientTempValue
        
        // Engine Temperature
        var engineTempValue = "-"
        if motorcycleData.engineTemperature != nil {
            var engineTemp:Double = motorcycleData.engineTemperature!
            if (engineTemp >= 104.0){
                let style = xml?[0]["dashboard"]?["values"]?["engineTemp"]?.attributes["style"]
                let regex = try! NSRegularExpression(pattern: "fill:([^<]*);", options: NSRegularExpression.Options.caseInsensitive)
                let range = NSMakeRange(0, style!.count)
                let modString = regex.stringByReplacingMatches(in: style!, options: [], range: range, withTemplate: "fill:#e20505;")
                xml?[0]["dashboard"]?["values"]?["engineTemp"]?.attributes["style"] = modString
            }
            if (UserDefaults.standard.integer(forKey: "temperature_unit_preference") == 1 ){
                temperatureUnit = "F"
                engineTemp = Utility.celciusToFahrenheit(engineTemp)
            }
            engineTempValue = "\(Int(round(engineTemp)))\(temperatureUnit)"
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
                    dataValue = "\(Int(round(trip1)))"
                    if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                        trip1 = Utility.kmToMiles(trip1)
                        distanceUnit = "mi"
                    }
                    dataUnit = distanceUnit
                    dataLabel = "dash_trip1_label".localized(forLanguageCode: "Base")
                }
                break
            case 2://Trip2
                if motorcycleData.tripTwo != nil {
                    var trip2:Double = motorcycleData.tripTwo!
                    dataValue = "\(Int(round(trip2)))"
                    if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                        trip2 = Utility.kmToMiles(trip2)
                        distanceUnit = "mi"
                    }
                    dataUnit = distanceUnit
                    dataLabel = "dash_trip2_label".localized(forLanguageCode: "Base")
                }
                break
            case 3://Range
                if motorcycleData.fuelRange != nil {
                    var fuelRange:Double = motorcycleData.fuelRange!
                    dataValue = "\(Int(round(fuelRange)))"
                    if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                        fuelRange = Utility.kmToMiles(fuelRange)
                        distanceUnit = "mi"
                    }
                    dataUnit = distanceUnit
                    dataLabel = "dash_range_label".localized(forLanguageCode: "Base")
                }
                break
            case 4://Altitude
                if motorcycleData.location != nil {
                    dataValue = "\(Int(round(motorcycleData.location!.altitude)))"
                    if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                        dataValue = "\(Int(round(Utility.mtoFeet(motorcycleData.location!.altitude))))"
                        heightUnit = "ft"
                    }
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
        
        //Lean Angle
        if (motorcycleData.leanAngleBike != nil) {
            xml?[0]["dashboard"]?["values"]?["angle"]?.text = "\(String(format: "%02d",abs(Int(motorcycleData.getleanAngleBike().rounded()))))"
        } else if (motorcycleData.leanAngle != nil) {
            xml?[0]["dashboard"]?["values"]?["angle"]?.text = "\(String(format: "%02d",abs(Int(motorcycleData.getleanAngle().rounded()))))"
        }
        //Left Max Angle
        if (motorcycleData.leanAngleBikeMaxL != nil) {
            xml?[0]["dashboard"]?["values"]?["angleMaxL"]?.text = "\(String(format: "%02d",abs(Int(motorcycleData.getleanAngleBikeMaxL().rounded()))))"
        } else if (motorcycleData.leanAngleMaxL != nil) {
            xml?[0]["dashboard"]?["values"]?["angleMaxL"]?.text = "\(String(format: "%02d",abs(Int(motorcycleData.getleanAngleMaxL().rounded()))))"
        }
        //Right Max Angle
        if (motorcycleData.leanAngleBikeMaxR != nil) {
            xml?[0]["dashboard"]?["values"]?["angleMaxR"]?.text = "\(String(format: "%02d",abs(Int(motorcycleData.getleanAngleBikeMaxR().rounded()))))"
        } else if (motorcycleData.leanAngleMaxR != nil) {
            xml?[0]["dashboard"]?["values"]?["angleMaxR"]?.text = "\(String(format: "%02d",abs(Int(motorcycleData.getleanAngleMaxR().rounded()))))"
        }
        
        //Lean Angle Gauge
        if (motorcycleData.leanAngleBike != nil) {
            if((motorcycleData.getleanAngleBike() <= 5.5) && (motorcycleData.getleanAngleBike() >= -5.5)){
                xml?[0]["dashboard"]?["angleTicks"]?["angle0"]?.attributes["style"] = "display:inline"
            }
            if((motorcycleData.getleanAngleBike() <= -5.5) && (motorcycleData.getleanAngleBike() >= -11.0)){
                xml?[0]["dashboard"]?["angleTicks"]?["angle1L"]?.attributes["style"] = "display:inline"
            }
            if((motorcycleData.getleanAngleBike() <= -11.0) && (motorcycleData.getleanAngleBike() >= -16.5)){
                xml?[0]["dashboard"]?["angleTicks"]?["angle2L"]?.attributes["style"] = "display:inline"
            }
            if((motorcycleData.getleanAngleBike() <= -16.5) && (motorcycleData.getleanAngleBike() >= -22.0)){
                xml?[0]["dashboard"]?["angleTicks"]?["angle3L"]?.attributes["style"] = "display:inline"
            }
            if((motorcycleData.getleanAngleBike() <= -22.0) && (motorcycleData.getleanAngleBike() >= -27.5)){
                xml?[0]["dashboard"]?["angleTicks"]?["angle4L"]?.attributes["style"] = "display:inline"
            }
            if((motorcycleData.getleanAngleBike() <= -27.5) && (motorcycleData.getleanAngleBike() >= -33.0)){
                xml?[0]["dashboard"]?["angleTicks"]?["angle5L"]?.attributes["style"] = "display:inline"
            }
            if((motorcycleData.getleanAngleBike() <= -33.0) && (motorcycleData.getleanAngleBike() >= -38.5)){
                xml?[0]["dashboard"]?["angleTicks"]?["angle6L"]?.attributes["style"] = "display:inline"
            }
            if((motorcycleData.getleanAngleBike() <= -38.5) && (motorcycleData.getleanAngleBike() >= -44.0)){
                xml?[0]["dashboard"]?["angleTicks"]?["angle7L"]?.attributes["style"] = "display:inline"
            }
            if((motorcycleData.getleanAngleBike() <= -44.0) && (motorcycleData.getleanAngleBike() >= -49.5)){
                xml?[0]["dashboard"]?["angleTicks"]?["angle8L"]?.attributes["style"] = "display:inline"
            }
            if(motorcycleData.getleanAngleBike() <= -49.5){
                xml?[0]["dashboard"]?["angleTicks"]?["angle9L"]?.attributes["style"] = "display:inline"
            }
            if((motorcycleData.getleanAngleBike() >= 5.5) && (motorcycleData.getleanAngleBike() <= 11.0)){
                xml?[0]["dashboard"]?["angleTicks"]?["angle1R"]?.attributes["style"] = "display:inline"
            }
            if((motorcycleData.getleanAngleBike() >= 11.0) && (motorcycleData.getleanAngleBike() <= 16.5)){
                xml?[0]["dashboard"]?["angleTicks"]?["angle2R"]?.attributes["style"] = "display:inline"
            }
            if((motorcycleData.getleanAngleBike() >= 16.5) && (motorcycleData.getleanAngleBike() <= 22.0)){
                xml?[0]["dashboard"]?["angleTicks"]?["angle3R"]?.attributes["style"] = "display:inline"
            }
            if((motorcycleData.getleanAngleBike() >= 22.0) && (motorcycleData.getleanAngleBike() <= 27.5)){
                xml?[0]["dashboard"]?["angleTicks"]?["angle4R"]?.attributes["style"] = "display:inline"
            }
            if((motorcycleData.getleanAngleBike() >= 27.5) && (motorcycleData.getleanAngleBike() <= 33.0)){
                xml?[0]["dashboard"]?["angleTicks"]?["angle5R"]?.attributes["style"] = "display:inline"
            }
            if((motorcycleData.getleanAngleBike() >= 33.0) && (motorcycleData.getleanAngleBike() <= 38.5)){
                xml?[0]["dashboard"]?["angleTicks"]?["angle6R"]?.attributes["style"] = "display:inline"
            }
            if((motorcycleData.getleanAngleBike() >= 38.5) && (motorcycleData.getleanAngleBike() <= 44.0)){
                xml?[0]["dashboard"]?["angleTicks"]?["angle7R"]?.attributes["style"] = "display:inline"
            }
            if((motorcycleData.getleanAngleBike() >= 44.0) && (motorcycleData.getleanAngleBike() <= 9.5)){
                xml?[0]["dashboard"]?["angleTicks"]?["angle8R"]?.attributes["style"] = "display:inline"
            }
            if(motorcycleData.getleanAngleBike() >= 49.5){
                xml?[0]["dashboard"]?["angleTicks"]?["angle9R"]?.attributes["style"] = "display:inline"
            }
        } else if (motorcycleData.leanAngle != nil) {
            if((motorcycleData.getleanAngle() <= 5.5) && (motorcycleData.getleanAngle() >= -5.5)){
                xml?[0]["dashboard"]?["angleTicks"]?["angle0"]?.attributes["style"] = "display:inline"
            }
            if((motorcycleData.getleanAngle() <= -5.5) && (motorcycleData.getleanAngle() >= -11.0)){
                xml?[0]["dashboard"]?["angleTicks"]?["angle1R"]?.attributes["style"] = "display:inline"
            }
            if((motorcycleData.getleanAngle() <= -11.0) && (motorcycleData.getleanAngle() >= -16.5)){
                xml?[0]["dashboard"]?["angleTicks"]?["angle2R"]?.attributes["style"] = "display:inline"
            }
            if((motorcycleData.getleanAngle() <= -16.5) && (motorcycleData.getleanAngle() >= -22.0)){
                xml?[0]["dashboard"]?["angleTicks"]?["angle3R"]?.attributes["style"] = "display:inline"
            }
            if((motorcycleData.getleanAngle() <= -22.0) && (motorcycleData.getleanAngle() >= -27.5)){
                xml?[0]["dashboard"]?["angleTicks"]?["angle4R"]?.attributes["style"] = "display:inline"
            }
            if((motorcycleData.getleanAngle() <= -27.5) && (motorcycleData.getleanAngle() >= -33.0)){
                xml?[0]["dashboard"]?["angleTicks"]?["angle5R"]?.attributes["style"] = "display:inline"
            }
            if((motorcycleData.getleanAngle() <= -33.0) && (motorcycleData.getleanAngle() >= -38.5)){
                xml?[0]["dashboard"]?["angleTicks"]?["angle6R"]?.attributes["style"] = "display:inline"
            }
            if((motorcycleData.getleanAngle() <= -38.5) && (motorcycleData.getleanAngle() >= -44.0)){
                xml?[0]["dashboard"]?["angleTicks"]?["angle7R"]?.attributes["style"] = "display:inline"
            }
            if((motorcycleData.getleanAngle() <= -44.0) && (motorcycleData.getleanAngle() >= -49.5)){
                xml?[0]["dashboard"]?["angleTicks"]?["angle8R"]?.attributes["style"] = "display:inline"
            }
            if(motorcycleData.getleanAngle() <= -49.5){
                xml?[0]["dashboard"]?["angleTicks"]?["angle9R"]?.attributes["style"] = "display:inline"
            }
            if((motorcycleData.getleanAngle() >= 5.5) && (motorcycleData.getleanAngle() <= 11.0)){
                xml?[0]["dashboard"]?["angleTicks"]?["angle1L"]?.attributes["style"] = "display:inline"
            }
            if((motorcycleData.getleanAngle() >= 11.0) && (motorcycleData.getleanAngle() <= 16.5)){
                xml?[0]["dashboard"]?["angleTicks"]?["angle2L"]?.attributes["style"] = "display:inline"
            }
            if((motorcycleData.getleanAngle() >= 16.5) && (motorcycleData.getleanAngle() <= 22.0)){
                xml?[0]["dashboard"]?["angleTicks"]?["angle3L"]?.attributes["style"] = "display:inline"
            }
            if((motorcycleData.getleanAngle() >= 22.0) && (motorcycleData.getleanAngle() <= 27.5)){
                xml?[0]["dashboard"]?["angleTicks"]?["angle4L"]?.attributes["style"] = "display:inline"
            }
            if((motorcycleData.getleanAngle() >= 27.5) && (motorcycleData.getleanAngle() <= 33.0)){
                xml?[0]["dashboard"]?["angleTicks"]?["angle5L"]?.attributes["style"] = "display:inline"
            }
            if((motorcycleData.getleanAngle() >= 33.0) && (motorcycleData.getleanAngle() <= 38.5)){
                xml?[0]["dashboard"]?["angleTicks"]?["angle6L"]?.attributes["style"] = "display:inline"
            }
            if((motorcycleData.getleanAngle() >= 38.5) && (motorcycleData.getleanAngle() <= 44.0)){
                xml?[0]["dashboard"]?["angleTicks"]?["angle7L"]?.attributes["style"] = "display:inline"
            }
            if((motorcycleData.getleanAngle() >= 44.0) && (motorcycleData.getleanAngle() <= 49.5)){
                xml?[0]["dashboard"]?["angleTicks"]?["angle8L"]?.attributes["style"] = "display:inline"
            }
            if(motorcycleData.getleanAngle() >= 49.5){
                xml?[0]["dashboard"]?["angleTicks"]?["angle9L"]?.attributes["style"] = "display:inline"
            }
        }
        
        //RPM Display
        switch UserDefaults.standard.integer(forKey: "max_rpm_preference"){
        case 0:
            //10000
            xml?[0]["dashboard"]?["rpmDialDigits"]?["rpmDialDigit1"]?.text = "2"
            xml?[0]["dashboard"]?["rpmDialDigits"]?["rpmDialDigit2"]?.text = "3"
            xml?[0]["dashboard"]?["rpmDialDigits"]?["rpmDialDigit3"]?.text = "4"
            xml?[0]["dashboard"]?["rpmDialDigits"]?["rpmDialDigit4"]?.text = "5"
            xml?[0]["dashboard"]?["rpmDialDigits"]?["rpmDialDigit5"]?.text = "6"
            xml?[0]["dashboard"]?["rpmDialDigits"]?["rpmDialDigit6"]?.text = "7"
            xml?[0]["dashboard"]?["rpmDialDigits"]?["rpmDialDigit7"]?.text = "8"
            xml?[0]["dashboard"]?["rpmDialDigits"]?["rpmDialDigit8"]?.text = "9"
            xml?[0]["dashboard"]?["rpmDialDigits"]?["rpmDialDigit9"]?.text = "10"
            
            if (motorcycleData.rpm != nil) {
                if (motorcycleData.getRPM() >= 0) {
                    
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick1"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 154) {
                    
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick2"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 308) {
                    
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick3"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 462) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick4"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 616) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick5"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 770) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick6"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 924) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick7"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 1078) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick8"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 1232) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick9"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 1386) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick10"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 1540) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick11"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 1694) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick12"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 1848) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick13"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 2000) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick14"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 2083) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick15"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 2167) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick16"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 2250) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick17"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 2334) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick18"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 2417) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick19"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 2501) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick20"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 2584) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick21"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 2668) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick22"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 2751) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick23"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 2835) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick24"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 2918) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick25"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 3000) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick26"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 3077) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick27"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 3154) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick28"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 3231) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick29"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 3308) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick30"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 3385) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick31"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 3462) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick32"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 3539) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick33"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 3616) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick34"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 3693) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick35"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 3770) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick36"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 3847) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick37"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 3924) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick38"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 4000) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick39"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 4077) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick40"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 4154) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick41"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 4231) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick42"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 4308) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick43"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 4385) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick44"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 4462) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick45"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 4539) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick46"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 4616) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick47"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 4693) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick48"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 4770) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick49"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 4847) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick50"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 4924) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick51"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 5000) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick52"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 5083) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick53"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 5166) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick54"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 5249) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick55"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 5332) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick56"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 5415) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick57"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 5498) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick58"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 5581) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick59"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 5664) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick60"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 5747) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick61"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 5830) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick62"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 5913) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick63"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 6000) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick64"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 6077) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick65"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 6154) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick66"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 6231) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick67"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 6308) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick68"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 6385) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick69"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 6462) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick70"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 6539) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick71"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 6616) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick72"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 6693) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick73"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 6770) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick74"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 6847) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick75"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 6924) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick76"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 7000) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick77"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 7083) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick78"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 7166) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick79"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 7249) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick80"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 7332) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick81"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 7415) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick82"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 7498) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick83"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 7581) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick84"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 7664) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick85"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 7747) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick86"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 7830) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick87"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 7913) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick88"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 8000) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick89"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 8083) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick90"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 8166) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick91"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 8249) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick92"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 8332) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick3"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 8415) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick94"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 8498) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick95"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 8581) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick96"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 8664) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick97"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 8747) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick98"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 8830) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick99"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 8913) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick100"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 9000) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick101"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 9066) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick102"]?.attributes["style"] = "display:inline"
                }
                // Needle
                if ((motorcycleData.getRPM() >= 0) && (motorcycleData.getRPM() <= 249)){
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle0"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 250) && (motorcycleData.getRPM() <= 499)){
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle1"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 500) && (motorcycleData.getRPM() <= 749)){
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle2"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 750) && (motorcycleData.getRPM() <= 999)){
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle3"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 1000) && (motorcycleData.getRPM() <= 1249)){
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle4"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 1250) && (motorcycleData.getRPM() <= 1499)){
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle5"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 1500) && (motorcycleData.getRPM() <= 1749)){
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle6"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 1750) && (motorcycleData.getRPM() <= 1999)){
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle7"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 2000) && (motorcycleData.getRPM() <= 2166)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle8"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 2167) && (motorcycleData.getRPM() <= 2332)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle9"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 2333) && (motorcycleData.getRPM() <= 2499)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle10"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 2500) && (motorcycleData.getRPM() <= 2600)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle11"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 2601) && (motorcycleData.getRPM() <= 2700)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle12"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 2701) && (motorcycleData.getRPM() <= 2800)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle13"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 2801) && (motorcycleData.getRPM() <= 2900)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle14"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 3000) && (motorcycleData.getRPM() <= 3166)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle15"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 3167) && (motorcycleData.getRPM() <= 3332)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle16"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 3333) && (motorcycleData.getRPM() <= 3499)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle17"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 3500) && (motorcycleData.getRPM() <= 3600)) {                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle18"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 3601) && (motorcycleData.getRPM() <= 3700)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle19"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 3701) && (motorcycleData.getRPM() <= 3800)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle20"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 3801) && (motorcycleData.getRPM() <= 3900)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle21"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 3901) && (motorcycleData.getRPM() <= 4000)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle22"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 4001) && (motorcycleData.getRPM() <= 4124)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle23"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 4125) && (motorcycleData.getRPM() <= 4249)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle24"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 4250) && (motorcycleData.getRPM() <= 4374)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle25"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 4375) && (motorcycleData.getRPM() <= 4499)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle26"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 4500) && (motorcycleData.getRPM() <= 4674)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle27"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 4750) && (motorcycleData.getRPM() <= 4874)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle20"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 4875) && (motorcycleData.getRPM() <= 4999)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle29"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 5000) && (motorcycleData.getRPM() <= 5124)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle30"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 5125) && (motorcycleData.getRPM() <= 5249)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle31"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 5250) && (motorcycleData.getRPM() <= 5374)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle32"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 5375) && (motorcycleData.getRPM() <= 5499)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle33"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 5500) && (motorcycleData.getRPM() <= 5624)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle34"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 5625) && (motorcycleData.getRPM() <= 5749)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle35"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 5750) && (motorcycleData.getRPM() <= 5874)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle36"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 5875) && (motorcycleData.getRPM() <= 6000)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle37"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 6001) && (motorcycleData.getRPM() <= 6142)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle38"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 6143) && (motorcycleData.getRPM() <= 6285)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle39"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 6286) && (motorcycleData.getRPM() <= 6428)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle40"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 6429) && (motorcycleData.getRPM() <= 6571)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle41"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 6572) && (motorcycleData.getRPM() <= 6714)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle42"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 6715) && (motorcycleData.getRPM() <= 6857)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle43"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 6858) && (motorcycleData.getRPM() <= 6999)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle44"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 7000) && (motorcycleData.getRPM() <= 7142)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle45"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 7143) && (motorcycleData.getRPM() <= 7285)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle46"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 7286) && (motorcycleData.getRPM() <= 7428)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle47"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 7429) && (motorcycleData.getRPM() <= 7571)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle48"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 7572) && (motorcycleData.getRPM() <= 7714)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle49"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 7715) && (motorcycleData.getRPM() <= 7857)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle50"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 7858) && (motorcycleData.getRPM() <= 7999)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle51"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 8000) && (motorcycleData.getRPM() <= 8142)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle52"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 8143) && (motorcycleData.getRPM() <= 8285)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle53"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 8286) && (motorcycleData.getRPM() <= 8428)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle54"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 8429) && (motorcycleData.getRPM() <= 8571)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle55"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 8572) && (motorcycleData.getRPM() <= 8714)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle56"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 8715) && (motorcycleData.getRPM() <= 8857)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle57"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 8858) && (motorcycleData.getRPM() <= 8999)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle58"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 9000) && (motorcycleData.getRPM() <= 9143)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle59"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 9144) && (motorcycleData.getRPM() <= 9287)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle60"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 9288) && (motorcycleData.getRPM() <= 9431)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle61"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 9432) && (motorcycleData.getRPM() <= 9575)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle62"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 9576) && (motorcycleData.getRPM() <= 9719)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle63"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 9720) && (motorcycleData.getRPM() <= 9863)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle64"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 9864) && (motorcycleData.getRPM() <= 9999)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle65"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 10000) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle66"]?.attributes["style"] = "display:inline"
                }
            }
            break
        case 1:
            //12000
            xml?[0]["dashboard"]?["rpmDialDigits"]?["rpmDialDigit1"]?.text = "2"
            xml?[0]["dashboard"]?["rpmDialDigits"]?["rpmDialDigit2"]?.text = "4"
            xml?[0]["dashboard"]?["rpmDialDigits"]?["rpmDialDigit3"]?.text = "6"
            xml?[0]["dashboard"]?["rpmDialDigits"]?["rpmDialDigit4"]?.text = "7"
            xml?[0]["dashboard"]?["rpmDialDigits"]?["rpmDialDigit5"]?.text = "8"
            xml?[0]["dashboard"]?["rpmDialDigits"]?["rpmDialDigit6"]?.text = "9"
            xml?[0]["dashboard"]?["rpmDialDigits"]?["rpmDialDigit7"]?.text = "10"
            xml?[0]["dashboard"]?["rpmDialDigits"]?["rpmDialDigit8"]?.text = "11"
            xml?[0]["dashboard"]?["rpmDialDigits"]?["rpmDialDigit9"]?.text = "12"
            
            if (motorcycleData.rpm != nil) {
                if (motorcycleData.getRPM() >= 0) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick1"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 154) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick2"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 308) {
                    xml?[0]["dashboard"]?["rpmTicks3"]?["rpmTick1"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 462) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick4"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 616) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick5"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 770) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick6"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 924) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick7"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 1078) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick8"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 1232) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTic9"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 1386) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick10"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 1540) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick11"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 1694) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick12"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 1848) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick13"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 2000) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick14"]?.attributes["style"] = "display:inline"
                }

                if (motorcycleData.getRPM() >= 2167) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick15"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 2167) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick16"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 2334) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick17"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 2501) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick18"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 2668) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick19"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 2835) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick20"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 3002) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick21"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 3169) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick22"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 3503) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick23"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 3670) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick24"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 3837) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick25"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 4000) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick26"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 4154) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick27"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 4308) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick28"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 4462) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick29"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 4616) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick30"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 4770) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick31"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 4924) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick32"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 5078) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick33"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 5232) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick34"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 5386) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick35"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 5540) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick36"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 5694) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick37"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 5848) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick38"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 6000) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick39"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 6077) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick40"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 6154) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick41"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 6231) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick42"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 6308) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick43"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 6385) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick44"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 6462) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick45"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 6539) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick46"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 6616) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick47"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 6693) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick48"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 6770) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick49"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 6847) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick50"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 6924) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick51"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 7000) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick52"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 7083) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick53"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 7166) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick54"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 7249) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick55"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 7332) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick56"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 7415) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick57"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 7498) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick58"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 7581) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick59"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 7664) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick60"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 7747) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick61"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 7830) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick62"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 7913) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick63"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 8000) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick64"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 8077) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick65"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 8154) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick66"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 8231) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick67"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 8308) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick68"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 8385) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick69"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 8462) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick70"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 8539) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick71"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 8616) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick72"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 8693) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick73"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 8770) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick74"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 8847) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick75"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 8924) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick76"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 9000) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick77"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 9083) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick78"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 9166) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick79"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 9249) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick80"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 9332) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick81"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 9415) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick82"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 9498) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick83"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 9581) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick84"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 9664) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick85"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 9747) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick86"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 9830) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick87"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 9913) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick88"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 10000) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick89"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 10083) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick90"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 10166) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick91"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 10249) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick92"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 10332) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick93"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 10415) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick94"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 10498) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick95"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 10581) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick96"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 10664) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick97"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 10747) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick98"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 10830) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick99"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 10913) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick100"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 11000) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick101"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 11066) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick101"]?.attributes["style"] = "display:inline"
                }
                // Needle
                if ((motorcycleData.getRPM() >= 0) && (motorcycleData.getRPM() <= 249)){
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle0"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 250) && (motorcycleData.getRPM() <= 499)){
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle1"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 500) && (motorcycleData.getRPM() <= 749)){
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle2"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 750) && (motorcycleData.getRPM() <= 999)){
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle3"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 1000) && (motorcycleData.getRPM() <= 1249)){
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle4"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 1250) && (motorcycleData.getRPM() <= 1499)){
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle5"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 1500) && (motorcycleData.getRPM() <= 1749)){
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle6"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 1750) && (motorcycleData.getRPM() <= 1999)){
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle7"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 2000) && (motorcycleData.getRPM() <= 2286)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle8"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 2287) && (motorcycleData.getRPM() <= 2573)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle9"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 2574) && (motorcycleData.getRPM() <= 2860)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle10"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 2861) && (motorcycleData.getRPM() <= 3147)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle11"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 3148) && (motorcycleData.getRPM() <= 3434)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle12"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 3435) && (motorcycleData.getRPM() <= 3721)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle13"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 3722) && (motorcycleData.getRPM() <= 3999)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle14"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 4000) && (motorcycleData.getRPM() <= 4249)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle15"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 4250) && (motorcycleData.getRPM() <= 4499)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle16"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 4500) && (motorcycleData.getRPM() <= 4749)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle17"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 4750) && (motorcycleData.getRPM() <= 4999)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle18"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 5000) && (motorcycleData.getRPM() <= 5249)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle19"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 5250) && (motorcycleData.getRPM() <= 5499)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle20"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 5500) && (motorcycleData.getRPM() <= 5749)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle21"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 5750) && (motorcycleData.getRPM() <= 6000)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle22"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 6001) && (motorcycleData.getRPM() <= 6124)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle23"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 6125) && (motorcycleData.getRPM() <= 6249)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle24"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 6250) && (motorcycleData.getRPM() <= 6374)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle25"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 6375) && (motorcycleData.getRPM() <= 6499)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle26"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 6500) && (motorcycleData.getRPM() <= 6674)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle27"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 6750) && (motorcycleData.getRPM() <= 6874)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle28"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 6875) && (motorcycleData.getRPM() <= 6999)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle29"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 7000) && (motorcycleData.getRPM() <= 7124)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle30"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 7125) && (motorcycleData.getRPM() <= 7249)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle31"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 7250) && (motorcycleData.getRPM() <= 7374)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle32"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 7375) && (motorcycleData.getRPM() <= 7499)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle33"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 7500) && (motorcycleData.getRPM() <= 7624)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle34"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 7625) && (motorcycleData.getRPM() <= 7749)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle35"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 7750) && (motorcycleData.getRPM() <= 7874)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle36"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 7875) && (motorcycleData.getRPM() <= 8000)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle37"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 8001) && (motorcycleData.getRPM() <= 6142)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle38"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 6143) && (motorcycleData.getRPM() <= 6285)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle39"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 6286) && (motorcycleData.getRPM() <= 6428)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle40"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 6429) && (motorcycleData.getRPM() <= 6571)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle41"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 6572) && (motorcycleData.getRPM() <= 6714)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle42"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 6715) && (motorcycleData.getRPM() <= 6857)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle43"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 6858) && (motorcycleData.getRPM() <= 6999)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle44"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 9000) && (motorcycleData.getRPM() <= 9142)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle45"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 9143) && (motorcycleData.getRPM() <= 9285)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle46"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 9286) && (motorcycleData.getRPM() <= 9428)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle47"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 9429) && (motorcycleData.getRPM() <= 9571)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle48"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 9572) && (motorcycleData.getRPM() <= 9714)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle49"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 9715) && (motorcycleData.getRPM() <= 9857)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle50"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 9858) && (motorcycleData.getRPM() <= 9999)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle51"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 10000) && (motorcycleData.getRPM() <= 10142)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle52"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 10143) && (motorcycleData.getRPM() <= 10285)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle53"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 10286) && (motorcycleData.getRPM() <= 10428)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle54"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 10429) && (motorcycleData.getRPM() <= 10571)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle55"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 10572) && (motorcycleData.getRPM() <= 10714)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle56"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 10715) && (motorcycleData.getRPM() <= 10857)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle57"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 10858) && (motorcycleData.getRPM() <= 10999)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle58"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 11000) && (motorcycleData.getRPM() <= 11143)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle59"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 11144) && (motorcycleData.getRPM() <= 11287)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle60"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 11288) && (motorcycleData.getRPM() <= 11431)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle61"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 11432) && (motorcycleData.getRPM() <= 11575)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle62"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 11576) && (motorcycleData.getRPM() <= 11719)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle63"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 11720) && (motorcycleData.getRPM() <= 11863)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle64"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 11864) && (motorcycleData.getRPM() <= 11999)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle65"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 12000) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle66"]?.attributes["style"] = "display:inline"
                }
            }
            break
        case 2:
            //15000
            if (motorcycleData.rpm != nil) {
                if (motorcycleData.getRPM() >= 0) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick1"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 154) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick2"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 308) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick3"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 462) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick4"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 616) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick5"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 770) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick6"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 924) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick7"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 1078) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick8"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 1232) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick9"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 1386) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick10"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 1540) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick11"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 1694) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick12"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 1848) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick13"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 2000) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick14"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 2167) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick15"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 2334) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick16"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 2501) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick17"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 2668) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick18"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 2835) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick19"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 3002) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick20"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 3169) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick21"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 3336) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick22"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 3503) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick23"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 3670) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick24"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 3837) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick25"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 4000) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick26"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 4308) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick27"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 4616) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick28"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 4924) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick29"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 5232) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick30"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 5540) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick31"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 5848) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick32"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 6156) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick33"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 6464) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick34"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 6772) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick35"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 7080) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick36"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 7388) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick37"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 7696) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick38"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 8000) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick39"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 8077) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick40"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 8154) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick41"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 8231) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick42"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 8308) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick43"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 8385) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick44"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 8462) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick45"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 8539) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick46"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 8616) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick47"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 8693) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick48"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 8770) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick49"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 8847) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick50"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 8924) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick51"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 9000) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick52"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 9083) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick53"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 9166) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick54"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 9249) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick55"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 9332) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick56"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 9415) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick57"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 9498) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick58"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 9581) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick59"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 9664) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick60"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 9747) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick61"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 9830) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick62"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 9913) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick63"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 10000) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick64"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 10077) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick65"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 10154) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick66"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 10231) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick67"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 10308) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick68"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 10385) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick69"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 10462) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick70"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 10539) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick71"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 10616) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick72"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 10693) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick73"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 10770) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick74"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 10847) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick75"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 10924) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick76"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 11000) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick77"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 11083) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick78"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 11166) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick79"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 11249) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick80"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 11332) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick81"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 11415) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick82"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 11498) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick83"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 11581) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick84"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 11664) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick85"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 11747) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick86"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 11830) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick87"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 11913) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick88"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 12000) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick89"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 12083) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick90"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 12166) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick91"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 12249) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick92"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 12332) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick93"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 12415) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick94"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 12498) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick95"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 12581) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick96"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 12664) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick97"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 12747) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick98"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 12830) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick99"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 12913) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick100"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 13000) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick101"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 13133) {
                    xml?[0]["dashboard"]?["rpmTicks"]?["rpmTick102"]?.attributes["style"] = "display:inline"
                }
                //Needle
                if ((motorcycleData.getRPM() >= 0) && (motorcycleData.getRPM() <= 249)){
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle0"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 250) && (motorcycleData.getRPM() <= 499)){
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle1"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 500) && (motorcycleData.getRPM() <= 749)){
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle2"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 750) && (motorcycleData.getRPM() <= 999)){
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle3"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 1000) && (motorcycleData.getRPM() <= 1249)){
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle4"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 1250) && (motorcycleData.getRPM() <= 1499)){
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle5"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 1500) && (motorcycleData.getRPM() <= 1749)){
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle6"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 1750) && (motorcycleData.getRPM() <= 1999)){
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle7"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 2000) && (motorcycleData.getRPM() <= 2332)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle8"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 2333) && (motorcycleData.getRPM() <= 2665)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle9"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 2666) && (motorcycleData.getRPM() <= 2998)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle10"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 3000) && (motorcycleData.getRPM() <= 3249)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle11"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 3250) && (motorcycleData.getRPM() <= 3499)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle12"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 3500) && (motorcycleData.getRPM() <= 3749)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle13"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 3750) && (motorcycleData.getRPM() <= 3999)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle14"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 4000) && (motorcycleData.getRPM() <= 4499)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle15"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 4500) && (motorcycleData.getRPM() <= 4999)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle16"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 5000) && (motorcycleData.getRPM() <= 5499)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle17"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 5500) && (motorcycleData.getRPM() <= 5999)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle18"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 6000) && (motorcycleData.getRPM() <= 6499)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle19"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 6500) && (motorcycleData.getRPM() <= 6999)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle20"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 7000) && (motorcycleData.getRPM() <= 7499)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle21"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 7500) && (motorcycleData.getRPM() <= 8000)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle22"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 8001) && (motorcycleData.getRPM() <= 8124)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle23"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 8125) && (motorcycleData.getRPM() <= 8249)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle24"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 8250) && (motorcycleData.getRPM() <= 8374)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle25"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 8375) && (motorcycleData.getRPM() <= 8499)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle26"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 8500) && (motorcycleData.getRPM() <= 8674)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle27"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 8750) && (motorcycleData.getRPM() <= 8874)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle28"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 8875) && (motorcycleData.getRPM() <= 8999)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle29"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 9000) && (motorcycleData.getRPM() <= 9124)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle30"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 9125) && (motorcycleData.getRPM() <= 9249)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle31"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 9250) && (motorcycleData.getRPM() <= 9374)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle32"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 9375) && (motorcycleData.getRPM() <= 9499)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle33"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 9500) && (motorcycleData.getRPM() <= 9624)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle34"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 9625) && (motorcycleData.getRPM() <= 9749)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle35"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 9750) && (motorcycleData.getRPM() <= 9874)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle36"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 9875) && (motorcycleData.getRPM() <= 10000)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle37"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 10001) && (motorcycleData.getRPM() <= 10142)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle38"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 10143) && (motorcycleData.getRPM() <= 10285)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle39"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 10286) && (motorcycleData.getRPM() <= 10428)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle40"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 10429) && (motorcycleData.getRPM() <= 10571)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle41"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 10572) && (motorcycleData.getRPM() <= 10714)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle42"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 10715) && (motorcycleData.getRPM() <= 10857)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle43"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 10858) && (motorcycleData.getRPM() <= 10999)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle44"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 11000) && (motorcycleData.getRPM() <= 11142)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle45"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 11143) && (motorcycleData.getRPM() <= 11285)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle46"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 11286) && (motorcycleData.getRPM() <= 11428)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle47"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 11429) && (motorcycleData.getRPM() <= 11571)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle48"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 11572) && (motorcycleData.getRPM() <= 11714)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle49"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 11715) && (motorcycleData.getRPM() <= 11857)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle50"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 11858) && (motorcycleData.getRPM() <= 11999)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle51"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 12000) && (motorcycleData.getRPM() <= 12142)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle52"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 12143) && (motorcycleData.getRPM() <= 12285)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle53"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 12286) && (motorcycleData.getRPM() <= 12428)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle54"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 12429) && (motorcycleData.getRPM() <= 12571)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle55"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 12572) && (motorcycleData.getRPM() <= 12714)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle56"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 12715) && (motorcycleData.getRPM() <= 12857)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle57"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 12858) && (motorcycleData.getRPM() <= 12999)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle58"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 13000) && (motorcycleData.getRPM() <= 13285)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle59"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 13286) && (motorcycleData.getRPM() <= 13571)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle60"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 13572) && (motorcycleData.getRPM() <= 13857)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle61"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 13858) && (motorcycleData.getRPM() <= 14143)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle62"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 14144) && (motorcycleData.getRPM() <= 14429)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle63"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 14430) && (motorcycleData.getRPM() <= 14715)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle64"]?.attributes["style"] = "display:inline"
                }
                if ((motorcycleData.getRPM() >= 14716) && (motorcycleData.getRPM() <= 14999)) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle65"]?.attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 15000) {
                    xml?[0]["dashboard"]?["rpmNeedles"]?["rpmNeedle66"]?.attributes["style"] = "display:inline"
                }
            }
            break
        default:
            //15000
            NSLog("SportDashboard: Unknown or default RPM Setting for sport dashboard")
            break
        }
        
        return xml!
    }
}
