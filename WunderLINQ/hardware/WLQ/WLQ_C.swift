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
    
    let keyMode_default:UInt8 = 0x00
    let keyMode_custom:UInt8 = 0x01

    let KEYBOARD_HID:UInt8 = 0x01
    let CONSUMER_HID:UInt8 = 0x02
    let UNDEFINED:UInt8 = 0x00

    let configFlashSize:Int = 46
    let defaultConfig:[UInt8] = [
        0x02, 0x00,                             // SP Sensitivity
        0x05, 0x00,                             // LP Sensitivity
        0x01, 0x00, 0x52,                       // Scroll Up
        0x01, 0x00, 0x51,                       // Scroll Down
        0x01, 0x00, 0x50, 0x01, 0x00, 0x29,     // Wheel Left
        0x01, 0x00, 0x4F, 0x01, 0x00, 0x28,     // Wheel Right
        0x02, 0x00, 0xE9, 0x02, 0x00, 0xB8,     // Rocker1 Up
        0x02, 0x00, 0xEA, 0x02, 0x00, 0xE2,     // Rocker1 Down
        0x02, 0x00, 0xB5, 0x02, 0x00, 0xB0,     // Rocker2 Up
        0x02, 0x00, 0xB6, 0x02, 0x00, 0xB7]     // Rocker2 Down

    let longPressSensitivity:Int = 25
    let wheelScrollUp:Int = 26
    let wheelScrollDown:Int = 27
    let wheelToggleRight:Int = 28
    let wheelToggleRightLongPress:Int = 29
    let wheelToggleLeft:Int = 30
    let wheelToggleLeftLongPress:Int = 31
    let rocker1Up:Int = 32
    let rocker1UpLongPress:Int = 33
    let rocker1Down:Int = 34
    let rocker1DownLongPress:Int = 35
    let rocker2Up:Int = 36
    let rocker2UpLongPress:Int = 37
    let rocker2Down:Int = 38
    let rocker2DownLongPress:Int = 39
    
    var actionNames: [Int: String] = [:]

    let firmwareVersionMajor_INDEX:Int = 3
    let firmwareVersionMinor_INDEX:Int = 4
    let keyMode_INDEX:Int = 5
    let spSensitivityHigh_INDEX:Int = 0
    let spSensitivityLow_INDEX:Int = 1
    let lpSensitivityHigh_INDEX:Int = 2
    let lpSensitivityLow_INDEX:Int = 3
    let wheelScrollUpKeyType_INDEX:Int = 4
    let wheelScrollUpKeyModifier_INDEX:Int = 5
    let wheelScrollUpKey_INDEX:Int = 6
    let wheelScrollDownKeyType_INDEX:Int = 7
    let wheelScrollDownKeyModifier_INDEX:Int = 8
    let wheelScrollDownKey_INDEX:Int = 9
    let wheelLeftPressKeyType_INDEX:Int = 10
    let wheelLeftPressKeyModifier_INDEX:Int = 11
    let wheelLeftPressKey_INDEX:Int = 12
    let wheelLeftLongPressKeyType_INDEX:Int = 13
    let wheelLeftLongPressKeyModifier_INDEX:Int = 14
    let wheelLeftLongPressKey_INDEX:Int = 15
    let wheelRightPressKeyType_INDEX:Int = 16
    let wheelRightPressKeyModifier_INDEX:Int = 17
    let wheelRightPressKey_INDEX:Int = 18
    let wheelRightLongPressKeyType_INDEX:Int = 19
    let wheelRightLongPressKeyModifier_INDEX:Int = 20
    let wheelRightLongPressKey_INDEX:Int = 21
    let rocker1UpPressKeyType_INDEX:Int = 22
    let rocker1UpPressKeyModifier_INDEX:Int = 23
    let rocker1UpPressKey_INDEX:Int = 24
    let rocker1UpLongPressKeyType_INDEX:Int = 25
    let rocker1UpLongPressKeyModifier_INDEX:Int = 26
    let rocker1UpLongPressKey_INDEX:Int = 27
    let rocker1DownPressKeyType_INDEX:Int = 28
    let rocker1DownPressKeyModifier_INDEX:Int = 29
    let rocker1DownPressKey_INDEX:Int = 30
    let rocker1DownLongPressKeyType_INDEX:Int = 31
    let rocker1DownLongPressKeyModifier_INDEX:Int = 32
    let rocker1DownLongPressKey_INDEX:Int = 33
    let rocker2UpPressKeyType_INDEX:Int = 34
    let rocker2UpPressKeyModifier_INDEX:Int = 35
    let rocker2UpPressKey_INDEX:Int = 36
    let rocker2UpLongPressKeyType_INDEX:Int = 37
    let rocker2UpLongPressKeyModifier_INDEX:Int = 38
    let rocker2UpLongPressKey_INDEX:Int = 39
    let rocker2DownPressKeyType_INDEX:Int = 40
    let rocker2DownPressKeyModifier_INDEX:Int = 41
    let rocker2DownPressKey_INDEX:Int = 42
    let rocker2DownLongPressKeyType_INDEX:Int = 43
    let rocker2DownLongPressKeyModifier_INDEX:Int = 44
    let rocker2DownLongPressKey_INDEX:Int = 45
    
    // Status message
    let statusSize:Int = 111
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
    
    let ROCKER1_U_BIT_BYTE_INDEX:Int = 12
    let ROCKER1_U_BIT_POS_INDEX:Int = 13
    let ROCKER1_U_BIT_HOLD_CNT_LOW_INDEX:Int = 14
    let ROCKER1_U_BIT_HOLD_CNT_HIGH_INDEX:Int = 15
    let ROCKER1_U_BIT_MAX_CNT_LOW_INDEX:Int = 16
    let ROCKER1_U_BIT_MAX_CNT_HIGH_INDEX:Int = 17
    let ROCKER1_U_BIT_MIN_CNT_LOW_INDEX:Int = 18
    let ROCKER1_U_BIT_MIN_CNT_HIGH_INDEX:Int = 19
    let ROCKER1_U_BIT_MAX_VAL_INDEX:Int = 20
    let ROCKER1_U_BIT_MIN_VAL_INDEX:Int = 21

    let ROCKER1_D_BIT_BYTE_INDEX:Int = 22
    let ROCKER1_D_BIT_POS_INDEX:Int = 23
    let ROCKER1_D_BIT_HOLD_CNT_LOW_INDEX:Int = 24
    let ROCKER1_D_BIT_HOLD_CNT_HIGH_INDEX:Int = 25
    let ROCKER1_D_BIT_MAX_CNT_LOW_INDEX:Int = 26
    let ROCKER1_D_BIT_MAX_CNT_HIGH_INDEX:Int = 27
    let ROCKER1_D_BIT_MIN_CNT_LOW_INDEX:Int = 28
    let ROCKER1_D_BIT_MIN_CNT_HIGH_INDEX:Int = 29
    let ROCKER1_D_BIT_MAX_VAL_INDEX:Int = 30
    let ROCKER1_D_BIT_MIN_VAL_INDEX:Int = 31
    
    let ROCKER2_U_BIT_BYTE_INDEX:Int = 32
    let ROCKER2_U_BIT_POS_INDEX:Int = 33
    let ROCKER2_U_BIT_HOLD_CNT_LOW_INDEX:Int = 34
    let ROCKER2_U_BIT_HOLD_CNT_HIGH_INDEX:Int = 35
    let ROCKER2_U_BIT_MAX_CNT_LOW_INDEX:Int = 36
    let ROCKER2_U_BIT_MAX_CNT_HIGH_INDEX:Int = 37
    let ROCKER2_U_BIT_MIN_CNT_LOW_INDEX:Int = 38
    let ROCKER2_U_BIT_MIN_CNT_HIGH_INDEX:Int = 39
    let ROCKER2_U_BIT_MAX_VAL_INDEX:Int = 40
    let ROCKER2_U_BIT_MIN_VAL_INDEX:Int = 41

    let ROCKER2_D_BIT_BYTE_INDEX:Int = 42
    let ROCKER2_D_BIT_POS_INDEX:Int = 43
    let ROCKER2_D_BIT_HOLD_CNT_LOW_INDEX:Int = 44
    let ROCKER2_D_BIT_HOLD_CNT_HIGH_INDEX:Int = 45
    let ROCKER2_D_BIT_MAX_CNT_LOW_INDEX:Int = 46
    let ROCKER2_D_BIT_MAX_CNT_HIGH_INDEX:Int = 47
    let ROCKER2_D_BIT_MIN_CNT_LOW_INDEX:Int = 48
    let ROCKER2_D_BIT_MIN_CNT_HIGH_INDEX:Int = 49
    let ROCKER2_D_BIT_MAX_VAL_INDEX:Int = 50
    let ROCKER2_D_BIT_MIN_VAL_INDEX:Int = 51

    let WW_R_BIT_BYTE_INDEX:Int = 52
    let WW_R_BIT_POS_INDEX:Int = 53
    let WW_R_BIT_HOLD_CNT_LOW_INDEX:Int = 54
    let WW_R_BIT_HOLD_CNT_HIGH_INDEX:Int = 55
    let WW_R_BIT_MAX_CNT_LOW_INDEX:Int = 56
    let WW_R_BIT_MAX_CNT_HIGH_INDEX:Int = 57
    let WW_R_BIT_MIN_CNT_LOW_INDEX:Int = 58
    let WW_R_BIT_MIN_CNT_HIGH_INDEX:Int = 59
    let WW_R_BIT_MAX_VAL_INDEX:Int = 60
    let WW_R_BIT_MIN_VAL_INDEX:Int = 61

    let WW_L_BIT_BYTE_INDEX:Int = 62
    let WW_L_BIT_POS_INDEX:Int = 63
    let WW_L_BIT_HOLD_CNT_LOW_INDEX:Int = 64
    let WW_L_BIT_HOLD_CNT_HIGH_INDEX:Int = 65
    let WW_L_BIT_MAX_CNT_LOW_INDEX:Int = 66
    let WW_L_BIT_MAX_CNT_HIGH_INDEX:Int = 67
    let WW_L_BIT_MIN_CNT_LOW_INDEX:Int = 68
    let WW_L_BIT_MIN_CNT_HIGH_INDEX:Int = 69
    let WW_L_BIT_MAX_VAL_INDEX:Int = 70
    let WW_L_BIT_MIN_VAL_INDEX:Int = 71

    let WW_SCROLL_BYTE_INDEX:Int = 72
    let WW_SCROLL_LENGTH_INDEX:Int = 73
    let WW_SCROLL_VAL_CURRENT_INDEX:Int = 74
    let WW_SCROLL_VAL_OLD_INDEX:Int = 75
    let WW_SCROLL_INC_VAL_INDEX:Int = 76
    let WW_SCROLL_DEC_VAL_INDEX:Int = 77

    let WLQ_SCHEDULE_SLOT_INDEX:Int = 78
    let OEM_SCHEDULE_SLOT_INDEX:Int = 79
    let ACC_SCHEDULE_SLOT_INDEX:Int = 80

    let PIXEL_OB_INTENSITY_INDEX:Int = 81
    let PIXEL_OB_B_INDEX:Int = 82
    let PIXEL_OB_G_INDEX:Int = 83
    let PIXEL_OB_R_INDEX:Int = 84
    let PIXEL_REMOTE_INTENSITY_INDEX:Int = 85
    let PIXEL_REMOTE_B_INDEX:Int = 86
    let PIXEL_REMOTE_G_INDEX:Int = 87
    let PIXEL_REMOTE_R_INDEX:Int = 88

    let ACTIVE_CHAN_INDEX:Int = 89
    let LIN_ACC_CHANNEL_CNT_INDEX:Int = 90

    let LIN_ACC_CHANNEL1_CONFIG_BYTE_INDEX:Int = 91
    let LIN_ACC_CHANNEL1_VAL_BYTE_INDEX:Int = 92
    let LIN_ACC_CHANNEL1_CONFIG_STATE_INDEX:Int = 93
    let LIN_ACC_CHANNEL1_VAL_RAW_INDEX:Int = 94
    let LIN_ACC_CHANNEL1_VAL_OFFSET_INDEX:Int = 95
    let LIN_ACC_CHANNEL1_VAL_SCALE_INDEX:Int = 96
    let LIN_ACC_CHANNEL1_PIXEL_INTENSITY_INDEX:Int = 97
    let LIN_ACC_CHANNEL1_PIXEL_B_INDEX:Int = 98
    let LIN_ACC_CHANNEL1_PIXEL_G_INDEX:Int = 99
    let LIN_ACC_CHANNEL1_PIXEL_R_INDEX:Int = 100

    let LIN_ACC_CHANNEL2_CONFIG_BYTE_INDEX:Int = 101
    let LIN_ACC_CHANNEL2_VAL_BYTE_INDEX:Int = 102
    let LIN_ACC_CHANNEL2_CONFIG_STATE_INDEX:Int = 103
    let LIN_ACC_CHANNEL2_VAL_RAW_INDEX:Int = 104
    let LIN_ACC_CHANNEL2_VAL_OFFSET_INDEX:Int = 105
    let LIN_ACC_CHANNEL2_VAL_SCALE_INDEX:Int = 106
    let LIN_ACC_CHANNEL2_PIXEL_INTENSITY_INDEX:Int = 107
    let LIN_ACC_CHANNEL2_PIXEL_B_INDEX:Int = 108
    let LIN_ACC_CHANNEL2_PIXEL_G_INDEX:Int = 109
    let LIN_ACC_CHANNEL2_PIXEL_R_INDEX:Int = 110
    
    var wunderLINQStatus:[UInt8]?
    var channel1PixelColor:UIColor?
    var channel2PixelColor:UIColor?
    var channelActive:UInt8?
    var channel1State:UInt8?
    var channel2State:UInt8?
    var channel1ValueRaw:UInt8?
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
    var rocker1UpPressKeyType:UInt8?
    var rocker1UpPressKeyModifier:UInt8?
    var rocker1UpPressKey:UInt8?
    var rocker1UpLongPressKeyType:UInt8?
    var rocker1UpLongPressKeyModifier:UInt8?
    var rocker1UpLongPressKey:UInt8?
    var rocker1DownPressKeyType:UInt8?
    var rocker1DownPressKeyModifier:UInt8?
    var rocker1DownPressKey:UInt8?
    var rocker1DownLongPressKeyType:UInt8?
    var rocker1DownLongPressKeyModifier:UInt8?
    var rocker1DownLongPressKey:UInt8?
    var rocker2UpPressKeyType:UInt8?
    var rocker2UpPressKeyModifier:UInt8?
    var rocker2UpPressKey:UInt8?
    var rocker2UpLongPressKeyType:UInt8?
    var rocker2UpLongPressKeyModifier:UInt8?
    var rocker2UpLongPressKey:UInt8?
    var rocker2DownPressKeyType:UInt8?
    var rocker2DownPressKeyModifier:UInt8?
    var rocker2DownPressKey:UInt8?
    var rocker2DownLongPressKeyType:UInt8?
    var rocker2DownLongPressKeyModifier:UInt8?
    var rocker2DownLongPressKey:UInt8?

    required override init() {
        super.init()
        NSLog("WLQ_C: init()")
        WLQ.shared = self
        WLQ.initialized = true
        actionNames = [longPressSensitivity: NSLocalizedString("sensitivity_label", comment: ""),
                              wheelScrollUp: NSLocalizedString("full_scroll_up_label", comment: ""),
                            wheelScrollDown: NSLocalizedString("full_scroll_down_label", comment: ""),
                           wheelToggleRight: NSLocalizedString("full_toggle_right_label", comment: ""),
                  wheelToggleRightLongPress: NSLocalizedString("full_toggle_right_long_label", comment: ""),
                            wheelToggleLeft: NSLocalizedString("full_toggle_left_label", comment: ""),
                   wheelToggleLeftLongPress: NSLocalizedString("full_toggle_left_long_label", comment: ""),
                                     rocker1Up: NSLocalizedString("full_rocker1_up_label", comment: ""),
                         rocker1UpLongPress: NSLocalizedString("full_rocker1_up_long_label", comment: ""),
                                rocker1Down: NSLocalizedString("full_rocker1_down_label", comment: ""),
                       rocker1DownLongPress: NSLocalizedString("full_rocker1_down_long_label", comment: ""),
                                  rocker2Up: NSLocalizedString("full_rocker2_up_label", comment: ""),
                      rocker2UpLongPress: NSLocalizedString("full_rocker2_up_long_label", comment: ""),
                             rocker2Down: NSLocalizedString("full_rocker2_down_label", comment: ""),
                    rocker2DownLongPress: NSLocalizedString("full_rocker2_down_long_label", comment: "")]
    }
    
    override func parseConfig(bytes: [UInt8]) {
        
        self.wunderLINQConfig = bytes
        self.firmwareVersion = "\(bytes[self.firmwareVersionMajor_INDEX]).\(bytes[self.firmwareVersionMinor_INDEX])"

        self.flashConfig = Array(bytes[6..<(6+configFlashSize)])
        self.tempConfig = self.flashConfig
        /*
        var messageHexString = ""
        for i in 0 ..< flashConfig!.count {
            messageHexString += String(format: "%02X", flashConfig![i])
            if i < flashConfig!.count - 1 {
                messageHexString += ","
            }
        }
        NSLog("WLQ_C: flashConfig: \(messageHexString)")
        var tmessageHexString = ""
        for i in 0 ..< tempConfig!.count {
            tmessageHexString += String(format: "%02X", tempConfig![i])
            if i < tempConfig!.count - 1 {
                tmessageHexString += ","
            }
        }
        NSLog("WLQ_C: tempConfig: \(tmessageHexString)")
        */
        self.keyMode = bytes[self.keyMode_INDEX]

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
        self.rocker1UpPressKeyType = self.flashConfig![self.rocker1UpPressKeyType_INDEX]
        self.rocker1UpPressKeyModifier = self.flashConfig![self.rocker1UpPressKeyModifier_INDEX]
        self.rocker1UpPressKey = self.flashConfig![self.rocker1UpPressKey_INDEX]
        self.rocker1UpLongPressKeyType = self.flashConfig![self.rocker1UpLongPressKeyType_INDEX]
        self.rocker1UpLongPressKeyModifier = self.flashConfig![self.rocker1UpLongPressKeyModifier_INDEX]
        self.rocker1UpLongPressKey = self.flashConfig![self.rocker1UpLongPressKey_INDEX]
        self.rocker1DownPressKeyType = self.flashConfig![self.rocker1DownPressKeyType_INDEX]
        self.rocker1DownPressKeyModifier = self.flashConfig![self.rocker1DownPressKeyModifier_INDEX]
        self.rocker1DownPressKey = self.flashConfig![self.rocker1DownPressKey_INDEX]
        self.rocker1DownLongPressKeyType = self.flashConfig![self.rocker1DownLongPressKeyType_INDEX]
        self.rocker1DownLongPressKeyModifier = self.flashConfig![self.rocker1DownLongPressKeyModifier_INDEX]
        self.rocker1DownLongPressKey = self.flashConfig![self.rocker1DownLongPressKey_INDEX]
        self.rocker2UpPressKeyType = self.flashConfig![self.rocker2UpPressKeyType_INDEX]
        self.rocker2UpPressKeyModifier = self.flashConfig![self.rocker2UpPressKeyModifier_INDEX]
        self.rocker2UpPressKey = self.flashConfig![self.rocker2UpPressKey_INDEX]
        self.rocker2UpLongPressKeyType = self.flashConfig![self.rocker2UpLongPressKeyType_INDEX]
        self.rocker2UpLongPressKeyModifier = self.flashConfig![self.rocker2UpLongPressKeyModifier_INDEX]
        self.rocker2UpLongPressKey = self.flashConfig![self.rocker2UpLongPressKey_INDEX]
        self.rocker2DownPressKeyType = self.flashConfig![self.rocker2DownPressKeyType_INDEX]
        self.rocker2DownPressKeyModifier = self.flashConfig![self.rocker2DownPressKeyModifier_INDEX]
        self.rocker2DownPressKey = self.flashConfig![self.rocker2DownPressKey_INDEX]
        self.rocker2DownLongPressKeyType = self.flashConfig![self.rocker2DownLongPressKeyType_INDEX]
        self.rocker2DownLongPressKeyModifier = self.flashConfig![self.rocker2DownLongPressKeyModifier_INDEX]
        self.rocker2DownLongPressKey = self.flashConfig![self.rocker2DownLongPressKey_INDEX]
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
        self.wunderLINQStatus = Array(bytes[3..<(3+statusSize)])
        self.channel1PixelColor = UIColor(red: CGFloat(wunderLINQStatus![LIN_ACC_CHANNEL1_PIXEL_R_INDEX])/255.0, green: CGFloat(wunderLINQStatus![LIN_ACC_CHANNEL1_PIXEL_G_INDEX])/255.0, blue: CGFloat(wunderLINQStatus![LIN_ACC_CHANNEL1_PIXEL_B_INDEX])/255.0, alpha: 1)
        self.channel2PixelColor = UIColor(red: CGFloat(wunderLINQStatus![LIN_ACC_CHANNEL2_PIXEL_R_INDEX])/255.0, green: CGFloat(wunderLINQStatus![LIN_ACC_CHANNEL2_PIXEL_G_INDEX])/255.0, blue: CGFloat(wunderLINQStatus![LIN_ACC_CHANNEL2_PIXEL_B_INDEX])/255.0, alpha: 1)
        self.channelActive = self.wunderLINQStatus![ACTIVE_CHAN_INDEX]
        self.channel1ValueRaw = self.wunderLINQStatus![LIN_ACC_CHANNEL1_VAL_RAW_INDEX]
        self.channel2ValueRaw = self.wunderLINQStatus![LIN_ACC_CHANNEL2_VAL_RAW_INDEX]
        self.channel1State = self.wunderLINQStatus![LIN_ACC_CHANNEL1_CONFIG_STATE_INDEX]
        self.channel2State = self.wunderLINQStatus![LIN_ACC_CHANNEL2_CONFIG_STATE_INDEX]
    }
    
    override func getStatus() -> [UInt8]?{
        return wunderLINQStatus
    }
    
    override func getAccChannelPixelColor(positon: Int) -> UIColor{
        switch(positon){
        case 1:
            return channel1PixelColor!
        case 2:
            return channel2PixelColor!
        default:
            return UIColor.clear
        }
    }
    
    override func getAccActive() -> UInt8{
        return channelActive!
    }
    
    override func getAccChannelState(positon: Int) -> UInt8{
        switch(positon){
        case 1:
            return channel1State!
        case 2:
            return channel2State!
        default:
            return 0x00
        }
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
        return 2
    }
    
    override func getLongPressSensitivity() -> UInt8{
        return sensitivity!
    }
    override func setLongPressSensitivity(value: UInt8){
        //setTempConfigByte(index: Sensitivity_INDEX, value: value)
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
        case rocker1Up:
            return rocker1UpPressKeyType!
        case rocker1UpLongPress:
            return rocker1UpLongPressKeyType!
        case rocker1Down:
            return rocker1DownPressKeyType!
        case rocker1DownLongPress:
            return rocker1DownLongPressKeyType!
        case rocker2Up:
            return rocker2UpPressKeyType!
        case rocker2UpLongPress:
            return rocker2UpLongPressKeyType!
        case rocker2Down:
            return rocker2DownPressKeyType!
        case rocker2DownLongPress:
            return rocker2DownLongPressKeyType!
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
            case rocker1Up:
                self.tempConfig![self.rocker1UpPressKeyType_INDEX] = key[0]
                self.tempConfig![self.rocker1UpPressKeyModifier_INDEX] = key[1]
                self.tempConfig![self.rocker1UpPressKey_INDEX] = key[2]
            case rocker1UpLongPress:
                self.tempConfig![self.rocker1UpLongPressKeyType_INDEX] = key[0]
                self.tempConfig![self.rocker1UpLongPressKeyModifier_INDEX] = key[1]
                self.tempConfig![self.rocker1UpLongPressKey_INDEX] = key[2]
            case rocker1Down:
                self.tempConfig![self.rocker1DownPressKeyType_INDEX] = key[0]
                self.tempConfig![self.rocker1DownPressKeyModifier_INDEX] = key[1]
                self.tempConfig![self.rocker1DownPressKey_INDEX] = key[2]
            case rocker1DownLongPress:
                self.tempConfig![self.rocker1DownLongPressKeyType_INDEX] = key[0]
                self.tempConfig![self.rocker1DownLongPressKeyModifier_INDEX] = key[1]
                self.tempConfig![self.rocker1DownLongPressKey_INDEX] = key[2]
            case rocker2Up:
                self.tempConfig![self.rocker2UpPressKeyType_INDEX] = key[0]
                self.tempConfig![self.rocker2UpPressKeyModifier_INDEX] = key[1]
                self.tempConfig![self.rocker2UpPressKey_INDEX] = key[2]
            case rocker2UpLongPress:
                self.tempConfig![self.rocker2UpLongPressKeyType_INDEX] = key[0]
                self.tempConfig![self.rocker2UpLongPressKeyModifier_INDEX] = key[1]
                self.tempConfig![self.rocker2UpLongPressKey_INDEX] = key[2]
            case rocker2Down:
                self.tempConfig![self.rocker2DownPressKeyType_INDEX] = key[0]
                self.tempConfig![self.rocker2DownPressKeyModifier_INDEX] = key[1]
                self.tempConfig![self.rocker2DownPressKey_INDEX] = key[2]
            case rocker2DownLongPress:
                self.tempConfig![self.rocker2DownLongPressKeyType_INDEX] = key[0]
                self.tempConfig![self.rocker2DownLongPressKeyModifier_INDEX] = key[1]
                self.tempConfig![self.rocker2DownLongPressKey_INDEX] = key[2]
            default:
                NSLog("WLQ_C: Invalid acitonID")
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
        case rocker1Up:
            if(rocker1UpPressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == rocker1UpPressKey! }) {
                    position = index
                }
            } else if(rocker1UpPressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == rocker1UpPressKey! }) {
                    position = index
                }
            }
        case rocker1UpLongPress:
            if(rocker1UpLongPressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == rocker1UpLongPressKey! }) {
                    position = index
                }
            } else if(rocker1UpLongPressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == rocker1UpLongPressKey! }) {
                    position = index
                }
            }
        case rocker1Down:
            if(rocker1DownPressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == rocker1DownPressKey! }) {
                    position = index
                }
            } else if(rocker1DownPressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == rocker1DownPressKey! }) {
                    position = index
                }
            }
        case rocker1DownLongPress:
            if(rocker1DownLongPressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == rocker1DownLongPressKey! }) {
                    position = index
                }
            } else if(rocker1DownLongPressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == rocker1DownLongPressKey! }) {
                    position = index
                }
            }
        case rocker2Up:
            if(rocker2UpPressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == rocker2UpPressKey! }) {
                    position = index
                }
            } else if(rocker2UpPressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == rocker2UpPressKey! }) {
                    position = index
                }
            }
        case rocker2UpLongPress:
            if(rocker2UpLongPressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == rocker2UpLongPressKey! }) {
                    position = index
                }
            } else if(rocker2UpLongPressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == rocker2UpLongPressKey! }) {
                    position = index
                }
            }
        case rocker2Down:
            if(rocker2DownPressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == rocker2DownPressKey! }) {
                    position = index
                }
            } else if(rocker2DownPressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == rocker2DownPressKey! }) {
                    position = index
                }
            }
        case rocker2DownLongPress:
            if(rocker2DownLongPressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == rocker2DownLongPressKey! }) {
                    position = index
                }
            } else if(rocker2DownLongPressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == rocker2DownLongPressKey! }) {
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
        case rocker1Up:
            if(rocker1UpPressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == rocker1UpPressKey! }) {
                    let name = keyboardHID.keyboardCodes[index].1
                    returnString = name
                }
            } else if(rocker1UpPressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == rocker1UpPressKey! }) {
                    let name = keyboardHID.consumerCodes[index].1
                    returnString = name
                }
            }
        case rocker1UpLongPress:
            if(rocker1UpLongPressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == rocker1UpLongPressKey! }) {
                    let name = keyboardHID.keyboardCodes[index].1
                    returnString = name
                }
            } else if(rocker1UpLongPressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == rocker1UpLongPressKey! }) {
                    let name = keyboardHID.consumerCodes[index].1
                    returnString = name
                }
            }
        case rocker1Down:
            if(rocker1DownPressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == rocker1DownPressKey! }) {
                    let name = keyboardHID.keyboardCodes[index].1
                    returnString = name
                }
            } else if(rocker1DownPressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == rocker1DownPressKey! }) {
                    let name = keyboardHID.consumerCodes[index].1
                    returnString = name
                }
            }
        case rocker1DownLongPress:
            if(rocker1DownLongPressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == rocker1DownLongPressKey! }) {
                    let name = keyboardHID.keyboardCodes[index].1
                    returnString = name
                }
            } else if(rocker1DownLongPressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == rocker1DownLongPressKey! }) {
                    let name = keyboardHID.consumerCodes[index].1
                    returnString = name
                }
            }
        case rocker2Up:
            if(rocker2UpPressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == rocker2UpPressKey! }) {
                    let name = keyboardHID.keyboardCodes[index].1
                    returnString = name
                }
            } else if(rocker2UpPressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == rocker2UpPressKey! }) {
                    let name = keyboardHID.consumerCodes[index].1
                    returnString = name
                }
            }
        case rocker2UpLongPress:
            if(rocker2UpLongPressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == rocker2UpLongPressKey! }) {
                    let name = keyboardHID.keyboardCodes[index].1
                    returnString = name
                }
            } else if(rocker2UpLongPressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == rocker2UpLongPressKey! }) {
                    let name = keyboardHID.consumerCodes[index].1
                    returnString = name
                }
            }
        case rocker2Down:
            if(rocker2DownPressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == rocker2DownPressKey! }) {
                    let name = keyboardHID.keyboardCodes[index].1
                    returnString = name
                }
            } else if(rocker2DownPressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == rocker2DownPressKey! }) {
                    let name = keyboardHID.consumerCodes[index].1
                    returnString = name
                }
            }
        case rocker2DownLongPress:
            if(rocker2DownLongPressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == rocker2DownLongPressKey! }) {
                    let name = keyboardHID.keyboardCodes[index].1
                    returnString = name
                }
            } else if(rocker2DownLongPressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == rocker2DownLongPressKey! }) {
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
        case self.rocker1Up:
            modifiers = self.rocker1UpPressKeyModifier!
        case self.rocker1UpLongPress:
            modifiers = self.rocker1UpLongPressKeyModifier!
        case self.rocker1Down:
            modifiers = self.rocker1DownPressKeyModifier!
        case self.rocker1DownLongPress:
            modifiers = self.rocker1DownLongPressKeyModifier!
        case self.rocker2Up:
            modifiers = self.rocker2UpPressKeyModifier!
        case self.rocker2UpLongPress:
            modifiers = self.rocker2UpLongPressKeyModifier!
        case self.rocker2Down:
            modifiers = self.rocker2DownPressKeyModifier!
        case self.rocker2DownLongPress:
            modifiers = self.rocker2DownLongPressKeyModifier!
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

enum WLQ_C_DEFINES {
    static let longPressSensitivity:Int = 25
    static let wheelScrollUp:Int = 26
    static let wheelScrollDown:Int = 27
    static let wheelToggleRight:Int = 28
    static let wheelToggleRightLongPress:Int = 29
    static let wheelToggleLeft:Int = 30
    static let wheelToggleLeftLongPress:Int = 31
    static let rocker1Up:Int = 32
    static let rocker1UpLongPress:Int = 33
    static let rocker1Down:Int = 34
    static let rocker1DownLongPress:Int = 35
    static let rocker2Up:Int = 36
    static let rocker2UpLongPress:Int = 37
    static let rocker2Down:Int = 38
    static let rocker2DownLongPress:Int = 39
}
