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
