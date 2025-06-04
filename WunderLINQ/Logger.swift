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

class Logger {

    static var dateFormat = "yyyyMMdd-HH:mm:ss.SSS"
    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.locale = Locale(identifier: "en_US")
        formatter.timeZone = TimeZone.current
        return formatter
    }
    
    class func log() {
        let motorcycleData = MotorcycleData.shared
        let loggingStatus = UserDefaults.standard.string(forKey: "loggingStatus")
        if(loggingStatus != nil){
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd-HH-mm-ss"
            if let convertedDate = dateFormatter.date(from: loggingStatus!) {
                // Get today's date
                let today = Date()
                // Use Calendar to compare the two dates
                let calendar = Calendar.current
                // Compare just the date components, ignoring time
                if calendar.isDate(convertedDate, inSameDayAs: today)
                {
                    var formattedEntry = ""
                    let fileName = "WunderLINQ-TripLog-" + loggingStatus! + ".csv"
                    // Get the documents folder url
                    let documentDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                    // Destination url for the log file to be saved
                    let fileURL = documentDirectory.appendingPathComponent("\(fileName)")
                    let fileManager = FileManager.default
                    if (!fileManager.fileExists(atPath: fileURL.path)) {
                        print("Logger: FILE NOT AVAILABLE")
                        initializeFile(fileURL: fileURL)
                    }
                    
                    // GPS Derived Data
                    var latitude:String = "No Fix"
                    var longitude:String = "No Fix"
                    var altitude:String = "No Fix"
                    var gpsSpeed:String = "No Fix"
                    
                    if motorcycleData.location != nil {
                        let currentLocation = motorcycleData.location!
                        latitude = "\(currentLocation.coordinate.latitude)"
                        longitude = "\(currentLocation.coordinate.longitude)"
                        
                        altitude = "\(currentLocation.altitude)"
                        if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                            altitude = "\(Utils.mtoFeet(currentLocation.altitude))"
                        }
                        
                        let currentSpeed = currentLocation.speed * 3.6
                        if currentSpeed >= 0{
                            gpsSpeed = "\(currentSpeed)"
                            let gpsSpeedValue:Double = currentSpeed
                            gpsSpeed = "\(gpsSpeedValue)"
                            if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                                gpsSpeed = "\(Utils.kmToMiles(gpsSpeedValue))"
                            }
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
                            engineTemp = "\(Utils.celciusToFahrenheit(engineTempValue))"
                        }
                    }
                    var ambientTemp:String = ""
                    if motorcycleData.ambientTemperature != nil {
                        let ambientTempValue:Double = motorcycleData.ambientTemperature!
                        ambientTemp = "\(motorcycleData.ambientTemperature!)"
                        if UserDefaults.standard.integer(forKey: "temperature_unit_preference") == 1 {
                            ambientTemp = "\(Utils.celciusToFahrenheit(ambientTempValue))"
                        }
                    }
                    var frontTirePressure:String = ""
                    if motorcycleData.frontTirePressure != nil {
                        let frontPressureValue:Double = motorcycleData.frontTirePressure!
                        switch UserDefaults.standard.integer(forKey: "pressure_unit_preference"){
                        case 1:
                            frontTirePressure = "\(Utils.barTokPa(frontPressureValue))"
                        case 2:
                            frontTirePressure = "\(Utils.barTokgf(frontPressureValue))"
                        case 3:
                            frontTirePressure = "\(Utils.barToPsi(frontPressureValue))"
                        default:
                            frontTirePressure = "\(frontPressureValue)"
                        }
                    }
                    var rearTirePressure:String = ""
                    if motorcycleData.rearTirePressure != nil {
                        let rearPressureValue:Double = motorcycleData.rearTirePressure!
                        switch UserDefaults.standard.integer(forKey: "pressure_unit_preference"){
                        case 1:
                            rearTirePressure = "\(Utils.barTokPa(rearPressureValue))"
                        case 2:
                            rearTirePressure = "\(Utils.barTokgf(rearPressureValue))"
                        case 3:
                            rearTirePressure = "\(Utils.barToPsi(rearPressureValue))"
                        default:
                            rearTirePressure = "\(rearPressureValue)"
                        }
                    }
                    var odometer:String = ""
                    if motorcycleData.odometer != nil {
                        let odometerValue:Double = motorcycleData.odometer!
                        odometer = "\(odometerValue)"
                        if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                            odometer = "\(Utils.kmToMiles(odometerValue))"
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
                            tripOne = "\(Utils.kmToMiles(tripOneValue))"
                        }
                    }
                    var tripTwo:String = ""
                    if motorcycleData.tripTwo != nil {
                        let tripTwoValue:Double = motorcycleData.tripTwo!
                        tripTwo = "\(tripTwoValue)"
                        if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                            tripTwo = "\(Utils.kmToMiles(tripTwoValue))"
                        }
                    }
                    var tripAuto:String = ""
                    if motorcycleData.tripAuto != nil {
                        let tripAutoValue:Double = motorcycleData.tripAuto!
                        tripAuto = "\(tripAutoValue)"
                        if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                            tripAuto = "\(Utils.kmToMiles(tripAutoValue))"
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
                            speed = "\(Utils.kmToMiles(speedValue))"
                        }
                    }
                    var avgSpeed:String = ""
                    if motorcycleData.averageSpeed != nil {
                        let avgSpeedValue:Double = motorcycleData.averageSpeed!
                        avgSpeed = "\(avgSpeedValue)"
                        if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                            avgSpeed = "\(Utils.kmToMiles(avgSpeedValue))"
                        }
                    }
                    var currentConsumption:String = ""
                    if motorcycleData.currentConsumption != nil {
                        let currentConsumptionValue:Double = motorcycleData.currentConsumption!
                        currentConsumption = "\(currentConsumptionValue)"
                        switch UserDefaults.standard.integer(forKey: "consumption_unit_preference"){
                        case 1:
                            currentConsumption = "\(Utils.l100ToMpg(currentConsumptionValue))"
                        case 2:
                            currentConsumption = "\(Utils.l100ToMpgi(currentConsumptionValue))"
                        case 3:
                            currentConsumption = "\(Utils.l100Tokml(currentConsumptionValue))"
                        default:
                            currentConsumption = "\(currentConsumptionValue)"
                        }
                    }
                    var fuelEconomyOne:String = ""
                    if motorcycleData.fuelEconomyOne != nil {
                        let fuelEconomyOneValue:Double = motorcycleData.fuelEconomyOne!
                        fuelEconomyOne = "\(fuelEconomyOneValue)"
                        switch UserDefaults.standard.integer(forKey: "consumption_unit_preference"){
                        case 1:
                            fuelEconomyOne = "\(Utils.l100ToMpg(fuelEconomyOneValue))"
                        case 2:
                            fuelEconomyOne = "\(Utils.l100ToMpgi(fuelEconomyOneValue))"
                        case 3:
                            fuelEconomyOne = "\(Utils.l100Tokml(fuelEconomyOneValue))"
                        default:
                            fuelEconomyOne = "\(fuelEconomyOneValue)"
                        }
                    }
                    var fuelEconomyTwo:String = ""
                    if motorcycleData.fuelEconomyTwo != nil {
                        fuelEconomyTwo = "\(motorcycleData.fuelEconomyTwo!)"
                        let fuelEconomyTwoValue:Double = motorcycleData.fuelEconomyTwo!
                        fuelEconomyTwo = "\(fuelEconomyTwoValue)"
                        if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                            fuelEconomyTwo = "\(Utils.l100ToMpg(fuelEconomyTwoValue))"
                        }
                        switch UserDefaults.standard.integer(forKey: "consumption_unit_preference"){
                        case 1:
                            fuelEconomyTwo = "\(Utils.l100ToMpg(fuelEconomyTwoValue))"
                        case 2:
                            fuelEconomyTwo = "\(Utils.l100ToMpgi(fuelEconomyTwoValue))"
                        case 3:
                            fuelEconomyTwo = "\(Utils.l100Tokml(fuelEconomyTwoValue))"
                        default:
                            fuelEconomyTwo = "\(fuelEconomyTwoValue)"
                        }
                    }
                    var fuelRange:String = ""
                    if motorcycleData.fuelRange != nil {
                        let fuelRangeValue:Double = motorcycleData.fuelRange!
                        fuelRange = "\(fuelRangeValue)"
                        if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                            fuelRange = "\(Utils.kmToMiles(fuelRangeValue))"
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
                    var rpm:String = ""
                    if motorcycleData.rpm != nil {
                        let rpmValue:Int16 = motorcycleData.rpm!
                        rpm = "\(rpmValue)"
                    }
                    var leanAngleBike:String = ""
                    if motorcycleData.leanAngleBike != nil {
                        let leanAngleBikeValue:Double = motorcycleData.leanAngleBike!
                        leanAngleBike = "\(leanAngleBikeValue.rounded(toPlaces: 1))"
                    }
                    var rearSpeed:String = ""
                    if motorcycleData.rearSpeed != nil {
                        let speedValue:Double = motorcycleData.rearSpeed!
                        rearSpeed = "\(speedValue)"
                        if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                            rearSpeed = "\(Utils.kmToMiles(speedValue))"
                        }
                    }
                    var deviceBattery:String = ""
                    if motorcycleData.localBattery != nil {
                        deviceBattery = "\(motorcycleData.localBattery!)"
                    }
                    
                    let entry = "\(latitude),\(longitude),\(altitude),\(gpsSpeed),\(gear),\(engineTemp),\(ambientTemp),\(frontTirePressure),\(rearTirePressure),\(odometer),\(voltage),\(throttlePosition),\(frontBrakes),\(rearBrakes),\(shifts),\(vin),\(ambientLight),\(tripOne),\(tripTwo),\(tripAuto),\(speed),\(avgSpeed),\(currentConsumption),\(fuelEconomyOne),\(fuelEconomyTwo),\(fuelRange),\(leanAngle),\(gForce),\(bearing),\(barometricPressure),\(rpm),\(leanAngleBike),\(rearSpeed),\(deviceBattery)"
                    formattedEntry = Date().toString() + "," + entry
                    do {
                        // Write to log
                        try formattedEntry.appendLineToURL(fileURL: fileURL as URL)
                        
                    } catch {
                        print("Logger: error writing to url:\(fileURL), ERROR: \(error)")
                    }
                } else {
                    print("Logger: New Day")
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyyMMdd-HH-mm-ss"
                    let dateString = dateFormatter.string(from: Date())
                    UserDefaults.standard.set(dateString, forKey: "loggingStatus")
                    
                    let fileName = "WunderLINQ-TripLog-" + dateString + ".csv"
                    // Get the documents folder url
                    let documentDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                    // Destination url for the log file to be saved
                    let fileURL = documentDirectory.appendingPathComponent("\(fileName)")
                    let fileManager = FileManager.default
                    if (!fileManager.fileExists(atPath: fileURL.path)) {
                        print("Logger: FILE NOT AVAILABLE")
                        initializeFile(fileURL: fileURL)
                    }
                }
            }
            
        }

    }
    
    private class func initializeFile(fileURL: URL){
        
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
        let rpmHeader = NSLocalizedString("rpm_header", comment: "")
        let leanAngleBikeHeader = NSLocalizedString("leanangle_bike_header", comment: "")
        let rearSpeedHeader = NSLocalizedString("rearwheel_speed_header", comment: "")
        let deviceBatteryHeader = NSLocalizedString("local_battery_header", comment: "")
        
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
            print("Logger: Unknown pressure unit setting")
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
        switch UserDefaults.standard.integer(forKey: "consumption_unit_preference"){
        case 0:
            consumptionUnit = "L/100"
        case 1:
            consumptionUnit = "mpg"
        case 2:
            consumptionUnit = "mpg"
        case 3:
            consumptionUnit = "km/L"
        default:
            print("Logger: Unknown consumption unit setting")
        }
        
        let header = "\(dateHeader) (\(dateFormat)),\(latitudeHeader),\(longitudeHeader),\(altitudeHeader) (\(altitudeUnit)),\(gpsSpeedHeader) (\(speedUnit)),\(gearHeader),\(engineTemperatureHeader) (\(temperatureUnit)),\(ambientTemperatureHeader) (\(temperatureUnit)),\(frontPressureHeader) (\(pressureUnit)),\(rearPressureHeader) (\(pressureUnit)),\(odometerHeader) (\(distanceUnit)),\(voltageHeader) (V),\(throttlePositionHeader) (%),\(frontBrakesHeader),\(rearBrakesHeader),\(shiftsHeader),\(vinHeader),\(ambientLightHeader),\(tripOneHeader) (\(distanceUnit)),\(tripTwoHeader) (\(distanceUnit)),\(tripAutoHeader) (\(distanceUnit)),\(speedHeader) (\(speedUnit)),\(averageSpeedHeader) (\(speedUnit)),\(currentConsumptionHeader) (\(consumptionUnit)),\(fuelEconomyOneHeader) (\(consumptionUnit)),\(fuelEconomyTwoHeader) (\(consumptionUnit)),\(fuelRangeHeader) (\(distanceUnit)),\(leanAngleHeader),\(gForceHeader),\(bearingHeader),\(barometricPressureHeader) (kPa),\(rpmHeader),\(leanAngleBikeHeader),\(rearSpeedHeader) (\(speedUnit)),\(deviceBatteryHeader) (%)"
        do {
            // Write to log
            try header.appendLineToURL(fileURL: fileURL as URL)
            
        } catch {
            print("Logger: error writing to url:\(fileURL), ERROR: \(error)")
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
