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
    
    func setHasFocus(hasFocus: Bool?){
        self.hasFocus = hasFocus
    }
    func getHasFocus() -> Bool{
        return self.hasFocus!
    }
    
    func setLocation(location: CLLocation?){
        self.location = location
    }
    func getLocation() -> CLLocation? {
        return self.location
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
            label = NSLocalizedString("rpm_header", comment: "")
        case MotorcycleData.shared.DATA_LEAN:
            //Lean Angle
            label = NSLocalizedString("leanangle_bike_header", comment: "")
        case MotorcycleData.shared.DATA_REAR_SPEED:
            //Rear Wheel Speed
            label = NSLocalizedString("rearwheel_speed_header", comment: "")
        case MotorcycleData.shared.DATA_BATTERY_DEVICE:
            //Device Battery
            label = NSLocalizedString("local_battery_header", comment: "")
        default:
            NSLog("MotorcycleData: Unknown : \(dataPoint)")
        }
        
        return label
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
                var engineTemp:Double = MotorcycleData.shared.engineTemperature!
                if (engineTemp >= 104.0){
                    icon = icon.imageWithColor(color1: UIColor.red)
                }
            }
        case MotorcycleData.shared.DATA_AIR_TEMP:
            // Ambient Temperature
            icon = (UIImage(named: "Thermometer")?.withRenderingMode(.alwaysTemplate))!
            if (MotorcycleData.shared.ambientTemperature != nil) {
                var ambientTemp:Double = MotorcycleData.shared.ambientTemperature!
                if(ambientTemp <= 0){
                    icon = (UIImage(named: "Snowflake")?.withRenderingMode(.alwaysTemplate))!
                    icon = icon.imageWithColor(color1: UIColor.blue)
                }
            }
        case MotorcycleData.shared.DATA_FRONT_RDC:
            // Front Tire Pressure
            icon = (UIImage(named: "Tire")?.withRenderingMode(.alwaysTemplate))!
            if(Faults.shared.getFrontTirePressureCriticalActive()){
                icon = (UIImage(named: "Tire-Alert")?.withRenderingMode(.alwaysTemplate))!
                icon = icon.imageWithColor(color1: UIColor.red)
            } else if(Faults.shared.getRearTirePressureWarningActive()){
                icon = (UIImage(named: "Tire-Alert")?.withRenderingMode(.alwaysTemplate))!
                icon = icon.imageWithColor(color1: UIColor.yellow)
            }
        case MotorcycleData.shared.DATA_REAR_RDC:
            // Rear Tire Pressure
            icon = (UIImage(named: "Tire")?.withRenderingMode(.alwaysTemplate))!
            if(Faults.shared.getRearTirePressureCriticalActive()){
                icon = (UIImage(named: "Tire-Alert")?.withRenderingMode(.alwaysTemplate))!
                icon = icon.imageWithColor(color1: UIColor.red)
            } else if(Faults.shared.getRearTirePressureWarningActive()){
                icon = (UIImage(named: "Tire-Alert")?.withRenderingMode(.alwaysTemplate))!
                icon = icon.imageWithColor(color1: UIColor.yellow)
            }
        case MotorcycleData.shared.DATA_ODOMETER:
            // Odometer
            icon = (UIImage(named: "Odometer")?.withRenderingMode(.alwaysTemplate))!
        case MotorcycleData.shared.DATA_VOLTAGE:
            // Voltage
            icon = (UIImage(named: "Battery")?.withRenderingMode(.alwaysTemplate))!
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
                let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
                let solar = Solar(for: yesterday, coordinate: MotorcycleData.shared.location!.coordinate)
                let sunset = solar?.sunset
                if(today > sunset!){
                    icon = (UIImage(named: "Moon")?.withRenderingMode(.alwaysTemplate))!
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
                } else if(batteryPct > 75 && batteryPct < 95){
                    icon = (UIImage(named: "Battery-Three-Quarters")?.withRenderingMode(.alwaysTemplate))!
                } else if(batteryPct > 50 && batteryPct < 75){
                    icon = (UIImage(named: "Battery-Half")?.withRenderingMode(.alwaysTemplate))!
                } else if(batteryPct > 25 && batteryPct < 50){
                    icon = (UIImage(named: "Battery-Quarter")?.withRenderingMode(.alwaysTemplate))!
                } else if(batteryPct > 0 && batteryPct < 25){
                    icon = (UIImage(named: "Battery-Empty")?.withRenderingMode(.alwaysTemplate))!
                    icon = icon.imageWithColor(color1: UIColor.red)
                }
            }
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
                    engineTemp = Utility.celciusToFahrenheit(engineTemp)
                }
                value = "\(engineTemp.rounded(toPlaces: 1))"
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case MotorcycleData.shared.DATA_AIR_TEMP:
            // Ambient Temperature
            if MotorcycleData.shared.ambientTemperature != nil {
                var ambientTemp:Double = MotorcycleData.shared.ambientTemperature!
                if UserDefaults.standard.integer(forKey: "temperature_unit_preference") == 1 {
                    ambientTemp = Utility.celciusToFahrenheit(ambientTemp)
                }
                value = "\(ambientTemp.rounded(toPlaces: 1))"
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case MotorcycleData.shared.DATA_FRONT_RDC:
            // Front Tire Pressure
            if MotorcycleData.shared.frontTirePressure != nil {
                var frontPressure:Double = MotorcycleData.shared.frontTirePressure!
                switch UserDefaults.standard.integer(forKey: "pressure_unit_preference"){
                case 1:
                    frontPressure = Utility.barTokPa(frontPressure)
                case 2:
                    frontPressure = Utility.barTokgf(frontPressure)
                case 3:
                    frontPressure = Utility.barToPsi(frontPressure)
                default:
                    break
                }
                value = "\(frontPressure.rounded(toPlaces: 1))"
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case MotorcycleData.shared.DATA_REAR_RDC:
            // Rear Tire Pressure
            if MotorcycleData.shared.rearTirePressure != nil {
                var rearPressure:Double = MotorcycleData.shared.rearTirePressure!
                switch UserDefaults.standard.integer(forKey: "pressure_unit_preference"){
                case 1:
                    rearPressure = Utility.barTokPa(rearPressure)
                case 2:
                    rearPressure = Utility.barTokgf(rearPressure)
                case 3:
                    rearPressure = Utility.barToPsi(rearPressure)
                default:
                    break
                }
                value = "\(rearPressure.rounded(toPlaces: 1))"
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case MotorcycleData.shared.DATA_ODOMETER:
            // Odometer
            if MotorcycleData.shared.odometer != nil {
                var odometer:Double = MotorcycleData.shared.odometer!
                if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                    odometer = Double(Utility.kmToMiles(Double(odometer)))
                }
                value = "\(Int(odometer))"
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case MotorcycleData.shared.DATA_VOLTAGE:
            // Voltage
            if MotorcycleData.shared.voltage != nil {
                value = "\(MotorcycleData.shared.voltage!)"
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case MotorcycleData.shared.DATA_THROTTLE:
            // Trottle
            if MotorcycleData.shared.throttlePosition != nil {
                value = "\(Int(round(MotorcycleData.shared.throttlePosition!)))"
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
                value = "\(MotorcycleData.shared.ambientLight!)"
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case MotorcycleData.shared.DATA_TRIP_ONE:
            // Trip 1
            if MotorcycleData.shared.tripOne != nil {
                var tripOne:Double = MotorcycleData.shared.tripOne!
                if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                    tripOne = Double(Utility.kmToMiles(Double(tripOne)))
                }
                value = "\(tripOne.rounded(toPlaces: 1))"
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case MotorcycleData.shared.DATA_TRIP_TWO:
            // Trip 2
            if MotorcycleData.shared.tripTwo != nil {
                var tripTwo:Double = MotorcycleData.shared.gettripTwo()
                if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                    tripTwo = Double(Utility.kmToMiles(Double(tripTwo)))
                }
                value = "\(tripTwo.rounded(toPlaces: 1))"
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case MotorcycleData.shared.DATA_TRIP_AUTO:
            // Trip Auto
            if MotorcycleData.shared.tripAuto != nil {
                var tripAuto:Double = MotorcycleData.shared.gettripAuto()
                if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                    tripAuto = Double(Utility.kmToMiles(Double(tripAuto)))
                }
                value = "\(tripAuto.rounded(toPlaces: 1))"
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case MotorcycleData.shared.DATA_SPEED:
            // Speed
            if MotorcycleData.shared.speed != nil {
                let speedValue = MotorcycleData.shared.speed!
                value = "\(Int(speedValue))"
                if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                    value = "\(Int(round(Utility.kmToMiles(speedValue))))"
                }
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case MotorcycleData.shared.DATA_AVG_SPEED:
            //Average Speed
            if MotorcycleData.shared.averageSpeed != nil {
                let avgSpeedValue:Double = MotorcycleData.shared.averageSpeed!
                value = "\(Int(avgSpeedValue))"
                if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                    value = "\(Int(round(Utility.kmToMiles(avgSpeedValue))))"
                }
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case MotorcycleData.shared.DATA_CURRENT_CONSUMPTION:
            //Current Consumption
            if MotorcycleData.shared.currentConsumption != nil {
                let currentConsumptionValue:Double = MotorcycleData.shared.currentConsumption!
                value = "\(currentConsumptionValue.rounded(toPlaces: 1))"
                switch UserDefaults.standard.integer(forKey: "consumption_unit_preference"){
                case 1:
                    value = "\(Utility.l100ToMpg(currentConsumptionValue).rounded(toPlaces: 1))"
                case 2:
                    value = "\(Utility.l100ToMpgi(currentConsumptionValue).rounded(toPlaces: 1))"
                case 3:
                    value = "\(Utility.l100Tokml(currentConsumptionValue).rounded(toPlaces: 1))"
                default:
                    value = "\(currentConsumptionValue.rounded(toPlaces: 1))"
                }
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case MotorcycleData.shared.DATA_ECONOMY_ONE:
            //Fuel Economy One
            if MotorcycleData.shared.fuelEconomyOne != nil {
                let fuelEconomyOneValue:Double = MotorcycleData.shared.fuelEconomyOne!
                value = "\(fuelEconomyOneValue.rounded(toPlaces: 1))"
                switch UserDefaults.standard.integer(forKey: "consumption_unit_preference"){
                case 1:
                    value = "\(Utility.l100ToMpg(fuelEconomyOneValue).rounded(toPlaces: 1))"
                case 2:
                    value = "\(Utility.l100ToMpgi(fuelEconomyOneValue).rounded(toPlaces: 1))"
                case 3:
                    value = "\(Utility.l100Tokml(fuelEconomyOneValue).rounded(toPlaces: 1))"
                default:
                    value = "\(fuelEconomyOneValue.rounded(toPlaces: 1))"
                }
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case MotorcycleData.shared.DATA_ECONOMY_TWO:
            //Fuel Economy Two
            if MotorcycleData.shared.fuelEconomyTwo != nil {
                let fuelEconomyTwoValue:Double = MotorcycleData.shared.fuelEconomyTwo!
                value = "\(fuelEconomyTwoValue.rounded(toPlaces: 1))"
                switch UserDefaults.standard.integer(forKey: "consumption_unit_preference"){
                case 1:
                    value = "\(Utility.l100ToMpg(fuelEconomyTwoValue).rounded(toPlaces: 1))"
                case 2:
                    value = "\(Utility.l100ToMpgi(fuelEconomyTwoValue).rounded(toPlaces: 1))"
                case 3:
                    value = "\(Utility.l100Tokml(fuelEconomyTwoValue).rounded(toPlaces: 1))"
                default:
                    value = "\(fuelEconomyTwoValue.rounded(toPlaces: 1))"
                }
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case MotorcycleData.shared.DATA_RANGE:
            //Fuel Range
            if MotorcycleData.shared.fuelRange != nil {
                let fuelRangeValue:Double = MotorcycleData.shared.fuelRange!
                value = "\(Int(fuelRangeValue))"
                if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                    value = "\(Int(round(Utility.kmToMiles(fuelRangeValue))))"
                }
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
                value = "\(Int(round(MotorcycleData.shared.leanAngle!)))"
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
                value = "\(Int(round(MotorcycleData.shared.barometricPressure!)))"
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
                        gpsSpeed = "\(Int(round(Utility.kmToMiles(gpsSpeedValue))))"
                    }
                    value = gpsSpeed
                }
            }
        case MotorcycleData.shared.DATA_ALTITUDE_DEVICE:
            //Altitude
            if MotorcycleData.shared.location != nil {
                var altitude:String = "\(Int(round(MotorcycleData.shared.location!.altitude)))"
                if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                    altitude = "\(Int(round(Utility.mtoFeet(MotorcycleData.shared.location!.altitude))))"
                }
                value = altitude
            }
        case MotorcycleData.shared.DATA_SUN_DEVICE:
            //Sunrise/Sunset
            if MotorcycleData.shared.location != nil {
                let today = Date()
                let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
                let solar = Solar(for: yesterday, coordinate: MotorcycleData.shared.location!.coordinate)
                let sunrise = solar?.sunrise
                let sunset = solar?.sunset
                let formatter = DateFormatter()
                formatter.dateFormat = "h:mm a"
                if UserDefaults.standard.integer(forKey: "time_format_preference") > 0 {
                    formatter.dateFormat = "HH:mm"
                }
                value = ("\(formatter.string(from: sunrise!))/\(formatter.string(from: sunset!))")
            }
        case MotorcycleData.shared.DATA_RPM:
            //RPM
            if ((MotorcycleData.shared.rpm != nil) && MotorcycleData.shared.rpm != 0) {
                value = "\(MotorcycleData.shared.rpm!)"
            } else {
                value = NSLocalizedString("blank_field", comment: "")
            }
        case MotorcycleData.shared.DATA_LEAN:
            //Lean Angle Bike
            if MotorcycleData.shared.leanAngleBike != nil {
                value = "\(Int(round(MotorcycleData.shared.leanAngleBike!)))"
            }
        case MotorcycleData.shared.DATA_REAR_SPEED:
            // Rear Wheel Speed
            if MotorcycleData.shared.rearSpeed != nil {
                let speedValue = MotorcycleData.shared.rearSpeed!
                value = "\(Int(speedValue))"
                if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                    value = "\(Int(round(Utility.kmToMiles(speedValue))))"
                }
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
        default:
            NSLog("MotorcycleData: Unknown : \(dataPoint)")
        }
        
        return value
    }
}
