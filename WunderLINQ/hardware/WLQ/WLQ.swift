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
    
    static var shared = WLQ()
    
    static var initialized = false
    
    init(){}
    
    func TYPE_N() -> Int{
        return 1
    }
    func TYPE_X() -> Int{
        return 2
    }
    func TYPE_S() -> Int{
        return 3
    }
    func KEYMODE_DEFAULT() -> UInt8{
        return 0x00
    }
    func KEYMODE_CUSTOM() -> UInt8{
        return 0x01
    }
    func KEYMODE_MEDIA() -> UInt8{
        return 0x02
    }
    func KEYMODE_DMD2() -> UInt8{
        return 0x03
    }
    func KEYBOARD_HID() -> UInt8{
        return 0x01
    }
    func CONSUMER_HID() -> UInt8{
        return 0x02
    }
    func UNDEFINED() -> UInt8{
        return 0x00
    }
    func GET_CONFIG_CMD() -> [UInt8]{
        return [0x57, 0x52, 0x57, 0x0D, 0x0A]
    }
    func WRITE_CONFIG_CMD() -> [UInt8]{
        return [0x57, 0x57, 0x43, 0x41]
    }
    func WRITE_MODE_CMD() -> [UInt8]{
        return [0x57, 0x57, 0x53, 0x53]
    }
    func WRITE_SENSITIVITY_CMD() -> [UInt8]{
        return [0x57, 0x57, 0x43, 0x53]
    }
    func SET_CLUSTER_CLOCK_CMD() -> [UInt8]{
        return [0x57, 0x57, 0x44, 0x43]
    }
    func RESET_CLUSTER_SPEED_CMD() -> [UInt8]{
        return [0x57, 0x57, 0x44, 0x52, 0x53]
    }
    func RESET_CLUSTER_ECONO1_CMD() -> [UInt8]{
        return [0x57, 0x57, 0x44, 0x52, 0x45, 0x01]
    }
    func RESET_CLUSTER_ECONO2_CMD() -> [UInt8]{
        return [0x57, 0x57, 0x44, 0x52, 0x45, 0x02]
    }
    func RESET_CLUSTER_TRIP1_CMD() -> [UInt8]{
        return [0x57, 0x57, 0x44, 0x52, 0x54, 0x01]
    }
    func RESET_CLUSTER_TRIP2_CMD() -> [UInt8]{
        return [0x57, 0x57, 0x44, 0x52, 0x54, 0x02]
    }
    func GET_STATUS_CMD() -> [UInt8]{
        return [0x57, 0x52, 0x53, 0x0D, 0x0A]
    }
    func CMD_EOM() -> [UInt8]{
        return [0x0D, 0x0A]
    }
    func gethardwareType() -> Int{
        fatalError("This method must be overridden")
    }
    func setfirmwareVersion(firmwareVersion: String?){
        fatalError("This method must be overridden")
    }
    func getfirmwareVersion() -> String{
        fatalError("This method must be overridden")
    }
    func sethardwareVersion(hardwareVersion: String?){
        fatalError("This method must be overridden")
    }
    func gethardwareVersion() -> String{
        fatalError("This method must be overridden")
    }
    func getDefaultConfig() -> [UInt8]{
        fatalError("This method must be overridden")
    }
    func parseConfig(bytes: [UInt8]) {
        fatalError("This method must be overridden")
    }
    func getConfig() -> [UInt8]{
        fatalError("This method must be overridden")
    }
    func getTempConfig() -> [UInt8]{
        fatalError("This method must be overridden")
    }
    func setTempConfigByte(index: Int, value: UInt8){
        fatalError("This method must be overridden")
    }
    func getVINThreshold() -> UInt16{
        fatalError("This method must be overridden")
    }
    func setVINThreshold(value: [UInt8]){
        fatalError("This method must be overridden")
    }
    func getKeyMode() -> UInt8{
        fatalError("This method must be overridden")
    }
    func getActionName(action: Int?) -> String{
        fatalError("This method must be overridden")
    }
    func setActionName(action: Int?, key: String){
        fatalError("This method must be overridden")
    }
    func getActionKeyType(action: Int?) -> UInt8{
        fatalError("This method must be overridden")
    }
    func setActionValue(action: Int?, value: UInt8){
        fatalError("This method must be overridden")
    }
    func setActionKey(action: Int?, key: [UInt8]){
        fatalError("This method must be overridden")
    }
    func getActionKeyPosition(action: Int) -> Int{
        fatalError("This method must be overridden")
    }
    func getActionValue(action: Int) -> String{
        fatalError("This method must be overridden")
    }
    func getActionValueRaw(action: Int) -> UInt8?{
        fatalError("This method must be overridden")
    }
    func getActionKeyModifiers(action: Int) -> UInt8{
        fatalError("This method must be overridden")
    }
    func setStatus(bytes: [UInt8]) {
        fatalError("This method must be overridden")
    }
    func getStatus() -> [UInt8]?{
        fatalError("This method must be overridden")
    }
    func getAccessories() -> UInt8{
        fatalError("This method must be overridden")
    }
    func setAccActive(active: UInt8){
        fatalError("This method must be overridden")
    }
    func getAccActive() -> UInt8{
        fatalError("This method must be overridden")
    }
    func getAccChannelValue(positon: Int) -> UInt8{
        fatalError("This method must be overridden")
    }
}
enum WLQ_DEFINES {
    static let KEYMODE:Int = 100
    static let ORIENTATION:Int = 101
    static let USB:Int = 1
    static let doublePressSensitivity:Int = 2
    static let longPressSensitivity:Int = 3
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
    static let up:Int = 26
    static let upLong:Int = 27
    static let down:Int = 28
    static let downLong:Int = 29
    static let right:Int = 30
    static let rightLong:Int = 31
    static let left:Int = 32
    static let leftLong:Int = 33
    static let fx1:Int = 34
    static let fx1Long:Int = 35
    static let fx2:Int = 36
    static let fx2Long:Int = 37
    static let pdmChannel1:Int = 50
    static let pdmChannel2:Int = 51
    static let pdmChannel3:Int = 52
    static let pdmChannel4:Int = 53
}
