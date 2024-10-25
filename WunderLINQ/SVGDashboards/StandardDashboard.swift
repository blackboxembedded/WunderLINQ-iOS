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

class StandardDashboard {
    
    class func updateDashboard(_ infoLine: Int) -> XML{
        let motorcycleData = MotorcycleData.shared
        let faults = Faults.shared
        
        var temperatureUnit = "C"
        var distanceUnit = "km"
        var heightUnit = "m"
        var distanceTimeUnit = "KMH"
        var pressureUnit = "psi"

        
        //let url = Bundle.main.url(forResource: "standard-dashboard-portrait", withExtension: "svg")!
        let url = Bundle.main.url(forResource: "standard-dashboard", withExtension: "svg")!
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
            xml?[0]["dashboard"]?["values"]?["speed"]?.text = "\(Utils.toZeroDecimalString(speedValue!))"
        }
        if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
            distanceTimeUnit = "MPH"
        }
        xml?[0]["dashboard"]?["labels"]?["speedLabel"]?.text = distanceTimeUnit
        
        //Gear
        var gearValue = "-"
        if motorcycleData.gear != nil {
            gearValue = motorcycleData.getgear()
            if gearValue == "N"{
                let style = xml?[0]["dashboard"]?["values"]?["gear"]?.attributes["style"]
                let regex = try! NSRegularExpression(pattern: "fill:([^<]*);", options: NSRegularExpression.Options.caseInsensitive)
                let range = NSMakeRange(0, style!.count)
                let modString = regex.stringByReplacingMatches(in: style!, options: [], range: range, withTemplate: "fill:#03ae1e;")
                xml?[0]["dashboard"]?["values"]?["gear"]?.attributes["style"] = modString
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
                let regex = try! NSRegularExpression(pattern: "fill:([^<]*);", options: NSRegularExpression.Options.caseInsensitive)
                let range = NSMakeRange(0, style!.count)
                let modString = regex.stringByReplacingMatches(in: style!, options: [], range: range, withTemplate: "fill:#e20505;")
                xml?[0]["dashboard"]?["values"]?["engineTemp"]?.attributes["style"] = modString
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
                        let style = xml?[0]["dashboard"]?["values"]?["dataValue"]?.attributes["style"]
                        let regex = try! NSRegularExpression(pattern: "fill:([^<]*);", options: NSRegularExpression.Options.caseInsensitive)
                        let range = NSMakeRange(0, style!.count)
                        let modString = regex.stringByReplacingMatches(in: style!, options: [], range: range, withTemplate: "fill:#e20505;")
                        xml?[0]["dashboard"]?["values"]?["dataValue"]?.attributes["style"] = modString
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
        xml?[0]["dashboard"]?["values"]?["dataValue"]?.text = dataValue
        xml?[0]["dashboard"]?["labels"]?["dataLabel"]?.text = dataLabel
        
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
        
        // Front Tire Pressure
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
            rdcFValue = "\(Utils.toOneDecimalString(frontPressure))\(pressureUnit)"
        }
        xml?[0]["dashboard"]?["values"]?["rdcF"]?.text = rdcFValue
        
        if(faults.getFrontTirePressureCriticalActive()){
            let style = xml?[0]["dashboard"]?["values"]?["rdcF"]?.attributes["style"]
            let regex = try! NSRegularExpression(pattern: "fill:([^<]*);", options: NSRegularExpression.Options.caseInsensitive)
            let range = NSMakeRange(0, style!.count)
            let modString = regex.stringByReplacingMatches(in: style!, options: [], range: range, withTemplate: "fill:#e20505;")
            xml?[0]["dashboard"]?["values"]?["rdcF"]?.attributes["style"] = modString
        } else if(faults.getRearTirePressureWarningActive()){
            let style = xml?[0]["dashboard"]?["values"]?["rdcF"]?.attributes["style"]
            let regex = try! NSRegularExpression(pattern: "fill:([^<]*);", options: NSRegularExpression.Options.caseInsensitive)
            let range = NSMakeRange(0, style!.count)
            let modString = regex.stringByReplacingMatches(in: style!, options: [], range: range, withTemplate: "fill:#fcc914;")
            xml?[0]["dashboard"]?["values"]?["rdcF"]?.attributes["style"] = modString
        }
        
        // Rear Tire Pressure
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
            rdcRValue = "\(Utils.toOneDecimalString(rearPressure))\(pressureUnit)"
        }
        xml?[0]["dashboard"]?["values"]?["rdcR"]?.text = rdcRValue
        
        if(faults.getRearTirePressureCriticalActive()){
            let style = xml?[0]["dashboard"]?["values"]?["rdcR"]?.attributes["style"]
            let regex = try! NSRegularExpression(pattern: "fill:([^<]*);", options: NSRegularExpression.Options.caseInsensitive)
            let range = NSMakeRange(0, style!.count)
            let modString = regex.stringByReplacingMatches(in: style!, options: [], range: range, withTemplate: "fill:#e20505;")
            xml?[0]["dashboard"]?["values"]?["rdcR"]?.attributes["style"] = modString
        } else if(faults.getRearTirePressureWarningActive()){
            let style = xml?[0]["dashboard"]?["values"]?["rdcR"]?.attributes["style"]
            let regex = try! NSRegularExpression(pattern: "fill:([^<]*);", options: NSRegularExpression.Options.caseInsensitive)
            let range = NSMakeRange(0, style!.count)
            let modString = regex.stringByReplacingMatches(in: style!, options: [], range: range, withTemplate: "fill:#fcc914;")
            xml?[0]["dashboard"]?["values"]?["rdcR"]?.attributes["style"] = modString
        }
        
        //Trip Logging
        //xml![0][5][0].attributes["style"] = "display:inline"
        //Camera
        //xml![0][5][1].attributes["style"] = "display:inline"
        
        // Fault icon
        if(!faults.getallActiveDesc().isEmpty){
            xml?[0]["dashboard"]?["icons"]?["iconFault"]?.attributes["style"] = "display:inline"
        }
        
        //Fuel Icon
        if(faults.getFuelFaultActive()){
            xml?[0]["dashboard"]?["icons"]?["iconFuel"]?.attributes["style"] = "display:inline"
        }
        
        //RPM Digits
        switch UserDefaults.standard.integer(forKey: "max_rpm_preference"){
        case 0:
            //10000
            if (motorcycleData.rpm != nil){
                if (motorcycleData.getRPM() >= 333) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[1].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 666) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[2].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 1000) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[3].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 1333) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[4].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 1666) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[5].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 2000) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[6].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 2333) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[7].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 2666) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[8].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 3000) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[9].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 3333) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[10].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 3666) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[11].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 4000) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[12].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 4333) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[13].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 4666) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[14].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 5000) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[15].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 5333) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[16].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 5666) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[17].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 6000) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[18].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 6333) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[19].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 6666) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[20].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 7000) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[21].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 7333) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[22].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 7666) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[23].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 8000) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[24].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 8333) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[25].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 8666) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[26].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 9000) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[27].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 9333) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[28].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 9666) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[29].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 10000) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[30].attributes["style"] = "display:inline"
                }
            }
            break
        case 1:
            //12000
            xml?[0]["dashboard"]?["rpmGaugeBackground"]?["rpmGaugeDigits"]?["rpmDialDigit1"]?.text = "2"
            xml?[0]["dashboard"]?["rpmGaugeBackground"]?["rpmGaugeDigits"]?["rpmDialDigit2"]?.text = "4"
            xml?[0]["dashboard"]?["rpmGaugeBackground"]?["rpmGaugeDigits"]?["rpmDialDigit3"]?.text = "5"
            xml?[0]["dashboard"]?["rpmGaugeBackground"]?["rpmGaugeDigits"]?["rpmDialDigit4"]?.text = "6"
            xml?[0]["dashboard"]?["rpmGaugeBackground"]?["rpmGaugeDigits"]?["rpmDialDigit5"]?.text = "7"
            xml?[0]["dashboard"]?["rpmGaugeBackground"]?["rpmGaugeDigits"]?["rpmDialDigit6"]?.text = "8"
            xml?[0]["dashboard"]?["rpmGaugeBackground"]?["rpmGaugeDigits"]?["rpmDialDigit7"]?.text = "9"
            xml?[0]["dashboard"]?["rpmGaugeBackground"]?["rpmGaugeDigits"]?["rpmDialDigit8"]?.text = "10"
            xml?[0]["dashboard"]?["rpmGaugeBackground"]?["rpmGaugeDigits"]?["rpmDialDigit9"]?.text = "11"
            xml?[0]["dashboard"]?["rpmGaugeBackground"]?["rpmGaugeDigits"]?["rpmDialDigit10"]?.text = "12"
            
            if (motorcycleData.rpm != nil){
                if (motorcycleData.getRPM() >= 666) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[1].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 1333) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[2].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 2000) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[3].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 2666) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[4].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 3333) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[5].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 4000) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[6].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 4333) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[7].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 4666) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[8].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 5000) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[9].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 5333) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[10].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 5666) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[11].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 6000) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[12].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 6333) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[13].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 6666) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[14].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 7000) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[15].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 7333) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[16].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 7666) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[17].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 8000) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[18].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 8333) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[19].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 8666) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[20].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 9000) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[21].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 9333) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[22].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 9666) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[23].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 10000) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[24].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 10333) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[25].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 10666) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[26].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 11000) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[27].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 11333) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[28].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 11666) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[29].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 12000) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[30].attributes["style"] = "display:inline"
                }
            }
            break
        case 2:
            //15000
            xml?[0]["dashboard"]?["rpmGaugeBackground"]?["rpmGaugeDigits"]?["rpmDialDigit1"]?.text = "2"
            xml?[0]["dashboard"]?["rpmGaugeBackground"]?["rpmGaugeDigits"]?["rpmDialDigit2"]?.text = "4"
            xml?[0]["dashboard"]?["rpmGaugeBackground"]?["rpmGaugeDigits"]?["rpmDialDigit3"]?.text = "6"
            xml?[0]["dashboard"]?["rpmGaugeBackground"]?["rpmGaugeDigits"]?["rpmDialDigit4"]?.text = "8"
            xml?[0]["dashboard"]?["rpmGaugeBackground"]?["rpmGaugeDigits"]?["rpmDialDigit5"]?.text = "9"
            xml?[0]["dashboard"]?["rpmGaugeBackground"]?["rpmGaugeDigits"]?["rpmDialDigit6"]?.text = "10"
            xml?[0]["dashboard"]?["rpmGaugeBackground"]?["rpmGaugeDigits"]?["rpmDialDigit7"]?.text = "11"
            xml?[0]["dashboard"]?["rpmGaugeBackground"]?["rpmGaugeDigits"]?["rpmDialDigit8"]?.text = "12"
            xml?[0]["dashboard"]?["rpmGaugeBackground"]?["rpmGaugeDigits"]?["rpmDialDigit9"]?.text = "13"
            xml?[0]["dashboard"]?["rpmGaugeBackground"]?["rpmGaugeDigits"]?["rpmDialDigit10"]?.text = "15"
            
            if (motorcycleData.rpm != nil){
                if (motorcycleData.getRPM() >= 666) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[1].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 1333) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[2].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 2000) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[3].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 2666) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[4].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 3333) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[5].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 4000) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[6].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 4666) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[7].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 5333) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[8].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 6000) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[9].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 6666) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[10].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 7333) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[11].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 8000) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[12].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 8333) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[3].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 8666) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[14].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 9000) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[15].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 9333) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[16].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 9666) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[17].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 10000) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[18].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 10333) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[19].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 10666) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[20].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 11000) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[21].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 11333) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[22].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 11666) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[23].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 12000) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[24].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 12333) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[25].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 12666) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[26].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 13000) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[27].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 13666) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[28].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 14333) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[29].attributes["style"] = "display:inline"
                }
                if (motorcycleData.getRPM() >= 15000) {
                    xml?[0]["dashboard"]?["rpmTiles"]?[30].attributes["style"] = "display:inline"
                }
            }
            break
        default:
            NSLog("StandardDashboard: Unknown or default RPM Setting for standard dashboard")
            break
        }

        return xml!
    }
}
