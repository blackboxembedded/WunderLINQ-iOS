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
    var location: CLLocation?
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
    
    func setLocation(location: CLLocation?){
        self.location = location
    }
    func getLocation() -> CLLocation{
        return self.location!
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
    }
}
