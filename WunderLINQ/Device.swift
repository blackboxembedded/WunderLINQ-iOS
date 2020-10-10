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

enum Device {
    
    static let WunderLINQAdvertisingUUID = "7340"
    static let DeviceInformationServiceUUID = "0000180A-0000-1000-8000-00805F9B34FB"
    static let FWRevisionCharacteristicUUID = "00002A26-0000-1000-8000-00805F9B34FB"
    static let HWRevisionCharacteristicUUID = "00002A27-0000-1000-8000-00805F9B34FB"
    static let WunderLINQServiceUUID = "02997340-015F-11E5-8C2B-0002A5D5C51B"
    static let MessageCharacteristicUUID = "00000003-0000-1000-8000-00805F9B34FB"
    static let CommandCharacteristicUUID = "00000004-0000-1000-8000-00805F9B34FB"
    static let restoreIdentifier = "com.blackboxembedded.wunderlinq"
    
}
