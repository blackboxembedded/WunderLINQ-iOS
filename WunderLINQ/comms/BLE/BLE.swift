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
