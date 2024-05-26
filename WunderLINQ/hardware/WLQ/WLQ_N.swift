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

class WLQ_N: WLQ {
    
    var firmwareVersion:String?
    var hardwareVersion:String?
    let hardwareVersion1:String = "2PCB1.9 10/18"
    let hardwareVersion2:String = "1PCB2.0 12/19"
    let hardwareVersion2_1:String = "2PCB2.2 081920"
    
    var wunderLINQConfig:[UInt8]?
    var flashConfig:[UInt8]?
    var tempConfig:[UInt8]?
    var USBVinThreshold:UInt16?
    
    //FW >=2.0
    let configFlashSize:Int = 64
    let defaultConfig2:[UInt8] = [
                0x00, 0x00, // USB Input Voltage threshold
                0x07, // RT/K Start // Sensitivity
                0x01, 0x00, 0x4F, 0x01, 0x00, 0x28, // Menu
                0x01, 0x00, 0x52, 0x00, 0x00, 0x00, // Zoom+
                0x01, 0x00, 0x51, 0x00, 0x00, 0x00, // Zoom-
                0x01, 0x00, 0x50, 0x01, 0x00, 0x29, // Speak
                0x02, 0x00, 0xE2, 0x00, 0x00, 0x00, // Mute
                0x02, 0x00, 0xB8, 0x00, 0x00, 0x00, // Display
                0x11, // Full Start // Sensitivity
                0x01, 0x00, 0x4F, 0x01, 0x00, 0x28, // Right Toggle
                0x01, 0x00, 0x50, 0x01, 0x00, 0x29, // Left Toggle
                0x01, 0x00, 0x52, 0x01, 0x00, 0x51, // Scroll
                0x02, 0x00, 0xB8, 0x02, 0x00, 0xE2] // Signal Cancel
    
    let defaultConfig2HW1:[UInt8] = [
                0x00, 0x00, // USB Input Voltage threshold
                0x07, // RT/K Start // Sensitivity
                0x01, 0x00, 0x4F, 0x01, 0x00, 0x28, // Menu
                0x01, 0x00, 0x52, 0x00, 0x00, 0x00, // Zoom+
                0x01, 0x00, 0x51, 0x00, 0x00, 0x00, // Zoom-
                0x01, 0x00, 0x50, 0x01, 0x00, 0x29, // Speak
                0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // Mute
                0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // Display
                0x11, // Full Start // Sensitivity
                0x01, 0x00, 0x4F, 0x01, 0x00, 0x28, // Right Toggle
                0x01, 0x00, 0x50, 0x01, 0x00, 0x29, // Left Toggle
                0x01, 0x00, 0x52, 0x01, 0x00, 0x51, // Scroll
                0x00, 0x00, 0x00, 0x00, 0x00, 0x00] // Signal Cancel

    let keyMode_default:UInt8 = 0x00
    let keyMode_custom:UInt8 = 0x01

    let KEYBOARD_HID:UInt8 = 0x01
    let CONSUMER_HID:UInt8 = 0x02
    let UNDEFINED:UInt8 = 0x00

    let OldSensitivity:Int = 0
    let KEYMODE:Int = 100
    let USB:Int = 1
    let RTKDoublePressSensitivity:Int = 2
    let fullLongPressSensitivity:Int = 3
    let RTKPage:Int = 4
    let RTKPageDoublePress:Int = 5
    let RTKZoomPlus:Int = 6
    let RTKZoomPlusDoublePress:Int = 7
    let RTKZoomMinus:Int = 8
    let RTKZoomMinusDoublePress:Int = 9
    let RTKSpeak:Int = 10
    let RTKSpeakDoublePress:Int = 11
    let RTKMute:Int = 12
    let RTKMuteDoublePress:Int = 13
    let RTKDisplayOff:Int = 14
    let RTKDisplayOffDoublePress:Int = 15
    let fullScrollUp:Int = 16
    let fullScrollDown:Int = 17
    let fullToggleRight:Int = 18
    let fullToggleRightLongPress:Int = 19
    let fullToggleLeft:Int = 20
    let fullToggleLeftLongPress:Int = 21
    let fullSignalCancel:Int = 22
    let fullSignalCancelLongPress:Int = 23
    
    var actionNames: [Int: String] = [:]

    let firmwareVersionMajor_INDEX:Int = 9
    let firmwareVersionMinor_INDEX:Int = 10
    let keyMode_INDEX:Int = 25
    let USBVinThresholdHigh_INDEX:Int = 0
    let USBVinThresholdLow_INDEX:Int = 1
    let RTKSensitivity_INDEX:Int = 2
    let RTKPagePressKeyType_INDEX:Int = 3
    let RTKPagePressKeyModifier_INDEX:Int = 4
    let RTKPagePressKey_INDEX:Int = 5
    let RTKPageDoublePressKeyType_INDEX:Int = 6
    let RTKPageDoublePressKeyModifier_INDEX:Int = 7
    let RTKPageDoublePressKey_INDEX:Int = 8
    let RTKZoomPPressKeyType_INDEX:Int = 9
    let RTKZoomPPressKeyModifier_INDEX:Int = 10
    let RTKZoomPPressKey_INDEX:Int = 11
    let RTKZoomPDoublePressKeyType_INDEX:Int = 12
    let RTKZoomPDoublePressKeyModifier_INDEX:Int = 13
    let RTKZoomPDoublePressKey_INDEX:Int = 14
    let RTKZoomMPressKeyType_INDEX:Int = 15
    let RTKZoomMPressKeyModifier_INDEX:Int = 16
    let RTKZoomMPressKey_INDEX:Int = 17
    let RTKZoomMDoublePressKeyType_INDEX:Int = 18
    let RTKZoomMDoublePressKeyModifier_INDEX:Int = 19
    let RTKZoomMDoublePressKey_INDEX:Int = 20
    let RTKSpeakPressKeyType_INDEX:Int = 21
    let RTKSpeakPressKeyModifier_INDEX:Int = 22
    let RTKSpeakPressKey_INDEX:Int = 23
    let RTKSpeakDoublePressKeyType_INDEX:Int = 24
    let RTKSpeakDoublePressKeyModifier_INDEX:Int = 25
    let RTKSpeakDoublePressKey_INDEX:Int = 26
    let RTKMutePressKeyType_INDEX:Int = 27
    let RTKMutePressKeyModifier_INDEX:Int = 28
    let RTKMutePressKey_INDEX:Int = 29
    let RTKMuteDoublePressKeyType_INDEX:Int = 30
    let RTKMuteDoublePressKeyModifier_INDEX:Int = 31
    let RTKMuteDoublePressKey_INDEX:Int = 32
    let RTKDisplayPressKeyType_INDEX:Int = 33
    let RTKDisplayPressKeyModifier_INDEX:Int = 34
    let RTKDisplayPressKey_INDEX:Int = 35
    let RTKDisplayDoublePressKeyType_INDEX:Int = 36
    let RTKDisplayDoublePressKeyModifier_INDEX:Int = 37
    let RTKDisplayDoublePressKey_INDEX:Int = 38
    let fullSensitivity_INDEX:Int = 39
    let fullRightPressKeyType_INDEX:Int = 40
    let fullRightPressKeyModifier_INDEX:Int = 41
    let fullRightPressKey_INDEX:Int = 42
    let fullRightLongPressKeyType_INDEX:Int = 43
    let fullRightLongPressKeyModifier_INDEX:Int = 44
    let fullRightLongPressKey_INDEX:Int = 45
    let fullLeftPressKeyType_INDEX:Int = 46
    let fullLeftPressKeyModifier_INDEX:Int = 47
    let fullLeftPressKey_INDEX:Int = 48
    let fullLeftLongPressKeyType_INDEX:Int = 49
    let fullLeftLongPressKeyModifier_INDEX:Int = 50
    let fullLeftLongPressKey_INDEX:Int = 51
    let fullScrollUpKeyType_INDEX:Int = 52
    let fullScrollUpKeyModifier_INDEX:Int = 53
    let fullScrollUpKey_INDEX:Int = 54
    let fullScrollDownKeyType_INDEX:Int = 55
    let fullScrollDownKeyModifier_INDEX:Int = 56
    let fullScrollDownKey_INDEX:Int = 57
    let fullSignalPressKeyType_INDEX:Int = 58
    let fullSignalPressKeyModifier_INDEX:Int = 59
    let fullSignalPressKey_INDEX:Int = 60
    let fullSignalLongPressKeyType_INDEX:Int = 61
    let fullSignalLongPressKeyModifier_INDEX:Int = 62
    let fullSignalLongPressKey_INDEX:Int = 63

    var keyMode:UInt8?
    var RTKSensitivity:UInt8?
    var RTKPagePressKeyType:UInt8?
    var RTKPagePressKeyModifier:UInt8?
    var RTKPagePressKey:UInt8?
    var RTKPageDoublePressKeyType:UInt8?
    var RTKPageDoublePressKeyModifier:UInt8?
    var RTKPageDoublePressKey:UInt8?
    var RTKZoomPPressKeyType:UInt8?
    var RTKZoomPPressKeyModifier:UInt8?
    var RTKZoomPPressKey:UInt8?
    var RTKZoomPDoublePressKeyType:UInt8?
    var RTKZoomPDoublePressKeyModifier:UInt8?
    var RTKZoomPDoublePressKey:UInt8?
    var RTKZoomMPressKeyType:UInt8?
    var RTKZoomMPressKeyModifier:UInt8?
    var RTKZoomMPressKey:UInt8?
    var RTKZoomMDoublePressKeyType:UInt8?
    var RTKZoomMDoublePressKeyModifier:UInt8?
    var RTKZoomMDoublePressKey:UInt8?
    var RTKSpeakPressKeyType:UInt8?
    var RTKSpeakPressKeyModifier:UInt8?
    var RTKSpeakPressKey:UInt8?
    var RTKSpeakDoublePressKeyType:UInt8?
    var RTKSpeakDoublePressKeyModifier:UInt8?
    var RTKSpeakDoublePressKey:UInt8?
    var RTKMutePressKeyType:UInt8?
    var RTKMutePressKeyModifier:UInt8?
    var RTKMutePressKey:UInt8?
    var RTKMuteDoublePressKeyType:UInt8?
    var RTKMuteDoublePressKeyModifier:UInt8?
    var RTKMuteDoublePressKey:UInt8?
    var RTKDisplayPressKeyType:UInt8?
    var RTKDisplayPressKeyModifier:UInt8?
    var RTKDisplayPressKey:UInt8?
    var RTKDisplayDoublePressKeyType:UInt8?
    var RTKDisplayDoublePressKeyModifier:UInt8?
    var RTKDisplayDoublePressKey:UInt8?
    var fullSensitivity:UInt8?
    var fullRightPressKeyType:UInt8?
    var fullRightPressKeyModifier:UInt8?
    var fullRightPressKey:UInt8?
    var fullRightLongPressKeyType:UInt8?
    var fullRightLongPressKeyModifier:UInt8?
    var fullRightLongPressKey:UInt8?
    var fullLeftPressKeyType:UInt8?
    var fullLeftPressKeyModifier:UInt8?
    var fullLeftPressKey:UInt8?
    var fullLeftLongPressKeyType:UInt8?
    var fullLeftLongPressKeyModifier:UInt8?
    var fullLeftLongPressKey:UInt8?
    var fullScrollUpKeyType:UInt8?
    var fullScrollUpKeyModifier:UInt8?
    var fullScrollUpKey:UInt8?
    var fullScrollDownKeyType:UInt8?
    var fullScrollDownKeyModifier:UInt8?
    var fullScrollDownKey:UInt8?
    var fullSignalPressKeyType:UInt8?
    var fullSignalPressKeyModifier:UInt8?
    var fullSignalPressKey:UInt8?
    var fullSignalLongPressKeyType:UInt8?
    var fullSignalLongPressKeyModifier:UInt8?
    var fullSignalLongPressKey:UInt8?

    required override init() {
        super.init()
        NSLog("WLQ_N: init()")
        WLQ.shared = self
        WLQ.initialized = true
        actionNames = [OldSensitivity: NSLocalizedString("sensitivity_label", comment: ""),
                       KEYMODE: NSLocalizedString("keymode_label", comment: ""),
                       USB: NSLocalizedString("usb_threshold_label", comment: ""),
                       RTKDoublePressSensitivity: NSLocalizedString("double_press_label", comment: ""),
                       fullLongPressSensitivity: NSLocalizedString("long_press_label", comment: ""),
                       RTKPage: NSLocalizedString("rtk_page_label", comment: ""),
                       RTKPageDoublePress: NSLocalizedString("rtk_page_double_label", comment: ""),
                       RTKZoomPlus: NSLocalizedString("rtk_zoomp_label", comment: ""),
                       RTKZoomPlusDoublePress: NSLocalizedString("rtk_zoomp_double_label", comment: ""),
                       RTKZoomMinus: NSLocalizedString("rtk_zoomm_label", comment: ""),
                       RTKZoomMinusDoublePress: NSLocalizedString("rtk_zoomm_double_label", comment: ""),
                       RTKSpeak: NSLocalizedString("rtk_speak_label", comment: ""),
                       RTKSpeakDoublePress: NSLocalizedString("rtk_speak_double_label", comment: ""),
                       RTKMute: NSLocalizedString("rtk_mute_label", comment: ""),
                       RTKMuteDoublePress: NSLocalizedString("rtk_mute_double_label", comment: ""),
                       RTKDisplayOff: NSLocalizedString("rtk_display_label", comment: ""),
                       RTKDisplayOffDoublePress: NSLocalizedString("rtk_display_double_label", comment: ""),
                       fullScrollUp: NSLocalizedString("full_scroll_up_label", comment: ""),
                       fullScrollDown: NSLocalizedString("full_scroll_down_label", comment: ""),
                       fullToggleRight: NSLocalizedString("full_toggle_right_label", comment: ""),
                       fullToggleRightLongPress: NSLocalizedString("full_toggle_right_long_label", comment: ""),
                       fullToggleLeft: NSLocalizedString("full_toggle_left_label", comment: ""),
                       fullToggleLeftLongPress: NSLocalizedString("full_toggle_left_long_label", comment: ""),
                       fullSignalCancel: NSLocalizedString("full_signal_cancel_label", comment: ""),
                       fullSignalCancelLongPress: NSLocalizedString("full_signal_cancel_long_label", comment: "")]
    }
    
    override func parseConfig(bytes: [UInt8]) {
        
        self.wunderLINQConfig = bytes
        self.firmwareVersion = "\(bytes[self.firmwareVersionMajor_INDEX]).\(bytes[self.firmwareVersionMinor_INDEX])"
        UserDefaults.standard.set("\(bytes[self.firmwareVersionMajor_INDEX]).\(bytes[self.firmwareVersionMinor_INDEX])", forKey: "firmwareVersion")

        if (self.firmwareVersion!.toDouble()! >= 2.0) { // FW >=2.0
            self.flashConfig = Array(bytes[26..<(26+configFlashSize)])
            self.tempConfig = self.flashConfig
            
            var messageHexString = ""
            for i in 0 ..< flashConfig!.count {
                messageHexString += String(format: "%02X", flashConfig![i])
                if i < flashConfig!.count - 1 {
                    messageHexString += ","
                }
            }
            NSLog("WLQ_N: flashConfig: \(messageHexString)")

            self.keyMode = bytes[self.keyMode_INDEX]
            let usbBytes: [UInt8] = [self.flashConfig![self.USBVinThresholdHigh_INDEX], self.flashConfig![self.USBVinThresholdLow_INDEX]]
            self.USBVinThreshold = usbBytes.withUnsafeBytes { $0.load(as: UInt16.self) }
            self.RTKSensitivity = self.flashConfig![self.RTKSensitivity_INDEX]
            self.RTKPagePressKeyType = self.flashConfig![self.RTKPagePressKeyType_INDEX]
            self.RTKPagePressKeyModifier = self.flashConfig![self.RTKPagePressKeyModifier_INDEX]
            self.RTKPagePressKey = self.flashConfig![self.RTKPagePressKey_INDEX]
            self.RTKPageDoublePressKeyType = self.flashConfig![self.RTKPageDoublePressKeyType_INDEX]
            self.RTKPageDoublePressKeyModifier = self.flashConfig![self.RTKPageDoublePressKeyModifier_INDEX]
            self.RTKPageDoublePressKey = self.flashConfig![self.RTKPageDoublePressKey_INDEX]
            self.RTKZoomPPressKeyType = self.flashConfig![self.RTKZoomPPressKeyType_INDEX]
            self.RTKZoomPPressKeyModifier = self.flashConfig![self.RTKZoomPPressKeyModifier_INDEX]
            self.RTKZoomPPressKey = self.flashConfig![self.RTKZoomPPressKey_INDEX]
            self.RTKZoomPDoublePressKeyType = self.flashConfig![self.RTKZoomPDoublePressKeyType_INDEX]
            self.RTKZoomPDoublePressKeyModifier = self.flashConfig![self.RTKZoomPDoublePressKeyModifier_INDEX]
            self.RTKZoomPDoublePressKey = self.flashConfig![self.RTKZoomPDoublePressKey_INDEX]
            self.RTKZoomMPressKeyType = self.flashConfig![self.RTKZoomMPressKeyType_INDEX]
            self.RTKZoomMPressKeyModifier = self.flashConfig![self.RTKZoomMPressKeyModifier_INDEX]
            self.RTKZoomMPressKey = self.flashConfig![self.RTKZoomMPressKey_INDEX]
            self.RTKZoomMDoublePressKeyType = self.flashConfig![self.RTKZoomMDoublePressKeyType_INDEX]
            self.RTKZoomMDoublePressKeyModifier = self.flashConfig![self.RTKZoomMDoublePressKeyModifier_INDEX]
            self.RTKZoomMDoublePressKey = self.flashConfig![self.RTKZoomMDoublePressKey_INDEX]
            self.RTKSpeakPressKeyType = self.flashConfig![self.RTKSpeakPressKeyType_INDEX]
            self.RTKSpeakPressKeyModifier = self.flashConfig![self.RTKSpeakPressKeyModifier_INDEX]
            self.RTKSpeakPressKey = self.flashConfig![self.RTKSpeakPressKey_INDEX]
            self.RTKSpeakDoublePressKeyType = self.flashConfig![self.RTKSpeakDoublePressKeyType_INDEX]
            self.RTKSpeakDoublePressKeyModifier = self.flashConfig![self.RTKSpeakDoublePressKeyModifier_INDEX]
            self.RTKSpeakDoublePressKey = self.flashConfig![self.RTKSpeakDoublePressKey_INDEX]
            self.RTKMutePressKeyType = self.flashConfig![self.RTKMutePressKeyType_INDEX]
            self.RTKMutePressKeyModifier = self.flashConfig![self.RTKMutePressKeyModifier_INDEX]
            self.RTKMutePressKey = self.flashConfig![self.RTKMutePressKey_INDEX]
            self.RTKMuteDoublePressKeyType = self.flashConfig![self.RTKMuteDoublePressKeyType_INDEX]
            self.RTKMuteDoublePressKeyModifier = self.flashConfig![self.RTKMuteDoublePressKeyModifier_INDEX]
            self.RTKMuteDoublePressKey = self.flashConfig![self.RTKMuteDoublePressKey_INDEX]
            self.RTKDisplayPressKeyType = self.flashConfig![self.RTKDisplayPressKeyType_INDEX]
            self.RTKDisplayPressKeyModifier = self.flashConfig![self.RTKDisplayPressKeyModifier_INDEX]
            self.RTKDisplayPressKey = self.flashConfig![self.RTKDisplayPressKey_INDEX]
            self.RTKDisplayDoublePressKeyType = self.flashConfig![self.RTKDisplayDoublePressKeyType_INDEX]
            self.RTKDisplayDoublePressKeyModifier = self.flashConfig![self.RTKDisplayDoublePressKeyModifier_INDEX]
            self.RTKDisplayDoublePressKey = self.flashConfig![self.RTKDisplayDoublePressKey_INDEX]
            self.fullSensitivity = self.flashConfig![self.fullSensitivity_INDEX]
            self.fullRightPressKeyType = self.flashConfig![self.fullRightPressKeyType_INDEX]
            self.fullRightPressKeyModifier = self.flashConfig![self.fullRightPressKeyModifier_INDEX]
            self.fullRightPressKey = self.flashConfig![self.fullRightPressKey_INDEX]
            self.fullRightLongPressKeyType = self.flashConfig![self.fullRightLongPressKeyType_INDEX]
            self.fullRightLongPressKeyModifier = self.flashConfig![self.fullRightLongPressKeyModifier_INDEX]
            self.fullRightLongPressKey = self.flashConfig![self.fullRightLongPressKey_INDEX]
            self.fullLeftPressKeyType = self.flashConfig![self.fullLeftPressKeyType_INDEX]
            self.fullLeftPressKeyModifier = self.flashConfig![self.fullLeftPressKeyModifier_INDEX]
            self.fullLeftPressKey = self.flashConfig![self.fullLeftPressKey_INDEX]
            self.fullLeftLongPressKeyType = self.flashConfig![self.fullLeftLongPressKeyType_INDEX]
            self.fullLeftLongPressKeyModifier = self.flashConfig![self.fullLeftLongPressKeyModifier_INDEX]
            self.fullLeftLongPressKey = self.flashConfig![self.fullLeftLongPressKey_INDEX]
            self.fullScrollUpKeyType = self.flashConfig![self.fullScrollUpKeyType_INDEX]
            self.fullScrollUpKeyModifier = self.flashConfig![fullScrollUpKeyModifier_INDEX]
            self.fullScrollUpKey = self.flashConfig![self.fullScrollUpKey_INDEX]
            self.fullScrollDownKeyType = self.flashConfig![self.fullScrollDownKeyType_INDEX]
            self.fullScrollDownKeyModifier = self.flashConfig![self.fullScrollDownKeyModifier_INDEX]
            self.fullScrollDownKey = self.flashConfig![self.fullScrollDownKey_INDEX]
            self.fullSignalPressKeyType = self.flashConfig![self.fullSignalPressKeyType_INDEX]
            self.fullSignalPressKeyModifier = self.flashConfig![self.fullSignalPressKeyModifier_INDEX]
            self.fullSignalPressKey = self.flashConfig![self.fullSignalPressKey_INDEX]
            self.fullSignalLongPressKeyType = self.flashConfig![self.fullSignalLongPressKeyType_INDEX]
            self.fullSignalLongPressKeyModifier = self.flashConfig![self.fullSignalLongPressKeyModifier_INDEX]
            self.fullSignalLongPressKey = self.flashConfig![self.fullSignalLongPressKey_INDEX]
        }
    }
    
    override func getDefaultConfig() -> [UInt8]{
        switch (gethardwareVersion()){
        case self.hardwareVersion2:
            return defaultConfig2
        case self.hardwareVersion2_1:
            return defaultConfig2HW1
        default:
            return [0x00]
        }
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
    
    override func gethardwareType() -> Int{
        return 1
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
    
    override func getVINThreshold() -> UInt16{
        return USBVinThreshold!
    }
    override  func setVINThreshold(value: [UInt8]){
        setTempConfigByte(index: USBVinThresholdHigh_INDEX, value: value[0])
        setTempConfigByte(index: USBVinThresholdLow_INDEX, value: value[1])
    }
    
    override func getDoublePressSensitivity() -> UInt8{
        return RTKSensitivity!
    }
    override func setDoublePressSensitivity(value: UInt8){
        setTempConfigByte(index: RTKSensitivity_INDEX, value: value)
    }
    override func getLongPressSensitivity() -> UInt8{
        return fullSensitivity!
    }
    override func setLongPressSensitivity(value: UInt8){
        setTempConfigByte(index: fullSensitivity_INDEX, value: value)
    }
    
    override func getActionKeyType(action: Int?) -> UInt8{
        switch (action){
        case RTKPage:
            return RTKPagePressKeyType!
        case RTKPageDoublePress:
            return RTKPageDoublePressKeyType!
        case RTKZoomPlus:
            return RTKZoomPPressKeyType!
        case RTKZoomPlusDoublePress:
            return RTKZoomPDoublePressKeyType!
        case RTKZoomMinus:
            return RTKZoomMPressKeyType!
        case RTKZoomMinusDoublePress:
            return RTKZoomMDoublePressKeyType!
        case RTKSpeak:
            return RTKSpeakPressKeyType!
        case RTKSpeakDoublePress:
            return RTKSpeakDoublePressKeyType!
        case RTKMute:
            return RTKMutePressKeyType!
        case RTKMuteDoublePress:
            return RTKMuteDoublePressKeyType!
        case RTKDisplayOff:
            return RTKDisplayPressKeyType!
        case RTKDisplayOffDoublePress:
            return RTKDisplayDoublePressKeyType!
        case fullScrollUp:
            return fullScrollUpKeyType!
        case fullScrollDown:
            return fullScrollDownKeyType!
        case fullToggleRight:
            return fullRightPressKeyType!
        case fullToggleRightLongPress:
            return fullRightLongPressKeyType!
        case fullToggleLeft:
            return fullLeftPressKeyType!
        case fullToggleLeftLongPress:
            return fullLeftLongPressKeyType!
        case fullSignalCancel:
            return fullSignalPressKeyType!
        case fullSignalCancelLongPress:
            return fullSignalLongPressKeyType!
        default:
            return 0x00
        }
    }
    
    override func setActionKey(action: Int?, key: [UInt8]) {
        if (key.count == 3){
            switch (action){
            case RTKPage:
                self.tempConfig![self.RTKPagePressKeyType_INDEX] = key[0]
                self.tempConfig![self.RTKPagePressKeyModifier_INDEX] = key[1]
                self.tempConfig![self.RTKPagePressKey_INDEX] = key[2]
            case RTKPageDoublePress:
                self.tempConfig![self.RTKPageDoublePressKeyType_INDEX] = key[0]
                self.tempConfig![self.RTKPageDoublePressKeyModifier_INDEX] = key[1]
                self.tempConfig![self.RTKPageDoublePressKey_INDEX] = key[2]
            case RTKZoomPlus:
                self.tempConfig![self.RTKZoomPPressKeyType_INDEX] = key[0]
                self.tempConfig![self.RTKZoomPPressKeyModifier_INDEX] = key[1]
                self.tempConfig![self.RTKZoomPPressKey_INDEX] = key[2]
            case RTKZoomPlusDoublePress:
                self.tempConfig![self.RTKZoomPDoublePressKeyType_INDEX] = key[0]
                self.tempConfig![self.RTKZoomPDoublePressKeyModifier_INDEX] = key[1]
                self.tempConfig![self.RTKZoomPDoublePressKey_INDEX] = key[2]
            case RTKZoomMinus:
                self.tempConfig![self.RTKZoomMPressKeyType_INDEX] = key[0]
                self.tempConfig![self.RTKZoomMPressKeyModifier_INDEX] = key[1]
                self.tempConfig![self.RTKZoomMPressKey_INDEX] = key[2]
            case RTKZoomMinusDoublePress:
                self.tempConfig![self.RTKZoomMDoublePressKeyType_INDEX] = key[0]
                self.tempConfig![self.RTKZoomMDoublePressKeyModifier_INDEX] = key[1]
                self.tempConfig![self.RTKZoomMDoublePressKey_INDEX] = key[2]
            case RTKSpeak:
                self.tempConfig![self.RTKSpeakPressKeyType_INDEX] = key[0]
                self.tempConfig![self.RTKSpeakPressKeyModifier_INDEX] = key[1]
                self.tempConfig![self.RTKSpeakPressKey_INDEX] = key[2]
            case RTKSpeakDoublePress:
                self.tempConfig![self.RTKSpeakDoublePressKeyType_INDEX] = key[0]
                self.tempConfig![self.RTKSpeakDoublePressKeyModifier_INDEX] = key[1]
                self.tempConfig![self.RTKSpeakDoublePressKey_INDEX] = key[2]
            case RTKMute:
                self.tempConfig![self.RTKMutePressKeyType_INDEX] = key[0]
                self.tempConfig![self.RTKMutePressKeyModifier_INDEX] = key[1]
                self.tempConfig![self.RTKMutePressKey_INDEX] = key[2]
            case RTKMuteDoublePress:
                self.tempConfig![self.RTKMuteDoublePressKeyType_INDEX] = key[0]
                self.tempConfig![self.RTKMuteDoublePressKeyModifier_INDEX] = key[1]
                self.tempConfig![self.RTKMuteDoublePressKey_INDEX] = key[2]
            case RTKDisplayOff:
                self.tempConfig![self.RTKDisplayPressKeyType_INDEX] = key[0]
                self.tempConfig![self.RTKDisplayPressKeyModifier_INDEX] = key[1]
                self.tempConfig![self.RTKDisplayPressKey_INDEX] = key[2]
            case RTKDisplayOffDoublePress:
                self.tempConfig![self.RTKDisplayDoublePressKeyType_INDEX] = key[0]
                self.tempConfig![self.RTKDisplayDoublePressKeyModifier_INDEX] = key[1]
                self.tempConfig![self.RTKDisplayDoublePressKey_INDEX] = key[2]
            case fullScrollUp:
                self.tempConfig![self.fullScrollUpKeyType_INDEX] = key[0]
                self.tempConfig![self.fullScrollUpKeyModifier_INDEX] = key[1]
                self.tempConfig![self.fullScrollUpKey_INDEX] = key[2]
            case fullScrollDown:
                self.tempConfig![self.fullScrollDownKeyType_INDEX] = key[0]
                self.tempConfig![self.fullScrollDownKeyModifier_INDEX] = key[1]
                self.tempConfig![self.fullScrollDownKey_INDEX] = key[2]
            case fullToggleRight:
                self.tempConfig![self.fullRightPressKeyType_INDEX] = key[0]
                self.tempConfig![self.fullRightPressKeyModifier_INDEX] = key[1]
                self.tempConfig![self.fullRightPressKey_INDEX] = key[2]
            case fullToggleRightLongPress:
                self.tempConfig![self.fullRightLongPressKeyType_INDEX] = key[0]
                self.tempConfig![self.fullRightLongPressKeyModifier_INDEX] = key[1]
                self.tempConfig![self.fullRightLongPressKey_INDEX] = key[2]
            case fullToggleLeft:
                self.tempConfig![self.fullLeftPressKeyType_INDEX] = key[0]
                self.tempConfig![self.fullLeftPressKeyModifier_INDEX] = key[1]
                self.tempConfig![self.fullLeftPressKey_INDEX] = key[2]
            case fullToggleLeftLongPress:
                self.tempConfig![self.fullLeftLongPressKeyType_INDEX] = key[0]
                self.tempConfig![self.fullLeftLongPressKeyModifier_INDEX] = key[1]
                self.tempConfig![self.fullLeftLongPressKey_INDEX] = key[2]
            case fullSignalCancel:
                self.tempConfig![self.fullSignalPressKeyType_INDEX] = key[0]
                self.tempConfig![self.fullSignalPressKeyModifier_INDEX] = key[1]
                self.tempConfig![self.fullSignalPressKey_INDEX] = key[2]
            case fullSignalCancelLongPress:
                self.tempConfig![self.fullSignalLongPressKeyType_INDEX] = key[0]
                self.tempConfig![self.fullSignalLongPressKeyModifier_INDEX] = key[1]
                self.tempConfig![self.fullSignalLongPressKey_INDEX] = key[2]
            default:
                NSLog("WLQ_N: Invalid acitonID")
            }
        }
    }
    
    override func getActionKeyPosition(action: Int) -> Int{
        var position:Int = 0
        let keyboardHID = KeyboardHID.shared
        switch (action){
        case fullScrollUp:
            if(fullScrollUpKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == fullScrollUpKey! }) {
                    position = index
                }
            } else if(fullScrollUpKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == fullScrollUpKey! }) {
                    position = index
                }
            }
        case fullScrollDown:
            if(fullScrollDownKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == fullScrollDownKey! }) {
                    position = index
                }
            } else if(fullScrollDownKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == fullScrollDownKey! }) {
                    position = index
                }
            }
        case fullToggleRight:
            if(fullRightPressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == fullRightPressKey! }) {
                    position = index
                }
            } else if(fullRightPressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == fullRightPressKey! }) {
                    position = index
                }
            }
        case fullToggleRightLongPress:
            if(fullRightLongPressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == fullRightLongPressKey! }) {
                    position = index
                }
            } else if(fullRightLongPressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == fullRightLongPressKey! }) {
                    position = index
                }
            }
        case fullToggleLeft:
            if(fullLeftPressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == fullLeftPressKey! }) {
                    position = index
                }
            } else if(fullLeftPressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == fullLeftPressKey! }) {
                    position = index
                }
            }
        case fullToggleLeftLongPress:
            if(fullLeftLongPressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == fullLeftLongPressKey! }) {
                    position = index
                }
            } else if(fullLeftLongPressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == fullLeftLongPressKey! }) {
                    position = index
                }
            }
        case fullSignalCancel:
            if(fullSignalPressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == fullSignalPressKey! }) {
                    position = index
                }
            } else if(fullSignalPressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == fullSignalPressKey! }) {
                    position = index
                }
            }
        case fullSignalCancelLongPress:
            if(fullSignalLongPressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == fullSignalLongPressKey! }) {
                    position = index
                }
            } else if(fullSignalLongPressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == fullSignalLongPressKey! }) {
                    position = index
                }
            }
        case RTKPage:
            if(RTKPagePressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == RTKPagePressKey! }) {
                    position = index
                }
            } else if(RTKPagePressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == RTKPagePressKey! }) {
                    position = index
                }
            }
        case RTKPageDoublePress:
            if(RTKPageDoublePressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == RTKPageDoublePressKey! }) {
                    position = index
                }
            } else if(RTKPageDoublePressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == RTKPageDoublePressKey! }) {
                    position = index
                }
            }
        case RTKZoomPlus:
            if(RTKZoomPPressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == RTKZoomPPressKey! }) {
                    position = index
                }
            } else if(RTKZoomPPressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == RTKZoomPPressKey! }) {
                    position = index
                }
            }
        case RTKZoomPlusDoublePress:
            if(RTKZoomPDoublePressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == RTKZoomPDoublePressKey! }) {
                    position = index
                }
            } else if(RTKZoomPDoublePressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == RTKZoomPDoublePressKey! }) {
                    position = index
                }
            }
        case RTKZoomMinus:
            if(RTKZoomMPressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == RTKZoomMPressKey! }) {
                    position = index
                }
            } else if(RTKZoomMPressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == RTKZoomMPressKey! }) {
                    position = index
                }
            }
        case RTKZoomMinusDoublePress:
            if(RTKZoomMDoublePressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == RTKZoomMDoublePressKey! }) {
                    position = index
                }
            } else if(RTKZoomMDoublePressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == RTKZoomMDoublePressKey! }) {
                    position = index
                }
            }
        case RTKSpeak:
            if(RTKSpeakPressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == RTKSpeakPressKey! }) {
                    position = index
                }
            } else if(RTKSpeakPressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == RTKSpeakPressKey! }) {
                    position = index
                }
            }
        case RTKSpeakDoublePress:
            if(RTKSpeakDoublePressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == RTKSpeakDoublePressKey! }) {
                    position = index
                }
            } else if(RTKSpeakDoublePressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == RTKSpeakDoublePressKey! }) {
                    position = index
                }
            }
        case RTKMute:
            if(RTKMutePressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == RTKMutePressKey! }) {
                    position = index
                }
            } else if(RTKMutePressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == RTKMutePressKey! }) {
                    position = index
                }
            }
        case RTKMuteDoublePress:
            if(RTKMuteDoublePressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == RTKMuteDoublePressKey! }) {
                    position = index
                }
            } else if(RTKMuteDoublePressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == RTKMuteDoublePressKey! }) {
                    position = index
                }
            }
        case RTKDisplayOff:
            if(RTKDisplayPressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == RTKDisplayPressKey! }) {
                    position = index
                }
            } else if(RTKDisplayPressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == RTKDisplayPressKey! }) {
                    position = index
                }
            }
        case RTKDisplayOffDoublePress:
            if(RTKDisplayDoublePressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == RTKDisplayDoublePressKey! }) {
                    position = index
                }
            } else if(RTKDisplayDoublePressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == RTKDisplayDoublePressKey! }) {
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
        case USB:
            if (USBVinThreshold == 0x0000){
                returnString = NSLocalizedString("usbcontrol_on_label", comment: "")
            } else if (USBVinThreshold == 0xFFFF){
                returnString = NSLocalizedString("usbcontrol_off_label", comment: "")
            } else {
                returnString = NSLocalizedString("usbcontrol_engine_label", comment: "")
            }
        case RTKDoublePressSensitivity:
            returnString = "\(Int(RTKSensitivity!) * 50)ms"
        case fullLongPressSensitivity:
            returnString = "\(Int(fullSensitivity!) * 50)ms"
        case fullScrollUp:
            if(fullScrollUpKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == fullScrollUpKey! }) {
                    let name = keyboardHID.keyboardCodes[index].1
                    returnString = name
                }
            } else if(fullScrollUpKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == fullScrollUpKey! }) {
                    let name = keyboardHID.consumerCodes[index].1
                    returnString = name
                }
            }
        case fullScrollDown:
            if(fullScrollDownKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == fullScrollDownKey! }) {
                    let name = keyboardHID.keyboardCodes[index].1
                    returnString = name
                }
            } else if(fullScrollDownKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == fullScrollDownKey! }) {
                    let name = keyboardHID.consumerCodes[index].1
                    returnString = name
                }
            }
        case fullToggleRight:
            if(fullRightPressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == fullRightPressKey! }) {
                    let name = keyboardHID.keyboardCodes[index].1
                    returnString = name
                }
            } else if(fullRightPressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == fullRightPressKey! }) {
                    let name = keyboardHID.consumerCodes[index].1
                    returnString = name
                }
            }
        case fullToggleRightLongPress:
            if(fullRightLongPressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == fullRightLongPressKey! }) {
                    let name = keyboardHID.keyboardCodes[index].1
                    returnString = name
                }
            } else if(fullRightLongPressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == fullRightLongPressKey! }) {
                    let name = keyboardHID.consumerCodes[index].1
                    returnString = name
                }
            }
        case fullToggleLeft:
            if(fullLeftPressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == fullLeftPressKey! }) {
                    let name = keyboardHID.keyboardCodes[index].1
                    returnString = name
                }
            } else if(fullLeftPressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == fullLeftPressKey! }) {
                    let name = keyboardHID.consumerCodes[index].1
                    returnString = name
                }
            }
        case fullToggleLeftLongPress:
            if(fullLeftLongPressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == fullLeftLongPressKey! }) {
                    let name = keyboardHID.keyboardCodes[index].1
                    returnString = name
                }
            } else if(fullLeftLongPressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == fullLeftLongPressKey! }) {
                    let name = keyboardHID.consumerCodes[index].1
                    returnString = name
                }
            }
        case fullSignalCancel:
            if(fullSignalPressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == fullSignalPressKey! }) {
                    let name = keyboardHID.keyboardCodes[index].1
                    returnString = name
                }
            } else if(fullSignalPressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == fullSignalPressKey! }) {
                    let name = keyboardHID.consumerCodes[index].1
                    returnString = name
                }
            }
        case fullSignalCancelLongPress:
            if(fullSignalLongPressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == fullSignalLongPressKey! }) {
                    let name = keyboardHID.keyboardCodes[index].1
                    returnString = name
                }
            } else if(fullSignalLongPressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == fullSignalLongPressKey! }) {
                    let name = keyboardHID.consumerCodes[index].1
                    returnString = name
                }
            }
        case RTKPage:
            if(RTKPagePressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == RTKPagePressKey! }) {
                    let name = keyboardHID.keyboardCodes[index].1
                    returnString = name
                }
            } else if(RTKPagePressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == RTKPagePressKey! }) {
                    let name = keyboardHID.consumerCodes[index].1
                    returnString = name
                }
            }
        case RTKPageDoublePress:
            if(RTKPageDoublePressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == RTKPageDoublePressKey! }) {
                    let name = keyboardHID.keyboardCodes[index].1
                    returnString = name
                }
            } else if(RTKPageDoublePressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == RTKPageDoublePressKey! }) {
                    let name = keyboardHID.consumerCodes[index].1
                    returnString = name
                }
            }
        case RTKZoomPlus:
            if(RTKZoomPPressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == RTKZoomPPressKey! }) {
                    let name = keyboardHID.keyboardCodes[index].1
                    returnString = name
                }
            } else if(RTKZoomPPressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == RTKZoomPPressKey! }) {
                    let name = keyboardHID.consumerCodes[index].1
                    returnString = name
                }
            }
        case RTKZoomPlusDoublePress:
            if(RTKZoomPDoublePressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == RTKZoomPDoublePressKey! }) {
                    let name = keyboardHID.keyboardCodes[index].1
                    returnString = name
                }
            } else if(RTKZoomPDoublePressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == RTKZoomPDoublePressKey! }) {
                    let name = keyboardHID.consumerCodes[index].1
                    returnString = name
                }
            }
        case RTKZoomMinus:
            if(RTKZoomMPressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == RTKZoomMPressKey! }) {
                    let name = keyboardHID.keyboardCodes[index].1
                    returnString = name
                }
            } else if(RTKZoomMPressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == RTKZoomMPressKey! }) {
                    let name = keyboardHID.consumerCodes[index].1
                    returnString = name
                }
            }
        case RTKZoomMinusDoublePress:
            if(RTKZoomMDoublePressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == RTKZoomMDoublePressKey! }) {
                    let name = keyboardHID.keyboardCodes[index].1
                    returnString = name
                }
            } else if(RTKZoomMDoublePressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == RTKZoomMDoublePressKey! }) {
                    let name = keyboardHID.consumerCodes[index].1
                    returnString = name
                }
            }
        case RTKSpeak:
            if(RTKSpeakPressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == RTKSpeakPressKey! }) {
                    let name = keyboardHID.keyboardCodes[index].1
                    returnString = name
                }
            } else if(RTKSpeakPressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == RTKSpeakPressKey! }) {
                    let name = keyboardHID.consumerCodes[index].1
                    returnString = name
                }
            }
        case RTKSpeakDoublePress:
            if(RTKSpeakDoublePressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == RTKSpeakDoublePressKey! }) {
                    let name = keyboardHID.keyboardCodes[index].1
                    returnString = name
                }
            } else if(RTKSpeakDoublePressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == RTKSpeakDoublePressKey! }) {
                    let name = keyboardHID.consumerCodes[index].1
                    returnString = name
                }
            }
        case RTKMute:
            if(RTKMutePressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == RTKMutePressKey! }) {
                    let name = keyboardHID.keyboardCodes[index].1
                    returnString = name
                }
            } else if(RTKMutePressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == RTKMutePressKey! }) {
                    let name = keyboardHID.consumerCodes[index].1
                    returnString = name
                }
            }
        case RTKMuteDoublePress:
            if(RTKMuteDoublePressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == RTKMuteDoublePressKey! }) {
                    let name = keyboardHID.keyboardCodes[index].1
                    returnString = name
                }
            } else if(RTKMuteDoublePressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == RTKMuteDoublePressKey! }) {
                    let name = keyboardHID.consumerCodes[index].1
                    returnString = name
                }
            }
        case RTKDisplayOff:
            if(RTKDisplayPressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == RTKDisplayPressKey! }) {
                    let name = keyboardHID.keyboardCodes[index].1
                    returnString = name
                }
            } else if(RTKDisplayPressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == RTKDisplayPressKey! }) {
                    let name = keyboardHID.consumerCodes[index].1
                    returnString = name
                }
            }
        case RTKDisplayOffDoublePress:
            if(RTKDisplayDoublePressKeyType == KEYBOARD_HID){
                if let index = keyboardHID.keyboardCodes.firstIndex(where: { $0.0 == RTKDisplayDoublePressKey! }) {
                    let name = keyboardHID.keyboardCodes[index].1
                    returnString = name
                }
            } else if(RTKDisplayDoublePressKeyType == CONSUMER_HID){
                if let index = keyboardHID.consumerCodes.firstIndex(where: { $0.0 == RTKDisplayDoublePressKey! }) {
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
        case self.fullScrollUp:
            modifiers = self.fullScrollUpKeyModifier!
        case self.fullScrollDown:
            modifiers = self.fullScrollDownKeyModifier!
        case self.fullToggleRight:
            modifiers = self.fullRightPressKeyModifier!
        case self.fullToggleRightLongPress:
            modifiers = self.fullRightLongPressKeyModifier!
        case self.fullToggleLeft:
            modifiers = self.fullLeftPressKeyModifier!
        case self.fullToggleLeftLongPress:
            modifiers = self.fullLeftLongPressKeyModifier!
        case self.fullSignalCancel:
            modifiers = self.fullSignalPressKeyModifier!
        case self.fullSignalCancelLongPress:
            modifiers = self.fullSignalLongPressKeyModifier!
        case self.RTKPage:
            modifiers = self.RTKPagePressKeyModifier!
        case self.RTKPageDoublePress:
            modifiers = self.RTKPageDoublePressKeyModifier!
        case self.RTKZoomPlus:
            modifiers = self.RTKZoomPPressKeyModifier!
        case self.RTKZoomPlusDoublePress:
            modifiers = self.RTKZoomPDoublePressKeyModifier!
        case self.RTKZoomMinus:
            modifiers = self.RTKZoomMPressKeyModifier!
        case self.RTKZoomMinusDoublePress:
            modifiers = self.RTKZoomMDoublePressKeyModifier!
        case self.RTKSpeak:
            modifiers = self.RTKSpeakPressKeyModifier!
        case self.RTKSpeakDoublePress:
            modifiers = self.RTKSpeakDoublePressKeyModifier!
        case self.RTKMute:
            modifiers = self.RTKMutePressKeyModifier!
        case self.RTKMuteDoublePress:
            modifiers = self.RTKMuteDoublePressKeyModifier!
        case self.RTKDisplayOff:
            modifiers = self.RTKDisplayPressKeyModifier!
        case self.RTKDisplayOffDoublePress:
            modifiers = self.RTKDisplayDoublePressKeyModifier!
        default:
            modifiers = 0x00
        }
        return modifiers
    }

    override func setfirmwareVersion(firmwareVersion: String?){
        NSLog("WLQ_N: Firmware Version: \(firmwareVersion ?? "?")")
        self.firmwareVersion = firmwareVersion
    }
    override func getfirmwareVersion() -> String{
        if (self.firmwareVersion != nil){
            return self.firmwareVersion!
        }
        return "Unknown"
    }

    override func sethardwareVersion(hardwareVersion: String?){
        NSLog("WLQ_N: HW Version: \(hardwareVersion ?? "?")")
        self.hardwareVersion = hardwareVersion
    }
    override func gethardwareVersion() -> String{
        if (self.hardwareVersion != nil){
            return self.hardwareVersion!
        }
        return "Unknown"
    }
    
    //Not used for Navigator
    override func setStatus(bytes: [UInt8]) {
        
    }
    override func getStatus() -> [UInt8]?{
        return nil
    }
}

enum WLQ_N_DEFINES {
    static let hardwareVersion1:String = "2PCB1.9 10/18"
    
    static let OldSensitivity:Int = 0
    static let KEYMODE:Int = 100
    static let USB:Int = 1
    static let RTKDoublePressSensitivity:Int = 2
    static let fullLongPressSensitivity:Int = 3
    static let RTKPage:Int = 4
    static let RTKPageDoublePress:Int = 5
    static let RTKZoomPlus:Int = 6
    static let RTKZoomPlusDoublePress:Int = 7
    static let RTKZoomMinus:Int = 8
    static let RTKZoomMinusDoublePress:Int = 9
    static let RTKSpeak:Int = 10
    static let RTKSpeakDoublePress:Int = 11
    static let RTKMute:Int = 12
    static let RTKMuteDoublePress:Int = 13
    static let RTKDisplayOff:Int = 14
    static let RTKDisplayOffDoublePress:Int = 15
    static let fullScrollUp:Int = 16
    static let fullScrollDown:Int = 17
    static let fullToggleRight:Int = 18
    static let fullToggleRightLongPress:Int = 19
    static let fullToggleLeft:Int = 20
    static let fullToggleLeftLongPress:Int = 21
    static let fullSignalCancel:Int = 22
    static let fullSignalCancelLongPress:Int = 23
}
