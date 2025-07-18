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

import CoreLocation
import Foundation
import os.log

class MotorcycleData {
    static let shared = MotorcycleData()
    var hasFocus: Bool? = false
    var location: CLLocation?
    var ignitionStatus: Bool?
    var vin: String?
    var nextService: Int?
    var nextServiceDate: Date?
    var frontTirePressure: Double?
    var rearTirePressure: Double?
    var ambientTemperature: Double?
    var engineTemperature: Double?
    var odometer: Double?
    var tripOne: Double?
    var tripTwo: Double?
    var tripAuto: Double?
    var shifts: Int? = 0
    var gear: String?
    var voltage: Double?
    var throttlePosition: Double?
    var frontBrake: Int? = 0
    var rearBrake: Int? = 0
    var ambientLight: Double?
    var speed: Double?
    var averageSpeed: Double?
    var fuelRange: Double?
    var fuelEconomyOne: Double?
    var fuelEconomyTwo: Double?
    var currentConsumption: Double?
    var leanAngle: Double?
    var gForce: Double?
    var bearing: Int?
    var time: Date?
    var barometricPressure: Double?
    var rpm: Int16? = 0
    var leanAngleBike: Double?
    var leanAngleBikeMaxL: Double?
    var leanAngleBikeMaxR: Double?
    var leanAngleMaxL: Double?
    var leanAngleMaxR: Double?
    var rearSpeed: Double?
    var prevBrake: Int? = 0
    var localBattery: Int?
    
    // Initialize the calculator with a 2-minute observation window
    let rateOfClimbCalculator = RateOfClimbCalculator(observationWindow: 120)
    
    func setHasFocus(hasFocus: Bool?){
        self.hasFocus = hasFocus
    }
    func getHasFocus() -> Bool{
        return self.hasFocus!
    }
    
    func setLocation(location: CLLocation?){
        self.location = location
        
        rateOfClimbCalculator.addAltitudeData(altitude: location!.altitude)
    }
    func getLocation() -> CLLocation? {
        return self.location
    }
    func getElevationChange() -> Double{
        return rateOfClimbCalculator.calculateRateOfClimb()
    }
    
    func setIgnitionStatus(ignitionStatus: Bool?){
        self.ignitionStatus = ignitionStatus
    }
    func getIgnitionStatus() -> Bool{
        return self.ignitionStatus!
    }
    
    func setVIN(vin: String?){
        self.vin = vin
    }
    func getVIN() -> String{
        return self.vin!
    }
    
    func setNextServiceDate(nextServiceDate: Date?){
        self.nextServiceDate = nextServiceDate
    }
    func getNextServiceDate() -> Date{
        return self.nextServiceDate!
    }
    
    func setNextService(nextService: Int?){
        self.nextService = nextService
    }
    func getNextService() -> Int{
        return self.nextService!
    }
    
    func setfrontTirePressure(frontTirePressure: Double?){
        self.frontTirePressure = frontTirePressure
    }
    func getfrontTirePressure() -> Double{
        return self.frontTirePressure!
    }
    
    func setrearTirePressure(rearTirePressure: Double?){
        self.rearTirePressure = rearTirePressure
    }
    func getrearTirePressure() -> Double{
        return self.rearTirePressure!
    }
    
    func setambientTemperature(ambientTemperature: Double?){
        self.ambientTemperature = ambientTemperature
    }
    func getambientTemperature() -> Double{
        return self.ambientTemperature!
    }
    
    func setengineTemperature(engineTemperature: Double?){
        self.engineTemperature = engineTemperature
    }
    func getengineTemperature() -> Double{
        return self.engineTemperature!
    }
    
    func setodometer(odometer: Double?){
        self.odometer = odometer
    }
    func getodometer() -> Double{
        return self.odometer!
    }
    
    func settripOne(tripOne: Double?){
        self.tripOne = tripOne
    }
    func gettripOne() -> Double{
        return self.tripOne!
    }
    
    func settripTwo(tripTwo: Double?){
        self.tripTwo = tripTwo
    }
    func gettripTwo() -> Double{
        return self.tripTwo!
    }
    
    func settripAuto(tripAuto: Double?){
        self.tripAuto = tripAuto
    }
    func gettripAuto() -> Double{
        return self.tripAuto!
    }
    
    func setshifts(shifts: Int?){
        self.shifts = shifts
    }
    func getshifts() -> Int{
        return self.shifts!
    }
    
    func setgear(gear: String?){
        self.gear = gear
    }
    func getgear() -> String{
        return self.gear!
    }
    
    func setvoltage(voltage: Double?){
        self.voltage = voltage
    }
    func getvoltage() -> Double{
        return self.voltage!
    }
    
    func setthrottlePosition(throttlePosition: Double?){
        self.throttlePosition = throttlePosition
    }
    func getthrottlePosition() -> Double{
        return self.throttlePosition!
    }
    
    func setfrontBrake(frontBrake: Int?){
        self.frontBrake = frontBrake
    }
    func getfrontBrake() -> Int{
        return self.frontBrake!
    }
    
    func setPrevBrake(prevBrake: Int?){
        self.prevBrake = prevBrake
    }
    func getPrevBrake() -> Int{
        return self.prevBrake!
    }
    
    func setrearBrake(rearBrake: Int?){
        self.rearBrake = rearBrake
    }
    func getrearBrake() -> Int{
        return self.rearBrake!
    }
    
    func setambientLight(ambientLight: Double?){
        self.ambientLight = ambientLight
    }
    func getambientLight() -> Double{
        return self.ambientLight!
    }
    
    func setspeed(speed: Double?){
        self.speed = speed
    }
    func getspeed() -> Double{
        return self.speed!
    }
    
    func setaverageSpeed(averageSpeed: Double?){
        self.averageSpeed = averageSpeed
    }
    func getaverageSpeed() -> Double{
        return self.averageSpeed!
    }
    
    func setfuelRange(fuelRange: Double?){
        self.fuelRange = fuelRange
    }
    func getfuelRange() -> Double{
        return self.fuelRange!
    }
    
    func setfuelEconomyOne(fuelEconomyOne: Double?){
        self.fuelEconomyOne = fuelEconomyOne
    }
    func getfuelEconomyOne() -> Double{
        return self.fuelEconomyOne!
    }
    
    func setfuelEconomyTwo(fuelEconomyTwo: Double?){
        self.fuelEconomyTwo = fuelEconomyTwo
    }
    func getfuelEconomyTwo() -> Double{
        return self.fuelEconomyTwo!
    }
    
    func setcurrentConsumption(currentConsumption: Double?){
        self.currentConsumption = currentConsumption
    }
    func getcurrentConsumption() -> Double{
        return self.currentConsumption!
    }
    
    func setleanAngle(leanAngle: Double?){
        self.leanAngle = leanAngle
    }
    func getleanAngle() -> Double{
        return self.leanAngle!
    }
    
    func setgForce(gForce: Double?){
        self.gForce = gForce
    }
    func getgForce() -> Double{
        return self.gForce!
    }
    
    func setbearing(bearing: Int?){
        self.bearing = bearing
    }
    func getbearing() -> Int{
        return self.bearing!
    }
    
    func setTime(time: Date?){
        self.time = time
    }
    func getTime() -> Date{
        return self.time!
    }
    
    func setBarometricPressure(barometricPressure: Double?){
        self.barometricPressure = barometricPressure
    }
    func getBarometricPressure() -> Double{
        return self.barometricPressure!
    }
    
    func setRPM(rpm: Int16?){
        self.rpm = rpm
    }
    func getRPM() -> Int16{
        return self.rpm!
    }
    
    func setleanAngleBike(leanAngleBike: Double?){
        self.leanAngleBike = leanAngleBike
    }
    func getleanAngleBike() -> Double{
        return self.leanAngleBike!
    }
    
    func setleanAngleBikeMaxL(leanAngleBikeMaxL: Double?){
        self.leanAngleBikeMaxL = leanAngleBikeMaxL
    }
    func getleanAngleBikeMaxL() -> Double{
        return self.leanAngleBikeMaxL!
    }
    
    func setleanAngleBikeMaxR(leanAngleBikeMaxR: Double?){
        self.leanAngleBikeMaxR = leanAngleBikeMaxR
    }
    func getleanAngleBikeMaxR() -> Double{
        return self.leanAngleBikeMaxR!
    }
    
    func setleanAngleMaxL(leanAngleMaxL: Double?){
        self.leanAngleMaxL = leanAngleMaxL
    }
    func getleanAngleMaxL() -> Double{
        return self.leanAngleMaxL!
    }
    
    func setleanAngleMaxR(leanAngleMaxR: Double?){
        self.leanAngleMaxR = leanAngleMaxR
    }
    func getleanAngleMaxR() -> Double{
        return self.leanAngleMaxR!
    }
    
    func setRearSpeed(rearSpeed: Double?){
        self.rearSpeed = rearSpeed
    }
    func getRearSpeed() -> Double{
        return self.rearSpeed!
    }
    
    func setLocalBattery(localBattery: Int?){
        self.localBattery = localBattery
    }
    func getLocalBattery() -> Int{
        return self.localBattery!
    }
    
    func resetData(){
        self.shifts = 0
        self.frontBrake = 0
        self.rearBrake = 0
        self.leanAngleBikeMaxL = nil
        self.leanAngleBikeMaxR = nil
        self.leanAngleMaxL = nil
        self.leanAngleMaxR = nil
    }
    
    func clear(){
        self.frontTirePressure = nil
        self.rearTirePressure = nil
        self.ambientTemperature = nil
        self.engineTemperature = nil
        self.odometer = nil
        self.tripOne = nil
        self.tripTwo = nil
        self.tripAuto = nil
        self.shifts = 0
        self.gear = nil
        self.voltage = nil
        self.throttlePosition = nil
        self.frontBrake = 0
        self.rearBrake = 0
        self.ambientLight = nil
        self.speed = nil
        self.averageSpeed = nil
        self.fuelRange = nil
        self.fuelEconomyOne = nil
        self.fuelEconomyTwo = nil
        self.currentConsumption = nil
        self.leanAngle = nil
        self.gForce = nil
        self.bearing = nil
        self.rpm = 0
        self.leanAngleBike = nil
        self.leanAngleBikeMaxL = nil
        self.leanAngleBikeMaxR = nil
        self.leanAngleMaxL = nil
        self.leanAngleMaxR = nil
        self.rearSpeed = nil
        self.localBattery = nil
    }
    
    private let CRITICAL_ENGINE_TEMP_C = 104.0 //219F hot engine
    private let CRITICAL_ENGINE_TEMP_LOW_C = 55.0 //130F cold engine
    private let CRITICAL_AIR_TEMP_HIGH_C = 37.5 //99.5F hot human
    private let CRITICAL_AIR_TEMP_LOW_C = 4.0 //39F cold human watch for frost
    private let CRITICAL_BATTERY_VOLTAGE_HIGH = 15.0
    private let CRITICAL_BATTERY_VOLTAGE_LOW = 12.0
    private let RANGE_CRITICAL = 5.0
    private let RANGE_LOW = 50.0
    
    public let DATA_GEAR = 0
    public let DATA_ENGINE_TEMP = 1
    public let DATA_AIR_TEMP = 2
    public let DATA_FRONT_RDC = 3
    public let DATA_REAR_RDC = 4
    public let DATA_ODOMETER = 5
    public let DATA_VOLTAGE = 6
    public let DATA_THROTTLE = 7
    public let DATA_FRONT_BRAKE = 8
    public let DATA_REAR_BRAKE = 9
    public let DATA_AMBIENT_LIGHT = 10
    public let DATA_TRIP_ONE = 11
    public let DATA_TRIP_TWO = 12
    public let DATA_TRIP_AUTO = 13
    public let DATA_SPEED = 14
    public let DATA_AVG_SPEED = 15
    public let DATA_CURRENT_CONSUMPTION = 16
    public let DATA_ECONOMY_ONE = 17
    public let DATA_ECONOMY_TWO = 18
    public let DATA_RANGE = 19
    public let DATA_SHIFTS = 20
    public let DATA_LEAN_DEVICE = 21
    public let DATA_GFORCE_DEVICE = 22
    public let DATA_BEARING_DEVICE = 23
    public let DATA_TIME_DEVICE = 24
    public let DATA_BAROMETRIC_DEVICE = 25
    public let DATA_SPEED_DEVICE = 26
    public let DATA_ALTITUDE_DEVICE = 27
    public let DATA_SUN_DEVICE = 28
    public let DATA_RPM = 29
    public let DATA_LEAN = 30
    public let DATA_REAR_SPEED = 31
    public let DATA_BATTERY_DEVICE = 32
    public let DATA_ELEVATION_CHANGE_DEVICE = 33
    
    class func getLabel(dataPoint: Int) -> String {
        var label:String = ""
        var temperatureUnit = "C"
        var heightUnit = "m"
        var distanceUnit = "km"
        var distanceTimeUnit = "kmh"
        var consumptionUnit = "L/100"
        var pressureUnit = "psi"
        // Pressure Unit
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
            NSLog("MainCollectionViewController: Unknown pressure unit setting")
        }
        if UserDefaults.standard.integer(forKey: "temperature_unit_preference") == 1 {
            temperatureUnit = "F"
        }
        if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
            distanceUnit = "mi"
            distanceTimeUnit = "mph"
            heightUnit = "ft"
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
            NSLog("MainCollectionViewController: Unknown consumption unit setting")
        }
        
        switch (dataPoint){
        case MotorcycleData.shared.DATA_GEAR:
            // Gear
            label = NSLocalizedString("gear_header", comment: "")
        case MotorcycleData.shared.DATA_ENGINE_TEMP:
            // Engine Temperature
            label = NSLocalizedString("enginetemp_header", comment: "") + " (" + temperatureUnit + ")"
        case MotorcycleData.shared.DATA_AIR_TEMP:
            // Ambient Temperature
            label = NSLocalizedString("ambienttemp_header", comment: "") + " (" + temperatureUnit + ")"
        case MotorcycleData.shared.DATA_FRONT_RDC:
            // Front Tire Pressure
            label = NSLocalizedString("frontpressure_header", comment: "") + " (" + pressureUnit + ")"
        case MotorcycleData.shared.DATA_REAR_RDC:
            // Rear Tire Pressure
            label = NSLocalizedString("rearpressure_header", comment: "") + " (" + pressureUnit + ")"
        case MotorcycleData.shared.DATA_ODOMETER:
            // Odometer
            label = NSLocalizedString("odometer_header", comment: "") + " (" + distanceUnit + ")"
        case MotorcycleData.shared.DATA_VOLTAGE:
            // Voltage
            label = NSLocalizedString("voltage_header", comment: "") + " (V)"
        case MotorcycleData.shared.DATA_THROTTLE:
            // Trottle
            label = NSLocalizedString("throttle_header", comment: "") + " (%)"
        case MotorcycleData.shared.DATA_FRONT_BRAKE:
            // Front Brakes
            label = NSLocalizedString("frontbrakes_header", comment: "")
        case MotorcycleData.shared.DATA_REAR_BRAKE:
            // Rear Brakes
            label = NSLocalizedString("rearbrakes_header", comment: "")
        case MotorcycleData.shared.DATA_AMBIENT_LIGHT:
            // Ambient Light
            label = NSLocalizedString("ambientlight_header", comment: "")
        case MotorcycleData.shared.DATA_TRIP_ONE:
            // Trip 1
            label = NSLocalizedString("tripone_header", comment: "") + " (" + distanceUnit + ")"
        case MotorcycleData.shared.DATA_TRIP_TWO:
            // Trip 2
            label = NSLocalizedString("triptwo_header", comment: "") + " (" + distanceUnit + ")"
        case MotorcycleData.shared.DATA_TRIP_AUTO:
            // Trip Auto
            label = NSLocalizedString("tripauto_header", comment: "") + " (" + distanceUnit + ")"
        case MotorcycleData.shared.DATA_SPEED:
            // Speed
            label = NSLocalizedString("speed_header", comment: "") + " (" + distanceTimeUnit + ")"
        case MotorcycleData.shared.DATA_AVG_SPEED:
            //Average Speed
            label = NSLocalizedString("avgspeed_header", comment: "") + " (" + distanceTimeUnit + ")"
        case MotorcycleData.shared.DATA_CURRENT_CONSUMPTION:
            //Current Consumption
            label = NSLocalizedString("cconsumption_header", comment: "") + " (" + consumptionUnit + ")"
        case MotorcycleData.shared.DATA_ECONOMY_ONE:
            //Fuel Economy One
            label = NSLocalizedString("fueleconomyone_header", comment: "") + " (" + consumptionUnit + ")"
        case MotorcycleData.shared.DATA_ECONOMY_TWO:
            //Fuel Economy Two
            label = NSLocalizedString("fueleconomytwo_header", comment: "") + " (" + consumptionUnit + ")"
        case MotorcycleData.shared.DATA_RANGE:
            //Fuel Range
            label = NSLocalizedString("fuelrange_header", comment: "") + " (" + distanceUnit + ")"
        case MotorcycleData.shared.DATA_SHIFTS:
            //Shifts
            label = NSLocalizedString("shifts_header", comment: "")
        case MotorcycleData.shared.DATA_LEAN_DEVICE:
            //Lean Angle
            label = NSLocalizedString("leanangle_header", comment: "")
        case MotorcycleData.shared.DATA_GFORCE_DEVICE:
            //g-force
            label = NSLocalizedString("gforce_header", comment: "")
        case MotorcycleData.shared.DATA_BEARING_DEVICE:
            //bearing
            label = NSLocalizedString("bearing_header", comment: "")
        case MotorcycleData.shared.DATA_TIME_DEVICE:
            //time
            label = NSLocalizedString("time_header", comment: "")
        case MotorcycleData.shared.DATA_BAROMETRIC_DEVICE:
            //barometric pressure
            label = NSLocalizedString("barometric_header", comment: "") + " (mBar)"
        case MotorcycleData.shared.DATA_SPEED_DEVICE:
            //GPS Speed
            label = NSLocalizedString("gpsspeed_header", comment: "") + " (" + distanceTimeUnit + ")"
        case MotorcycleData.shared.DATA_ALTITUDE_DEVICE:
            //altitude
            label = NSLocalizedString("altitude_header", comment: "") + " (" + heightUnit + ")"
        case MotorcycleData.shared.DATA_SUN_DEVICE:
            //Sunrise/Sunset
            label = NSLocalizedString("sunrisesunset_header", comment: "")
        case MotorcycleData.shared.DATA_RPM:
            //RPM
            label = NSLocalizedString("rpm_header", comment: "") + " (x1000)"
        case MotorcycleData.shared.DATA_LEAN:
            //Lean Angle
            label = NSLocalizedString("leanangle_bike_header", comment: "")
        case MotorcycleData.shared.DATA_REAR_SPEED:
            //Rear Wheel Speed
            label = NSLocalizedString("rearwheel_speed_header", comment: "")
        case MotorcycleData.shared.DATA_BATTERY_DEVICE:
            //Device Battery
            label = NSLocalizedString("local_battery_header", comment: "")
        case MotorcycleData.shared.DATA_ELEVATION_CHANGE_DEVICE:
            //Elevation change
            label = NSLocalizedString("elevation_change_header", comment: "") + " (" + heightUnit + "/2min)"
        default:
            NSLog("MotorcycleData: Unknown : \(dataPoint)")
        }
        
        return label
    }
    
    class func getValueColor(dataPoint: Int) -> UIColor? {
        var labelColor:UIColor?
        switch(UserDefaults.standard.integer(forKey: "darkmode_preference")){
        case 0:
            //OFF
            labelColor = UIColor.black
        case 1:
            //On
            labelColor = UIColor.white
        default:
            //Default
            if let window = UIApplication.shared.windows.first {
                if (window.traitCollection.userInterfaceStyle == .dark) {
                    labelColor = UIColor.white
                } else {
                    labelColor = UIColor.black
                }
            }
        }
        
        switch (dataPoint){
        case MotorcycleData.shared.DATA_GEAR:
            // Gear
            if (MotorcycleData.shared.gear != nil) {
                let gear:String = MotorcycleData.shared.gear!
                if gear == "N" {
                    labelColor = UIColor(named: "motorrad_green")
                } else if "123456".contains(gear) {
                    labelColor = UIColor(named: "motorrad_yellow")
                }
            }
        case MotorcycleData.shared.DATA_ENGINE_TEMP:
            // Engine Temperature
            if (MotorcycleData.shared.engineTemperature != nil) {
                let engineTemp:Double = MotorcycleData.shared.engineTemperature!
                if (engineTemp >= MotorcycleData.shared.CRITICAL_ENGINE_TEMP_C){
                    labelColor = UIColor(named: "motorrad_red")
                } else if (engineTemp <= MotorcycleData.shared.CRITICAL_ENGINE_TEMP_LOW_C){
                    labelColor = UIColor(named: "motorrad_blue")
                }
            }
        case MotorcycleData.shared.DATA_AIR_TEMP:
            // Ambient Temperature
            if (MotorcycleData.shared.ambientTemperature != nil) {
                let ambientTemp:Double = MotorcycleData.shared.ambientTemperature!
                if(ambientTemp <= MotorcycleData.shared.CRITICAL_AIR_TEMP_LOW_C){
                    labelColor = UIColor(named: "motorrad_blue")
                } else if (ambientTemp >= MotorcycleData.shared.CRITICAL_ENGINE_TEMP_LOW_C){
                    labelColor = UIColor(named: "motorrad_red")
                }
            }
        case MotorcycleData.shared.DATA_FRONT_RDC:
            // Front Tire Pressure
            if(Faults.shared.getFrontTirePressureCriticalActive()){
                labelColor = UIColor(named: "motorrad_red")
            } else if(Faults.shared.getRearTirePressureWarningActive()){
                labelColor = UIColor(named: "motorrad_yellow")
            }
        case MotorcycleData.shared.DATA_REAR_RDC:
            // Rear Tire Pressure
            if(Faults.shared.getRearTirePressureCriticalActive()){
                labelColor = UIColor(named: "motorrad_red")
            } else if(Faults.shared.getRearTirePressureWarningActive()){
                labelColor = UIColor(named: "motorrad_yellow")
            }
        case MotorcycleData.shared.DATA_ODOMETER:
            // Odometer
            break
        case MotorcycleData.shared.DATA_VOLTAGE:
            // Voltage
            if (MotorcycleData.shared.voltage != nil) {
                let voltage:Double = MotorcycleData.shared.voltage!
                if (voltage >= MotorcycleData.shared.CRITICAL_BATTERY_VOLTAGE_HIGH){
                    labelColor = UIColor(named: "motorrad_red")
                } else if (voltage < MotorcycleData.shared.CRITICAL_BATTERY_VOLTAGE_LOW){
                    labelColor = UIColor(named: "motorrad_yellow")
                }
            }
        case MotorcycleData.shared.DATA_THROTTLE:
            // Trottle
            break
        case MotorcycleData.shared.DATA_FRONT_BRAKE:
            // Front Brakes
            break
        case MotorcycleData.shared.DATA_REAR_BRAKE:
            // Rear Brakes
            break
        case MotorcycleData.shared.DATA_AMBIENT_LIGHT:
            // Ambient Light
            break
        case MotorcycleData.shared.DATA_TRIP_ONE:
            // Trip 1
            break
        case MotorcycleData.shared.DATA_TRIP_TWO:
            // Trip 2
            break
        case MotorcycleData.shared.DATA_TRIP_AUTO:
            // Trip Auto
            break
        case MotorcycleData.shared.DATA_SPEED:
            // Speed
            break
        case MotorcycleData.shared.DATA_AVG_SPEED:
            //Average Speed
            break
        case MotorcycleData.shared.DATA_CURRENT_CONSUMPTION:
            //Current Consumption
            break
        case MotorcycleData.shared.DATA_ECONOMY_ONE:
            //Fuel Economy One
            break
        case MotorcycleData.shared.DATA_ECONOMY_TWO:
            //Fuel Economy Two
            break
        case MotorcycleData.shared.DATA_RANGE:
            //Fuel Range
            if (MotorcycleData.shared.fuelRange != nil) {
                let range:Double = MotorcycleData.shared.fuelRange!
                if (range < MotorcycleData.shared.RANGE_CRITICAL){
                    labelColor = UIColor(named: "motorrad_red")
                } else if (range < MotorcycleData.shared.RANGE_LOW){
                    labelColor = UIColor(named: "motorrad_yellow")
                }
            }
        case MotorcycleData.shared.DATA_SHIFTS:
            //Shifts
            break
        case MotorcycleData.shared.DATA_LEAN_DEVICE:
            //Lean Angle Device
            break
        case MotorcycleData.shared.DATA_GFORCE_DEVICE:
            //g-force
            break
        case MotorcycleData.shared.DATA_BEARING_DEVICE:
            //bearing
            break
        case MotorcycleData.shared.DATA_TIME_DEVICE:
            //time
            break
        case MotorcycleData.shared.DATA_BAROMETRIC_DEVICE:
            //barometric pressure
            break
        case MotorcycleData.shared.DATA_SPEED_DEVICE:
            //GPS Speed
            break
        case MotorcycleData.shared.DATA_ALTITUDE_DEVICE:
            //altitude
            break
        case MotorcycleData.shared.DATA_SUN_DEVICE:
            //Sunrise/Sunset
            break
        case MotorcycleData.shared.DATA_RPM:
            //RPM
            break
        case MotorcycleData.shared.DATA_LEAN:
            //Lean Angle Bike
            break
        case MotorcycleData.shared.DATA_REAR_SPEED:
            //Rear Wheel Speed
            break
        case MotorcycleData.shared.DATA_BATTERY_DEVICE:
            //Device Battery
            if (MotorcycleData.shared.localBattery != nil) {
                let batteryPct = MotorcycleData.shared.localBattery!
                if(batteryPct > 0 && batteryPct < 25){
                    labelColor = UIColor(named: "motorrad_red")
                }
            }
        case MotorcycleData.shared.DATA_ELEVATION_CHANGE_DEVICE:
            //Elevation change
            break
        default:
            NSLog("MotorcycleData: Unknown : \(dataPoint)")
        }
        return labelColor
    }
    
    class func getIcon(dataPoint: Int) -> UIImage {
        var icon:UIImage = (UIImage(named: "Cog")?.withRenderingMode(.alwaysTemplate))!
        switch (dataPoint){
        case MotorcycleData.shared.DATA_GEAR:
            // Gear
            icon = (UIImage(named: "Cog")?.withRenderingMode(.alwaysTemplate))!
        case MotorcycleData.shared.DATA_ENGINE_TEMP:
            // Engine Temperature
            icon = (UIImage(named: "Engine-Temp")?.withRenderingMode(.alwaysTemplate))!
            if (MotorcycleData.shared.engineTemperature != nil) {
                let engineTemp:Double = MotorcycleData.shared.engineTemperature!
                if (engineTemp >= MotorcycleData.shared.CRITICAL_ENGINE_TEMP_C){
                    icon = icon.imageWithColor(color1: UIColor(named: "motorrad_red")!)
                } else if (engineTemp <= MotorcycleData.shared.CRITICAL_ENGINE_TEMP_LOW_C){
                    icon = icon.imageWithColor(color1: UIColor(named: "motorrad_blue")!)
                }
            }
        case MotorcycleData.shared.DATA_AIR_TEMP:
            // Ambient Temperature
            icon = (UIImage(named: "Thermometer")?.withRenderingMode(.alwaysTemplate))!
            if (MotorcycleData.shared.ambientTemperature != nil) {
                let ambientTemp:Double = MotorcycleData.shared.ambientTemperature!
                if(ambientTemp <= MotorcycleData.shared.CRITICAL_AIR_TEMP_LOW_C){
                    icon = (UIImage(named: "Snowflake")?.withRenderingMode(.alwaysTemplate))!
                    icon = icon.imageWithColor(color1: UIColor(named: "motorrad_blue")!)
                } else if (ambientTemp >= MotorcycleData.shared.CRITICAL_ENGINE_TEMP_LOW_C){
                    icon = icon.imageWithColor(color1: UIColor(named: "motorrad_red")!)
                }
            }
        case MotorcycleData.shared.DATA_FRONT_RDC:
            // Front Tire Pressure
            icon = (UIImage(named: "Tire")?.withRenderingMode(.alwaysTemplate))!
            if(Faults.shared.getFrontTirePressureCriticalActive()){
                icon = (UIImage(named: "Tire-Alert")?.withRenderingMode(.alwaysTemplate))!
                icon = icon.imageWithColor(color1: UIColor(named: "motorrad_red")!)
            } else if(Faults.shared.getRearTirePressureWarningActive()){
                icon = (UIImage(named: "Tire-Alert")?.withRenderingMode(.alwaysTemplate))!
                icon = icon.imageWithColor(color1: UIColor(named: "motorrad_yellow")!)
            }
        case MotorcycleData.shared.DATA_REAR_RDC:
            // Rear Tire Pressure
            icon = (UIImage(named: "Tire")?.withRenderingMode(.alwaysTemplate))!
            if(Faults.shared.getRearTirePressureCriticalActive()){
                icon = (UIImage(named: "Tire-Alert")?.withRenderingMode(.alwaysTemplate))!
                icon = icon.imageWithColor(color1: UIColor(named: "motorrad_red")!)
            } else if(Faults.shared.getRearTirePressureWarningActive()){
                icon = (UIImage(named: "Tire-Alert")?.withRenderingMode(.alwaysTemplate))!
                icon = icon.imageWithColor(color1: UIColor(named: "motorrad_yellow")!)
            }
        case MotorcycleData.shared.DATA_ODOMETER:
            // Odometer
            icon = (UIImage(named: "Odometer")?.withRenderingMode(.alwaysTemplate))!
        case MotorcycleData.shared.DATA_VOLTAGE:
            // Voltage
            icon = (UIImage(named: "Battery")?.withRenderingMode(.alwaysTemplate))!
            if (MotorcycleData.shared.voltage != nil) {
                let voltage:Double = MotorcycleData.shared.voltage!
                if (voltage >= MotorcycleData.shared.CRITICAL_BATTERY_VOLTAGE_HIGH){
                    icon = icon.imageWithColor(color1: UIColor(named: "motorrad_red")!)
                } else if (voltage < MotorcycleData.shared.CRITICAL_BATTERY_VOLTAGE_LOW){
                    icon = icon.imageWithColor(color1: UIColor(named: "motorrad_yellow")!)
                }
            }
        case MotorcycleData.shared.DATA_THROTTLE:
            // Trottle
            icon = (UIImage(named: "Signature")?.withRenderingMode(.alwaysTemplate))!
        case MotorcycleData.shared.DATA_FRONT_BRAKE:
            // Front Brakes
            icon = (UIImage(named: "Brakes")?.withRenderingMode(.alwaysTemplate))!
        case MotorcycleData.shared.DATA_REAR_BRAKE:
            // Rear Brakes
            icon = (UIImage(named: "Brakes")?.withRenderingMode(.alwaysTemplate))!
        case MotorcycleData.shared.DATA_AMBIENT_LIGHT:
            // Ambient Light
            icon = (UIImage(named: "Light-bulb")?.withRenderingMode(.alwaysTemplate))!
        case MotorcycleData.shared.DATA_TRIP_ONE:
            // Trip 1
            icon = (UIImage(named: "Suitcase")?.withRenderingMode(.alwaysTemplate))!
        case MotorcycleData.shared.DATA_TRIP_TWO:
            // Trip 2
            icon = (UIImage(named: "Suitcase")?.withRenderingMode(.alwaysTemplate))!
        case MotorcycleData.shared.DATA_TRIP_AUTO:
            // Trip Auto
            icon = (UIImage(named: "Suitcase")?.withRenderingMode(.alwaysTemplate))!
        case MotorcycleData.shared.DATA_SPEED:
            // Speed
            icon = (UIImage(named: "Tachometer")?.withRenderingMode(.alwaysTemplate))!
        case MotorcycleData.shared.DATA_AVG_SPEED:
            //Average Speed
            icon = (UIImage(named: "Tachometer")?.withRenderingMode(.alwaysTemplate))!
        case MotorcycleData.shared.DATA_CURRENT_CONSUMPTION:
            //Current Consumption
            icon = (UIImage(named: "Gas-pump")?.withRenderingMode(.alwaysTemplate))!
        case MotorcycleData.shared.DATA_ECONOMY_ONE:
            //Fuel Economy One
            icon = (UIImage(named: "Gas-pump")?.withRenderingMode(.alwaysTemplate))!
        case MotorcycleData.shared.DATA_ECONOMY_TWO:
            //Fuel Economy Two
            icon = (UIImage(named: "Gas-pump")?.withRenderingMode(.alwaysTemplate))!
        case MotorcycleData.shared.DATA_RANGE:
            //Fuel Range
            icon = (UIImage(named: "Gas-pump")?.withRenderingMode(.alwaysTemplate))!
        case MotorcycleData.shared.DATA_SHIFTS:
            //Shifts
            icon = (UIImage(named: "Arrows-alt")?.withRenderingMode(.alwaysTemplate))!
        case MotorcycleData.shared.DATA_LEAN_DEVICE:
            //Lean Angle Device
            icon = (UIImage(named: "Angle")?.withRenderingMode(.alwaysTemplate))!
        case MotorcycleData.shared.DATA_GFORCE_DEVICE:
            //g-force
            icon = (UIImage(named: "Accelerometer")?.withRenderingMode(.alwaysTemplate))!
        case MotorcycleData.shared.DATA_BEARING_DEVICE:
            //bearing
            icon = (UIImage(named: "Compass")?.withRenderingMode(.alwaysTemplate))!
        case MotorcycleData.shared.DATA_TIME_DEVICE:
            //time
            icon = (UIImage(named: "Clock")?.withRenderingMode(.alwaysTemplate))!
        case MotorcycleData.shared.DATA_BAROMETRIC_DEVICE:
            //barometric pressure
            icon = (UIImage(named: "Barometer")?.withRenderingMode(.alwaysTemplate))!
        case MotorcycleData.shared.DATA_SPEED_DEVICE:
            //GPS Speed
            icon = (UIImage(named: "Tachometer")?.withRenderingMode(.alwaysTemplate))!
        case MotorcycleData.shared.DATA_ALTITUDE_DEVICE:
            //altitude
            icon = (UIImage(named: "Mountain")?.withRenderingMode(.alwaysTemplate))!
        case MotorcycleData.shared.DATA_SUN_DEVICE:
            //Sunrise/Sunset
            icon = (UIImage(named: "Sun")?.withRenderingMode(.alwaysTemplate))!
            if (MotorcycleData.shared.location != nil) {
                let today = Date()
                let solar = Solar(for: today, coordinate: MotorcycleData.shared.location!.coordinate)
                let sunset = solar?.sunset
                if(today > sunset!){
                    icon = (UIImage(named: "Moon")?.withRenderingMode(.alwaysTemplate))!
                    icon = icon.imageWithColor(color1: UIColor(named: "motorrad_blue")!)
                } else {
                    icon = icon.imageWithColor(color1: UIColor(named: "motorrad_yellow")!)
                }
            }
        case MotorcycleData.shared.DATA_RPM:
            //RPM
            icon = (UIImage(named: "Tachometer")?.withRenderingMode(.alwaysTemplate))!
        case MotorcycleData.shared.DATA_LEAN:
            //Lean Angle Bike
            icon = (UIImage(named: "Angle")?.withRenderingMode(.alwaysTemplate))!
        case MotorcycleData.shared.DATA_REAR_SPEED:
            //Rear Wheel Speed
            icon = (UIImage(named: "Tachometer")?.withRenderingMode(.alwaysTemplate))!
        case MotorcycleData.shared.DATA_BATTERY_DEVICE:
            //Device Battery
            icon = (UIImage(named: "Battery-Empty")?.withRenderingMode(.alwaysTemplate))!
            if (MotorcycleData.shared.localBattery != nil) {
                let batteryPct = MotorcycleData.shared.localBattery!
                if(batteryPct > 95){
                    icon = (UIImage(named: "Battery-Full")?.withRenderingMode(.alwaysTemplate))!
                } else if(batteryPct > 75){
                    icon = (UIImage(named: "Battery-Three-Quarters")?.withRenderingMode(.alwaysTemplate))!
                } else if(batteryPct > 50){
                    icon = (UIImage(named: "Battery-Half")?.withRenderingMode(.alwaysTemplate))!
                } else if(batteryPct > 25){
                    icon = (UIImage(named: "Battery-Quarter")?.withRenderingMode(.alwaysTemplate))!
                } else if(batteryPct > 0){
                    icon = (UIImage(named: "Battery-Empty")?.withRenderingMode(.alwaysTemplate))!
                    icon = icon.imageWithColor(color1: UIColor(named: "motorrad_red")!)
                }
            }
        case MotorcycleData.shared.DATA_ELEVATION_CHANGE_DEVICE:
            //Elevation change
            icon = (UIImage(named: "Signature")?.withRenderingMode(.alwaysTemplate))!
        default:
            NSLog("MotorcycleData: Unknown : \(dataPoint)")
        }
        
        return icon
    }
    
    class func getValue(dataPoint: Int) -> String {
        var value:String =  NSLocalizedString("blank_field", comment: "")
        switch (dataPoint){
        case MotorcycleData.shared.DATA_GEAR:
            // Gear
            if MotorcycleData.shared.gear != nil {
                value = MotorcycleData.shared.getgear()
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case MotorcycleData.shared.DATA_ENGINE_TEMP:
            // Engine Temperature
            if MotorcycleData.shared.engineTemperature != nil {
                var engineTemp:Double = MotorcycleData.shared.engineTemperature!
                if (UserDefaults.standard.integer(forKey: "temperature_unit_preference") == 1 ){
                    engineTemp = Utils.celciusToFahrenheit(engineTemp)
                }
                value = "\(Utils.toZeroDecimalString(engineTemp))"
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case MotorcycleData.shared.DATA_AIR_TEMP:
            // Ambient Temperature
            if MotorcycleData.shared.ambientTemperature != nil {
                var ambientTemp:Double = MotorcycleData.shared.ambientTemperature!
                if UserDefaults.standard.integer(forKey: "temperature_unit_preference") == 1 {
                    ambientTemp = Utils.celciusToFahrenheit(ambientTemp)
                }
                value = "\(Utils.toZeroDecimalString(ambientTemp))"
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case MotorcycleData.shared.DATA_FRONT_RDC:
            // Front Tire Pressure
            if MotorcycleData.shared.frontTirePressure != nil {
                var frontPressure:Double = MotorcycleData.shared.frontTirePressure!
                switch UserDefaults.standard.integer(forKey: "pressure_unit_preference"){
                case 1:
                    frontPressure = Utils.barTokPa(frontPressure)
                case 2:
                    frontPressure = Utils.barTokgf(frontPressure)
                case 3:
                    frontPressure = Utils.barToPsi(frontPressure)
                default:
                    break
                }
                value = "\(Utils.toOneDecimalString(frontPressure))"
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case MotorcycleData.shared.DATA_REAR_RDC:
            // Rear Tire Pressure
            if MotorcycleData.shared.rearTirePressure != nil {
                var rearPressure:Double = MotorcycleData.shared.rearTirePressure!
                switch UserDefaults.standard.integer(forKey: "pressure_unit_preference"){
                case 1:
                    rearPressure = Utils.barTokPa(rearPressure)
                case 2:
                    rearPressure = Utils.barTokgf(rearPressure)
                case 3:
                    rearPressure = Utils.barToPsi(rearPressure)
                default:
                    break
                }
                value = "\(Utils.toOneDecimalString(rearPressure))"
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case MotorcycleData.shared.DATA_ODOMETER:
            // Odometer
            if MotorcycleData.shared.odometer != nil {
                var odometer:Double = MotorcycleData.shared.odometer!
                if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                    odometer = Double(Utils.kmToMiles(Double(odometer)))
                }
                value = "\(Utils.toZeroDecimalString(odometer, wrapGrouping: true))"
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case MotorcycleData.shared.DATA_VOLTAGE:
            // Voltage
            if MotorcycleData.shared.voltage != nil {
                let voltage:Double = MotorcycleData.shared.voltage!
                value = "\(Utils.toOneDecimalString(voltage))"
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case MotorcycleData.shared.DATA_THROTTLE:
            // Trottle
            if MotorcycleData.shared.throttlePosition != nil {
                let throttlePosition:Double = MotorcycleData.shared.throttlePosition!
                value = "\(Utils.toZeroDecimalString(throttlePosition))"
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case MotorcycleData.shared.DATA_FRONT_BRAKE:
            // Front Brakes
            if ((MotorcycleData.shared.frontBrake != nil) && MotorcycleData.shared.frontBrake != 0) {
                value = "\(MotorcycleData.shared.frontBrake!)"
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case MotorcycleData.shared.DATA_REAR_BRAKE:
            // Rear Brakes
            if ((MotorcycleData.shared.rearBrake != nil) && MotorcycleData.shared.rearBrake != 0)  {
                value = "\(MotorcycleData.shared.rearBrake!)"
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case MotorcycleData.shared.DATA_AMBIENT_LIGHT:
            // Ambient Light
            if MotorcycleData.shared.ambientLight != nil {
                value = "\(Int(MotorcycleData.shared.ambientLight!))"
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case MotorcycleData.shared.DATA_TRIP_ONE:
            // Trip 1
            if MotorcycleData.shared.tripOne != nil {
                var tripOne:Double = MotorcycleData.shared.tripOne!
                if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                    tripOne = Double(Utils.kmToMiles(Double(tripOne)))
                }
                value = "\(Utils.toOneDecimalString(tripOne))"
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case MotorcycleData.shared.DATA_TRIP_TWO:
            // Trip 2
            if MotorcycleData.shared.tripTwo != nil {
                var tripTwo:Double = MotorcycleData.shared.gettripTwo()
                if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                    tripTwo = Double(Utils.kmToMiles(Double(tripTwo)))
                }
                value = "\(Utils.toOneDecimalString(tripTwo))"
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case MotorcycleData.shared.DATA_TRIP_AUTO:
            // Trip Auto
            if MotorcycleData.shared.tripAuto != nil {
                var tripAuto:Double = MotorcycleData.shared.gettripAuto()
                if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                    tripAuto = Double(Utils.kmToMiles(Double(tripAuto)))
                }
                value = "\(Utils.toOneDecimalString(tripAuto))"
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case MotorcycleData.shared.DATA_SPEED:
            // Speed
            if MotorcycleData.shared.speed != nil {
                var speedValue = MotorcycleData.shared.speed!
                if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                    speedValue = Utils.kmToMiles(speedValue)
                }
                value = "\(Utils.toZeroDecimalString(speedValue))"
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case MotorcycleData.shared.DATA_AVG_SPEED:
            //Average Speed
            if MotorcycleData.shared.averageSpeed != nil {
                var avgSpeedValue:Double = MotorcycleData.shared.averageSpeed!
                if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                    avgSpeedValue = Utils.kmToMiles(avgSpeedValue)
                }
                value = "\(Int(avgSpeedValue))"
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case MotorcycleData.shared.DATA_CURRENT_CONSUMPTION:
            //Current Consumption
            if MotorcycleData.shared.currentConsumption != nil {
                var currentConsumptionValue:Double = MotorcycleData.shared.currentConsumption!
                switch UserDefaults.standard.integer(forKey: "consumption_unit_preference"){
                case 1:
                    currentConsumptionValue = Utils.l100ToMpg(currentConsumptionValue)
                case 2:
                    currentConsumptionValue = Utils.l100ToMpgi(currentConsumptionValue)
                case 3:
                    currentConsumptionValue = Utils.l100Tokml(currentConsumptionValue)
                default:
                    break
                }
                value = "\(Utils.toOneDecimalString(currentConsumptionValue))"
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case MotorcycleData.shared.DATA_ECONOMY_ONE:
            //Fuel Economy One
            if MotorcycleData.shared.fuelEconomyOne != nil {
                var fuelEconomyOneValue:Double = MotorcycleData.shared.fuelEconomyOne!
                switch UserDefaults.standard.integer(forKey: "consumption_unit_preference"){
                case 1:
                    fuelEconomyOneValue = Utils.l100ToMpg(fuelEconomyOneValue)
                case 2:
                    fuelEconomyOneValue = Utils.l100ToMpgi(fuelEconomyOneValue)
                case 3:
                    fuelEconomyOneValue = Utils.l100Tokml(fuelEconomyOneValue)
                default:
                    break
                }
                value = "\(Utils.toOneDecimalString(fuelEconomyOneValue))"
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case MotorcycleData.shared.DATA_ECONOMY_TWO:
            //Fuel Economy Two
            if MotorcycleData.shared.fuelEconomyTwo != nil {
                var fuelEconomyTwoValue:Double = MotorcycleData.shared.fuelEconomyTwo!
                switch UserDefaults.standard.integer(forKey: "consumption_unit_preference"){
                case 1:
                    fuelEconomyTwoValue = Utils.l100ToMpg(fuelEconomyTwoValue)
                case 2:
                    fuelEconomyTwoValue = Utils.l100ToMpgi(fuelEconomyTwoValue)
                case 3:
                    fuelEconomyTwoValue = Utils.l100Tokml(fuelEconomyTwoValue)
                default:
                    break
                }
                value = "\(Utils.toOneDecimalString(fuelEconomyTwoValue))"
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case MotorcycleData.shared.DATA_RANGE:
            //Fuel Range
            if MotorcycleData.shared.fuelRange != nil {
                var fuelRangeValue:Double = MotorcycleData.shared.fuelRange!
                if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                    fuelRangeValue = Utils.kmToMiles(fuelRangeValue)
                }
                value = "\(Utils.toZeroDecimalString(fuelRangeValue))"
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case MotorcycleData.shared.DATA_SHIFTS:
            //Shifts
            if MotorcycleData.shared.shifts != nil {
                value = "\(MotorcycleData.shared.shifts!)"
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case MotorcycleData.shared.DATA_LEAN_DEVICE:
            //Lean Angle
            if MotorcycleData.shared.leanAngle != nil {
                value = "\(Utils.toZeroDecimalString(MotorcycleData.shared.leanAngle!))"
            }
        case MotorcycleData.shared.DATA_GFORCE_DEVICE:
            //g-force
            if MotorcycleData.shared.gForce != nil {
                value = "\(MotorcycleData.shared.gForce!.rounded(toPlaces: 1))"
            }
        case MotorcycleData.shared.DATA_BEARING_DEVICE:
            //Bearing
            if MotorcycleData.shared.bearing != nil {
                value = "\(MotorcycleData.shared.bearing!)"
                if UserDefaults.standard.integer(forKey: "bearing_unit_preference") != 0 {
                    let bearing = MotorcycleData.shared.bearing!
                    var cardinal = "-";
                    if bearing > 331 || bearing <= 28 {
                        cardinal = NSLocalizedString("north", comment: "")
                    } else if bearing > 28 && bearing <= 73 {
                        cardinal = NSLocalizedString("north_east", comment: "")
                    } else if bearing > 73 && bearing <= 118 {
                        cardinal = NSLocalizedString("east", comment: "")
                    } else if bearing > 118 && bearing <= 163 {
                        cardinal = NSLocalizedString("south_east", comment: "")
                    } else if bearing > 163 && bearing <= 208 {
                        cardinal = NSLocalizedString("south", comment: "")
                    } else if bearing > 208 && bearing <= 253 {
                        cardinal = NSLocalizedString("south_west", comment: "")
                    } else if bearing > 253 && bearing <= 298 {
                        cardinal = NSLocalizedString("west", comment: "")
                    } else if bearing > 298 && bearing <= 331 {
                        cardinal = NSLocalizedString("north_west", comment: "")
                    } else {
                        cardinal = "-"
                    }
                    value = cardinal
                }
            }
        case MotorcycleData.shared.DATA_TIME_DEVICE:
            //Time
            if MotorcycleData.shared.time != nil {
                let formatter = DateFormatter()
                formatter.dateFormat = "h:mm a"
                if UserDefaults.standard.integer(forKey: "time_format_preference") > 0 {
                    formatter.dateFormat = "HH:mm"
                }
                value = ("\(formatter.string(from: MotorcycleData.shared.time!))")
            }
        case MotorcycleData.shared.DATA_BAROMETRIC_DEVICE:
            //Barometric Pressure
            if MotorcycleData.shared.barometricPressure != nil {
                value = "\(Utils.toZeroDecimalString(MotorcycleData.shared.barometricPressure!))"
            }
        case MotorcycleData.shared.DATA_SPEED_DEVICE:
            //GPS speed
            if MotorcycleData.shared.location != nil {
                var gpsSpeed:String = "0"
                if MotorcycleData.shared.location!.speed >= 0{
                    gpsSpeed = "\(MotorcycleData.shared.location!.speed * 3.6)"
                    let gpsSpeedValue:Double = MotorcycleData.shared.location!.speed * 3.6
                    gpsSpeed = "\(Int(round(gpsSpeedValue)))"
                    if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                        gpsSpeed = "\(Int(round(Utils.kmToMiles(gpsSpeedValue))))"
                    }
                    value = gpsSpeed
                }
            }
        case MotorcycleData.shared.DATA_ALTITUDE_DEVICE:
            //Altitude
            if MotorcycleData.shared.location != nil {
                var altitude:Double = MotorcycleData.shared.location!.altitude
                if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                    altitude = Utils.mtoFeet(MotorcycleData.shared.location!.altitude)
                }
                value = Utils.toZeroDecimalString(altitude)
            }
        case MotorcycleData.shared.DATA_SUN_DEVICE:
            //Sunrise/Sunset
            if MotorcycleData.shared.location != nil {
                let today = Date()
                let solar = Solar(for: today, coordinate: MotorcycleData.shared.location!.coordinate)
                let sunrise = solar?.sunrise
                let sunset = solar?.sunset
                let formatter = DateFormatter()
                formatter.dateFormat = "h:mm a"
                if UserDefaults.standard.integer(forKey: "time_format_preference") > 0 {
                    formatter.dateFormat = "HH:mm"
                }
                // Calculate the duration between the current time and sunrise/sunset
                let sunriseDuration = sunrise!.timeIntervalSince(today)
                let sunsetDuration = sunset!.timeIntervalSince(today)
                
                // Convert durations to hours
                let sunriseHrs = Utils.toZeroDecimalString(Double(sunriseDuration) / 3600.0)
                let sunsetHrs = Utils.toZeroDecimalString(Double(sunsetDuration) / 3600.0)
                
                value = ("\(formatter.string(from: sunrise!)) (\(sunriseHrs))\n\(formatter.string(from: sunset!)) (\(sunsetHrs))")
            }
        case MotorcycleData.shared.DATA_RPM:
            //RPM
            if ((MotorcycleData.shared.rpm != nil) && MotorcycleData.shared.rpm != 0) {
                let rpmValue:Double = Double(MotorcycleData.shared.rpm!) / 1000.0
                value = "\(rpmValue.rounded(toPlaces: 1))"
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case MotorcycleData.shared.DATA_LEAN:
            //Lean Angle Bike
            if MotorcycleData.shared.leanAngleBike != nil {
                value = "\(Utils.toZeroDecimalString(MotorcycleData.shared.leanAngleBike!))"
            }
        case MotorcycleData.shared.DATA_REAR_SPEED:
            // Rear Wheel Speed
            if MotorcycleData.shared.rearSpeed != nil {
                var speedValue = MotorcycleData.shared.rearSpeed!
                if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                    speedValue = Utils.kmToMiles(speedValue)
                }
                value = "\(Utils.toZeroDecimalString(speedValue))"
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case MotorcycleData.shared.DATA_BATTERY_DEVICE:
            // Device Battery
            if MotorcycleData.shared.localBattery != nil {
                let batteryPct = MotorcycleData.shared.localBattery!
                value = "\(Int(batteryPct))"
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case MotorcycleData.shared.DATA_ELEVATION_CHANGE_DEVICE:
            //Elevation change
            var elevationChange:Double = MotorcycleData.shared.getElevationChange()
            if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                elevationChange = Utils.mtoFeet(elevationChange)
            }
            value = "\(elevationChange.rounded(toPlaces: 1))"
        default:
            NSLog("MotorcycleData: Unknown : \(dataPoint)")
        }
        
        return value
    }
}
