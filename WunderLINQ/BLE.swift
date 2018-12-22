//
//  BLE.swift
//  WunderLINQ
//
//  Created by Keith Conger on 12/21/18.
//  Copyright © 2018 Black Box Embedded, LLC. All rights reserved.
//

import Foundation
import CoreBluetooth

class BLE {
    static let shared = BLE()
    
    var peripheral: CBPeripheral?
    var cmdCharacteristic: CBCharacteristic?

    func setPeripheral(peripheral: CBPeripheral?){
        self.peripheral = peripheral
    }
    func getPeripheral() -> CBPeripheral{
        return self.peripheral!
    }
    
    func setcmdCharacteristic(cmdCharacteristic: CBCharacteristic?){
        self.cmdCharacteristic = cmdCharacteristic
    }
    func getcmdCharacteristic() -> CBCharacteristic{
        return self.cmdCharacteristic!
    }
}
