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
class WLQ_C: WLQ {
    
    var hardwareVersion:String?
    let hardwareVersion1:String = "2PCB7.0 11/19/21"
    
    var wunderLINQConfig:[UInt8]?
    var flashConfig:[UInt8]?
    var tempConfig:[UInt8]?
    var firmwareVersion:String?
    var USBVinThreshold:UInt16?
    
    let keyMode_default:UInt8 = 0x00
    let keyMode_custom:UInt8 = 0x01

    let KEYBOARD_HID:UInt8 = 0x01
    let CONSUMER_HID:UInt8 = 0x02
    let UNDEFINED:UInt8 = 0x00

    let configFlashSize:Int = 36
    let defaultConfig:[UInt8] = [
        0x40, 0xD9, 0x42,                                   // CAN
        0x00, 0x00,                                         // USB
        0x11,                                               // Sensitivity
        0x01, 0x00, 0x52,                                   // Scroll Up
        0x01, 0x00, 0x51,                                   // Scroll Down
        0x01, 0x00, 0x50, 0x01, 0x00, 0x29,                 // Wheel Left
        0x01, 0x00, 0x4F, 0x01, 0x00, 0x28,                 // Wheel Right
        0x02, 0x00, 0xE9, 0x02, 0x00, 0xE2,                 // Menu Up
        0x02, 0x00, 0xEA, 0x02, 0x00, 0xE2]                 // Menu Down

    let longPressSensitivity:Int = 25
    let wheelScrollUp:Int = 26
    let wheelScrollDown:Int = 27
    let wheelToggleRight:Int = 28
    let wheelToggleRightLongPress:Int = 29
    let wheelToggleLeft:Int = 30
    let wheelToggleLeftLongPress:Int = 31
    let menuUp:Int = 32
    let menuUpLongPress:Int = 33
    let menuDown:Int = 34
    let menuDownLongPress:Int = 35
    
    var actionNames: [Int: String] = [:]

    let firmwareVersionMajor_INDEX:Int = 3
    let firmwareVersionMinor_INDEX:Int = 4
    let keyMode_INDEX:Int = 5
    let CANCF1_INDEX:Int = 0
    let CANCF2_INDEX:Int = 1
    let CANCF3_INDEX:Int = 2
    let USBVinThresholdHigh_INDEX:Int = 3
    let USBVinThresholdLow_INDEX:Int = 4
    let Sensitivity_INDEX:Int = 5
    let wheelScrollUpKeyType_INDEX:Int = 6
    let wheelScrollUpKeyModifier_INDEX:Int = 7
    let wheelScrollUpKey_INDEX:Int = 8
    let wheelScrollDownKeyType_INDEX:Int = 9
    let wheelScrollDownKeyModifier_INDEX:Int = 10
    let wheelScrollDownKey_INDEX:Int = 11
    let wheelLeftPressKeyType_INDEX:Int = 12
    let wheelLeftPressKeyModifier_INDEX:Int = 13
    let wheelLeftPressKey_INDEX:Int = 14
    let wheelLeftLongPressKeyType_INDEX:Int = 15
    let wheelLeftLongPressKeyModifier_INDEX:Int = 16
    let wheelLeftLongPressKey_INDEX:Int = 17
    let wheelRightPressKeyType_INDEX:Int = 18
    let wheelRightPressKeyModifier_INDEX:Int = 19
    let wheelRightPressKey_INDEX:Int = 20
    let wheelRightLongPressKeyType_INDEX:Int = 21
    let wheelRightLongPressKeyModifier_INDEX:Int = 22
    let wheelRightLongPressKey_INDEX:Int = 23
    let menuUpPressKeyType_INDEX:Int = 24
    let menuUpPressKeyModifier_INDEX:Int = 25
    let menuUpPressKey_INDEX:Int = 26
    let menuUpLongPressKeyType_INDEX:Int = 27
    let menuUpLongPressKeyModifier_INDEX:Int = 28
    let menuUpLongPressKey_INDEX:Int = 29
    let menuDownPressKeyType_INDEX:Int = 30
    let menuDownPressKeyModifier_INDEX:Int = 31
    let menuDownPressKey_INDEX:Int = 32
    let menuDownLongPressKeyType_INDEX:Int = 33
    let menuDownLongPressKeyModifier_INDEX:Int = 34
    let menuDownLongPressKey_INDEX:Int = 35
    
    // Status message
    let MODE_INDEX:Int = 0
    //let MODE_INDEX = 1
    let TRIGGER_BIT_BYTE_INDEX:Int = 2
    let TRIGGER_BIT_POS_INDEX:Int = 3
    let TRIGGER_BIT_HOLD_CNT_LOW_INDEX:Int = 4
    let TRIGGER_BIT_HOLD_CNT_HIGH_INDEX:Int = 5
    let TRIGGER_BIT_MAX_CNT_LOW_INDEX:Int = 6
    let TRIGGER_BIT_MAX_CNT_HIGH_INDEX:Int = 7
    let TRIGGER_BIT_MIN_CNT_LOW_INDEX:Int = 8
    let TRIGGER_BIT_MIN_CNT_HIGH_INDEX:Int = 9
    let TRIGGER_BIT_MAX_VAL_INDEX:Int = 10
    let TRIGGER_BIT_MIN_VAL_INDEX:Int = 11

    let WW_R_BIT_BYTE_INDEX:Int = 12
    let WW_R_BIT_POS_INDEX:Int = 13
    let WW_R_BIT_HOLD_CNT_LOW_INDEX:Int = 14
    let WW_R_BIT_HOLD_CNT_HIGH_INDEX:Int = 15
    let WW_R_BIT_MAX_CNT_LOW_INDEX:Int = 16
    let WW_R_BIT_MAX_CNT_HIGH_INDEX:Int = 17
    let WW_R_BIT_MIN_CNT_LOW_INDEX:Int = 18
    let WW_R_BIT_MIN_CNT_HIGH_INDEX:Int = 19
    let WW_R_BIT_MAX_VAL_INDEX:Int = 20
    let WW_R_BIT_MIN_VAL_INDEX:Int = 21

    let WW_L_BIT_BYTE_INDEX:Int = 22
    let WW_L_BIT_POS_INDEX:Int = 23
    let WW_L_BIT_HOLD_CNT_LOW_INDEX:Int = 24
    let WW_L_BIT_HOLD_CNT_HIGH_INDEX:Int = 25
    let WW_L_BIT_MAX_CNT_LOW_INDEX:Int = 26
    let WW_L_BIT_MAX_CNT_HIGH_INDEX:Int = 27
    let WW_L_BIT_MIN_CNT_LOW_INDEX:Int = 28
    let WW_L_BIT_MIN_CNT_HIGH_INDEX:Int = 29
    let WW_L_BIT_MAX_VAL_INDEX:Int = 30
    let WW_L_BIT_MIN_VAL_INDEX:Int = 31

    let WW_SCROLL_BYTE_INDEX:Int = 32
    let WW_SCROLL_LENGTH_INDEX:Int = 33
    let WW_SCROLL_VAL_CURRENT_INDEX:Int = 34
    let WW_SCROLL_VAL_OLD_INDEX:Int = 35
    let WW_SCROLL_INC_VAL_INDEX:Int = 36
    let WW_SCROLL_DEC_VAL_INDEX:Int = 37

    let WLQ_SCHEDULE_SLOT_INDEX:Int = 38
    let OEM_SCHEDULE_SLOT_INDEX:Int = 39
    let ACC_SCHEDULE_SLOT_INDEX:Int = 40

    let PIXEL_OB_INTENSITY_INDEX:Int = 41
    let PIXEL_OB_B_INDEX:Int = 42
    let PIXEL_OB_G_INDEX:Int = 43
    let PIXEL_OB_R_INDEX:Int = 44
    let PIXEL_REMOTE_INTENSITY_INDEX:Int = 45
    let PIXEL_REMOTE_B_INDEX:Int = 46
    let PIXEL_REMOTE_G_INDEX:Int = 47
    let PIXEL_REMOTE_R_INDEX:Int = 48

    let ACTIVE_CHAN_INDEX:Int = 49
    let LIN_ACC_CHANNEL_CNT_INDEX:Int = 50

    let LIN_ACC_CHANNEL1_CONFIG_BYTE_INDEX:Int = 51
    let LIN_ACC_CHANNEL1_VAL_BYTE_INDEX:Int = 52
    let LIN_ACC_CHANNEL1_CONFIG_STATE_INDEX:Int = 53
    let LIN_ACC_CHANNEL1_VAL_RAW_INDEX:Int = 54
    let LIN_ACC_CHANNEL1_VAL_OFFSET_INDEX:Int = 55
    let LIN_ACC_CHANNEL1_VAL_SCALE_INDEX:Int = 56
    let LIN_ACC_CHANNEL1_PIXEL_INTENSITY_INDEX:Int = 57
    let LIN_ACC_CHANNEL1_PIXEL_B_INDEX:Int = 58
    let LIN_ACC_CHANNEL1_PIXEL_G_INDEX:Int = 59
    let LIN_ACC_CHANNEL1_PIXEL_R_INDEX:Int = 60

    let LIN_ACC_CHANNEL2_CONFIG_BYTE_INDEX:Int = 61
    let LIN_ACC_CHANNEL2_VAL_BYTE_INDEX:Int = 62
    let LIN_ACC_CHANNEL2_CONFIG_STATE_INDEX:Int = 63
    let LIN_ACC_CHANNEL2_VAL_RAW_INDEX:Int = 64
    let LIN_ACC_CHANNEL2_VAL_OFFSET_INDEX:Int = 65
    let LIN_ACC_CHANNEL2_VAL_SCALE_INDEX:Int = 66
    let LIN_ACC_CHANNEL2_PIXEL_INTENSITY_INDEX:Int = 67
    let LIN_ACC_CHANNEL2_PIXEL_B_INDEX:Int = 68
    let LIN_ACC_CHANNEL2_PIXEL_G_INDEX:Int = 69
    let LIN_ACC_CHANNEL2_PIXEL_R_INDEX:Int = 70
    
    var wunderLINQStatus:[UInt8]?
    var channel1PixelColor:UInt8?
    var channel2PixelColor:UInt8?
    var channel1PixelIntensity:UInt8?
    var channel2PixelIntensity:UInt8?
    var channe1ValueRaw:UInt8?
    var channel2ValueRaw:UInt8?

    var keyMode:UInt8?
    var sensitivity:UInt8?
    var wheelRightPressKeyType:UInt8?
    var wheelRightPressKeyModifier:UInt8?
    var wheelRightPressKey:UInt8?
    var wheelRightLongPressKeyType:UInt8?
    var wheelRightLongPressKeyModifier:UInt8?
    var wheelRightLongPressKey:UInt8?
    var wheelLeftPressKeyType:UInt8?
    var wheelLeftPressKeyModifier:UInt8?
    var wheelLeftPressKey:UInt8?
    var wheelLeftLongPressKeyType:UInt8?
    var wheelLeftLongPressKeyModifier:UInt8?
    var wheelLeftLongPressKey:UInt8?
    var wheelScrollUpKeyType:UInt8?
    var wheelScrollUpKeyModifier:UInt8?
    var wheelScrollUpKey:UInt8?
    var wheelScrollDownKeyType:UInt8?
    var wheelScrollDownKeyModifier:UInt8?
    var wheelScrollDownKey:UInt8?
    var menuUpPressKeyType:UInt8?
    var menuUpPressKeyModifier:UInt8?
    var menuUpPressKey:UInt8?
    var menuUpLongPressKeyType:UInt8?
    var menuUpLongPressKeyModifier:UInt8?
    var menuUpLongPressKey:UInt8?
    var menuDownPressKeyType:UInt8?
    var menuDownPressKeyModifier:UInt8?
    var menuDownPressKey:UInt8?
    var menuDownLongPressKeyType:UInt8?
    var menuDownLongPressKeyModifier:UInt8?
    var menuDownLongPressKey:UInt8?

    required override init() {
        super.init()
        WLQ.shared = self
        actionNames = [longPressSensitivity: NSLocalizedString("sensitivity_label", comment: ""),
                              wheelScrollUp: NSLocalizedString("full_scroll_up_label", comment: ""),
                            wheelScrollDown: NSLocalizedString("full_scroll_down_label", comment: ""),
                           wheelToggleRight: NSLocalizedString("full_toggle_right_label", comment: ""),
                  wheelToggleRightLongPress: NSLocalizedString("full_toggle_right_long_label", comment: ""),
                            wheelToggleLeft: NSLocalizedString("full_toggle_left_label", comment: ""),
                   wheelToggleLeftLongPress: NSLocalizedString("full_toggle_left_long_label", comment: ""),
                                     menuUp: NSLocalizedString("full_menu_up_label", comment: ""),
                            menuUpLongPress: NSLocalizedString("full_menu_up_long_label", comment: ""),
                                   menuDown: NSLocalizedString("full_menu_down_label", comment: ""),
                          menuDownLongPress: NSLocalizedString("full_menu_down_long_label", comment: "")]
    }
    
    override func parseConfig(bytes: [UInt8]) {
        
        self.wunderLINQConfig = bytes
        self.firmwareVersion = "\(bytes[self.firmwareVersionMajor_INDEX]).\(bytes[self.firmwareVersionMinor_INDEX])"

        self.flashConfig = Array(bytes[6..<(6+configFlashSize)])
        self.tempConfig = self.flashConfig
        
        var messageHexString = ""
        for i in 0 ..< flashConfig!.count {
            messageHexString += String(format: "%02X", flashConfig![i])
            if i < flashConfig!.count - 1 {
                messageHexString += ","
            }
        }
        print("flashConfig: \(messageHexString)")
        var tmessageHexString = ""
        for i in 0 ..< tempConfig!.count {
            tmessageHexString += String(format: "%02X", tempConfig![i])
            if i < tempConfig!.count - 1 {
                tmessageHexString += ","
            }
        }
        print("tempConfig: \(tmessageHexString)")
        
        self.keyMode = bytes[self.keyMode_INDEX]
        let usbBytes: [UInt8] = [self.flashConfig![self.USBVinThresholdHigh_INDEX], self.flashConfig![self.USBVinThresholdLow_INDEX]]
        self.USBVinThreshold = usbBytes.withUnsafeBytes { $0.load(as: UInt16.self) }
        //let CANSpeed: [UInt8] = [self.flashConfig![self.CANCF1_INDEX], self.flashConfig![self.CANCF2_INDEX], self.flashConfig![self.CANCF3_INDEX]]
        self.sensitivity = self.flashConfig![self.Sensitivity_INDEX]
        self.wheelRightPressKeyType = self.flashConfig![self.wheelRightPressKeyType_INDEX]
        self.wheelRightPressKeyModifier = self.flashConfig![self.wheelRightPressKeyModifier_INDEX]
        self.wheelRightPressKey = self.flashConfig![self.wheelRightPressKey_INDEX]
        self.wheelRightLongPressKeyType = self.flashConfig![self.wheelRightLongPressKeyType_INDEX]
        self.wheelRightLongPressKeyModifier = self.flashConfig![self.wheelRightLongPressKeyModifier_INDEX]
        self.wheelRightLongPressKey = self.flashConfig![self.wheelRightLongPressKey_INDEX]
        self.wheelLeftPressKeyType = self.flashConfig![self.wheelLeftPressKeyType_INDEX]
        self.wheelLeftPressKeyModifier = self.flashConfig![self.wheelLeftPressKeyModifier_INDEX]
        self.wheelLeftPressKey = self.flashConfig![self.wheelLeftPressKey_INDEX]
        self.wheelLeftLongPressKeyType = self.flashConfig![self.wheelLeftLongPressKeyType_INDEX]
        self.wheelLeftLongPressKeyModifier = self.flashConfig![self.wheelLeftLongPressKeyModifier_INDEX]
        self.wheelLeftLongPressKey = self.flashConfig![self.wheelLeftLongPressKey_INDEX]
        self.wheelScrollUpKeyType = self.flashConfig![self.wheelScrollUpKeyType_INDEX]
        self.wheelScrollUpKeyModifier = self.flashConfig![wheelScrollUpKeyModifier_INDEX]
        self.wheelScrollUpKey = self.flashConfig![self.wheelScrollUpKey_INDEX]
        self.wheelScrollDownKeyType = self.flashConfig![self.wheelScrollDownKeyType_INDEX]
        self.wheelScrollDownKeyModifier = self.flashConfig![self.wheelScrollDownKeyModifier_INDEX]
        self.wheelScrollDownKey = self.flashConfig![self.wheelScrollDownKey_INDEX]
        self.menuUpPressKeyType = self.flashConfig![self.menuUpPressKeyType_INDEX]
        self.menuUpPressKeyModifier = self.flashConfig![self.menuUpPressKeyModifier_INDEX]
        self.menuUpPressKey = self.flashConfig![self.menuUpPressKey_INDEX]
        self.menuUpLongPressKeyType = self.flashConfig![self.menuUpLongPressKeyType_INDEX]
        self.menuUpLongPressKeyModifier = self.flashConfig![self.menuUpLongPressKeyModifier_INDEX]
        self.menuUpLongPressKey = self.flashConfig![self.menuUpLongPressKey_INDEX]
        self.menuDownPressKeyType = self.flashConfig![self.menuDownPressKeyType_INDEX]
        self.menuDownPressKeyModifier = self.flashConfig![self.menuDownPressKeyModifier_INDEX]
        self.menuDownPressKey = self.flashConfig![self.menuDownPressKey_INDEX]
        self.menuDownLongPressKeyType = self.flashConfig![self.menuDownLongPressKeyType_INDEX]
        self.menuDownLongPressKeyModifier = self.flashConfig![self.menuDownLongPressKeyModifier_INDEX]
        self.menuDownLongPressKey = self.flashConfig![self.menuDownLongPressKey_INDEX]
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
        self.wunderLINQStatus = Array(bytes[3..<(3+71)])//Fix
        self.channel1PixelColor = 0x00 << 24 | self.wunderLINQStatus![LIN_ACC_CHANNEL1_PIXEL_R_INDEX] << 16 | self.wunderLINQStatus![LIN_ACC_CHANNEL1_PIXEL_G_INDEX] << 8 | self.wunderLINQStatus![LIN_ACC_CHANNEL1_PIXEL_B_INDEX]
        self.channel2PixelColor = 0x00 << 24 | self.wunderLINQStatus![LIN_ACC_CHANNEL2_PIXEL_R_INDEX] << 16 | self.wunderLINQStatus![LIN_ACC_CHANNEL2_PIXEL_G_INDEX] << 8 | self.wunderLINQStatus![LIN_ACC_CHANNEL2_PIXEL_B_INDEX]
        self.channel1PixelIntensity = self.wunderLINQStatus![LIN_ACC_CHANNEL1_PIXEL_INTENSITY_INDEX]
        self.channel2PixelIntensity = self.wunderLINQStatus![LIN_ACC_CHANNEL2_PIXEL_INTENSITY_INDEX]
        self.channe1ValueRaw = self.wunderLINQStatus![LIN_ACC_CHANNEL1_VAL_RAW_INDEX]
        self.channel2ValueRaw = self.wunderLINQStatus![LIN_ACC_CHANNEL2_VAL_RAW_INDEX]
    }
    
    override func getStatus() -> [UInt8]{
        var messageHexString = ""
        for i in 0 ..< wunderLINQStatus!.count {
            messageHexString += String(format: "%02X", wunderLINQStatus![i])
            if i < wunderLINQStatus!.count - 1 {
                messageHexString += ","
            }
        }
        print("flashConfig: \(messageHexString)")
        return wunderLINQStatus!
    }
    
    override func gethardwareType() -> Int{
        return 2
    }
    
    override func getKeyMode() -> UInt8{
        return self.keyMode!
    }
    
    override func getActionName(action: Int?) -> String{
        return actionNames[action!]!
    }
    override func setActionName(action: Int?, key: String){
        actionNames[action!] = key
    }

    override func getActionKeyType(action: Int?) -> UInt8{
        switch (action){
        case wheelScrollUp:
            return wheelScrollUpKeyType!
        case wheelScrollDown:
            return wheelScrollDownKeyType!
        case wheelToggleRight:
            return wheelRightPressKeyType!
        case wheelToggleRightLongPress:
            return wheelRightLongPressKeyType!
        case wheelToggleLeft:
            return wheelLeftPressKeyType!
        case wheelToggleLeftLongPress:
            return wheelLeftLongPressKeyType!
        case menuUp:
            return menuUpPressKeyType!
        case menuUpLongPress:
            return menuUpLongPressKeyType!
        case menuDown:
            return menuDownPressKeyType!
        case menuDownLongPress:
            return menuDownLongPressKeyType!
        default:
            return 0x00
        }
    }
    
    override func setActionKey(action: Int?, key: [UInt8]) {
        if (key.count == 3){
            switch (action){
            case wheelScrollUp:
                self.tempConfig![self.wheelScrollUpKeyType_INDEX] = key[0]
                self.tempConfig![self.wheelScrollUpKeyModifier_INDEX] = key[1]
                self.tempConfig![self.wheelScrollUpKey_INDEX] = key[2]
            case wheelScrollDown:
                self.tempConfig![self.wheelScrollDownKeyType_INDEX] = key[0]
                self.tempConfig![self.wheelScrollDownKeyModifier_INDEX] = key[1]
                self.tempConfig![self.wheelScrollDownKey_INDEX] = key[2]
            case wheelToggleRight:
                self.tempConfig![self.wheelRightPressKeyType_INDEX] = key[0]
                self.tempConfig![self.wheelRightPressKeyModifier_INDEX] = key[1]
                self.tempConfig![self.wheelRightPressKey_INDEX] = key[2]
            case wheelToggleRightLongPress:
                self.tempConfig![self.wheelRightLongPressKeyType_INDEX] = key[0]
                self.tempConfig![self.wheelRightLongPressKeyModifier_INDEX] = key[1]
                self.tempConfig![self.wheelRightLongPressKey_INDEX] = key[2]
            case wheelToggleLeft:
                self.tempConfig![self.wheelLeftPressKeyType_INDEX] = key[0]
                self.tempConfig![self.wheelLeftPressKeyModifier_INDEX] = key[1]
                self.tempConfig![self.wheelLeftPressKey_INDEX] = key[2]
            case wheelToggleLeftLongPress:
                self.tempConfig![self.wheelLeftLongPressKeyType_INDEX] = key[0]
                self.tempConfig![self.wheelLeftLongPressKeyModifier_INDEX] = key[1]
                self.tempConfig![self.wheelLeftLongPressKey_INDEX] = key[2]
            case menuUp:
                self.tempConfig![self.menuUpPressKeyType_INDEX] = key[0]
                self.tempConfig![self.menuUpPressKeyModifier_INDEX] = key[1]
                self.tempConfig![self.menuUpPressKey_INDEX] = key[2]
            case menuUpLongPress:
                self.tempConfig![self.menuUpLongPressKeyType_INDEX] = key[0]
                self.tempConfig![self.menuUpLongPressKeyModifier_INDEX] = key[1]
                self.tempConfig![self.menuUpLongPressKey_INDEX] = key[2]
            case menuDown:
                self.tempConfig![self.menuDownPressKeyType_INDEX] = key[0]
                self.tempConfig![self.menuDownPressKeyModifier_INDEX] = key[1]
                self.tempConfig![self.menuDownPressKey_INDEX] = key[2]
            case menuDownLongPress:
                self.tempConfig![self.menuDownLongPressKeyType_INDEX] = key[0]
                self.tempConfig![self.menuDownLongPressKeyModifier_INDEX] = key[1]
                self.tempConfig![self.menuDownLongPressKey_INDEX] = key[2]
            default:
                print("Invalid acitonID")
            }
        }
    }
    
    override func getActionKeyPosition(action: Int) -> Int{
        var position:Int = 0
        let keyboardHID = KeyboardHID.shared
        switch (action){
        case wheelScrollUp:
            if(wheelScrollUpKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == wheelScrollUpKey! }) {
                    position = index
                }
            } else if(wheelScrollUpKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == wheelScrollUpKey! }) {
                    position = index
                }
            }
        case wheelScrollDown:
            if(wheelScrollDownKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == wheelScrollDownKey! }) {
                    position = index
                }
            } else if(wheelScrollDownKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == wheelScrollDownKey! }) {
                    position = index
                }
            }
        case wheelToggleRight:
            if(wheelRightPressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == wheelRightPressKey! }) {
                    position = index
                }
            } else if(wheelRightPressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == wheelRightPressKey! }) {
                    position = index
                }
            }
        case wheelToggleRightLongPress:
            if(wheelRightLongPressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == wheelRightLongPressKey! }) {
                    position = index
                }
            } else if(wheelRightLongPressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == wheelRightLongPressKey! }) {
                    position = index
                }
            }
        case wheelToggleLeft:
            if(wheelLeftPressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == wheelLeftPressKey! }) {
                    position = index
                }
            } else if(wheelLeftPressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == wheelLeftPressKey! }) {
                    position = index
                }
            }
        case wheelToggleLeftLongPress:
            if(wheelLeftLongPressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == wheelLeftLongPressKey! }) {
                    position = index
                }
            } else if(wheelLeftLongPressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == wheelLeftLongPressKey! }) {
                    position = index
                }
            }
        case menuUp:
            if(menuUpPressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == menuUpPressKey! }) {
                    position = index
                }
            } else if(menuUpPressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == menuUpPressKey! }) {
                    position = index
                }
            }
        case menuUpLongPress:
            if(menuUpLongPressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == menuUpLongPressKey! }) {
                    position = index
                }
            } else if(menuUpLongPressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == menuUpLongPressKey! }) {
                    position = index
                }
            }
        case menuDown:
            if(menuDownPressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == menuDownPressKey! }) {
                    position = index
                }
            } else if(menuDownPressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == menuDownPressKey! }) {
                    position = index
                }
            }
        case menuDownLongPress:
            if(menuDownLongPressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == menuDownLongPressKey! }) {
                    position = index
                }
            } else if(menuDownLongPressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == menuDownLongPressKey! }) {
                    position = index
                }
            }
        default:
            position = 0
        }
        return position
    }
    
    override func getActionValue(action: Int) -> String{
        var returnString = NSLocalizedString("hid_0x00_label", comment: "")
        let keyboardHID = KeyboardHID.shared
        switch (action){
        case longPressSensitivity:
            returnString = "\(sensitivity!)"
        case wheelScrollUp:
            if(wheelScrollUpKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == wheelScrollUpKey! }) {
                    let name = keyboardHID.keyboardCodes[index].1
                    returnString = name
                }
            } else if(wheelScrollUpKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == wheelScrollUpKey! }) {
                    let name = keyboardHID.consumerCodes[index].1
                    returnString = name
                }
            }
        case wheelScrollDown:
            if(wheelScrollDownKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == wheelScrollDownKey! }) {
                    let name = keyboardHID.keyboardCodes[index].1
                    returnString = name
                }
            } else if(wheelScrollDownKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == wheelScrollDownKey! }) {
                    let name = keyboardHID.consumerCodes[index].1
                    returnString = name
                }
            }
        case wheelToggleRight:
            if(wheelRightPressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == wheelRightPressKey! }) {
                    let name = keyboardHID.keyboardCodes[index].1
                    returnString = name
                }
            } else if(wheelRightPressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == wheelRightPressKey! }) {
                    let name = keyboardHID.consumerCodes[index].1
                    returnString = name
                }
            }
        case wheelToggleRightLongPress:
            if(wheelRightLongPressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == wheelRightLongPressKey! }) {
                    let name = keyboardHID.keyboardCodes[index].1
                    returnString = name
                }
            } else if(wheelRightLongPressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == wheelRightLongPressKey! }) {
                    let name = keyboardHID.consumerCodes[index].1
                    returnString = name
                }
            }
        case wheelToggleLeft:
            if(wheelLeftPressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == wheelLeftPressKey! }) {
                    let name = keyboardHID.keyboardCodes[index].1
                    returnString = name
                }
            } else if(wheelLeftPressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == wheelLeftPressKey! }) {
                    let name = keyboardHID.consumerCodes[index].1
                    returnString = name
                }
            }
        case wheelToggleLeftLongPress:
            if(wheelLeftLongPressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == wheelLeftLongPressKey! }) {
                    let name = keyboardHID.keyboardCodes[index].1
                    returnString = name
                }
            } else if(wheelLeftLongPressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == wheelLeftLongPressKey! }) {
                    let name = keyboardHID.consumerCodes[index].1
                    returnString = name
                }
            }
        case menuUp:
            if(menuUpPressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == menuUpPressKey! }) {
                    let name = keyboardHID.keyboardCodes[index].1
                    returnString = name
                }
            } else if(menuUpPressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == menuUpPressKey! }) {
                    let name = keyboardHID.consumerCodes[index].1
                    returnString = name
                }
            }
        case menuUpLongPress:
            if(menuUpLongPressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == menuUpLongPressKey! }) {
                    let name = keyboardHID.keyboardCodes[index].1
                    returnString = name
                }
            } else if(menuUpLongPressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == menuUpLongPressKey! }) {
                    let name = keyboardHID.consumerCodes[index].1
                    returnString = name
                }
            }
        case menuDown:
            if(menuDownPressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == menuDownPressKey! }) {
                    let name = keyboardHID.keyboardCodes[index].1
                    returnString = name
                }
            } else if(menuDownPressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == menuDownPressKey! }) {
                    let name = keyboardHID.consumerCodes[index].1
                    returnString = name
                }
            }
        case menuDownLongPress:
            if(menuDownLongPressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == menuDownLongPressKey! }) {
                    let name = keyboardHID.keyboardCodes[index].1
                    returnString = name
                }
            } else if(menuDownLongPressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == menuDownLongPressKey! }) {
                    let name = keyboardHID.consumerCodes[index].1
                    returnString = name
                }
            }
        default:
            returnString = "Unknown Action Number: \(action)"
        }
        return returnString
    }
    
    override func getActionKeyModifiers(action: Int) -> UInt8{
        var modifiers:UInt8 = 0x00
        switch (action){
        case self.wheelScrollUp:
            modifiers = self.wheelScrollUpKeyModifier!
        case self.wheelScrollDown:
            modifiers = self.wheelScrollDownKeyModifier!
        case self.wheelToggleRight:
            modifiers = self.wheelRightPressKeyModifier!
        case self.wheelToggleRightLongPress:
            modifiers = self.wheelRightLongPressKeyModifier!
        case self.wheelToggleLeft:
            modifiers = self.wheelLeftPressKeyModifier!
        case self.wheelToggleLeftLongPress:
            modifiers = self.wheelLeftLongPressKeyModifier!
        case self.menuUp:
            modifiers = self.menuUpPressKeyModifier!
        case self.menuUpLongPress:
            modifiers = self.menuUpLongPressKeyModifier!
        default:
            modifiers = 0x00
        }
        return modifiers
    }
    
    //Old
    override func setfirmwareVersion(firmwareVersion: String?){
        self.firmwareVersion = firmwareVersion
    }
    override func getfirmwareVersion() -> String{
        if (self.firmwareVersion != nil){
            return self.firmwareVersion!
        }
        return "Unknown"
    }

    override func sethardwareVersion(hardwareVersion: String?){
        self.hardwareVersion = hardwareVersion
    }
    override func gethardwareVersion() -> String{
        if (self.hardwareVersion != nil){
            return self.hardwareVersion!
        }
        return "Unknown"
    }}
