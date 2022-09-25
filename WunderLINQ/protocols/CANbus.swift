//
//  CANbus.swift
//  WunderLINQ
//
//  Created by Keith Conger on 1/13/22.
//  Copyright © 2022 Black Box Embedded, LLC. All rights reserved.
//

import Foundation

class CANbus {
    class func parseMessage(_ data:Data) {
        let motorcycleData = MotorcycleData.shared
        let faults = Faults.shared
        let dataLength = data.count / MemoryLayout<UInt8>.size
        var dataArray = [UInt8](repeating: 0, count: dataLength)
        (data as NSData).getBytes(&dataArray, length: dataLength * MemoryLayout<Int16>.size)

        // Log raw messages
        if UserDefaults.standard.bool(forKey: "debug_logging_preference") {
            var messageHexString = ""
            for i in 0 ..< dataArray.count {
                messageHexString += String(format: "%02X", dataArray[i])
            }
            Logger.logDBG(entry: messageHexString)
        }
        
        let msgID:UInt16 = ((UInt16(data[0]) & 0xFF)<<3) + ((UInt16(data[1]) & 0xFF)>>5)
        switch (msgID){
        case 268:
            //RPM
            if ((data[4] != 0xFF) && (data[5] != 0xFF)){
                let rpm = ((Double(data[4]) + (Double(data[5] & 0x0F) * 255)) * 5)
                motorcycleData.setRPM(rpm: Int16(rpm))
            }
            break
        case 272:
            // Throttle Position
            if (data[7] != 0xFF){
                let minPosition:Double = 36;
                let maxPosition:Double = 236;
                let throttlePosition = ((Double(data[7]) - minPosition) * 100) / (maxPosition - minPosition)
                motorcycleData.setthrottlePosition(throttlePosition: throttlePosition)
            }
            break;
        case 700:
            // Engine Temperature
            if (data[4] != 0xFF){
                let engineTemp:Double = Double(data[4]) * 0.75 - 25
                motorcycleData.setengineTemperature(engineTemperature: engineTemp)
            }
            // Gear
            var gear = "-"
            switch (data[7] >> 4) & 0x0F {
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
            case 0xF:
                gear = "-"
            default:
                print("Unknown Gear Value")
                gear = "-"
            }
            if (motorcycleData.gear != gear && gear != "-") {
                motorcycleData.setshifts(shifts: motorcycleData.shifts! + 1)
            }
            motorcycleData.setgear(gear: gear)
            break
        case 720:
            //Ambient Temp
            if (data[4] != 0xFF){
                let ambientTemp:Double = Double(data[4]) * 0.50 - 40
                motorcycleData.setambientTemperature(ambientTemperature: ambientTemp)
                if (ambientTemp <= 0.0){
                    faults.setIceWarningActive(active: true)
                } else {
                    faults.setIceWarningActive(active: false)
                }
            }
            
            break
        case 1023:
            // Ambient Light
            let ambientLightValue = data[3] & 0x0F
            motorcycleData.setambientLight(ambientLight: Double(ambientLightValue))
            // Odometer
            if ((data[7] != 0xFF) && (data[8] != 0xFF) && (data[9] != 0xFF)){
                let odometer:Double = Double(UInt32((UInt32(data[7]) | UInt32(data[8]) << 8 | UInt32(data[9]) << 16)))
                motorcycleData.setodometer(odometer: (odometer * 1.0))
            }
            break
        default:
            break
        }
    }
    
}
