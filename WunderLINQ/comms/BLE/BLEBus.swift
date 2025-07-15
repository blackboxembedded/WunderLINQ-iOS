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

class BLEBus {
    class func parseMessage(_ data:[UInt8]) {
        let motorcycleData = MotorcycleData.shared
        let faults = Faults.shared
        
        let lastMessage = data
        switch lastMessage[0] {
        case 0x00:
            // VIN
            if (lastMessage[1] != 0xFF && lastMessage[2] != 0xFF && lastMessage[3] != 0xFF && lastMessage[4] != 0xFF && lastMessage[5] != 0xFF && lastMessage[6] != 0xFF && lastMessage[7] != 0xFF){
                let bytes: [UInt8] = [lastMessage[1],lastMessage[2],lastMessage[3],lastMessage[4],lastMessage[5],lastMessage[6],lastMessage[7]]
                let vin = String(bytes: bytes, encoding: .utf8)
                motorcycleData.setVIN(vin: vin)
            }
        case 0x01:
            // Ignition
            if (((lastMessage[2] >> 4) & 0x0F) != 0xF) {
                let ignitionValue = (lastMessage[2] >> 4) & 0x0F // the highest 4 bits.
                switch (ignitionValue) {
                case 0x0:
                    motorcycleData.setIgnitionStatus(ignitionStatus: false)
                case 0x1:
                    motorcycleData.setIgnitionStatus(ignitionStatus: false)
                case 0x2:
                    motorcycleData.setIgnitionStatus(ignitionStatus: false)
                case 0x3:
                    motorcycleData.setIgnitionStatus(ignitionStatus: false)
                case 0x4:
                    motorcycleData.setIgnitionStatus(ignitionStatus: true)
                case 0x5:
                    motorcycleData.setIgnitionStatus(ignitionStatus: true)
                case 0x6:
                    motorcycleData.setIgnitionStatus(ignitionStatus: true)
                case 0x7:
                    motorcycleData.setIgnitionStatus(ignitionStatus: true)
                default:
                    break
                }
            }
            // Rear Wheel Speed
            if ((lastMessage[3] != 0xFF) && (lastMessage[4] != 0xFF)){
                let rearSpeed = Double(lastMessage[3] | ((lastMessage[4] & 0x0F) << 8))  * 0.14
                motorcycleData.setRearSpeed(rearSpeed: rearSpeed)
            }
            // Fuel Range
            if ((lastMessage[4] != 0xFF) && (lastMessage[5] != 0xFF)){
                let firstNibble = Double((lastMessage[4] >> 4) & 0x0F)
                let secondNibble = Double((lastMessage[5] & 0x0F)) * 16
                let thirdNibble = Double(((lastMessage[5] >> 4) & 0x0F)) * 256
                let fuelRange = firstNibble + secondNibble + thirdNibble
                motorcycleData.setfuelRange(fuelRange: fuelRange)
            }
            // Ambient Light
            if ((lastMessage[6] & 0x0F) != 0xF){
                let ambientLightValue = lastMessage[6] & 0x0F
                motorcycleData.setambientLight(ambientLight: Double(ambientLightValue))
            }
        case 0x04:
            // Control
            break
        case 0x05:
            // Lean Angle
            if ((lastMessage[1] != 0xFF) && ((lastMessage[2] & 0x0F) != 0xF)){
                let leanAngleBike:Double = Double(UInt32((UInt32((lastMessage[2] & 0x0F)) << 8 | UInt32(lastMessage[1]))))
                var leanAngleBikeFixed:Double = 0
                if(leanAngleBike >= 2048){
                    leanAngleBikeFixed = leanAngleBike - 2048
                } else {
                    leanAngleBikeFixed = (2048 - leanAngleBike) * -1
                }
                leanAngleBikeFixed = (leanAngleBikeFixed * 0.045)
                motorcycleData.setleanAngleBike(leanAngleBike: leanAngleBikeFixed)
                
                // Store Max L and R lean angle
                if(leanAngleBikeFixed > 0){
                    if (motorcycleData.leanAngleMaxR != nil) {
                        if (leanAngleBikeFixed > motorcycleData.leanAngleMaxR!) {
                            motorcycleData.setleanAngleMaxR(leanAngleMaxR: leanAngleBikeFixed)
                        }
                    } else {
                        motorcycleData.setleanAngleMaxR(leanAngleMaxR: leanAngleBikeFixed)
                    }
                } else if(leanAngleBikeFixed < 0){
                    if (motorcycleData.leanAngleMaxL != nil) {
                        if (abs(leanAngleBikeFixed) > motorcycleData.leanAngleMaxL!) {
                            motorcycleData.setleanAngleMaxL(leanAngleMaxL: abs(leanAngleBikeFixed))
                        }
                    } else {
                        motorcycleData.setleanAngleMaxL(leanAngleMaxL: abs(leanAngleBikeFixed))
                    }
                }
            }
            
            // Brakes
            if (((lastMessage[2] >> 4) & 0x0F) != 0xF){
                let brakes = (lastMessage[2] >> 4) & 0x0F // the highest 4 bits.
                if(motorcycleData.getPrevBrake() == 0){
                    motorcycleData.setPrevBrake(prevBrake: Int(brakes))
                }
                if (motorcycleData.getPrevBrake() != brakes) {
                    motorcycleData.setPrevBrake(prevBrake: Int(brakes))
                    switch (brakes) {
                    case 0x6:
                        //Front
                        motorcycleData.setfrontBrake(frontBrake: motorcycleData.frontBrake! + 1)
                        
                    case 0x9:
                        //Back
                        motorcycleData.setrearBrake(rearBrake: motorcycleData.rearBrake! + 1)
                        
                    case 0xA:
                        //Both
                        motorcycleData.setfrontBrake(frontBrake: motorcycleData.frontBrake! + 1)
                        motorcycleData.setrearBrake(rearBrake: motorcycleData.rearBrake! + 1)
                        
                    default:
                        break
                    }
                }
            }
            // ABS Fault
            if ((lastMessage[3] & 0x0F) != 0xF){
                let absValue = lastMessage[3] & 0x0F // the lowest 4 bits
                switch (absValue){
                case 0x2:
                    faults.setAbsSelfDiagActive(active: false)
                    faults.setAbsSelfDiagActive(active: false)
                    faults.setAbsDeactivatedActive(active: false)
                    faults.setAbsErrorActive(active: true)
                    
                case 0x3:
                    faults.setAbsSelfDiagActive(active: true)
                    faults.setAbsDeactivatedActive(active: false)
                    faults.setAbsErrorActive(active: false)
                    break;
                case 0x5:
                    faults.setAbsSelfDiagActive(active: false)
                    faults.setAbsDeactivatedActive(active: false)
                    faults.setAbsErrorActive(active: true)
                    
                case 0x6:
                    faults.setAbsSelfDiagActive(active: false)
                    faults.setAbsDeactivatedActive(active: false)
                    faults.setAbsErrorActive(active: true)
                    
                case 0x7:
                    faults.setAbsSelfDiagActive(active: false)
                    faults.setAbsDeactivatedActive(active: false)
                    faults.setAbsErrorActive(active: true)
                    
                case 0x8:
                    faults.setAbsSelfDiagActive(active: false)
                    faults.setAbsDeactivatedActive(active: true)
                    faults.setAbsErrorActive(active: false)
                    
                case 0xA:
                    faults.setAbsSelfDiagActive(active: false)
                    faults.setAbsDeactivatedActive(active: false)
                    faults.setAbsErrorActive(active: true)
                    
                case 0xB:
                    faults.setAbsSelfDiagActive(active: true)
                    faults.setAbsDeactivatedActive(active: false)
                    faults.setAbsErrorActive(active: false)
                    
                case 0xD:
                    faults.setAbsSelfDiagActive(active: false)
                    faults.setAbsDeactivatedActive(active: false)
                    faults.setAbsErrorActive(active: true)
                    
                case 0xE:
                    faults.setAbsSelfDiagActive(active: false)
                    faults.setAbsDeactivatedActive(active: false)
                    faults.setAbsErrorActive(active: true)
                    
                case 0xF:
                    faults.setAbsSelfDiagActive(active: false)
                    faults.setAbsDeactivatedActive(active: false)
                    faults.setAbsErrorActive(active: false)
                    
                default:
                    faults.setAbsSelfDiagActive(active: false)
                    faults.setAbsDeactivatedActive(active: false)
                    faults.setAbsErrorActive(active: false)
                    break;
                }
            }
            // Tire Pressure
            if (lastMessage[4] != 0xFF){
                var frontPressure:Double = Double(lastMessage[4]) / 50
                motorcycleData.setfrontTirePressure(frontTirePressure: frontPressure)
                if UserDefaults.standard.bool(forKey: "custom_tpm_preference"){
                    switch UserDefaults.standard.integer(forKey: "pressure_unit_preference"){
                    case 1:
                        frontPressure = Utils.barTokPa(frontPressure)
                    case 2:
                        frontPressure = Utils.barTokgf(frontPressure)
                    case 3:
                        frontPressure = Utils.barToPsi(frontPressure)
                    default:
                        NSLog("Unknown pressure unit setting")
                    }
                    if frontPressure <= UserDefaults.standard.double(forKey: "tpm_threshold_preference"){
                        faults.setFrontTirePressureCriticalActive(active: true)
                        if (UserDefaults.standard.bool(forKey: "notification_preference")){
                            faults.frontTirePressureCriticalNotificationActive = true
                        }
                    } else {
                        faults.setFrontTirePressureCriticalActive(active: false)
                        if (UserDefaults.standard.bool(forKey: "notification_preference")){
                            faults.frontTirePressureCriticalNotificationActive = false
                        }
                    }
                }
            }
            if (lastMessage[5] != 0xFF){
                var rearPressure:Double = Double(lastMessage[5]) / 50
                motorcycleData.setrearTirePressure(rearTirePressure: rearPressure)
                if UserDefaults.standard.bool(forKey: "custom_tpm_preference"){
                    switch UserDefaults.standard.integer(forKey: "pressure_unit_preference"){
                    case 1:
                        rearPressure = Utils.barTokPa(rearPressure)
                    case 2:
                        rearPressure = Utils.barTokgf(rearPressure)
                    case 3:
                        rearPressure = Utils.barToPsi(rearPressure)
                    default:
                        NSLog("Unknown pressure unit setting")
                    }
                    if rearPressure <= UserDefaults.standard.double(forKey: "tpm_threshold_preference"){
                        faults.setRearTirePressureCriticalActive(active: true)
                        if (UserDefaults.standard.bool(forKey: "notification_preference")){
                            faults.rearTirePressureCriticalNotificationActive = true
                        }
                    } else {
                        faults.setRearTirePressureCriticalActive(active: false)
                        if (UserDefaults.standard.bool(forKey: "notification_preference")){
                            faults.rearTirePressureCriticalNotificationActive = false
                        }
                    }
                }
            }
            // Tire Pressure Faults
            if (lastMessage[6] != 0xFF){
                if !UserDefaults.standard.bool(forKey: "custom_tpm_preference"){
                    switch (lastMessage[6]) {
                    case 0xC9:
                        faults.setFrontTirePressureWarningActive(active: true)
                        faults.setRearTirePressureWarningActive(active: false)
                        faults.setFrontTirePressureCriticalActive(active: false)
                        faults.setRearTirePressureCriticalActive(active: false)
                        if (UserDefaults.standard.bool(forKey: "notification_preference")){
                            if(faults.frontTirePressureCriticalNotificationActive) {
                                faults.frontTirePressureCriticalNotificationActive = false
                            }
                            if(faults.rearTirePressureCriticalNotificationActive) {
                                faults.rearTirePressureCriticalNotificationActive = false
                            }
                        }
                        
                    case 0xCA:
                        faults.setFrontTirePressureWarningActive(active: false)
                        faults.setRearTirePressureWarningActive(active: true)
                        faults.setFrontTirePressureCriticalActive(active: false)
                        faults.setRearTirePressureCriticalActive(active: false)
                        if (UserDefaults.standard.bool(forKey: "notification_preference")){
                            if(faults.frontTirePressureCriticalNotificationActive) {
                                faults.frontTirePressureCriticalNotificationActive = false
                            }
                            if(faults.rearTirePressureCriticalNotificationActive) {
                                faults.rearTirePressureCriticalNotificationActive = false
                            }
                        }
                        
                    case 0xCB:
                        faults.setFrontTirePressureWarningActive(active: true)
                        faults.setRearTirePressureWarningActive(active: true)
                        faults.setFrontTirePressureCriticalActive(active: false)
                        faults.setRearTirePressureCriticalActive(active: false)
                        if (UserDefaults.standard.bool(forKey: "notification_preference")){
                            if(faults.frontTirePressureCriticalNotificationActive) {
                                faults.frontTirePressureCriticalNotificationActive = false
                            }
                            if(faults.rearTirePressureCriticalNotificationActive) {
                                faults.rearTirePressureCriticalNotificationActive = false
                            }
                        }
                        
                    case 0xD1:
                        faults.setFrontTirePressureWarningActive(active: false)
                        faults.setRearTirePressureWarningActive(active: false)
                        faults.setFrontTirePressureCriticalActive(active: true)
                        faults.setRearTirePressureCriticalActive(active: false)
                        if (UserDefaults.standard.bool(forKey: "notification_preference")){
                            if(!faults.frontTirePressureCriticalNotificationActive) {
                                faults.frontTirePressureCriticalNotificationActive = true
                            }
                            if(faults.rearTirePressureCriticalNotificationActive) {
                                faults.rearTirePressureCriticalNotificationActive = false
                            }
                        }
                        
                    case 0xD2:
                        faults.setFrontTirePressureWarningActive(active: false)
                        faults.setRearTirePressureWarningActive(active: false)
                        faults.setFrontTirePressureCriticalActive(active: false)
                        faults.setRearTirePressureCriticalActive(active: true)
                        if (UserDefaults.standard.bool(forKey: "notification_preference")){
                            if(faults.frontTirePressureCriticalNotificationActive) {
                                faults.frontTirePressureCriticalNotificationActive = false
                            }
                            if(!faults.rearTirePressureCriticalNotificationActive) {
                                faults.rearTirePressureCriticalNotificationActive = true
                            }
                        }
                        
                    case 0xD3:
                        faults.setFrontTirePressureWarningActive(active: false)
                        faults.setRearTirePressureWarningActive(active: false)
                        faults.setFrontTirePressureCriticalActive(active: true)
                        faults.setRearTirePressureCriticalActive(active: true)
                        if (UserDefaults.standard.bool(forKey: "notification_preference")){
                            if(!faults.frontTirePressureCriticalNotificationActive) {
                                faults.frontTirePressureCriticalNotificationActive = true
                            }
                            if(!faults.rearTirePressureCriticalNotificationActive) {
                                faults.rearTirePressureCriticalNotificationActive = true
                            }
                        }
                        
                    default:
                        faults.setFrontTirePressureWarningActive(active: false)
                        faults.setRearTirePressureWarningActive(active: false)
                        faults.setFrontTirePressureCriticalActive(active: false)
                        faults.setRearTirePressureCriticalActive(active: false)
                        if (UserDefaults.standard.bool(forKey: "notification_preference")){
                            if(faults.frontTirePressureCriticalNotificationActive) {
                                faults.frontTirePressureCriticalNotificationActive = false
                            }
                            if(faults.rearTirePressureCriticalNotificationActive) {
                                faults.rearTirePressureCriticalNotificationActive = false
                            }
                        }
                    }
                }
            }
            
        case 0x06:
            //RPM
            if ((lastMessage[1] != 0xFF) && (lastMessage[2] != 0xFF)){
                let rpm = ((Double(lastMessage[1]) + (Double(lastMessage[2] & 0x0F) * 255)) * 5)
                motorcycleData.setRPM(rpm: Int16(rpm))
            }
            
            // Gear
            if ((((lastMessage[2] >> 4) & 0x0F)) != 0xF){
                var gear = "-"
                switch (lastMessage[2] >> 4) & 0x0F {
                case 0x1:
                    gear = "1"
                case 0x2:
                    gear = "N"
                case 0x4:
                    gear = "2"
                case 0x7:
                    gear = "3"
                case 0x8:
                    gear = "4"
                case 0xB:
                    gear = "5"
                case 0xD:
                    gear = "6"
                default:
                    gear = "-"
                }
                if (motorcycleData.gear != gear && gear != "-") {
                    motorcycleData.setshifts(shifts: motorcycleData.shifts! + 1)
                }
                motorcycleData.setgear(gear: gear)
            }
            
            // Throttle Position
            if (lastMessage[3] != 0xFF){
                let minPosition:Double = 36;
                let maxPosition:Double = 236;
                var throttlePosition = ((Double(lastMessage[3]) - minPosition) * 100) / (maxPosition - minPosition)
                if (throttlePosition < 0 ){
                    throttlePosition = 0
                } else if (throttlePosition > 100 ){
                    throttlePosition = 100
                }
                motorcycleData.setthrottlePosition(throttlePosition: throttlePosition)
            }
            
            // Engine Temperature
            if (lastMessage[4] != 0xFF){
                let engineTemp:Double = Double(lastMessage[4]) * 0.75 - 25
                motorcycleData.setengineTemperature(engineTemperature: engineTemp)
            }
            
            // ASC Fault
            if (((lastMessage[5]  >> 4) & 0x0F) != 0xF){
                let ascValue = (lastMessage[5]  >> 4) & 0x0F // the highest 4 bits.
                switch (ascValue){
                case 0x1:
                    faults.setAscSelfDiagActive(active: false)
                    faults.setAscInterventionActive(active: true)
                    faults.setAscDeactivatedActive(active: false)
                    faults.setAscErrorActive(active: false)
                    
                case 0x2:
                    faults.setAscSelfDiagActive(active: false)
                    faults.setAscInterventionActive(active: false)
                    faults.setAscDeactivatedActive(active: false)
                    faults.setAscErrorActive(active: true)
                    
                case 0x3:
                    faults.setAscSelfDiagActive(active: true)
                    faults.setAscInterventionActive(active: false)
                    faults.setAscDeactivatedActive(active: false)
                    faults.setAscErrorActive(active: false)
                    
                case 0x5:
                    faults.setAscSelfDiagActive(active: false)
                    faults.setAscInterventionActive(active: false)
                    faults.setAscDeactivatedActive(active: false)
                    faults.setAscErrorActive(active: true)
                    
                case 0x6:
                    faults.setAscSelfDiagActive(active: false)
                    faults.setAscInterventionActive(active: false)
                    faults.setAscDeactivatedActive(active: false)
                    faults.setAscErrorActive(active: true)
                    
                case 0x7:
                    faults.setAscSelfDiagActive(active: false)
                    faults.setAscInterventionActive(active: false)
                    faults.setAscDeactivatedActive(active: false)
                    faults.setAscErrorActive(active: true)
                    
                case 0x8:
                    faults.setAscSelfDiagActive(active: false)
                    faults.setAscInterventionActive(active: false)
                    faults.setAscDeactivatedActive(active: true)
                    faults.setAscErrorActive(active: false)
                    break;
                case 0x9:
                    faults.setAscSelfDiagActive(active: false)
                    faults.setAscInterventionActive(active: true)
                    faults.setAscDeactivatedActive(active: false)
                    faults.setAscErrorActive(active: false)
                    
                case 0xA:
                    faults.setAscSelfDiagActive(active: false)
                    faults.setAscInterventionActive(active: false)
                    faults.setAscDeactivatedActive(active: false)
                    faults.setAscErrorActive(active: true)
                    
                case 0xB:
                    faults.setAscSelfDiagActive(active: true)
                    faults.setAscInterventionActive(active: false)
                    faults.setAscDeactivatedActive(active: false)
                    faults.setAscErrorActive(active: false)
                    
                case 0xD:
                    faults.setAscSelfDiagActive(active: false)
                    faults.setAscInterventionActive(active: false)
                    faults.setAscDeactivatedActive(active: false)
                    faults.setAscErrorActive(active: true)
                    break;
                case 0xE:
                    faults.setAscSelfDiagActive(active: false)
                    faults.setAscInterventionActive(active: false)
                    faults.setAscDeactivatedActive(active: false)
                    faults.setAscErrorActive(active: true)
                    
                default:
                    faults.setAscSelfDiagActive(active: false)
                    faults.setAscInterventionActive(active: false)
                    faults.setAscDeactivatedActive(active: false)
                    faults.setAscErrorActive(active: false)
                    
                }
            }
            //Oil Fault
            if((lastMessage[5] & 0x0F) != 0xF){
                let oilValue = lastMessage[5] & 0x0F // the lowest 4 bits
                switch (oilValue){
                case 0x2:
                    faults.setOilLowActive(active: true)
                    
                case 0x6:
                    faults.setOilLowActive(active: true)
                    
                case 0xA:
                    faults.setOilLowActive(active: true)
                    
                case 0xE:
                    faults.setOilLowActive(active: true)
                    
                default:
                    faults.setOilLowActive(active: false)
                    
                }
            }
            
        case 0x07:
            // Average Speed
            if ((lastMessage[1] != 0xFF) && (lastMessage[2] != 0xFF)){
                let firstNibble = Double((lastMessage[1] >> 4) & 0x0F) * 2
                let secondNibble = Double((lastMessage[1] & 0x0F)) * 0.125
                let thirdNibble = Double((lastMessage[2] & 0x0F)) * 32
                let avgSpeed = firstNibble + secondNibble + thirdNibble
                motorcycleData.setaverageSpeed(averageSpeed: avgSpeed)
            }
            
            // Speed
            if (lastMessage[3] != 0xFF){
                let speed = Double(lastMessage[3]) * 2
                motorcycleData.setspeed(speed: speed)
            }
            
            // Voltage
            if (lastMessage[4] != 0xFF){
                let voltage = Double(lastMessage[4]) / 10
                motorcycleData.setvoltage(voltage: voltage)
            }
            
            // Fuel Fault
            if (((lastMessage[5] >> 4) & 0x0F) != 0xF){
                let fuelValue = (lastMessage[5] >> 4) & 0x0F // the highest 4 bits.
                switch (fuelValue){
                case 0x2:
                    faults.setFuelFaultActive(active: true)
                    
                case 0x6:
                    faults.setFuelFaultActive(active: true)
                    
                case 0xA:
                    faults.setFuelFaultActive(active: true)
                    
                case 0xE:
                    faults.setFuelFaultActive(active: true)
                    
                default:
                    faults.setFuelFaultActive(active: false)
                    
                }
            }
            
            // General Fault
            if ((lastMessage[5] & 0x0F) != 0xF){
                let generalFault = lastMessage[5] & 0x0F // the lowest 4 bits
                switch (generalFault){
                case 0x1:
                    faults.setGeneralFlashingYellowActive(active: true)
                    faults.setGeneralShowsYellowActive(active: false)
                    faults.setGeneralFlashingRedActive(active: false)
                    faults.setGeneralShowsRedActive(active: false)
                    if (UserDefaults.standard.bool(forKey: "notification_preference")){
                        if(faults.generalFlashingRedNotificationActive) {
                            faults.generalFlashingRedNotificationActive = false
                        }
                        if(faults.generalShowsRedNotificationActive) {
                            faults.generalShowsRedNotificationActive = false
                        }
                    }
                    
                case 0x2:
                    faults.setGeneralFlashingYellowActive(active: false)
                    faults.setGeneralShowsYellowActive(active: true)
                    faults.setGeneralFlashingRedActive(active: false)
                    faults.setGeneralShowsRedActive(active: false)
                    if (UserDefaults.standard.bool(forKey: "notification_preference")){
                        if(faults.generalFlashingRedNotificationActive) {
                            faults.generalFlashingRedNotificationActive = false
                        }
                        if(faults.generalShowsRedNotificationActive) {
                            faults.generalShowsRedNotificationActive = false
                        }
                    }
                    
                case 0x4:
                    faults.setGeneralFlashingYellowActive(active: false)
                    faults.setGeneralShowsYellowActive(active: false)
                    faults.setGeneralFlashingRedActive(active: true)
                    faults.setGeneralShowsRedActive(active: false)
                    if (UserDefaults.standard.bool(forKey: "notification_preference")){
                        if(!faults.generalFlashingRedNotificationActive) {
                            faults.generalFlashingRedNotificationActive = true
                        }
                        if(faults.generalShowsRedNotificationActive) {
                            faults.generalShowsRedNotificationActive = false
                        }
                    }
                    
                case 0x5:
                    faults.setGeneralFlashingYellowActive(active: true)
                    faults.setGeneralShowsYellowActive(active: false)
                    faults.setGeneralFlashingRedActive(active: true)
                    faults.setGeneralShowsRedActive(active: false)
                    if (UserDefaults.standard.bool(forKey: "notification_preference")){
                        if(!faults.generalFlashingRedNotificationActive) {
                            faults.generalFlashingRedNotificationActive = true
                        }
                        if(faults.generalShowsRedNotificationActive) {
                            faults.generalShowsRedNotificationActive = false
                        }
                    }
                    
                case 0x6:
                    faults.setGeneralFlashingYellowActive(active: false)
                    faults.setGeneralShowsYellowActive(active: true)
                    faults.setGeneralFlashingRedActive(active: true)
                    faults.setGeneralShowsRedActive(active: false)
                    if (UserDefaults.standard.bool(forKey: "notification_preference")){
                        if(!faults.generalFlashingRedNotificationActive) {
                            faults.generalFlashingRedNotificationActive = true
                        }
                        if(faults.generalShowsRedNotificationActive) {
                            faults.generalShowsRedNotificationActive = false
                        }
                    }
                    
                case 0x7:
                    faults.setGeneralFlashingYellowActive(active: false)
                    faults.setGeneralShowsYellowActive(active: false)
                    faults.setGeneralFlashingRedActive(active: true)
                    faults.setGeneralShowsRedActive(active: false)
                    if (UserDefaults.standard.bool(forKey: "notification_preference")){
                        if(!faults.generalFlashingRedNotificationActive) {
                            faults.generalFlashingRedNotificationActive = true
                        }
                        if(faults.generalShowsRedNotificationActive) {
                            faults.generalShowsRedNotificationActive = false
                        }
                    }
                    
                case 0x8:
                    faults.setGeneralFlashingYellowActive(active: false)
                    faults.setGeneralShowsYellowActive(active: false)
                    faults.setGeneralFlashingRedActive(active: false)
                    faults.setGeneralShowsRedActive(active: true)
                    if (UserDefaults.standard.bool(forKey: "notification_preference")){
                        if(faults.generalFlashingRedNotificationActive) {
                            faults.generalFlashingRedNotificationActive = false
                        }
                        if(!faults.generalShowsRedNotificationActive) {
                            faults.generalShowsRedNotificationActive = true
                        }
                    }
                    
                case 0x9:
                    faults.setGeneralFlashingYellowActive(active: false)
                    faults.setGeneralShowsYellowActive(active: false)
                    faults.setGeneralFlashingRedActive(active: true)
                    faults.setGeneralShowsRedActive(active: true)
                    if (UserDefaults.standard.bool(forKey: "notification_preference")){
                        if(!faults.generalFlashingRedNotificationActive && !faults.generalShowsRedNotificationActive) {
                            faults.generalFlashingRedNotificationActive = true
                            faults.generalShowsRedNotificationActive = true
                        }
                    }
                    
                case 0xA:
                    faults.setGeneralFlashingYellowActive(active: false)
                    faults.setGeneralShowsYellowActive(active: true)
                    faults.setGeneralFlashingRedActive(active: false)
                    faults.setGeneralShowsRedActive(active: true)
                    if (UserDefaults.standard.bool(forKey: "notification_preference")){
                        if(faults.generalFlashingRedNotificationActive) {
                            faults.generalFlashingRedNotificationActive = false
                        }
                        if(!faults.generalShowsRedNotificationActive) {
                            faults.generalShowsRedNotificationActive = true
                        }
                    }
                    
                case 0xB:
                    faults.setGeneralFlashingYellowActive(active: false)
                    faults.setGeneralShowsYellowActive(active: false)
                    faults.setGeneralFlashingRedActive(active: false)
                    faults.setGeneralShowsRedActive(active: true)
                    if (UserDefaults.standard.bool(forKey: "notification_preference")){
                        if(faults.generalFlashingRedNotificationActive) {
                            faults.generalFlashingRedNotificationActive = false
                        }
                        if(!faults.generalShowsRedNotificationActive) {
                            faults.generalShowsRedNotificationActive = true
                        }
                    }
                    
                case 0xD:
                    faults.setGeneralFlashingYellowActive(active: true)
                    faults.setGeneralShowsYellowActive(active: false)
                    faults.setGeneralFlashingRedActive(active: false)
                    faults.setGeneralShowsRedActive(active: false)
                    if (UserDefaults.standard.bool(forKey: "notification_preference")){
                        if(faults.generalFlashingRedNotificationActive) {
                            faults.generalFlashingRedNotificationActive = false
                        }
                        if(faults.generalShowsRedNotificationActive) {
                            faults.generalShowsRedNotificationActive = false
                        }
                    }
                    
                case 0xE:
                    faults.setGeneralFlashingYellowActive(active: false)
                    faults.setGeneralShowsYellowActive(active: true)
                    faults.setGeneralFlashingRedActive(active: false)
                    faults.setGeneralShowsRedActive(active: false)
                    if (UserDefaults.standard.bool(forKey: "notification_preference")){
                        if(faults.generalFlashingRedNotificationActive) {
                            faults.generalFlashingRedNotificationActive = false
                        }
                        if(faults.generalShowsRedNotificationActive) {
                            faults.generalShowsRedNotificationActive = false
                        }
                    }
                    
                default:
                    faults.setGeneralFlashingYellowActive(active: false)
                    faults.setGeneralShowsYellowActive(active: false)
                    faults.setGeneralFlashingRedActive(active: false)
                    faults.setGeneralShowsRedActive(active: false)
                    if (UserDefaults.standard.bool(forKey: "notification_preference")){
                        if(faults.generalFlashingRedNotificationActive) {
                            faults.generalFlashingRedNotificationActive = false
                        }
                        if(faults.generalShowsRedNotificationActive) {
                            faults.generalShowsRedNotificationActive = false
                        }
                    }
                    
                }
            }
        case 0x08:
            // Ambient Temperature
            if (lastMessage[1] != 0xFF){
                let ambientTemp:Double = Double(lastMessage[1]) * 0.50 - 40
                if (ambientTemp >= -20.0 && ambientTemp <= 45.0) { // Filter out improbable values
                    motorcycleData.setambientTemperature(ambientTemperature: ambientTemp)
                    if (ambientTemp <= 0.0){
                        faults.setIceWarningActive(active: true)
                    } else {
                        faults.setIceWarningActive(active: false)
                    }
                }
            }
            
            // LAMP Faults
            if (((lastMessage[3]  >> 4) & 0x0F) != 0xF) {
                // LAMPF 1
                let lampfOneValue = (lastMessage[3]  >> 4) & 0x0F // the highest 4 bits.
                switch (lampfOneValue) {
                case 0x1:
                    faults.setAddFrontLightOneActive(active: true)
                    faults.setAddFrontLightTwoActive(active: false)
                    
                case 0x2:
                    faults.setAddFrontLightOneActive(active: false)
                    faults.setAddFrontLightTwoActive(active: true)
                    
                case 0x3:
                    faults.setAddFrontLightOneActive(active: true)
                    faults.setAddFrontLightTwoActive(active: true)
                    
                case 0x5:
                    faults.setAddFrontLightOneActive(active: true)
                    faults.setAddFrontLightTwoActive(active: false)
                    
                case 0x6:
                    faults.setAddFrontLightOneActive(active: false)
                    faults.setAddFrontLightTwoActive(active: true)
                    
                case 0x9:
                    faults.setAddFrontLightOneActive(active: true)
                    faults.setAddFrontLightTwoActive(active: false)
                    
                case 0xA:
                    faults.setAddFrontLightOneActive(active: false)
                    faults.setAddFrontLightTwoActive(active: true)
                    
                case 0xB:
                    faults.setAddFrontLightOneActive(active: true)
                    faults.setAddFrontLightTwoActive(active: true)
                    
                case 0xD:
                    faults.setAddFrontLightOneActive(active: true)
                    faults.setAddFrontLightTwoActive(active: false)
                    
                case 0xE:
                    faults.setAddFrontLightOneActive(active: false)
                    faults.setAddFrontLightTwoActive(active: true)
                    
                default:
                    faults.setAddFrontLightOneActive(active: false)
                    faults.setAddFrontLightTwoActive(active: false)
                    
                }
            }
            // LAMPF 2
            if (((lastMessage[4] >> 4) & 0x0F) != 0xF) {
                let lampfTwoHighValue = (lastMessage[4] >> 4) & 0x0F // the highest 4 bits.
                switch (lampfTwoHighValue) {
                case 0x1:
                    faults.setDaytimeRunningActive(active: true)
                    faults.setFrontLeftSignalActive(active: false)
                    faults.setFrontRightSignalActive(active: false)
                    
                case 0x2:
                    faults.setDaytimeRunningActive(active: false)
                    faults.setFrontLeftSignalActive(active: true)
                    faults.setFrontRightSignalActive(active: false)
                    
                case 0x3:
                    faults.setDaytimeRunningActive(active: true)
                    faults.setFrontLeftSignalActive(active: true)
                    faults.setFrontRightSignalActive(active: false)
                    
                case 0x4:
                    faults.setDaytimeRunningActive(active: false)
                    faults.setFrontLeftSignalActive(active: false)
                    faults.setFrontRightSignalActive(active: true)
                    
                case 0x5:
                    faults.setDaytimeRunningActive(active: true)
                    faults.setFrontLeftSignalActive(active: false)
                    faults.setFrontRightSignalActive(active: true)
                    
                case 0x6:
                    faults.setDaytimeRunningActive(active: false)
                    faults.setFrontLeftSignalActive(active: true)
                    faults.setFrontRightSignalActive(active: true)
                    
                case 0x7:
                    faults.setDaytimeRunningActive(active: true)
                    faults.setFrontLeftSignalActive(active: true)
                    faults.setFrontRightSignalActive(active: true)
                    
                case 0x9:
                    faults.setDaytimeRunningActive(active: true)
                    faults.setFrontLeftSignalActive(active: false)
                    faults.setFrontRightSignalActive(active: false)
                    
                case 0xA:
                    faults.setDaytimeRunningActive(active: false)
                    faults.setFrontLeftSignalActive(active: true)
                    faults.setFrontRightSignalActive(active: false)
                    
                case 0xB:
                    faults.setDaytimeRunningActive(active: true)
                    faults.setFrontLeftSignalActive(active: true)
                    faults.setFrontRightSignalActive(active: false)
                    
                case 0xC:
                    faults.setDaytimeRunningActive(active: false)
                    faults.setFrontLeftSignalActive(active: false)
                    faults.setFrontRightSignalActive(active: true)
                    
                case 0xD:
                    faults.setDaytimeRunningActive(active: true);
                    faults.setFrontLeftSignalActive(active: false);
                    faults.setFrontRightSignalActive(active: true);
                    
                case 0xE:
                    faults.setDaytimeRunningActive(active: false)
                    faults.setFrontLeftSignalActive(active: true)
                    faults.setFrontRightSignalActive(active: true)
                    
                case 0xF:
                    faults.setDaytimeRunningActive(active: true)
                    faults.setFrontLeftSignalActive(active: true)
                    faults.setFrontRightSignalActive(active: true)
                    
                default:
                    faults.setDaytimeRunningActive(active: false)
                    faults.setFrontLeftSignalActive(active: false)
                    faults.setFrontRightSignalActive(active: false)
                    
                }
            }
        
            if((data[4] & 0x0F) != 0xF){
                let lampfTwoLowValue = data[4] & 0x0F // the lowest 4 bits
                switch (lampfTwoLowValue) {
                case 0x1:
                    faults.setFrontParkingLightOneActive(active: true)
                    faults.setFrontParkingLightTwoActive(active: false)
                    faults.setLowBeamActive(active: false)
                    faults.setHighBeamActive(active: false)
                    
                case 0x2:
                    faults.setFrontParkingLightOneActive(active: false)
                    faults.setFrontParkingLightTwoActive(active: true)
                    faults.setLowBeamActive(active: false)
                    faults.setHighBeamActive(active: false)
                    
                case 0x3:
                    faults.setFrontParkingLightOneActive(active: true)
                    faults.setFrontParkingLightTwoActive(active: true)
                    faults.setLowBeamActive(active: false)
                    faults.setHighBeamActive(active: false)
                    
                case 0x4:
                    faults.setFrontParkingLightOneActive(active: false)
                    faults.setFrontParkingLightTwoActive(active: false)
                    faults.setLowBeamActive(active: true)
                    faults.setHighBeamActive(active: false)
                    
                case 0x5:
                    faults.setFrontParkingLightOneActive(active: true);
                    faults.setFrontParkingLightTwoActive(active: false)
                    faults.setLowBeamActive(active: true)
                    faults.setHighBeamActive(active: false)
                    
                case 0x6:
                    faults.setFrontParkingLightOneActive(active: false)
                    faults.setFrontParkingLightTwoActive(active: true)
                    faults.setLowBeamActive(active: true)
                    faults.setHighBeamActive(active: false)
                    
                case 0x7:
                    faults.setFrontParkingLightOneActive(active: true)
                    faults.setFrontParkingLightTwoActive(active: true)
                    faults.setLowBeamActive(active: true)
                    faults.setHighBeamActive(active: false)
                    
                case 0x8:
                    faults.setFrontParkingLightOneActive(active: false)
                    faults.setFrontParkingLightTwoActive(active: false)
                    faults.setLowBeamActive(active: false)
                    faults.setHighBeamActive(active: true)
                    
                case 0x9:
                    faults.setFrontParkingLightOneActive(active: true)
                    faults.setFrontParkingLightTwoActive(active: false)
                    faults.setLowBeamActive(active: false)
                    faults.setHighBeamActive(active: true)
                    
                case 0xA:
                    faults.setFrontParkingLightOneActive(active: false)
                    faults.setFrontParkingLightTwoActive(active: true)
                    faults.setLowBeamActive(active: false)
                    faults.setHighBeamActive(active: true)
                    
                case 0xB:
                    faults.setFrontParkingLightOneActive(active: true)
                    faults.setFrontParkingLightTwoActive(active: true)
                    faults.setLowBeamActive(active: false)
                    faults.setHighBeamActive(active: true)
                    
                case 0xC:
                    faults.setFrontParkingLightOneActive(active: false)
                    faults.setFrontParkingLightTwoActive(active: false)
                    faults.setLowBeamActive(active: true)
                    faults.setHighBeamActive(active: true)
                    
                case 0xD:
                    faults.setFrontParkingLightOneActive(active: true)
                    faults.setFrontParkingLightTwoActive(active: false)
                    faults.setLowBeamActive(active: true)
                    faults.setHighBeamActive(active: true)
                    
                case 0xE:
                    faults.setFrontParkingLightOneActive(active: false)
                    faults.setFrontParkingLightTwoActive(active: true)
                    faults.setLowBeamActive(active: true)
                    faults.setHighBeamActive(active: true)
                    
                case 0xF:
                    faults.setFrontParkingLightOneActive(active: true)
                    faults.setFrontParkingLightTwoActive(active: true)
                    faults.setLowBeamActive(active: true)
                    faults.setHighBeamActive(active: true)
                    
                default:
                    faults.setFrontParkingLightOneActive(active: false)
                    faults.setFrontParkingLightTwoActive(active: false)
                    faults.setLowBeamActive(active: false)
                    faults.setHighBeamActive(active: false)
                    
                }
            }
            
            // LAMPF 3
            if (((lastMessage[5] >> 4) & 0x0F) != 0xF ) {
                let lampfThreeHighValue = (lastMessage[5] >> 4) & 0x0F // the highest 4 bits.
                switch (lampfThreeHighValue) {
                case 0x1:
                    faults.setRearRightSignalActive(active: true)
                    
                case 0x3:
                    faults.setRearRightSignalActive(active: true)
                    
                case 0x5:
                    faults.setRearRightSignalActive(active: true)
                    
                case 0x7:
                    faults.setRearRightSignalActive(active: true)
                    
                case 0x9:
                    faults.setRearRightSignalActive(active: true)
                    
                case 0xB:
                    faults.setRearRightSignalActive(active: true)
                    
                case 0xD:
                    faults.setRearRightSignalActive(active: true)
                    
                case 0xF:
                    faults.setRearRightSignalActive(active: true)
                    
                default:
                    faults.setRearRightSignalActive(active: false)
                    
                }
            }
            if ((lastMessage[5] & 0x0F) != 0xF){
                let lampfThreeLowValue = lastMessage[5] & 0x0F // the lowest 4 bits
                switch (lampfThreeLowValue) {
                case 0x1:
                    faults.setRearLeftSignalActive(active: false)
                    faults.setRearLightActive(active: true)
                    faults.setBrakeLightActive(active: false)
                    faults.setLicenseLightActive(active: false)
                    
                case 0x2:
                    faults.setRearLeftSignalActive(active: false)
                    faults.setRearLightActive(active: false)
                    faults.setBrakeLightActive(active: true)
                    faults.setLicenseLightActive(active: false)
                    
                case 0x3:
                    faults.setRearLeftSignalActive(active: false)
                    faults.setRearLightActive(active: true)
                    faults.setBrakeLightActive(active: true)
                    faults.setLicenseLightActive(active: false)
                    
                case 0x4:
                    faults.setRearLeftSignalActive(active: false)
                    faults.setRearLightActive(active: false)
                    faults.setBrakeLightActive(active: false)
                    faults.setLicenseLightActive(active: true)
                    
                case 0x5:
                    faults.setRearLeftSignalActive(active: true)
                    faults.setRearLightActive(active: false)
                    faults.setBrakeLightActive(active: false)
                    faults.setLicenseLightActive(active: true)
                    
                case 0x6:
                    faults.setRearLeftSignalActive(active: false)
                    faults.setRearLightActive(active: false)
                    faults.setBrakeLightActive(active: true)
                    faults.setLicenseLightActive(active: true)
                    
                case 0x7:
                    faults.setRearLeftSignalActive(active: false)
                    faults.setRearLightActive(active: true)
                    faults.setBrakeLightActive(active: true)
                    faults.setLicenseLightActive(active: true)
                    
                case 0x8:
                    faults.setRearLeftSignalActive(active: true)
                    faults.setRearLightActive(active: false)
                    faults.setBrakeLightActive(active: false)
                    faults.setLicenseLightActive(active: false)
                    
                case 0x9:
                    faults.setRearLeftSignalActive(active: true)
                    faults.setRearLightActive(active: true)
                    faults.setBrakeLightActive(active: false)
                    faults.setLicenseLightActive(active: false)
                    
                case 0xA:
                    faults.setRearLeftSignalActive(active: true)
                    faults.setRearLightActive(active: false)
                    faults.setBrakeLightActive(active: true)
                    faults.setLicenseLightActive(active: false)
                    
                case 0xC:
                    faults.setRearLeftSignalActive(active: true)
                    faults.setRearLightActive(active: false)
                    faults.setBrakeLightActive(active: false)
                    faults.setLicenseLightActive(active: true)
                    
                case 0xD:
                    faults.setRearLeftSignalActive(active: true)
                    faults.setRearLightActive(active: true)
                    faults.setBrakeLightActive(active: true)
                    faults.setLicenseLightActive(active: false)
                    
                case 0xE:
                    faults.setRearLeftSignalActive(active: true)
                    faults.setRearLightActive(active: false)
                    faults.setBrakeLightActive(active: true)
                    faults.setLicenseLightActive(active: true)
                    
                case 0xF:
                    faults.setRearLeftSignalActive(active: true)
                    faults.setRearLightActive(active: true)
                    faults.setBrakeLightActive(active: true)
                    faults.setLicenseLightActive(active: true)
                    
                default:
                    faults.setRearLeftSignalActive(active: false)
                    faults.setRearLightActive(active: false)
                    faults.setBrakeLightActive(active: false)
                    faults.setLicenseLightActive(active: false)
                    
                }
            }
            
            // LAMPF 4
            if (((lastMessage[6] >> 4) & 0x0F) != 0xF) {
                let lampfFourHighValue = (lastMessage[6] >> 4) & 0x0F // the highest 4 bits.
                switch (lampfFourHighValue) {
                case 0x1:
                    faults.setRearFogLightActive(active: true)
                    
                case 0x3:
                    faults.setRearFogLightActive(active: true)
                    
                case 0x5:
                    faults.setRearFogLightActive(active: true)
                    
                case 0x9:
                    faults.setRearFogLightActive(active: true)
                    
                case 0xB:
                    faults.setRearFogLightActive(active: true)
                    
                case 0xD:
                    faults.setRearFogLightActive(active: true)
                    
                case 0xF:
                    faults.setRearFogLightActive(active: true)
                default:
                    faults.setRearFogLightActive(active: false)
                    
                }
            }
            if((lastMessage[6] & 0x0F) != 0xF){
                let lampfFourLowValue = lastMessage[6] & 0x0F // the lowest 4 bits
                switch (lampfFourLowValue) {
                case 0x1:
                    faults.setAddDippedLightActive(active: true)
                    faults.setAddBrakeLightActive(active: false)
                    faults.setFrontLampOneLightActive(active: false)
                    faults.setFrontLampTwoLightActive(active: false)
                    
                case 0x2:
                    faults.setAddDippedLightActive(active: false)
                    faults.setAddBrakeLightActive(active: true)
                    faults.setFrontLampOneLightActive(active: false)
                    faults.setFrontLampTwoLightActive(active: false)
                    
                case 0x3:
                    faults.setAddDippedLightActive(active: true)
                    faults.setAddBrakeLightActive(active: true)
                    faults.setFrontLampOneLightActive(active: false)
                    faults.setFrontLampTwoLightActive(active: false)
                    
                case 0x4:
                    faults.setAddDippedLightActive(active: false)
                    faults.setAddBrakeLightActive(active: false)
                    faults.setFrontLampOneLightActive(active: true)
                    faults.setFrontLampTwoLightActive(active: false)
                    
                case 0x5:
                    faults.setAddDippedLightActive(active: true)
                    faults.setAddBrakeLightActive(active: false)
                    faults.setFrontLampOneLightActive(active: true)
                    faults.setFrontLampTwoLightActive(active: false)
                    
                case 0x6:
                    faults.setAddDippedLightActive(active: false)
                    faults.setAddBrakeLightActive(active: true)
                    faults.setFrontLampOneLightActive(active: true)
                    faults.setFrontLampTwoLightActive(active: false)
                    
                case 0x7:
                    faults.setAddDippedLightActive(active: true)
                    faults.setAddBrakeLightActive(active: true)
                    faults.setFrontLampOneLightActive(active: true)
                    faults.setFrontLampTwoLightActive(active: false)
                    
                case 0x8:
                    faults.setAddDippedLightActive(active: false)
                    faults.setAddBrakeLightActive(active: false)
                    faults.setFrontLampOneLightActive(active: false)
                    faults.setFrontLampTwoLightActive(active: true)
                    
                case 0x9:
                    faults.setAddDippedLightActive(active: true)
                    faults.setAddBrakeLightActive(active: false)
                    faults.setFrontLampOneLightActive(active: false)
                    faults.setFrontLampTwoLightActive(active: true)
                    
                case 0xA:
                    faults.setAddDippedLightActive(active: false)
                    faults.setAddBrakeLightActive(active: true)
                    faults.setFrontLampOneLightActive(active: false)
                    faults.setFrontLampTwoLightActive(active: true)
                    
                case 0xB:
                    faults.setAddDippedLightActive(active: true)
                    faults.setAddBrakeLightActive(active: true)
                    faults.setFrontLampOneLightActive(active: false)
                    faults.setFrontLampTwoLightActive(active: true)
                    
                case 0xC:
                    faults.setAddDippedLightActive(active: false)
                    faults.setAddBrakeLightActive(active: false)
                    faults.setFrontLampOneLightActive(active: true)
                    faults.setFrontLampTwoLightActive(active: true)
                    
                case 0xD:
                    faults.setAddDippedLightActive(active: true)
                    faults.setAddBrakeLightActive(active: false)
                    faults.setFrontLampOneLightActive(active: true)
                    faults.setFrontLampTwoLightActive(active: true)
                    
                case 0xE:
                    faults.setAddDippedLightActive(active: false)
                    faults.setAddBrakeLightActive(active: true)
                    faults.setFrontLampOneLightActive(active: true)
                    faults.setFrontLampTwoLightActive(active: true)
                    
                default:
                    faults.setAddDippedLightActive(active: false)
                    faults.setAddBrakeLightActive(active: false)
                    faults.setFrontLampOneLightActive(active: false)
                    faults.setFrontLampTwoLightActive(active: false)
                }
            }
        case 0x09:
            // Fuel Economy 1
            if (lastMessage[2] != 0xFF){
                let firstNibble = Double((lastMessage[2] >> 4) & 0x0F) * 1.6
                let secondNibble = Double((lastMessage[2] & 0x0F)) * 0.1
                let fuelEconomyOne = firstNibble + secondNibble
                motorcycleData.setfuelEconomyOne(fuelEconomyOne: fuelEconomyOne)
            }
            
            // Fuel Economy 2
            if (lastMessage[3] != 0xFF){
                let firstNibble = Double((lastMessage[3] >> 4) & 0x0F) * 1.6
                let secondNibble = Double((lastMessage[3] & 0x0F)) * 0.1
                let fuelEconomyTwo = firstNibble + secondNibble
                motorcycleData.setfuelEconomyTwo(fuelEconomyTwo: fuelEconomyTwo)
            }
            
            // Current Consumption
            if (lastMessage[4] != 0xFF){
                let firstNibble = Double((lastMessage[4] >> 4) & 0x0F) * 1.6
                let secondNibble = Double((lastMessage[4] & 0x0F)) * 0.1
                let currentConsumption = firstNibble + secondNibble
                motorcycleData.setcurrentConsumption(currentConsumption: currentConsumption)
            }
            
        case 0x0A:
            // Odometer
            if ((lastMessage[1] != 0xFF) && (lastMessage[2] != 0xFF) && (lastMessage[3] != 0xFF)){
                let odometer:Double = Double(UInt32((UInt32(lastMessage[1]) | UInt32(lastMessage[2]) << 8 | UInt32(lastMessage[3]) << 16)))
                motorcycleData.setodometer(odometer: (odometer * 1.0))
            }
            
            // Trip Auto
            if ((lastMessage[4] != 0xFF) && (lastMessage[5] != 0xFF) && (lastMessage[6] != 0xFF)){
                let tripAuto:Double = Double(UInt32((UInt32(lastMessage[4]) | UInt32(lastMessage[5]) << 8 | UInt32(lastMessage[6]) << 16))) / 10.0
                motorcycleData.settripAuto(tripAuto: tripAuto)
            }
            
        case 0x0B:
            //Next Service Date
            if ((lastMessage[1] != 0xFF) && (lastMessage[2] != 0xFF) && (lastMessage[3] != 0xFF)){
                let year = UInt32(UInt32(lastMessage[2] & 0x0F) << 8) | UInt32(lastMessage[1])
                let month = ((lastMessage[2] >> 4) & 0x0F)
                let day = lastMessage[3]
                let calendar = Calendar(identifier: .gregorian)
                let components = DateComponents(year: Int(year), month: Int(month), day: Int(day))
                let nextServiceDate = calendar.date(from: components)
                motorcycleData.setNextServiceDate(nextServiceDate: nextServiceDate)
                let currentDate = Date()
                if calendar.compare(nextServiceDate!, to: currentDate, toGranularity: .day) == .orderedDescending {
                    faults.setserviceActive(active: false)
                } else {
                    faults.setserviceActive(active: true)
                }
            }
            //Next Service
            if (lastMessage[4] != 0xFF){
                let nextService = UInt16(lastMessage[4]) * 100
                motorcycleData.setNextService(nextService: Int(nextService))
            }
        case 0x0C:
            // Trip 1 & Trip 2
            if (!((lastMessage[1] == 0xFF) && (lastMessage[2] == 0xFF) && (lastMessage[3] == 0xFF))){
                let tripOne:Double = Double(UInt32((UInt32(lastMessage[1]) | UInt32(lastMessage[2]) << 8 | UInt32(lastMessage[3]) << 16))) / 10.0
                motorcycleData.settripOne(tripOne: tripOne)
            }
            if (!((lastMessage[4] == 0xFF) && (lastMessage[5] == 0xFF) && (lastMessage[6] == 0xFF))){
                let tripTwo:Double = Double(UInt32((UInt32(lastMessage[4]) | UInt32(lastMessage[5]) << 8 | UInt32(lastMessage[6]) << 16))) / 10.0
                motorcycleData.settripTwo(tripTwo: tripTwo)
            }
            
        default:
            break
        }
    }
}
