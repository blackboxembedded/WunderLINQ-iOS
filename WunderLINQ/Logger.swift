//
//  Logger.swift
//  WunderLINQ
//
//  Created by Keith Conger on 8/21/17.
//  Copyright © 2017 Black Box Embedded, LLC. All rights reserved.
//

import Foundation

class Logger {

    static var dateFormat = "yyyyMMdd-HH:mm:ss"
    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        return formatter
    }
    
    class func log() {
        let motorcycleData = MotorcycleData.shared
        let loggingStatus = UserDefaults.standard.string(forKey: "loggingStatus")
        if(loggingStatus != nil){
            var formattedEntry = ""
            let fileName = "WunderLINQ-TripLog-" + loggingStatus! + ".csv"
            // Get the documents folder url
            let documentDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            // Destination url for the log file to be saved
            let fileURL = documentDirectory.appendingPathComponent("\(fileName)")
            let fileManager = FileManager.default
            if (!fileManager.fileExists(atPath: fileURL.path)) {
                print("FILE NOT AVAILABLE")
                //Add Header
                let dateHeader = NSLocalizedString("time_header", comment: "")
                let latitudeHeader = NSLocalizedString("latitude_header", comment: "")
                let longitudeHeader = NSLocalizedString("longitude_header", comment: "")
                let altitudeHeader = NSLocalizedString("altitude_header", comment: "")
                let gpsSpeedHeader = NSLocalizedString("gpsspeed_header", comment: "")
                let gearHeader = NSLocalizedString("gear_header", comment: "")
                let engineTemperatureHeader = NSLocalizedString("enginetemp_header", comment: "")
                let ambientTemperatureHeader = NSLocalizedString("ambienttemp_header", comment: "")
                let frontPressureHeader = NSLocalizedString("frontpressure_header", comment: "")
                let rearPressureHeader = NSLocalizedString("rearpressure_header", comment: "")
                let odometerHeader = NSLocalizedString("odometer_header", comment: "")
                let voltageHeader = NSLocalizedString("voltage_header", comment: "")
                let throttlePositionHeader = NSLocalizedString("throttle_header", comment: "")
                let frontBrakesHeader = NSLocalizedString("frontbrakes_header", comment: "")
                let rearBrakesHeader = NSLocalizedString("rearbrakes_header", comment: "")
                let shiftsHeader = NSLocalizedString("shifts_header", comment: "")
                let vinHeader = NSLocalizedString("vin_header", comment: "")
                let ambientLightHeader = NSLocalizedString("ambientlight_header", comment: "")
                let tripOneHeader = NSLocalizedString("tripone_header", comment: "")
                let tripTwoHeader = NSLocalizedString("triptwo_header", comment: "")
                let tripAutoHeader = NSLocalizedString("tripauto_header", comment: "")
                let speedHeader = NSLocalizedString("speed_header", comment: "")
                let averageSpeedHeader = NSLocalizedString("avgspeed_header", comment: "")
                let currentConsumptionHeader = NSLocalizedString("cconsumption_header", comment: "")
                let fuelEconomyOneHeader = NSLocalizedString("fueleconomyone_header", comment: "")
                let fuelEconomyTwoHeader = NSLocalizedString("fueleconomytwo_header", comment: "")
                let fuelRangeHeader = NSLocalizedString("fuelrange_header", comment: "")
                let leanAngleHeader = NSLocalizedString("leanangle_header", comment: "")
                let gForceHeader = NSLocalizedString("gforce_header", comment: "")
                let bearingHeader = NSLocalizedString("bearing_header", comment: "")
                let barometricPressureHeader = NSLocalizedString("barometric_header", comment: "")
                
                // Update main display
                var temperatureUnit = "C"
                var distanceUnit = "km"
                var altitudeUnit = "m"
                var pressureUnit = "bar"
                var speedUnit = "kmh"
                var consumptionUnit = "L/100"
                
                switch UserDefaults.standard.integer(forKey: "pressure_unit_preference"){
                case 0:
                    pressureUnit = "bar"
                case 1:
                    pressureUnit = "kPa"
                case 2:
                    pressureUnit = "kg-f"
                case 3:
                    pressureUnit = "psi"
                default:
                    print("Unknown pressure unit setting")
                }
                if UserDefaults.standard.integer(forKey: "temperature_unit_preference") == 1 {
                    temperatureUnit = "F"
                }
                if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                    distanceUnit = "mi"
                    altitudeUnit = "ft"
                    speedUnit = "mph"
                    consumptionUnit = "mpg"
                }
                
                let header = "\(dateHeader),\(latitudeHeader),\(longitudeHeader),\(altitudeHeader) (\(altitudeUnit)),\(gpsSpeedHeader) (\(speedUnit)),\(gearHeader),\(engineTemperatureHeader) (\(temperatureUnit)),\(ambientTemperatureHeader) (\(temperatureUnit)),\(frontPressureHeader) (\(pressureUnit)),\(rearPressureHeader) (\(pressureUnit)),\(odometerHeader) (\(distanceUnit)),\(voltageHeader) (V),\(throttlePositionHeader) (%),\(frontBrakesHeader),\(rearBrakesHeader),\(shiftsHeader),\(vinHeader),\(ambientLightHeader),\(tripOneHeader) (\(distanceUnit)),\(tripTwoHeader) (\(distanceUnit)),\(tripAutoHeader) (\(distanceUnit)),\(speedHeader) (\(speedUnit)),\(averageSpeedHeader) (\(speedUnit)),\(currentConsumptionHeader) (\(consumptionUnit)),\(fuelEconomyOneHeader) (\(consumptionUnit)),\(fuelEconomyTwoHeader) (\(consumptionUnit)),\(fuelRangeHeader) (\(distanceUnit)),\(leanAngleHeader),\(gForceHeader),\(bearingHeader),\(barometricPressureHeader) (kPa)"
                formattedEntry = header
                do {
                    // Write to log
                    try formattedEntry.appendLineToURL(fileURL: fileURL as URL)
                    
                } catch {
                    print("error writing to url:", fileURL, error)
                }
            }
            
            let currentLocation = motorcycleData.getLocation()
            let latitude:String = "\(currentLocation.coordinate.latitude)"
            let longitude:String = "\(currentLocation.coordinate.longitude)"
            
            var altitude:String = "\(currentLocation.altitude)"
            if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                altitude = "\(Utility.mtoFeet(currentLocation.altitude))"
            }
            var gpsSpeed:String = "0"
            if currentLocation.speed >= 0{
                gpsSpeed = "\(currentLocation.speed)"
                let gpsSpeedValue:Double = currentLocation.speed
                gpsSpeed = "\(gpsSpeedValue)"
                if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                    gpsSpeed = "\(Utility.kmToMiles(gpsSpeedValue))"
                }
            }
            var gear: String = ""
            if motorcycleData.gear != nil {
                gear = motorcycleData.gear!
            }
            var engineTemp:String = ""
            if motorcycleData.engineTemperature != nil {
                let engineTempValue:Double = motorcycleData.engineTemperature!
                engineTemp = "\(motorcycleData.engineTemperature!)"
                if UserDefaults.standard.integer(forKey: "temperature_unit_preference") == 1 {
                    engineTemp = "\(Utility.celciusToFahrenheit(engineTempValue))"
                }
            }
            var ambientTemp:String = ""
            if motorcycleData.ambientTemperature != nil {
                let ambientTempValue:Double = motorcycleData.ambientTemperature!
                ambientTemp = "\(motorcycleData.ambientTemperature!)"
                if UserDefaults.standard.integer(forKey: "temperature_unit_preference") == 1 {
                    ambientTemp = "\(Utility.celciusToFahrenheit(ambientTempValue))"
                }
            }
            var frontTirePressure:String = ""
            if motorcycleData.frontTirePressure != nil {
                let frontPressureValue:Double = motorcycleData.frontTirePressure!
                switch UserDefaults.standard.integer(forKey: "pressure_unit_preference"){
                case 1:
                    frontTirePressure = "\(Utility.barTokPa(frontPressureValue))"
                case 2:
                    frontTirePressure = "\(Utility.barTokgf(frontPressureValue))"
                case 3:
                    frontTirePressure = "\(Utility.barToPsi(frontPressureValue))"
                default:
                    frontTirePressure = "\(frontPressureValue)"
                }
            }
            var rearTirePressure:String = ""
            if motorcycleData.rearTirePressure != nil {
                let rearPressureValue:Double = motorcycleData.rearTirePressure!
                switch UserDefaults.standard.integer(forKey: "pressure_unit_preference"){
                case 1:
                    rearTirePressure = "\(Utility.barTokPa(rearPressureValue))"
                case 2:
                    rearTirePressure = "\(Utility.barTokgf(rearPressureValue))"
                case 3:
                    rearTirePressure = "\(Utility.barToPsi(rearPressureValue))"
                default:
                    rearTirePressure = "\(rearPressureValue)"
                }
            }
            var odometer:String = ""
            if motorcycleData.odometer != nil {
                let odometerValue:Double = motorcycleData.odometer!
                odometer = "\(odometerValue)"
                if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                    odometer = "\(Utility.kmToMiles(odometerValue))"
                }
                
            }
            var voltage:String = ""
            if motorcycleData.voltage != nil {
                voltage = "\(motorcycleData.voltage!)"
            }
            var throttlePosition:String = ""
            if motorcycleData.throttlePosition != nil {
                throttlePosition = "\(motorcycleData.throttlePosition!)"
            }
            var frontBrakes:String = ""
            if motorcycleData.frontBrake != nil {
                frontBrakes = "\(motorcycleData.frontBrake!)"
            }
            var rearBrakes:String = ""
            if motorcycleData.rearBrake != nil {
                rearBrakes = "\(motorcycleData.rearBrake!)"
            }
            var shifts:String = ""
            if motorcycleData.shifts != nil {
                shifts = "\(motorcycleData.shifts!)"
            }
            var vin:String = ""
            if motorcycleData.vin != nil {
                vin = "\(motorcycleData.vin!)"
            }
            var tripOne:String = ""
            if motorcycleData.tripOne != nil {
                let tripOneValue:Double = motorcycleData.tripOne!
                tripOne = "\(tripOneValue)"
                if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                    tripOne = "\(Utility.kmToMiles(tripOneValue))"
                }
            }
            var tripTwo:String = ""
            if motorcycleData.tripTwo != nil {
                let tripTwoValue:Double = motorcycleData.tripTwo!
                tripTwo = "\(tripTwoValue)"
                if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                    tripTwo = "\(Utility.kmToMiles(tripTwoValue))"
                }
            }
            var tripAuto:String = ""
            if motorcycleData.tripAuto != nil {
                let tripAutoValue:Double = motorcycleData.tripAuto!
                tripAuto = "\(tripAutoValue)"
                if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                    tripAuto = "\(Utility.kmToMiles(tripAutoValue))"
                }
            }
            var ambientLight:String = ""
            if motorcycleData.ambientLight != nil {
                ambientLight = "\(motorcycleData.ambientLight!)"
            }
            var speed:String = ""
            if motorcycleData.speed != nil {
                let speedValue:Double = motorcycleData.speed!
                speed = "\(speedValue)"
                if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                    speed = "\(Utility.kmToMiles(speedValue))"
                }
            }
            var avgSpeed:String = ""
            if motorcycleData.averageSpeed != nil {
                let avgSpeedValue:Double = motorcycleData.averageSpeed!
                avgSpeed = "\(avgSpeedValue)"
                if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                    avgSpeed = "\(Utility.kmToMiles(avgSpeedValue))"
                }
            }
            var currentConsumption:String = ""
            if motorcycleData.currentConsumption != nil {
                let currentConsumptionValue:Double = motorcycleData.currentConsumption!
                currentConsumption = "\(currentConsumptionValue)"
                if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                    currentConsumption = "\(Utility.l100ToMpg(currentConsumptionValue))"
                }
            }
            var fuelEconomyOne:String = ""
            if motorcycleData.fuelEconomyOne != nil {
                let fuelEconomyOneValue:Double = motorcycleData.fuelEconomyOne!
                fuelEconomyOne = "\(fuelEconomyOneValue)"
                if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                    fuelEconomyOne = "\(Utility.l100ToMpg(fuelEconomyOneValue))"
                }
            }
            var fuelEconomyTwo:String = ""
            if motorcycleData.fuelEconomyTwo != nil {
                fuelEconomyTwo = "\(motorcycleData.fuelEconomyTwo!)"
                let fuelEconomyTwoValue:Double = motorcycleData.fuelEconomyTwo!
                fuelEconomyTwo = "\(fuelEconomyTwoValue)"
                if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                    fuelEconomyTwo = "\(Utility.l100ToMpg(fuelEconomyTwoValue))"
                }
            }
            var fuelRange:String = ""
            if motorcycleData.fuelRange != nil {
                let fuelRangeValue:Double = motorcycleData.fuelRange!
                fuelRange = "\(fuelRangeValue)"
                if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                    fuelRange = "\(Utility.kmToMiles(fuelRangeValue))"
                }
            }
            var leanAngle:String = ""
            if motorcycleData.leanAngle != nil {
                let leanAngleValue:Double = motorcycleData.leanAngle!
                leanAngle = "\(leanAngleValue.rounded(toPlaces: 1))"
            }
            var gForce:String = ""
            if motorcycleData.gForce != nil {
                let gForceValue:Double = motorcycleData.gForce!
                gForce = "\(gForceValue.rounded(toPlaces: 1))"
            }
            var bearing:String = ""
            if motorcycleData.bearing != nil {
                let bearingValue:Int = motorcycleData.bearing!
                bearing = "\(bearingValue)"
            }
            var barometricPressure:String = ""
            if motorcycleData.barometricPressure != nil {
                let barometricPressureValue:Double = motorcycleData.barometricPressure!
                barometricPressure = "\(barometricPressureValue)"
            }
            
            let entry = "\(latitude),\(longitude),\(altitude),\(gpsSpeed),\(gear),\(engineTemp),\(ambientTemp),\(frontTirePressure),\(rearTirePressure),\(odometer),\(voltage),\(throttlePosition),\(frontBrakes),\(rearBrakes),\(shifts),\(vin),\(ambientLight),\(tripOne),\(tripTwo),\(tripAuto),\(speed),\(avgSpeed),\(currentConsumption),\(fuelEconomyOne),\(fuelEconomyTwo),\(fuelRange),\(leanAngle),\(gForce),\(bearing),\(barometricPressure)"
            formattedEntry = Date().toString() + "," + entry
            do {
                // Write to log
                try formattedEntry.appendLineToURL(fileURL: fileURL as URL)
                
            } catch {
                print("error writing to url:", fileURL, error)
            }
        }

    }
    
    class func logDBG(entry: String) {
        print("Debug Log ENtry")
        let fileName = "dbg"
        // Get the documents folder url
        let documentDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        // Destination url for the log file to be saved
        let fileURL = documentDirectory.appendingPathComponent("\(fileName)")
        let formattedEntry = Date().toString() + "," + entry
        do {
            // Write to log
            try formattedEntry.appendLineToURL(fileURL: fileURL as URL)
            
        } catch {
            print("error writing to url:", fileURL, error)
        }
    }
    
    private class func sourceFileName(filePath: String) -> String {
        let components = filePath.components(separatedBy: "/")
        return components.isEmpty ? "" : components.last!
    }
}

internal extension Date {
    func toString() -> String {
        return Logger.dateFormatter.string(from: self as Date)
    }
}

extension String {
    func appendLineToURL(fileURL: URL) throws {
        try (self + "\n").appendToURL(fileURL: fileURL)
    }
    
    func appendToURL(fileURL: URL) throws {
        let data = self.data(using: String.Encoding.utf8)!
        try data.append(fileURL: fileURL)
    }
}

extension Data {
    func append(fileURL: URL) throws {
        if let fileHandle = FileHandle(forWritingAtPath: fileURL.path) {
            defer {
                fileHandle.closeFile()
            }
            fileHandle.seekToEndOfFile()
            fileHandle.write(self)
        }
        else {
            try write(to: fileURL, options: .atomic)
        }
    }
}
