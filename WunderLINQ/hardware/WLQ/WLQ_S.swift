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

class WLQ_S: WLQ {
    
    var hardwareVersion:String?
    let hardwareVersion1:String = "WLQS1.0"
    
    var wunderLINQConfig:[UInt8]?
    var flashConfig:[UInt8]?
    var tempConfig:[UInt8]?
    var firmwareVersion:String?
    
    let keyMode_default:UInt8 = 0x00
    let keyMode_custom:UInt8 = 0x01

    let KEYBOARD_HID:UInt8 = 0x01
    let CONSUMER_HID:UInt8 = 0x02
    let UNDEFINED:UInt8 = 0x00

    let configFlashSize:Int = 41
    let defaultConfig:[UInt8] = [
        0x11,                               // Long Press Sensitivity
        0x01, 0x00, 0x52, 0x00, 0x00, 0x00, // Scroll Up - Up Arrow
        0x01, 0x00, 0x51, 0x00, 0x00, 0x00, // Scroll Down - Down Arrow
        0x01, 0x00, 0x50, 0x01, 0x00, 0x29, // Wheel Left - Left Arrow
        0x01, 0x00, 0x4F, 0x01, 0x00, 0x28, // Wheel Right - Right Arrow
        0x01, 0x00, 0x29, 0x00, 0x00, 0x00, // Rocker2 Up - FX1
        0x01, 0x00, 0x28, 0x00, 0x00, 0x00, // Rocker2 Down - FX2
        0x00,                               // PDM Channel 1 Mode
        0x00,                               // PDM Channel 2 Mode
        0x00,                               // PDM Channel 3 Mode
        0x00                                // PDM Channel 4 Mode
        ]

    let KEYMODE:Int = 100
    let longPressSensitivity:Int = 3
    let up:Int = 26
    let upLong:Int = 27
    let down:Int = 28
    let downLong:Int = 29
    let right:Int = 30
    let rightLong:Int = 31
    let left:Int = 32
    let leftLong:Int = 33
    let fx1:Int = 34
    let fx1Long:Int = 35
    let fx2:Int = 36
    let fx2Long:Int = 37
    let pdmChannel1:Int = 50
    let pdmChannel2:Int = 51
    let pdmChannel3:Int = 52
    let pdmChannel4:Int = 53
    
    var actionNames: [Int: String] = [:]

    let firmwareVersionMajor_INDEX:Int = 3
    let firmwareVersionMinor_INDEX:Int = 4
    let keyMode_INDEX:Int = 5
    let sensitivity_INDEX:Int = 0
    let upKeyType_INDEX:Int = 1
    let upKeyModifier_INDEX:Int = 2
    let upKey_INDEX:Int = 3
    let upLongKeyType_INDEX:Int = 4
    let upLongKeyModifier_INDEX:Int = 5
    let upLongKey_INDEX:Int = 6
    let downKeyType_INDEX:Int = 7
    let downKeyModifier_INDEX:Int = 8
    let downKey_INDEX:Int = 9
    let downLongKeyType_INDEX:Int = 10
    let downLongKeyModifier_INDEX:Int = 11
    let downLongKey_INDEX:Int = 12
    let leftKeyType_INDEX:Int = 13
    let leftKeyModifier_INDEX:Int = 14
    let leftKey_INDEX:Int = 15
    let leftLongKeyType_INDEX:Int = 16
    let leftLongKeyModifier_INDEX:Int = 17
    let leftLongKey_INDEX:Int = 18
    let rightKeyType_INDEX:Int = 19
    let rightKeyModifier_INDEX:Int = 20
    let rightKey_INDEX:Int = 21
    let rightLongKeyType_INDEX:Int = 22
    let rightLongKeyModifier_INDEX:Int = 23
    let rightLongKey_INDEX:Int = 24
    let fx1KeyType_INDEX:Int = 25
    let fx1KeyModifier_INDEX:Int = 26
    let fx1Key_INDEX:Int = 27
    let fx1LongKeyType_INDEX:Int = 28
    let fx1LongKeyModifier_INDEX:Int = 29
    let fx1LongKey_INDEX:Int = 30
    let fx2KeyType_INDEX:Int = 31
    let fx2KeyModifier_INDEX:Int = 32
    let fx2Key_INDEX:Int = 33
    let fx2LongKeyType_INDEX:Int = 34
    let fx2LongKeyModifier_INDEX:Int = 35
    let fx2LongKey_INDEX:Int = 36
    
    let pdmChannel1_INDEX:Int = 37
    let pdmChannel2_INDEX:Int = 38
    let pdmChannel3_INDEX:Int = 39
    let pdmChannel4_INDEX:Int = 40
    let accessories_INDEX:Int = 47
    
    // PDM Status message
    let statusSize:Int = 6
    let NUM_CHAN_INDEX:Int = 0
    let ACTIVE_CHAN_INDEX:Int = 1
    let ACC_PDM_CHANNEL1_VAL_RAW_INDEX:Int = 2
    let ACC_PDM_CHANNEL2_VAL_RAW_INDEX:Int = 3
    let ACC_PDM_CHANNEL3_VAL_RAW_INDEX:Int = 4
    let ACC_PDM_CHANNEL4_VAL_RAW_INDEX:Int = 5

    var wunderLINQStatus:[UInt8]?
    var activeChannel:UInt8?
    var channel1ValueRaw:UInt8?
    var channel2ValueRaw:UInt8?
    var channel3ValueRaw:UInt8?
    var channel4ValueRaw:UInt8?

    var keyMode:UInt8?
    var sensitivity:UInt8?
    var rightKeyType:UInt8?
    var rightKeyModifier:UInt8?
    var rightKey:UInt8?
    var rightLongKeyType:UInt8?
    var rightLongKeyModifier:UInt8?
    var rightLongKey:UInt8?
    var leftKeyType:UInt8?
    var leftKeyModifier:UInt8?
    var leftKey:UInt8?
    var leftLongKeyType:UInt8?
    var leftLongKeyModifier:UInt8?
    var leftLongKey:UInt8?
    var upKeyType:UInt8?
    var upKeyModifier:UInt8?
    var upKey:UInt8?
    var upLongKeyType:UInt8?
    var upLongKeyModifier:UInt8?
    var upLongKey:UInt8?
    var downKeyType:UInt8?
    var downKeyModifier:UInt8?
    var downKey:UInt8?
    var downLongKeyType:UInt8?
    var downLongKeyModifier:UInt8?
    var downLongKey:UInt8?
    var fx1KeyType:UInt8?
    var fx1KeyModifier:UInt8?
    var fx1Key:UInt8?
    var fx1LongKeyType:UInt8?
    var fx1LongKeyModifier:UInt8?
    var fx1LongKey:UInt8?
    var fx2KeyType:UInt8?
    var fx2KeyModifier:UInt8?
    var fx2Key:UInt8?
    var fx2LongKeyType:UInt8?
    var fx2LongKeyModifier:UInt8?
    var fx2LongKey:UInt8?
    
    var pdmChannel1Setting:UInt8?
    var pdmChannel2Setting:UInt8?
    var pdmChannel3Setting:UInt8?
    var pdmChannel4Setting:UInt8?
    var accessories:UInt8? = 0x00
    
    required override init() {
        super.init()
        print("WLQ_S: init()")
        WLQ.shared = self
        WLQ.initialized = true
        actionNames = [KEYMODE: NSLocalizedString("keymode_label", comment: ""),
                        longPressSensitivity: NSLocalizedString("long_press_label", comment: ""),
                        up: NSLocalizedString("up_label", comment: ""),
                        upLong: NSLocalizedString("up_long_label", comment: ""),
                        down: NSLocalizedString("down_label", comment: ""),
                        downLong: NSLocalizedString("down_long_label", comment: ""),
                        left: NSLocalizedString("left_label", comment: ""),
                        leftLong: NSLocalizedString("left_long_label", comment: ""),
                        right: NSLocalizedString("right_label", comment: ""),
                        rightLong: NSLocalizedString("right_long_label", comment: ""),
                        fx1: NSLocalizedString("fx1_label", comment: ""),
                        fx1Long: NSLocalizedString("fx1_long_label", comment: ""),
                        fx2: NSLocalizedString("fx2_label", comment: ""),
                        fx2Long: NSLocalizedString("fx2_long_label", comment: ""),
                        pdmChannel1: NSLocalizedString("pdm_channel1_label", comment: ""),
                        pdmChannel2: NSLocalizedString("pdm_channel2_label", comment: ""),
                        pdmChannel3: NSLocalizedString("pdm_channel3_label", comment: ""),
                        pdmChannel4: NSLocalizedString("pdm_channel4_label", comment: "")
        ]
    }
    
    override func parseConfig(bytes: [UInt8]) {
        
        self.wunderLINQConfig = bytes
        self.firmwareVersion = "\(bytes[self.firmwareVersionMajor_INDEX]).\(bytes[self.firmwareVersionMinor_INDEX])"
        UserDefaults.standard.set("\(bytes[self.firmwareVersionMajor_INDEX]).\(bytes[self.firmwareVersionMinor_INDEX])", forKey: "firmwareVersion")

        self.flashConfig = Array(bytes[6..<(6+configFlashSize)])
        self.tempConfig = self.flashConfig
        
        var messageHexString = ""
        for i in 0 ..< flashConfig!.count {
            messageHexString += String(format: "%02X", flashConfig![i])
            if i < flashConfig!.count - 1 {
                messageHexString += ","
            }
        }
        print("WLQ_S: flashConfig: \(messageHexString)")
        
        self.keyMode = bytes[self.keyMode_INDEX]

        self.sensitivity = self.flashConfig![self.sensitivity_INDEX]
        self.rightKeyType = self.flashConfig![self.rightKeyType_INDEX]
        self.rightKeyModifier = self.flashConfig![self.rightKeyModifier_INDEX]
        self.rightKey = self.flashConfig![self.rightKey_INDEX]
        self.rightLongKeyType = self.flashConfig![self.rightLongKeyType_INDEX]
        self.rightLongKeyModifier = self.flashConfig![self.rightLongKeyModifier_INDEX]
        self.rightLongKey = self.flashConfig![self.rightLongKey_INDEX]
        self.leftKeyType = self.flashConfig![self.leftKeyType_INDEX]
        self.leftKeyModifier = self.flashConfig![self.leftKeyModifier_INDEX]
        self.leftKey = self.flashConfig![self.leftKey_INDEX]
        self.leftLongKeyType = self.flashConfig![self.leftLongKeyType_INDEX]
        self.leftLongKeyModifier = self.flashConfig![self.leftLongKeyModifier_INDEX]
        self.leftLongKey = self.flashConfig![self.leftLongKey_INDEX]
        self.upKeyType = self.flashConfig![self.upKeyType_INDEX]
        self.upKeyModifier = self.flashConfig![self.upKeyModifier_INDEX]
        self.upKey = self.flashConfig![self.upKey_INDEX]
        self.upLongKeyType = self.flashConfig![self.upLongKeyType_INDEX]
        self.upLongKeyModifier = self.flashConfig![self.upLongKeyModifier_INDEX]
        self.upLongKey = self.flashConfig![self.upLongKey_INDEX]
        self.downKeyType = self.flashConfig![self.downKeyType_INDEX]
        self.downKeyModifier = self.flashConfig![self.downKeyModifier_INDEX]
        self.downKey = self.flashConfig![self.downKey_INDEX]
        self.downLongKeyType = self.flashConfig![self.downLongKeyType_INDEX]
        self.downLongKeyModifier = self.flashConfig![self.downLongKeyModifier_INDEX]
        self.downLongKey = self.flashConfig![self.downLongKey_INDEX]
        self.fx1KeyType = self.flashConfig![self.fx1KeyType_INDEX]
        self.fx1KeyModifier = self.flashConfig![self.fx1KeyModifier_INDEX]
        self.fx1Key = self.flashConfig![self.fx1Key_INDEX]
        self.fx1LongKeyType = self.flashConfig![self.fx1LongKeyType_INDEX]
        self.fx1LongKeyModifier = self.flashConfig![self.fx1LongKeyModifier_INDEX]
        self.fx1LongKey = self.flashConfig![self.fx1LongKey_INDEX]
        self.fx2KeyType = self.flashConfig![self.fx2KeyType_INDEX]
        self.fx2KeyModifier = self.flashConfig![self.fx2KeyModifier_INDEX]
        self.fx2Key = self.flashConfig![self.fx2Key_INDEX]
        self.fx2LongKeyType = self.flashConfig![self.fx2LongKeyType_INDEX]
        self.fx2LongKeyModifier = self.flashConfig![self.fx2LongKeyModifier_INDEX]
        self.fx2LongKey = self.flashConfig![self.fx2LongKey_INDEX]
        self.pdmChannel1Setting = self.flashConfig![self.pdmChannel1_INDEX]
        self.pdmChannel2Setting = self.flashConfig![self.pdmChannel2_INDEX]
        self.pdmChannel3Setting = self.flashConfig![self.pdmChannel3_INDEX]
        self.pdmChannel4Setting = self.flashConfig![self.pdmChannel4_INDEX]
        self.accessories = bytes[accessories_INDEX]
    }
    
    override func getDefaultConfig() -> [UInt8]{
        return defaultConfig
    }
    
    override func getTempConfig() -> [UInt8]{
        return tempConfig!
    }
    
    override func setTempConfigByte(index: Int, value: UInt8){
        tempConfig![index] = value
    }
    
    override func getConfig() -> [UInt8]{
        return flashConfig!
    }
    
    override func setStatus(bytes: [UInt8]) {
        self.wunderLINQStatus = Array(bytes[4..<(4+statusSize)])
        self.activeChannel = self.wunderLINQStatus![ACTIVE_CHAN_INDEX]
        self.channel1ValueRaw = self.wunderLINQStatus![ACC_PDM_CHANNEL1_VAL_RAW_INDEX]
        self.channel2ValueRaw = self.wunderLINQStatus![ACC_PDM_CHANNEL2_VAL_RAW_INDEX]
        self.channel3ValueRaw = self.wunderLINQStatus![ACC_PDM_CHANNEL3_VAL_RAW_INDEX]
        self.channel4ValueRaw = self.wunderLINQStatus![ACC_PDM_CHANNEL4_VAL_RAW_INDEX]
    }
    
    override func getStatus() -> [UInt8]?{
        return wunderLINQStatus
    }
    
    override func getAccessories() -> UInt8{
        return accessories!
    }
    
    override func setAccActive(active: UInt8) {
        activeChannel = active
    }
    
    override func getAccActive() -> UInt8{
        return activeChannel!
    }

    override func getAccChannelValue(positon: Int) -> UInt8{
        switch(positon){
        case 1:
            return channel1ValueRaw!
        case 2:
            return channel2ValueRaw!
        default:
            return 0x00
        }
    }
    
    override func gethardwareType() -> Int{
        return 3
    }
    
    override func getKeyMode() -> UInt8{
        return keyMode!
    }
    
    override func getActionName(action: Int?) -> String{
        return actionNames[action!]!
    }
    override func setActionName(action: Int?, key: String){
        actionNames[action!] = key
    }

    override func getActionKeyType(action: Int?) -> UInt8{
        switch (action){
        case up:
            return upKeyType!
        case upLong:
            return upLongKeyType!
        case down:
            return downKeyType!
        case downLong:
            return downLongKeyType!
        case left:
            return leftKeyType!
        case leftLong:
            return leftLongKeyType!
        case right:
            return rightKeyType!
        case rightLong:
            return rightLongKeyType!
        case fx1:
            return fx1KeyType!
        case fx1Long:
            return fx1LongKeyType!
        case fx2:
            return fx2KeyType!
        case fx2Long:
            return fx2LongKeyType!
        default:
            return 0x00
        }
    }
    
    override func setActionKey(action: Int?, key: [UInt8]) {
        if (key.count == 3){
            switch (action){
            case up:
                self.tempConfig![self.upKeyType_INDEX] = key[0]
                self.tempConfig![self.upKeyModifier_INDEX] = key[1]
                self.tempConfig![self.upKey_INDEX] = key[2]
            case upLong:
                self.tempConfig![self.upLongKeyType_INDEX] = key[0]
                self.tempConfig![self.upLongKeyModifier_INDEX] = key[1]
                self.tempConfig![self.upLongKey_INDEX] = key[2]
            case down:
                self.tempConfig![self.downKeyType_INDEX] = key[0]
                self.tempConfig![self.downKeyModifier_INDEX] = key[1]
                self.tempConfig![self.downKey_INDEX] = key[2]
            case downLong:
                self.tempConfig![self.downLongKeyType_INDEX] = key[0]
                self.tempConfig![self.downLongKeyModifier_INDEX] = key[1]
                self.tempConfig![self.downLongKey_INDEX] = key[2]
            case left:
                self.tempConfig![self.leftKeyType_INDEX] = key[0]
                self.tempConfig![self.leftKeyModifier_INDEX] = key[1]
                self.tempConfig![self.leftKey_INDEX] = key[2]
            case leftLong:
                self.tempConfig![self.leftLongKeyType_INDEX] = key[0]
                self.tempConfig![self.leftLongKeyModifier_INDEX] = key[1]
                self.tempConfig![self.leftLongKey_INDEX] = key[2]
            case right:
                self.tempConfig![self.rightKeyType_INDEX] = key[0]
                self.tempConfig![self.rightKeyModifier_INDEX] = key[1]
                self.tempConfig![self.rightKey_INDEX] = key[2]
            case rightLong:
                self.tempConfig![self.rightLongKeyType_INDEX] = key[0]
                self.tempConfig![self.rightLongKeyModifier_INDEX] = key[1]
                self.tempConfig![self.rightLongKey_INDEX] = key[2]
            case fx1:
                self.tempConfig![self.fx1KeyType_INDEX] = key[0]
                self.tempConfig![self.fx1KeyModifier_INDEX] = key[1]
                self.tempConfig![self.fx1Key_INDEX] = key[2]
            case fx1Long:
                self.tempConfig![self.fx1LongKeyType_INDEX] = key[0]
                self.tempConfig![self.fx1LongKeyModifier_INDEX] = key[1]
                self.tempConfig![self.fx1LongKey_INDEX] = key[2]
            case fx2:
                self.tempConfig![self.fx2KeyType_INDEX] = key[0]
                self.tempConfig![self.fx2KeyModifier_INDEX] = key[1]
                self.tempConfig![self.fx2Key_INDEX] = key[2]
            case fx2Long:
                self.tempConfig![self.fx2LongKeyType_INDEX] = key[0]
                self.tempConfig![self.fx2LongKeyModifier_INDEX] = key[1]
                self.tempConfig![self.fx2LongKey_INDEX] = key[2]
            default:
                print("WLQ_S: Invalid acitonID")
            }
        }
    }
    
    override func getActionKeyPosition(action: Int) -> Int{
        var position:Int = 0
        let keyboardHID = KeyboardHID.shared
        switch (action){
        case up:
            if(upKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == upKey! }) {
                    position = index
                }
            } else if(upKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == upKey! }) {
                    position = index
                }
            }
        case upLong:
            if(upLongKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == upLongKey! }) {
                    position = index
                }
            } else if(upLongKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == upLongKey! }) {
                    position = index
                }
            }
        case down:
            if(downKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == downKey! }) {
                    position = index
                }
            } else if(downKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == downKey! }) {
                    position = index
                }
            }
        case downLong:
            if(downLongKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == downLongKey! }) {
                    position = index
                }
            } else if(downLongKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == downLongKey! }) {
                    position = index
                }
            }
        case left:
            if(leftKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == leftKey! }) {
                    position = index
                }
            } else if(leftKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == leftKey! }) {
                    position = index
                }
            }
        case leftLong:
            if(leftLongKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == leftLongKey! }) {
                    position = index
                }
            } else if(leftLongKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == leftLongKey! }) {
                    position = index
                }
            }
        case right:
            if(rightKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == rightKey! }) {
                    position = index
                }
            } else if(rightKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == rightKey! }) {
                    position = index
                }
            }
        case rightLong:
            if(rightLongKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == rightLongKey! }) {
                    position = index
                }
            } else if(rightLongKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == rightLongKey! }) {
                    position = index
                }
            }
        case fx1:
            if(fx1KeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == fx1Key! }) {
                    position = index
                }
            } else if(fx1KeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == fx1Key! }) {
                    position = index
                }
            }
        case fx1Long:
            if(fx1LongKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == fx1LongKey! }) {
                    position = index
                }
            } else if(fx1LongKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == fx1LongKey! }) {
                    position = index
                }
            }
        case fx2:
            if(fx2KeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == fx2Key! }) {
                    position = index
                }
            } else if(fx2KeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == fx2Key! }) {
                    position = index
                }
            }
        case fx2Long:
            if(fx2LongKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == fx2LongKey! }) {
                    position = index
                }
            } else if(fx2LongKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == fx2LongKey! }) {
                    position = index
                }
            }
        default:
            position = 0
        }
        return position
    }
    
    override func setActionValue(action: Int?, value: UInt8){
        switch (action){
        case longPressSensitivity:
            tempConfig![sensitivity_INDEX] = value
        case pdmChannel1:
            tempConfig![pdmChannel1_INDEX] = value;
        case pdmChannel2:
            tempConfig![pdmChannel2_INDEX] = value;
        case pdmChannel3:
            tempConfig![pdmChannel3_INDEX] = value;
        case pdmChannel4:
            tempConfig![pdmChannel2_INDEX] = value;
        default:
            print("WLQ_S: setActionValue Unknown Action ID:")
        }
    }
    
    override func getActionValue(action: Int) -> String{
        var returnString = NSLocalizedString("hid_0x00_label", comment: "")
        let keyboardHID = KeyboardHID.shared
        switch (action){
        case KEYMODE:
            switch (keyMode){
            case 0:
                returnString = NSLocalizedString("keymode_default_label", comment: "")
            case 1:
                returnString = NSLocalizedString("keymode_custom_label", comment: "")
            case 2:
                returnString = NSLocalizedString("keymode_media_label", comment: "")
            case 3:
                returnString = NSLocalizedString("keymode_dmd2_label", comment: "")
            default:
                returnString = ""
            }
        case longPressSensitivity:
            returnString = "\(Int(sensitivity!) * 50)"
        case up:
            if(upKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == upKey! }) {
                    let name = keyboardHID.keyboardCodes[index].1
                    returnString = name
                }
            } else if(upKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == upKey! }) {
                    let name = keyboardHID.consumerCodes[index].1
                    returnString = name
                }
            }
        case upLong:
            if(upLongKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == upLongKey! }) {
                    let name = keyboardHID.keyboardCodes[index].1
                    returnString = name
                }
            } else if(upLongKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == upLongKey! }) {
                    let name = keyboardHID.consumerCodes[index].1
                    returnString = name
                }
            }
        case down:
            if(downKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == downKey! }) {
                    let name = keyboardHID.keyboardCodes[index].1
                    returnString = name
                }
            } else if(downKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == downKey! }) {
                    let name = keyboardHID.consumerCodes[index].1
                    returnString = name
                }
            }
        case downLong:
            if(downLongKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == downLongKey! }) {
                    let name = keyboardHID.keyboardCodes[index].1
                    returnString = name
                }
            } else if(downLongKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == downLongKey! }) {
                    let name = keyboardHID.consumerCodes[index].1
                    returnString = name
                }
            }
        case left:
            if(leftKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == leftKey! }) {
                    let name = keyboardHID.keyboardCodes[index].1
                    returnString = name
                }
            } else if(leftKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == leftKey! }) {
                    let name = keyboardHID.consumerCodes[index].1
                    returnString = name
                }
            }
        case leftLong:
            if(leftLongKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == leftLongKey! }) {
                    let name = keyboardHID.keyboardCodes[index].1
                    returnString = name
                }
            } else if(leftLongKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == leftLongKey! }) {
                    let name = keyboardHID.consumerCodes[index].1
                    returnString = name
                }
            }
        case right:
            if(rightKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == rightKey! }) {
                    let name = keyboardHID.keyboardCodes[index].1
                    returnString = name
                }
            } else if(rightKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == rightKey! }) {
                    let name = keyboardHID.consumerCodes[index].1
                    returnString = name
                }
            }
        case rightLong:
            if(rightLongKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == rightLongKey! }) {
                    let name = keyboardHID.keyboardCodes[index].1
                    returnString = name
                }
            } else if(rightLongKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == rightLongKey! }) {
                    let name = keyboardHID.consumerCodes[index].1
                    returnString = name
                }
            }
        case fx1:
            if(fx1KeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == fx1Key! }) {
                    let name = keyboardHID.keyboardCodes[index].1
                    returnString = name
                }
            } else if(fx1KeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == fx1Key! }) {
                    let name = keyboardHID.consumerCodes[index].1
                    returnString = name
                }
            }
        case fx1Long:
            if(fx1LongKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == fx1LongKey! }) {
                    let name = keyboardHID.keyboardCodes[index].1
                    returnString = name
                }
            } else if(fx1LongKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == fx1LongKey! }) {
                    let name = keyboardHID.consumerCodes[index].1
                    returnString = name
                }
            }
        case fx2:
            if(fx2KeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == fx2Key! }) {
                    let name = keyboardHID.keyboardCodes[index].1
                    returnString = name
                }
            } else if(fx2KeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == fx2Key! }) {
                    let name = keyboardHID.consumerCodes[index].1
                    returnString = name
                }
            }
        case fx2Long:
            if(fx2LongKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == fx2LongKey! }) {
                    let name = keyboardHID.keyboardCodes[index].1
                    returnString = name
                }
            } else if(fx2LongKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == fx2LongKey! }) {
                    let name = keyboardHID.consumerCodes[index].1
                    returnString = name
                }
            }
        case pdmChannel1:
            switch (pdmChannel1Setting){
            case 0x00:
                returnString = NSLocalizedString("pdm_channel_mode_toggle", comment: "")
            case 0x01:
                returnString = NSLocalizedString("pdm_channel_mode_momentary", comment: "")
            case 0x02:
                returnString = NSLocalizedString("pdm_channel_mode_ignition", comment: "")
            case 0x03:
                returnString = NSLocalizedString("pdm_channel_mode_highbeam", comment: "")
            case 0x04:
                returnString = NSLocalizedString("pdm_channel_mode_brakes", comment: "")
            case 0x05:
                returnString = NSLocalizedString("pdm_channel_mode_ambient_light", comment: "")
            case 0x06:
                returnString = NSLocalizedString("pdm_channel_mode_ambient_temp", comment: "")
            case 0x07:
                returnString = NSLocalizedString("pdm_channel_mode_heated_grips", comment: "")
            case 0xFF:
                returnString = NSLocalizedString("pdm_channel_mode_disabled", comment: "")
            default:
                returnString = ""
            }
        case pdmChannel2:
            switch (pdmChannel2Setting){
            case 0x00:
                returnString = NSLocalizedString("pdm_channel_mode_toggle", comment: "")
            case 0x01:
                returnString = NSLocalizedString("pdm_channel_mode_momentary", comment: "")
            case 0x02:
                returnString = NSLocalizedString("pdm_channel_mode_ignition", comment: "")
            case 0x03:
                returnString = NSLocalizedString("pdm_channel_mode_highbeam", comment: "")
            case 0x04:
                returnString = NSLocalizedString("pdm_channel_mode_brakes", comment: "")
            case 0x05:
                returnString = NSLocalizedString("pdm_channel_mode_ambient_light", comment: "")
            case 0x06:
                returnString = NSLocalizedString("pdm_channel_mode_ambient_temp", comment: "")
            case 0x07:
                returnString = NSLocalizedString("pdm_channel_mode_heated_grips", comment: "")
            case 0xFF:
                returnString = NSLocalizedString("pdm_channel_mode_disabled", comment: "")
            default:
                returnString = ""
            }
        case pdmChannel3:
            switch (pdmChannel3Setting){
            case 0x00:
                returnString = NSLocalizedString("pdm_channel_mode_toggle", comment: "")
            case 0x01:
                returnString = NSLocalizedString("pdm_channel_mode_momentary", comment: "")
            case 0x02:
                returnString = NSLocalizedString("pdm_channel_mode_ignition", comment: "")
            case 0x03:
                returnString = NSLocalizedString("pdm_channel_mode_highbeam", comment: "")
            case 0x04:
                returnString = NSLocalizedString("pdm_channel_mode_brakes", comment: "")
            case 0x05:
                returnString = NSLocalizedString("pdm_channel_mode_ambient_light", comment: "")
            case 0x06:
                returnString = NSLocalizedString("pdm_channel_mode_ambient_temp", comment: "")
            case 0x07:
                returnString = NSLocalizedString("pdm_channel_mode_heated_grips", comment: "")
            case 0xFF:
                returnString = NSLocalizedString("pdm_channel_mode_disabled", comment: "")
            default:
                returnString = ""
            }
        case pdmChannel4:
            switch (pdmChannel4Setting){
            case 0x00:
                returnString = NSLocalizedString("pdm_channel_mode_toggle", comment: "")
            case 0x01:
                returnString = NSLocalizedString("pdm_channel_mode_momentary", comment: "")
            case 0x02:
                returnString = NSLocalizedString("pdm_channel_mode_ignition", comment: "")
            case 0x03:
                returnString = NSLocalizedString("pdm_channel_mode_highbeam", comment: "")
            case 0x04:
                returnString = NSLocalizedString("pdm_channel_mode_brakes", comment: "")
            case 0x05:
                returnString = NSLocalizedString("pdm_channel_mode_ambient_light", comment: "")
            case 0x06:
                returnString = NSLocalizedString("pdm_channel_mode_ambient_temp", comment: "")
            case 0x07:
                returnString = NSLocalizedString("pdm_channel_mode_heated_grips", comment: "")
            case 0xFF:
                returnString = NSLocalizedString("pdm_channel_mode_disabled", comment: "")
            default:
                returnString = ""
            }
        default:
            returnString = ""
        }
        return returnString
    }
    
    override func getActionValueRaw(action: Int) -> UInt8?{
        switch (action){
        case longPressSensitivity:
            return sensitivity!
        case pdmChannel1:
            return pdmChannel1Setting!
        case pdmChannel2:
            return pdmChannel2Setting!
        case pdmChannel3:
            return pdmChannel3Setting!
        case pdmChannel4:
            return pdmChannel4Setting!
        default:
            print("WLQ_S: setActionValue Unknown Action ID:")
        }
        return nil
    }
    
    override func getActionKeyModifiers(action: Int) -> UInt8{
        var modifiers:UInt8 = 0x00
        switch (action){
        case self.up:
            modifiers = self.upKeyModifier!
        case self.upLong:
            modifiers = self.upLongKeyModifier!
        case self.down:
            modifiers = self.downKeyModifier!
        case self.downLong:
            modifiers = self.downLongKeyModifier!
        case self.left:
            modifiers = self.leftKeyModifier!
        case self.leftLong:
            modifiers = self.leftLongKeyModifier!
        case self.right:
            modifiers = self.rightKeyModifier!
        case self.rightLong:
            modifiers = self.rightLongKeyModifier!
        case self.fx1:
            modifiers = self.fx1KeyModifier!
        case self.fx1Long:
            modifiers = self.fx1LongKeyModifier!
        case self.fx2:
            modifiers = self.fx2KeyModifier!
        case self.fx2Long:
            modifiers = self.fx2LongKeyModifier!
        default:
            modifiers = 0x00
        }
        return modifiers
    }

    override func setfirmwareVersion(firmwareVersion: String?){
        print("WLQ_S: Firmware Version: \(firmwareVersion ?? "?")")
        self.firmwareVersion = firmwareVersion
    }
    override func getfirmwareVersion() -> String{
        if (self.firmwareVersion != nil){
            return self.firmwareVersion!
        }
        return "Unknown"
    }

    override func sethardwareVersion(hardwareVersion: String?){
        print("WLQ_S: HW Version: \(hardwareVersion ?? "?")")
        self.hardwareVersion = hardwareVersion
    }
    override func gethardwareVersion() -> String{
        if (self.hardwareVersion != nil){
            return self.hardwareVersion!
        }
        return "Unknown"
    }}
