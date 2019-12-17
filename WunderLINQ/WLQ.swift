//
//  WLQ.swift
//  WunderLINQ
//
//  Created by Keith Conger on 12/21/18.
//  Copyright © 2018 Black Box Embedded, LLC. All rights reserved.
//

import Foundation

class WLQ {
    static let shared = WLQ()
    
    var firmwareVersion: String?
    var hardwareVersion: String?
    var wwMode: UInt8?
    var wwHoldSensitivity: UInt8?
    
    func setfirmwareVersion(firmwareVersion: String?){
        self.firmwareVersion = firmwareVersion
    }
    func getfirmwareVersion() -> String{
        if (self.firmwareVersion != nil){
            return self.firmwareVersion!
        }
        return "Unknown"
    }
    
    func sethardwareVersion(hardwareVersion: String?){
        self.hardwareVersion = hardwareVersion
    }
    func gethardwareVersion() -> String{
        if (self.hardwareVersion != nil){
            return self.hardwareVersion!
        }
        return "Unknown"
    }
    
    func setwwMode(wwMode: UInt8?){
        self.wwMode = wwMode
    }
    func getwwMode() -> UInt8{
        return self.wwMode!
    }
    
    func setwwHoldSensitivity(wwHoldSensitivity: UInt8?){
        self.wwHoldSensitivity = wwHoldSensitivity
    }
    func getwwHoldSensitivity() -> UInt8{
        return self.wwHoldSensitivity!
    }
}
