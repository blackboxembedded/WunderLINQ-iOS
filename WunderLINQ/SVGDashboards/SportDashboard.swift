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

class SportDashboard {

    // Main function to update the dashboard
    class func updateDashboard(_ infoLine: Int, _ isPortrait: Bool, _ height: CGFloat, _ width: CGFloat) -> XMLNode? {
        
        let motorcycleData = MotorcycleData.shared
        let faults = Faults.shared
        
        var temperatureUnit = "C"
        var distanceUnit = "km"
        var heightUnit = "m"
        var distanceTimeUnit = "KMH"

        var dashboardSVG = "sport-dashboard"
        if isPortrait {
            dashboardSVG = dashboardSVG + "-portrait"
        }
        // Load the XML file from the project bundle
        guard let url = Bundle.main.url(forResource: dashboardSVG, withExtension: "svg"),
              let xml = XML(contentsOf: url) else {
            os_log("Error: Unable to load or parse the XML file.")
            return nil
        }
        
        if let svgTag = findElement(byID: "sport-dashboard", in: xml) {
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
            os_log("SportDashboard: Unknown speed unit setting")
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
        
        //Lean Angle
        if let angleTag = findElement(byID: "angle", in: xml) {
            if (motorcycleData.leanAngleBike != nil) {
                angleTag.text = "\(Utils.toZeroDecimalString(abs(motorcycleData.getleanAngleBike())))"
            } else if (motorcycleData.leanAngle != nil) {
                angleTag.text = "\(Utils.toZeroDecimalString(abs(motorcycleData.getleanAngle())))"
            }
        } else {
            os_log("angleTag not found.")
        }
        //Left Max Angle
        if let angleMaxLTag = findElement(byID: "angleMaxL", in: xml) {
            if (motorcycleData.leanAngleBikeMaxL != nil) {
                angleMaxLTag.text = "\(Utils.toZeroDecimalString(abs(motorcycleData.getleanAngleBikeMaxL())))"
            } else if (motorcycleData.leanAngleMaxL != nil) {
                angleMaxLTag.text = "\(Utils.toZeroDecimalString(abs(motorcycleData.getleanAngleMaxL())))"
            }
        } else {
            os_log("angleMaxLTag not found.")
        }
        //Right Max Angle
        if let angleMaxRTag = findElement(byID: "angleMaxR", in: xml) {
            if (motorcycleData.leanAngleBikeMaxR != nil) {
                angleMaxRTag.text = "\(Utils.toZeroDecimalString(abs(motorcycleData.getleanAngleBikeMaxR())))"
            } else if (motorcycleData.leanAngleMaxR != nil) {
                angleMaxRTag.text = "\(Utils.toZeroDecimalString(abs(motorcycleData.getleanAngleMaxR())))"
            }
        } else {
            os_log("angleMaxRTag not found.")
        }
        
        //Lean Angle Gauge
        var angle = "0"
        var centerRadius = ", 540, 1540)"
        if (isPortrait){
            centerRadius = ",540, 1540)"
        }
        if let needleTag = findElement(byID: "needle", in: xml) {
            if (motorcycleData.leanAngleBike != nil) {
                var leanAngle:Double = motorcycleData.leanAngleBike!
                if (leanAngle >  60) {
                    leanAngle = 60.0;
                } else if (leanAngle < -60) {
                    leanAngle = -60.0;
                }
                leanAngle *= 1.5
                angle = "\(leanAngle)"
            } else if (motorcycleData.leanAngle != nil) {
                var leanAngle:Double = motorcycleData.leanAngle!
                if (leanAngle >  60) {
                    leanAngle = 60.0;
                } else if (leanAngle < -60) {
                    leanAngle = -60.0;
                }
                leanAngle *= 1.5
                angle = "\(-leanAngle)"
            }
            needleTag.attributes["transform"] = "rotate(\(angle)\(centerRadius)"
        } else {
            os_log("needleTag not found.")
        }
        
        //RPM Display
        if let rpmTicksTag = findElement(byID: "rpmTicks", in: xml) {
            switch UserDefaults.standard.integer(forKey: "max_rpm_preference"){
            case 0:
                //10000
                if let rpmDialDigitsTag = findElement(byID: "rpmDialDigits", in: xml) {
                    rpmDialDigitsTag["rpmDialDigit1"]?.text = "2"
                    rpmDialDigitsTag["rpmDialDigit2"]?.text = "3"
                    rpmDialDigitsTag["rpmDialDigit3"]?.text = "4"
                    rpmDialDigitsTag["rpmDialDigit4"]?.text = "5"
                    rpmDialDigitsTag["rpmDialDigit5"]?.text = "6"
                    rpmDialDigitsTag["rpmDialDigit6"]?.text = "7"
                    rpmDialDigitsTag["rpmDialDigit7"]?.text = "8"
                    rpmDialDigitsTag["rpmDialDigit8"]?.text = "9"
                    rpmDialDigitsTag["rpmDialDigit9"]?.text = "10"
                }
                
                if (motorcycleData.rpm != nil) {
                    if (motorcycleData.getRPM() >= 0) {
                        
                        rpmTicksTag["rpmTick1"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 154) {
                        
                        rpmTicksTag["rpmTick2"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 308) {
                        
                        rpmTicksTag["rpmTick3"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 462) {
                        rpmTicksTag["rpmTick4"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 616) {
                        rpmTicksTag["rpmTick5"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 770) {
                        rpmTicksTag["rpmTick6"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 924) {
                        rpmTicksTag["rpmTick7"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 1078) {
                        rpmTicksTag["rpmTick8"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 1232) {
                        rpmTicksTag["rpmTick9"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 1386) {
                        rpmTicksTag["rpmTick10"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 1540) {
                        rpmTicksTag["rpmTick11"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 1694) {
                        rpmTicksTag["rpmTick12"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 1848) {
                        rpmTicksTag["rpmTick13"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 2000) {
                        rpmTicksTag["rpmTick14"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 2083) {
                        rpmTicksTag["rpmTick15"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 2167) {
                        rpmTicksTag["rpmTick16"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 2250) {
                        rpmTicksTag["rpmTick17"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 2334) {
                        rpmTicksTag["rpmTick18"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 2417) {
                        rpmTicksTag["rpmTick19"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 2501) {
                        rpmTicksTag["rpmTick20"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 2584) {
                        rpmTicksTag["rpmTick21"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 2668) {
                        rpmTicksTag["rpmTick22"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 2751) {
                        rpmTicksTag["rpmTick23"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 2835) {
                        rpmTicksTag["rpmTick24"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 2918) {
                        rpmTicksTag["rpmTick25"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 3000) {
                        rpmTicksTag["rpmTick26"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 3077) {
                        rpmTicksTag["rpmTick27"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 3154) {
                        rpmTicksTag["rpmTick28"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 3231) {
                        rpmTicksTag["rpmTick29"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 3308) {
                        rpmTicksTag["rpmTick30"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 3385) {
                        rpmTicksTag["rpmTick31"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 3462) {
                        rpmTicksTag["rpmTick32"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 3539) {
                        rpmTicksTag["rpmTick33"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 3616) {
                        rpmTicksTag["rpmTick34"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 3693) {
                        rpmTicksTag["rpmTick35"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 3770) {
                        rpmTicksTag["rpmTick36"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 3847) {
                        rpmTicksTag["rpmTick37"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 3924) {
                        rpmTicksTag["rpmTick38"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 4000) {
                        rpmTicksTag["rpmTick39"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 4077) {
                        rpmTicksTag["rpmTick40"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 4154) {
                        rpmTicksTag["rpmTick41"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 4231) {
                        rpmTicksTag["rpmTick42"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 4308) {
                        rpmTicksTag["rpmTick43"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 4385) {
                        rpmTicksTag["rpmTick44"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 4462) {
                        rpmTicksTag["rpmTick45"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 4539) {
                        rpmTicksTag["rpmTick46"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 4616) {
                        rpmTicksTag["rpmTick47"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 4693) {
                        rpmTicksTag["rpmTick48"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 4770) {
                        rpmTicksTag["rpmTick49"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 4847) {
                        rpmTicksTag["rpmTick50"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 4924) {
                        rpmTicksTag["rpmTick51"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 5000) {
                        rpmTicksTag["rpmTick52"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 5083) {
                        rpmTicksTag["rpmTick53"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 5166) {
                        rpmTicksTag["rpmTick54"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 5249) {
                        rpmTicksTag["rpmTick55"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 5332) {
                        rpmTicksTag["rpmTick56"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 5415) {
                        rpmTicksTag["rpmTick57"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 5498) {
                        rpmTicksTag["rpmTick58"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 5581) {
                        rpmTicksTag["rpmTick59"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 5664) {
                        rpmTicksTag["rpmTick60"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 5747) {
                        rpmTicksTag["rpmTick61"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 5830) {
                        rpmTicksTag["rpmTick62"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 5913) {
                        rpmTicksTag["rpmTick63"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 6000) {
                        rpmTicksTag["rpmTick64"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 6077) {
                        rpmTicksTag["rpmTick65"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 6154) {
                        rpmTicksTag["rpmTick66"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 6231) {
                        rpmTicksTag["rpmTick67"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 6308) {
                        rpmTicksTag["rpmTick68"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 6385) {
                        rpmTicksTag["rpmTick69"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 6462) {
                        rpmTicksTag["rpmTick70"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 6539) {
                        rpmTicksTag["rpmTick71"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 6616) {
                        rpmTicksTag["rpmTick72"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 6693) {
                        rpmTicksTag["rpmTick73"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 6770) {
                        rpmTicksTag["rpmTick74"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 6847) {
                        rpmTicksTag["rpmTick75"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 6924) {
                        rpmTicksTag["rpmTick76"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 7000) {
                        rpmTicksTag["rpmTick77"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 7083) {
                        rpmTicksTag["rpmTick78"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 7166) {
                        rpmTicksTag["rpmTick79"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 7249) {
                        rpmTicksTag["rpmTick80"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 7332) {
                        rpmTicksTag["rpmTick81"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 7415) {
                        rpmTicksTag["rpmTick82"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 7498) {
                        rpmTicksTag["rpmTick83"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 7581) {
                        rpmTicksTag["rpmTick84"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 7664) {
                        rpmTicksTag["rpmTick85"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 7747) {
                        rpmTicksTag["rpmTick86"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 7830) {
                        rpmTicksTag["rpmTick87"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 7913) {
                        rpmTicksTag["rpmTick88"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 8000) {
                        rpmTicksTag["rpmTick89"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 8083) {
                        rpmTicksTag["rpmTick90"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 8166) {
                        rpmTicksTag["rpmTick91"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 8249) {
                        rpmTicksTag["rpmTick92"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 8332) {
                        rpmTicksTag["rpmTick3"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 8415) {
                        rpmTicksTag["rpmTick94"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 8498) {
                        rpmTicksTag["rpmTick95"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 8581) {
                        rpmTicksTag["rpmTick96"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 8664) {
                        rpmTicksTag["rpmTick97"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 8747) {
                        rpmTicksTag["rpmTick98"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 8830) {
                        rpmTicksTag["rpmTick99"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 8913) {
                        rpmTicksTag["rpmTick100"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 9000) {
                        rpmTicksTag["rpmTick101"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 9066) {
                        rpmTicksTag["rpmTick102"]?.attributes["style"] = "display:inline"
                    }
                    // Needle
                    if let rpmNeedlesTag = findElement(byID: "rpmNeedles", in: xml) {
                        if ((motorcycleData.getRPM() >= 0) && (motorcycleData.getRPM() <= 249)){
                            rpmNeedlesTag["rpmNeedle0"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 250) && (motorcycleData.getRPM() <= 499)){
                            rpmNeedlesTag["rpmNeedle1"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 500) && (motorcycleData.getRPM() <= 749)){
                            rpmNeedlesTag["rpmNeedle2"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 750) && (motorcycleData.getRPM() <= 999)){
                            rpmNeedlesTag["rpmNeedle3"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 1000) && (motorcycleData.getRPM() <= 1249)){
                            rpmNeedlesTag["rpmNeedle4"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 1250) && (motorcycleData.getRPM() <= 1499)){
                            rpmNeedlesTag["rpmNeedle5"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 1500) && (motorcycleData.getRPM() <= 1749)){
                            rpmNeedlesTag["rpmNeedle6"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 1750) && (motorcycleData.getRPM() <= 1999)){
                            rpmNeedlesTag["rpmNeedle7"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 2000) && (motorcycleData.getRPM() <= 2166)) {
                            rpmNeedlesTag["rpmNeedle8"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 2167) && (motorcycleData.getRPM() <= 2332)) {
                            rpmNeedlesTag["rpmNeedle9"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 2333) && (motorcycleData.getRPM() <= 2499)) {
                            rpmNeedlesTag["rpmNeedle10"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 2500) && (motorcycleData.getRPM() <= 2600)) {
                            rpmNeedlesTag["rpmNeedle11"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 2601) && (motorcycleData.getRPM() <= 2700)) {
                            rpmNeedlesTag["rpmNeedle12"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 2701) && (motorcycleData.getRPM() <= 2800)) {
                            rpmNeedlesTag["rpmNeedle13"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 2801) && (motorcycleData.getRPM() <= 2900)) {
                            rpmNeedlesTag["rpmNeedle14"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 3000) && (motorcycleData.getRPM() <= 3166)) {
                            rpmNeedlesTag["rpmNeedle15"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 3167) && (motorcycleData.getRPM() <= 3332)) {
                            rpmNeedlesTag["rpmNeedle16"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 3333) && (motorcycleData.getRPM() <= 3499)) {
                            rpmNeedlesTag["rpmNeedle17"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 3500) && (motorcycleData.getRPM() <= 3600)) {
                            rpmNeedlesTag["rpmNeedle18"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 3601) && (motorcycleData.getRPM() <= 3700)) {
                            rpmNeedlesTag["rpmNeedle19"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 3701) && (motorcycleData.getRPM() <= 3800)) {
                            rpmNeedlesTag["rpmNeedle20"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 3801) && (motorcycleData.getRPM() <= 3900)) {
                            rpmNeedlesTag["rpmNeedle21"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 3901) && (motorcycleData.getRPM() <= 4000)) {
                            rpmNeedlesTag["rpmNeedle22"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 4001) && (motorcycleData.getRPM() <= 4124)) {
                            rpmNeedlesTag["rpmNeedle23"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 4125) && (motorcycleData.getRPM() <= 4249)) {
                            rpmNeedlesTag["rpmNeedle24"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 4250) && (motorcycleData.getRPM() <= 4374)) {
                            rpmNeedlesTag["rpmNeedle25"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 4375) && (motorcycleData.getRPM() <= 4499)) {
                            rpmNeedlesTag["rpmNeedle26"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 4500) && (motorcycleData.getRPM() <= 4674)) {
                            rpmNeedlesTag["rpmNeedle27"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 4750) && (motorcycleData.getRPM() <= 4874)) {
                            rpmNeedlesTag["rpmNeedle20"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 4875) && (motorcycleData.getRPM() <= 4999)) {
                            rpmNeedlesTag["rpmNeedle29"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 5000) && (motorcycleData.getRPM() <= 5124)) {
                            rpmNeedlesTag["rpmNeedle30"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 5125) && (motorcycleData.getRPM() <= 5249)) {
                            rpmNeedlesTag["rpmNeedle31"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 5250) && (motorcycleData.getRPM() <= 5374)) {
                            rpmNeedlesTag["rpmNeedle32"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 5375) && (motorcycleData.getRPM() <= 5499)) {
                            rpmNeedlesTag["rpmNeedle33"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 5500) && (motorcycleData.getRPM() <= 5624)) {
                            rpmNeedlesTag["rpmNeedle34"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 5625) && (motorcycleData.getRPM() <= 5749)) {
                            rpmNeedlesTag["rpmNeedle35"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 5750) && (motorcycleData.getRPM() <= 5874)) {
                            rpmNeedlesTag["rpmNeedle36"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 5875) && (motorcycleData.getRPM() <= 6000)) {
                            rpmNeedlesTag["rpmNeedle37"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 6001) && (motorcycleData.getRPM() <= 6142)) {
                            rpmNeedlesTag["rpmNeedle38"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 6143) && (motorcycleData.getRPM() <= 6285)) {
                            rpmNeedlesTag["rpmNeedle39"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 6286) && (motorcycleData.getRPM() <= 6428)) {
                            rpmNeedlesTag["rpmNeedle40"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 6429) && (motorcycleData.getRPM() <= 6571)) {
                            rpmNeedlesTag["rpmNeedle41"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 6572) && (motorcycleData.getRPM() <= 6714)) {
                            rpmNeedlesTag["rpmNeedle42"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 6715) && (motorcycleData.getRPM() <= 6857)) {
                            rpmNeedlesTag["rpmNeedle43"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 6858) && (motorcycleData.getRPM() <= 6999)) {
                            rpmNeedlesTag["rpmNeedle44"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 7000) && (motorcycleData.getRPM() <= 7142)) {
                            rpmNeedlesTag["rpmNeedle45"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 7143) && (motorcycleData.getRPM() <= 7285)) {
                            rpmNeedlesTag["rpmNeedle46"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 7286) && (motorcycleData.getRPM() <= 7428)) {
                            rpmNeedlesTag["rpmNeedle47"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 7429) && (motorcycleData.getRPM() <= 7571)) {
                            rpmNeedlesTag["rpmNeedle48"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 7572) && (motorcycleData.getRPM() <= 7714)) {
                            rpmNeedlesTag["rpmNeedle49"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 7715) && (motorcycleData.getRPM() <= 7857)) {
                            rpmNeedlesTag["rpmNeedle50"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 7858) && (motorcycleData.getRPM() <= 7999)) {
                            rpmNeedlesTag["rpmNeedle51"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 8000) && (motorcycleData.getRPM() <= 8142)) {
                            rpmNeedlesTag["rpmNeedle52"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 8143) && (motorcycleData.getRPM() <= 8285)) {
                            rpmNeedlesTag["rpmNeedle53"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 8286) && (motorcycleData.getRPM() <= 8428)) {
                            rpmNeedlesTag["rpmNeedle54"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 8429) && (motorcycleData.getRPM() <= 8571)) {
                            rpmNeedlesTag["rpmNeedle55"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 8572) && (motorcycleData.getRPM() <= 8714)) {
                            rpmNeedlesTag["rpmNeedle56"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 8715) && (motorcycleData.getRPM() <= 8857)) {
                            rpmNeedlesTag["rpmNeedle57"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 8858) && (motorcycleData.getRPM() <= 8999)) {
                            rpmNeedlesTag["rpmNeedle58"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 9000) && (motorcycleData.getRPM() <= 9143)) {
                            rpmNeedlesTag["rpmNeedle59"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 9144) && (motorcycleData.getRPM() <= 9287)) {
                            rpmNeedlesTag["rpmNeedle60"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 9288) && (motorcycleData.getRPM() <= 9431)) {
                            rpmNeedlesTag["rpmNeedle61"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 9432) && (motorcycleData.getRPM() <= 9575)) {
                            rpmNeedlesTag["rpmNeedle62"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 9576) && (motorcycleData.getRPM() <= 9719)) {
                            rpmNeedlesTag["rpmNeedle63"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 9720) && (motorcycleData.getRPM() <= 9863)) {
                            rpmNeedlesTag["rpmNeedle64"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 9864) && (motorcycleData.getRPM() <= 9999)) {
                            rpmNeedlesTag["rpmNeedle65"]?.attributes["style"] = "display:inline"
                        }
                        if (motorcycleData.getRPM() >= 10000) {
                            rpmNeedlesTag["rpmNeedle66"]?.attributes["style"] = "display:inline"
                        }
                    }
                }
                break
            case 1:
                //12000
                if let rpmDialDigitsTag = findElement(byID: "rpmDialDigits", in: xml) {
                    rpmDialDigitsTag["rpmDialDigit1"]?.text = "2"
                    rpmDialDigitsTag["rpmDialDigit2"]?.text = "4"
                    rpmDialDigitsTag["rpmDialDigit3"]?.text = "6"
                    rpmDialDigitsTag["rpmDialDigit4"]?.text = "7"
                    rpmDialDigitsTag["rpmDialDigit5"]?.text = "8"
                    rpmDialDigitsTag["rpmDialDigit6"]?.text = "9"
                    rpmDialDigitsTag["rpmDialDigit7"]?.text = "10"
                    rpmDialDigitsTag["rpmDialDigit8"]?.text = "11"
                    rpmDialDigitsTag["rpmDialDigit9"]?.text = "12"
                }
                
                if (motorcycleData.rpm != nil) {
                    if (motorcycleData.getRPM() >= 0) {
                        rpmTicksTag["rpmTick1"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 154) {
                        rpmTicksTag["rpmTick2"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 308) {
                        rpmTicksTag["rpmTicks3"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 462) {
                        rpmTicksTag["rpmTick4"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 616) {
                        rpmTicksTag["rpmTick5"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 770) {
                        rpmTicksTag["rpmTick6"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 924) {
                        rpmTicksTag["rpmTick7"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 1078) {
                        rpmTicksTag["rpmTick8"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 1232) {
                        rpmTicksTag["rpmTic9"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 1386) {
                        rpmTicksTag["rpmTick10"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 1540) {
                        rpmTicksTag["rpmTick11"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 1694) {
                        rpmTicksTag["rpmTick12"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 1848) {
                        rpmTicksTag["rpmTick13"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 2000) {
                        rpmTicksTag["rpmTick14"]?.attributes["style"] = "display:inline"
                    }
                    
                    if (motorcycleData.getRPM() >= 2167) {
                        rpmTicksTag["rpmTick15"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 2167) {
                        rpmTicksTag["rpmTick16"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 2334) {
                        rpmTicksTag["rpmTick17"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 2501) {
                        rpmTicksTag["rpmTick18"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 2668) {
                        rpmTicksTag["rpmTick19"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 2835) {
                        rpmTicksTag["rpmTick20"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 3002) {
                        rpmTicksTag["rpmTick21"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 3169) {
                        rpmTicksTag["rpmTick22"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 3503) {
                        rpmTicksTag["rpmTick23"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 3670) {
                        rpmTicksTag["rpmTick24"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 3837) {
                        rpmTicksTag["rpmTick25"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 4000) {
                        rpmTicksTag["rpmTick26"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 4154) {
                        rpmTicksTag["rpmTick27"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 4308) {
                        rpmTicksTag["rpmTick28"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 4462) {
                        rpmTicksTag["rpmTick29"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 4616) {
                        rpmTicksTag["rpmTick30"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 4770) {
                        rpmTicksTag["rpmTick31"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 4924) {
                        rpmTicksTag["rpmTick32"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 5078) {
                        rpmTicksTag["rpmTick33"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 5232) {
                        rpmTicksTag["rpmTick34"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 5386) {
                        rpmTicksTag["rpmTick35"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 5540) {
                        rpmTicksTag["rpmTick36"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 5694) {
                        rpmTicksTag["rpmTick37"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 5848) {
                        rpmTicksTag["rpmTick38"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 6000) {
                        rpmTicksTag["rpmTick39"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 6077) {
                        rpmTicksTag["rpmTick40"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 6154) {
                        rpmTicksTag["rpmTick41"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 6231) {
                        rpmTicksTag["rpmTick42"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 6308) {
                        rpmTicksTag["rpmTick43"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 6385) {
                        rpmTicksTag["rpmTick44"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 6462) {
                        rpmTicksTag["rpmTick45"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 6539) {
                        rpmTicksTag["rpmTick46"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 6616) {
                        rpmTicksTag["rpmTick47"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 6693) {
                        rpmTicksTag["rpmTick48"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 6770) {
                        rpmTicksTag["rpmTick49"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 6847) {
                        rpmTicksTag["rpmTick50"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 6924) {
                        rpmTicksTag["rpmTick51"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 7000) {
                        rpmTicksTag["rpmTick52"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 7083) {
                        rpmTicksTag["rpmTick53"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 7166) {
                        rpmTicksTag["rpmTick54"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 7249) {
                        rpmTicksTag["rpmTick55"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 7332) {
                        rpmTicksTag["rpmTick56"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 7415) {
                        rpmTicksTag["rpmTick57"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 7498) {
                        rpmTicksTag["rpmTick58"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 7581) {
                        rpmTicksTag["rpmTick59"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 7664) {
                        rpmTicksTag["rpmTick60"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 7747) {
                        rpmTicksTag["rpmTick61"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 7830) {
                        rpmTicksTag["rpmTick62"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 7913) {
                        rpmTicksTag["rpmTick63"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 8000) {
                        rpmTicksTag["rpmTick64"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 8077) {
                        rpmTicksTag["rpmTick65"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 8154) {
                        rpmTicksTag["rpmTick66"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 8231) {
                        rpmTicksTag["rpmTick67"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 8308) {
                        rpmTicksTag["rpmTick68"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 8385) {
                        rpmTicksTag["rpmTick69"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 8462) {
                        rpmTicksTag["rpmTick70"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 8539) {
                        rpmTicksTag["rpmTick71"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 8616) {
                        rpmTicksTag["rpmTick72"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 8693) {
                        rpmTicksTag["rpmTick73"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 8770) {
                        rpmTicksTag["rpmTick74"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 8847) {
                        rpmTicksTag["rpmTick75"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 8924) {
                        rpmTicksTag["rpmTick76"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 9000) {
                        rpmTicksTag["rpmTick77"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 9083) {
                        rpmTicksTag["rpmTick78"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 9166) {
                        rpmTicksTag["rpmTick79"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 9249) {
                        rpmTicksTag["rpmTick80"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 9332) {
                        rpmTicksTag["rpmTick81"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 9415) {
                        rpmTicksTag["rpmTick82"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 9498) {
                        rpmTicksTag["rpmTick83"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 9581) {
                        rpmTicksTag["rpmTick84"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 9664) {
                        rpmTicksTag["rpmTick85"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 9747) {
                        rpmTicksTag["rpmTick86"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 9830) {
                        rpmTicksTag["rpmTick87"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 9913) {
                        rpmTicksTag["rpmTick88"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 10000) {
                        rpmTicksTag["rpmTick89"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 10083) {
                        rpmTicksTag["rpmTick90"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 10166) {
                        rpmTicksTag["rpmTick91"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 10249) {
                        rpmTicksTag["rpmTick92"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 10332) {
                        rpmTicksTag["rpmTick93"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 10415) {
                        rpmTicksTag["rpmTick94"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 10498) {
                        rpmTicksTag["rpmTick95"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 10581) {
                        rpmTicksTag["rpmTick96"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 10664) {
                        rpmTicksTag["rpmTick97"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 10747) {
                        rpmTicksTag["rpmTick98"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 10830) {
                        rpmTicksTag["rpmTick99"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 10913) {
                        rpmTicksTag["rpmTick100"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 11000) {
                        rpmTicksTag["rpmTick101"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 11066) {
                        rpmTicksTag["rpmTick101"]?.attributes["style"] = "display:inline"
                    }
                    // Needle
                    if let rpmNeedlesTag = findElement(byID: "rpmNeedles", in: xml) {
                        if ((motorcycleData.getRPM() >= 0) && (motorcycleData.getRPM() <= 249)){
                            rpmNeedlesTag["rpmNeedle0"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 250) && (motorcycleData.getRPM() <= 499)){
                            rpmNeedlesTag["rpmNeedle1"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 500) && (motorcycleData.getRPM() <= 749)){
                            rpmNeedlesTag["rpmNeedle2"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 750) && (motorcycleData.getRPM() <= 999)){
                            rpmNeedlesTag["rpmNeedle3"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 1000) && (motorcycleData.getRPM() <= 1249)){
                            rpmNeedlesTag["rpmNeedle4"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 1250) && (motorcycleData.getRPM() <= 1499)){
                            rpmNeedlesTag["rpmNeedle5"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 1500) && (motorcycleData.getRPM() <= 1749)){
                            rpmNeedlesTag["rpmNeedle6"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 1750) && (motorcycleData.getRPM() <= 1999)){
                            rpmNeedlesTag["rpmNeedle7"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 2000) && (motorcycleData.getRPM() <= 2286)) {
                            rpmNeedlesTag["rpmNeedle8"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 2287) && (motorcycleData.getRPM() <= 2573)) {
                            rpmNeedlesTag["rpmNeedle9"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 2574) && (motorcycleData.getRPM() <= 2860)) {
                            rpmNeedlesTag["rpmNeedle10"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 2861) && (motorcycleData.getRPM() <= 3147)) {
                            rpmNeedlesTag["rpmNeedle11"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 3148) && (motorcycleData.getRPM() <= 3434)) {
                            rpmNeedlesTag["rpmNeedle12"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 3435) && (motorcycleData.getRPM() <= 3721)) {
                            rpmNeedlesTag["rpmNeedle13"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 3722) && (motorcycleData.getRPM() <= 3999)) {
                            rpmNeedlesTag["rpmNeedle14"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 4000) && (motorcycleData.getRPM() <= 4249)) {
                            rpmNeedlesTag["rpmNeedle15"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 4250) && (motorcycleData.getRPM() <= 4499)) {
                            rpmNeedlesTag["rpmNeedle16"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 4500) && (motorcycleData.getRPM() <= 4749)) {
                            rpmNeedlesTag["rpmNeedle17"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 4750) && (motorcycleData.getRPM() <= 4999)) {
                            rpmNeedlesTag["rpmNeedle18"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 5000) && (motorcycleData.getRPM() <= 5249)) {
                            rpmNeedlesTag["rpmNeedle19"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 5250) && (motorcycleData.getRPM() <= 5499)) {
                            rpmNeedlesTag["rpmNeedle20"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 5500) && (motorcycleData.getRPM() <= 5749)) {
                            rpmNeedlesTag["rpmNeedle21"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 5750) && (motorcycleData.getRPM() <= 6000)) {
                            rpmNeedlesTag["rpmNeedle22"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 6001) && (motorcycleData.getRPM() <= 6124)) {
                            rpmNeedlesTag["rpmNeedle23"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 6125) && (motorcycleData.getRPM() <= 6249)) {
                            rpmNeedlesTag["rpmNeedle24"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 6250) && (motorcycleData.getRPM() <= 6374)) {
                            rpmNeedlesTag["rpmNeedle25"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 6375) && (motorcycleData.getRPM() <= 6499)) {
                            rpmNeedlesTag["rpmNeedle26"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 6500) && (motorcycleData.getRPM() <= 6674)) {
                            rpmNeedlesTag["rpmNeedle27"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 6750) && (motorcycleData.getRPM() <= 6874)) {
                            rpmNeedlesTag["rpmNeedle28"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 6875) && (motorcycleData.getRPM() <= 6999)) {
                            rpmNeedlesTag["rpmNeedle29"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 7000) && (motorcycleData.getRPM() <= 7124)) {
                            rpmNeedlesTag["rpmNeedle30"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 7125) && (motorcycleData.getRPM() <= 7249)) {
                            rpmNeedlesTag["rpmNeedle31"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 7250) && (motorcycleData.getRPM() <= 7374)) {
                            rpmNeedlesTag["rpmNeedle32"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 7375) && (motorcycleData.getRPM() <= 7499)) {
                            rpmNeedlesTag["rpmNeedle33"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 7500) && (motorcycleData.getRPM() <= 7624)) {
                            rpmNeedlesTag["rpmNeedle34"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 7625) && (motorcycleData.getRPM() <= 7749)) {
                            rpmNeedlesTag["rpmNeedle35"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 7750) && (motorcycleData.getRPM() <= 7874)) {
                            rpmNeedlesTag["rpmNeedle36"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 7875) && (motorcycleData.getRPM() <= 8000)) {
                            rpmNeedlesTag["rpmNeedle37"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 8001) && (motorcycleData.getRPM() <= 6142)) {
                            rpmNeedlesTag["rpmNeedle38"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 6143) && (motorcycleData.getRPM() <= 6285)) {
                            rpmNeedlesTag["rpmNeedle39"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 6286) && (motorcycleData.getRPM() <= 6428)) {
                            rpmNeedlesTag["rpmNeedle40"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 6429) && (motorcycleData.getRPM() <= 6571)) {
                            rpmNeedlesTag["rpmNeedle41"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 6572) && (motorcycleData.getRPM() <= 6714)) {
                            rpmNeedlesTag["rpmNeedle42"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 6715) && (motorcycleData.getRPM() <= 6857)) {
                            rpmNeedlesTag["rpmNeedle43"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 6858) && (motorcycleData.getRPM() <= 6999)) {
                            rpmNeedlesTag["rpmNeedle44"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 9000) && (motorcycleData.getRPM() <= 9142)) {
                            rpmNeedlesTag["rpmNeedle45"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 9143) && (motorcycleData.getRPM() <= 9285)) {
                            rpmNeedlesTag["rpmNeedle46"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 9286) && (motorcycleData.getRPM() <= 9428)) {
                            rpmNeedlesTag["rpmNeedle47"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 9429) && (motorcycleData.getRPM() <= 9571)) {
                            rpmNeedlesTag["rpmNeedle48"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 9572) && (motorcycleData.getRPM() <= 9714)) {
                            rpmNeedlesTag["rpmNeedle49"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 9715) && (motorcycleData.getRPM() <= 9857)) {
                            rpmNeedlesTag["rpmNeedle50"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 9858) && (motorcycleData.getRPM() <= 9999)) {
                            rpmNeedlesTag["rpmNeedle51"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 10000) && (motorcycleData.getRPM() <= 10142)) {
                            rpmNeedlesTag["rpmNeedle52"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 10143) && (motorcycleData.getRPM() <= 10285)) {
                            rpmNeedlesTag["rpmNeedle53"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 10286) && (motorcycleData.getRPM() <= 10428)) {
                            rpmNeedlesTag["rpmNeedle54"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 10429) && (motorcycleData.getRPM() <= 10571)) {
                            rpmNeedlesTag["rpmNeedle55"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 10572) && (motorcycleData.getRPM() <= 10714)) {
                            rpmNeedlesTag["rpmNeedle56"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 10715) && (motorcycleData.getRPM() <= 10857)) {
                            rpmNeedlesTag["rpmNeedle57"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 10858) && (motorcycleData.getRPM() <= 10999)) {
                            rpmNeedlesTag["rpmNeedle58"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 11000) && (motorcycleData.getRPM() <= 11143)) {
                            rpmNeedlesTag["rpmNeedle59"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 11144) && (motorcycleData.getRPM() <= 11287)) {
                            rpmNeedlesTag["rpmNeedle60"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 11288) && (motorcycleData.getRPM() <= 11431)) {
                            rpmNeedlesTag["rpmNeedle61"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 11432) && (motorcycleData.getRPM() <= 11575)) {
                            rpmNeedlesTag["rpmNeedle62"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 11576) && (motorcycleData.getRPM() <= 11719)) {
                            rpmNeedlesTag["rpmNeedle63"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 11720) && (motorcycleData.getRPM() <= 11863)) {
                            rpmNeedlesTag["rpmNeedle64"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 11864) && (motorcycleData.getRPM() <= 11999)) {
                            rpmNeedlesTag["rpmNeedle65"]?.attributes["style"] = "display:inline"
                        }
                        if (motorcycleData.getRPM() >= 12000) {
                            rpmNeedlesTag["rpmNeedle66"]?.attributes["style"] = "display:inline"
                        }
                    }
                }
                break
            case 2:
                //15000
                if (motorcycleData.rpm != nil) {
                    if (motorcycleData.getRPM() >= 0) {
                        rpmTicksTag["rpmTick1"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 154) {
                        rpmTicksTag["rpmTick2"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 308) {
                        rpmTicksTag["rpmTick3"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 462) {
                        rpmTicksTag["rpmTick4"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 616) {
                        rpmTicksTag["rpmTick5"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 770) {
                        rpmTicksTag["rpmTick6"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 924) {
                        rpmTicksTag["rpmTick7"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 1078) {
                        rpmTicksTag["rpmTick8"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 1232) {
                        rpmTicksTag["rpmTick9"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 1386) {
                        rpmTicksTag["rpmTick10"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 1540) {
                        rpmTicksTag["rpmTick11"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 1694) {
                        rpmTicksTag["rpmTick12"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 1848) {
                        rpmTicksTag["rpmTick13"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 2000) {
                        rpmTicksTag["rpmTick14"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 2167) {
                        rpmTicksTag["rpmTick15"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 2334) {
                        rpmTicksTag["rpmTick16"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 2501) {
                        rpmTicksTag["rpmTick17"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 2668) {
                        rpmTicksTag["rpmTick18"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 2835) {
                        rpmTicksTag["rpmTick19"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 3002) {
                        rpmTicksTag["rpmTick20"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 3169) {
                        rpmTicksTag["rpmTick21"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 3336) {
                        rpmTicksTag["rpmTick22"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 3503) {
                        rpmTicksTag["rpmTick23"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 3670) {
                        rpmTicksTag["rpmTick24"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 3837) {
                        rpmTicksTag["rpmTick25"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 4000) {
                        rpmTicksTag["rpmTick26"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 4308) {
                        rpmTicksTag["rpmTick27"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 4616) {
                        rpmTicksTag["rpmTick28"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 4924) {
                        rpmTicksTag["rpmTick29"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 5232) {
                        rpmTicksTag["rpmTick30"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 5540) {
                        rpmTicksTag["rpmTick31"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 5848) {
                        rpmTicksTag["rpmTick32"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 6156) {
                        rpmTicksTag["rpmTick33"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 6464) {
                        rpmTicksTag["rpmTick34"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 6772) {
                        rpmTicksTag["rpmTick35"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 7080) {
                        rpmTicksTag["rpmTick36"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 7388) {
                        rpmTicksTag["rpmTick37"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 7696) {
                        rpmTicksTag["rpmTick38"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 8000) {
                        rpmTicksTag["rpmTick39"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 8077) {
                        rpmTicksTag["rpmTick40"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 8154) {
                        rpmTicksTag["rpmTick41"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 8231) {
                        rpmTicksTag["rpmTick42"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 8308) {
                        rpmTicksTag["rpmTick43"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 8385) {
                        rpmTicksTag["rpmTick44"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 8462) {
                        rpmTicksTag["rpmTick45"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 8539) {
                        rpmTicksTag["rpmTick46"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 8616) {
                        rpmTicksTag["rpmTick47"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 8693) {
                        rpmTicksTag["rpmTick48"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 8770) {
                        rpmTicksTag["rpmTick49"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 8847) {
                        rpmTicksTag["rpmTick50"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 8924) {
                        rpmTicksTag["rpmTick51"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 9000) {
                        rpmTicksTag["rpmTick52"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 9083) {
                        rpmTicksTag["rpmTick53"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 9166) {
                        rpmTicksTag["rpmTick54"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 9249) {
                        rpmTicksTag["rpmTick55"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 9332) {
                        rpmTicksTag["rpmTick56"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 9415) {
                        rpmTicksTag["rpmTick57"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 9498) {
                        rpmTicksTag["rpmTick58"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 9581) {
                        rpmTicksTag["rpmTick59"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 9664) {
                        rpmTicksTag["rpmTick60"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 9747) {
                        rpmTicksTag["rpmTick61"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 9830) {
                        rpmTicksTag["rpmTick62"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 9913) {
                        rpmTicksTag["rpmTick63"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 10000) {
                        rpmTicksTag["rpmTick64"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 10077) {
                        rpmTicksTag["rpmTick65"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 10154) {
                        rpmTicksTag["rpmTick66"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 10231) {
                        rpmTicksTag["rpmTick67"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 10308) {
                        rpmTicksTag["rpmTick68"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 10385) {
                        rpmTicksTag["rpmTick69"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 10462) {
                        rpmTicksTag["rpmTick70"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 10539) {
                        rpmTicksTag["rpmTick71"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 10616) {
                        rpmTicksTag["rpmTick72"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 10693) {
                        rpmTicksTag["rpmTick73"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 10770) {
                        rpmTicksTag["rpmTick74"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 10847) {
                        rpmTicksTag["rpmTick75"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 10924) {
                        rpmTicksTag["rpmTick76"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 11000) {
                        rpmTicksTag["rpmTick77"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 11083) {
                        rpmTicksTag["rpmTick78"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 11166) {
                        rpmTicksTag["rpmTick79"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 11249) {
                        rpmTicksTag["rpmTick80"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 11332) {
                        rpmTicksTag["rpmTick81"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 11415) {
                        rpmTicksTag["rpmTick82"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 11498) {
                        rpmTicksTag["rpmTick83"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 11581) {
                        rpmTicksTag["rpmTick84"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 11664) {
                        rpmTicksTag["rpmTick85"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 11747) {
                        rpmTicksTag["rpmTick86"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 11830) {
                        rpmTicksTag["rpmTick87"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 11913) {
                        rpmTicksTag["rpmTick88"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 12000) {
                        rpmTicksTag["rpmTick89"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 12083) {
                        rpmTicksTag["rpmTick90"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 12166) {
                        rpmTicksTag["rpmTick91"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 12249) {
                        rpmTicksTag["rpmTick92"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 12332) {
                        rpmTicksTag["rpmTick93"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 12415) {
                        rpmTicksTag["rpmTick94"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 12498) {
                        rpmTicksTag["rpmTick95"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 12581) {
                        rpmTicksTag["rpmTick96"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 12664) {
                        rpmTicksTag["rpmTick97"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 12747) {
                        rpmTicksTag["rpmTick98"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 12830) {
                        rpmTicksTag["rpmTick99"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 12913) {
                        rpmTicksTag["rpmTick100"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 13000) {
                        rpmTicksTag["rpmTick101"]?.attributes["style"] = "display:inline"
                    }
                    if (motorcycleData.getRPM() >= 13133) {
                        rpmTicksTag["rpmTick102"]?.attributes["style"] = "display:inline"
                    }
                    //Needle
                    if let rpmNeedlesTag = findElement(byID: "rpmNeedles", in: xml) {
                        if ((motorcycleData.getRPM() >= 0) && (motorcycleData.getRPM() <= 249)){
                            rpmNeedlesTag["rpmNeedle0"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 250) && (motorcycleData.getRPM() <= 499)){
                            rpmNeedlesTag["rpmNeedle1"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 500) && (motorcycleData.getRPM() <= 749)){
                            rpmNeedlesTag["rpmNeedle2"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 750) && (motorcycleData.getRPM() <= 999)){
                            rpmNeedlesTag["rpmNeedle3"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 1000) && (motorcycleData.getRPM() <= 1249)){
                            rpmNeedlesTag["rpmNeedle4"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 1250) && (motorcycleData.getRPM() <= 1499)){
                            rpmNeedlesTag["rpmNeedle5"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 1500) && (motorcycleData.getRPM() <= 1749)){
                            rpmNeedlesTag["rpmNeedle6"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 1750) && (motorcycleData.getRPM() <= 1999)){
                            rpmNeedlesTag["rpmNeedle7"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 2000) && (motorcycleData.getRPM() <= 2332)) {
                            rpmNeedlesTag["rpmNeedle8"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 2333) && (motorcycleData.getRPM() <= 2665)) {
                            rpmNeedlesTag["rpmNeedle9"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 2666) && (motorcycleData.getRPM() <= 2998)) {
                            rpmNeedlesTag["rpmNeedle10"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 3000) && (motorcycleData.getRPM() <= 3249)) {
                            rpmNeedlesTag["rpmNeedle11"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 3250) && (motorcycleData.getRPM() <= 3499)) {
                            rpmNeedlesTag["rpmNeedle12"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 3500) && (motorcycleData.getRPM() <= 3749)) {
                            rpmNeedlesTag["rpmNeedle13"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 3750) && (motorcycleData.getRPM() <= 3999)) {
                            rpmNeedlesTag["rpmNeedle14"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 4000) && (motorcycleData.getRPM() <= 4499)) {
                            rpmNeedlesTag["rpmNeedle15"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 4500) && (motorcycleData.getRPM() <= 4999)) {
                            rpmNeedlesTag["rpmNeedle16"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 5000) && (motorcycleData.getRPM() <= 5499)) {
                            rpmNeedlesTag["rpmNeedle17"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 5500) && (motorcycleData.getRPM() <= 5999)) {
                            rpmNeedlesTag["rpmNeedle18"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 6000) && (motorcycleData.getRPM() <= 6499)) {
                            rpmNeedlesTag["rpmNeedle19"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 6500) && (motorcycleData.getRPM() <= 6999)) {
                            rpmNeedlesTag["rpmNeedle20"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 7000) && (motorcycleData.getRPM() <= 7499)) {
                            rpmNeedlesTag["rpmNeedle21"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 7500) && (motorcycleData.getRPM() <= 8000)) {
                            rpmNeedlesTag["rpmNeedle22"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 8001) && (motorcycleData.getRPM() <= 8124)) {
                            rpmNeedlesTag["rpmNeedle23"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 8125) && (motorcycleData.getRPM() <= 8249)) {
                            rpmNeedlesTag["rpmNeedle24"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 8250) && (motorcycleData.getRPM() <= 8374)) {
                            rpmNeedlesTag["rpmNeedle25"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 8375) && (motorcycleData.getRPM() <= 8499)) {
                            rpmNeedlesTag["rpmNeedle26"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 8500) && (motorcycleData.getRPM() <= 8674)) {
                            rpmNeedlesTag["rpmNeedle27"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 8750) && (motorcycleData.getRPM() <= 8874)) {
                            rpmNeedlesTag["rpmNeedle28"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 8875) && (motorcycleData.getRPM() <= 8999)) {
                            rpmNeedlesTag["rpmNeedle29"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 9000) && (motorcycleData.getRPM() <= 9124)) {
                            rpmNeedlesTag["rpmNeedle30"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 9125) && (motorcycleData.getRPM() <= 9249)) {
                            rpmNeedlesTag["rpmNeedle31"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 9250) && (motorcycleData.getRPM() <= 9374)) {
                            rpmNeedlesTag["rpmNeedle32"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 9375) && (motorcycleData.getRPM() <= 9499)) {
                            rpmNeedlesTag["rpmNeedle33"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 9500) && (motorcycleData.getRPM() <= 9624)) {
                            rpmNeedlesTag["rpmNeedle34"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 9625) && (motorcycleData.getRPM() <= 9749)) {
                            rpmNeedlesTag["rpmNeedle35"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 9750) && (motorcycleData.getRPM() <= 9874)) {
                            rpmNeedlesTag["rpmNeedle36"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 9875) && (motorcycleData.getRPM() <= 10000)) {
                            rpmNeedlesTag["rpmNeedle37"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 10001) && (motorcycleData.getRPM() <= 10142)) {
                            rpmNeedlesTag["rpmNeedle38"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 10143) && (motorcycleData.getRPM() <= 10285)) {
                            rpmNeedlesTag["rpmNeedle39"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 10286) && (motorcycleData.getRPM() <= 10428)) {
                            rpmNeedlesTag["rpmNeedle40"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 10429) && (motorcycleData.getRPM() <= 10571)) {
                            rpmNeedlesTag["rpmNeedle41"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 10572) && (motorcycleData.getRPM() <= 10714)) {
                            rpmNeedlesTag["rpmNeedle42"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 10715) && (motorcycleData.getRPM() <= 10857)) {
                            rpmNeedlesTag["rpmNeedle43"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 10858) && (motorcycleData.getRPM() <= 10999)) {
                            rpmNeedlesTag["rpmNeedle44"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 11000) && (motorcycleData.getRPM() <= 11142)) {
                            rpmNeedlesTag["rpmNeedle45"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 11143) && (motorcycleData.getRPM() <= 11285)) {
                            rpmNeedlesTag["rpmNeedle46"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 11286) && (motorcycleData.getRPM() <= 11428)) {
                            rpmNeedlesTag["rpmNeedle47"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 11429) && (motorcycleData.getRPM() <= 11571)) {
                            rpmNeedlesTag["rpmNeedle48"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 11572) && (motorcycleData.getRPM() <= 11714)) {
                            rpmNeedlesTag["rpmNeedle49"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 11715) && (motorcycleData.getRPM() <= 11857)) {
                            rpmNeedlesTag["rpmNeedle50"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 11858) && (motorcycleData.getRPM() <= 11999)) {
                            rpmNeedlesTag["rpmNeedle51"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 12000) && (motorcycleData.getRPM() <= 12142)) {
                            rpmNeedlesTag["rpmNeedle52"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 12143) && (motorcycleData.getRPM() <= 12285)) {
                            rpmNeedlesTag["rpmNeedle53"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 12286) && (motorcycleData.getRPM() <= 12428)) {
                            rpmNeedlesTag["rpmNeedle54"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 12429) && (motorcycleData.getRPM() <= 12571)) {
                            rpmNeedlesTag["rpmNeedle55"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 12572) && (motorcycleData.getRPM() <= 12714)) {
                            rpmNeedlesTag["rpmNeedle56"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 12715) && (motorcycleData.getRPM() <= 12857)) {
                            rpmNeedlesTag["rpmNeedle57"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 12858) && (motorcycleData.getRPM() <= 12999)) {
                            rpmNeedlesTag["rpmNeedle58"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 13000) && (motorcycleData.getRPM() <= 13285)) {
                            rpmNeedlesTag["rpmNeedle59"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 13286) && (motorcycleData.getRPM() <= 13571)) {
                            rpmNeedlesTag["rpmNeedle60"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 13572) && (motorcycleData.getRPM() <= 13857)) {
                            rpmNeedlesTag["rpmNeedle61"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 13858) && (motorcycleData.getRPM() <= 14143)) {
                            rpmNeedlesTag["rpmNeedle62"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 14144) && (motorcycleData.getRPM() <= 14429)) {
                            rpmNeedlesTag["rpmNeedle63"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 14430) && (motorcycleData.getRPM() <= 14715)) {
                            rpmNeedlesTag["rpmNeedle64"]?.attributes["style"] = "display:inline"
                        }
                        if ((motorcycleData.getRPM() >= 14716) && (motorcycleData.getRPM() <= 14999)) {
                            rpmNeedlesTag["rpmNeedle65"]?.attributes["style"] = "display:inline"
                        }
                        if (motorcycleData.getRPM() >= 15000) {
                            rpmNeedlesTag["rpmNeedle66"]?.attributes["style"] = "display:inline"
                        }
                    }
                }
                break
            default:
                //15000
                os_log("SportDashboard: Unknown or default RPM Setting for sport dashboard")
                break
            }
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
