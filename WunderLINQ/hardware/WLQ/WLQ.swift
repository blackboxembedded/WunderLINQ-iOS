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
    
    init(){}
    
    func TYPE_NAVIGATOR() -> Int{
        return 1
    }
    func TYPE_COMNMANDER() -> Int{
        return 2
    }
    func KEYMODE_DEFAULT() -> UInt8{
        return 0x00
    }
    func KEYMODE_CUSTOM () -> UInt8{
        return 0x01
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
    
    func parseConfig(bytes: [UInt8]) {
        fatalError("This method must be overridden")
    }
    func getConfig() -> [UInt8]{
        fatalError("This method must be overridden")
    }
    func setStatus(bytes: [UInt8]) {
        fatalError("This method must be overridden")
    }
    func getStatus() -> [UInt8]?{
        fatalError("This method must be overridden")
    }
    func getTempConfig() -> [UInt8]{
        fatalError("This method must be overridden")
    }
    func setTempConfigByte(index: Int, value: UInt8){
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
    func setActionKey(action: Int?, key: [UInt8]){
        fatalError("This method must be overridden")
    }
    func getActionKeyPosition(action: Int) -> Int{
        fatalError("This method must be overridden")
    }
    func getActionValue(action: Int) -> String{
        fatalError("This method must be overridden")
    }
    func getActionKeyModifiers(action: Int) -> UInt8{
        fatalError("This method must be overridden")
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
    
    func getAccActive() -> UInt8{
        fatalError("This method must be overridden")
    }
    
    func getAccChannelState(positon: Int) -> UInt8{
        fatalError("This method must be overridden")
    }
    
    func getAccChannelValue(positon: Int) -> UInt8{
        fatalError("This method must be overridden")
    }
    
    func getAccChannelPixelColor(positon: Int) -> UIColor{
        fatalError("This method must be overridden")
    }
}
