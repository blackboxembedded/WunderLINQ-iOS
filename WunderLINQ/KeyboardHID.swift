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

class KeyboardHID {
    
    static let shared = KeyboardHID()
    
    let modifierCodes = [NSLocalizedString("keyboard_hid_modifier_0x01_label", comment: ""),
                         NSLocalizedString("keyboard_hid_modifier_0x02_label", comment: ""),
                         NSLocalizedString("keyboard_hid_modifier_0x04_label", comment: ""),
                         NSLocalizedString("keyboard_hid_modifier_0x08_label", comment: ""),
                         NSLocalizedString("keyboard_hid_modifier_0x10_label", comment: ""),
                         NSLocalizedString("keyboard_hid_modifier_0x20_label", comment: ""),
                         NSLocalizedString("keyboard_hid_modifier_0x40_label", comment: ""),
                         NSLocalizedString("keyboard_hid_modifier_0x80_label", comment: "")]
    
    let keyboardCodes: KeyValuePairs = [
        0x00: NSLocalizedString("hid_0x00_label", comment: ""),
        0x04: NSLocalizedString("keyboard_hid_0x04_label", comment: ""),
        0x05: NSLocalizedString("keyboard_hid_0x05_label", comment: ""),
        0x06: NSLocalizedString("keyboard_hid_0x06_label", comment: ""),
        0x07: NSLocalizedString("keyboard_hid_0x07_label", comment: ""),
        0x08: NSLocalizedString("keyboard_hid_0x08_label", comment: ""),
        0x09: NSLocalizedString("keyboard_hid_0x09_label", comment: ""),
        0x0A: NSLocalizedString("keyboard_hid_0x0A_label", comment: ""),
        0x0B: NSLocalizedString("keyboard_hid_0x0B_label", comment: ""),
        0x0C: NSLocalizedString("keyboard_hid_0x0C_label", comment: ""),
        0x0D: NSLocalizedString("keyboard_hid_0x0D_label", comment: ""),
        0x0E: NSLocalizedString("keyboard_hid_0x0E_label", comment: ""),
        0x0F: NSLocalizedString("keyboard_hid_0x0F_label", comment: ""),
        0x10: NSLocalizedString("keyboard_hid_0x10_label", comment: ""),
        0x11: NSLocalizedString("keyboard_hid_0x11_label", comment: ""),
        0x12: NSLocalizedString("keyboard_hid_0x12_label", comment: ""),
        0x13: NSLocalizedString("keyboard_hid_0x13_label", comment: ""),
        0x14: NSLocalizedString("keyboard_hid_0x14_label", comment: ""),
        0x15: NSLocalizedString("keyboard_hid_0x15_label", comment: ""),
        0x16: NSLocalizedString("keyboard_hid_0x16_label", comment: ""),
        0x17: NSLocalizedString("keyboard_hid_0x17_label", comment: ""),
        0x18: NSLocalizedString("keyboard_hid_0x18_label", comment: ""),
        0x19: NSLocalizedString("keyboard_hid_0x19_label", comment: ""),
        0x1A: NSLocalizedString("keyboard_hid_0x1A_label", comment: ""),
        0x1B: NSLocalizedString("keyboard_hid_0x1B_label", comment: ""),
        0x1C: NSLocalizedString("keyboard_hid_0x1C_label", comment: ""),
        0x1D: NSLocalizedString("keyboard_hid_0x1D_label", comment: ""),
        0x1E: NSLocalizedString("keyboard_hid_0x1E_label", comment: ""),
        0x1F: NSLocalizedString("keyboard_hid_0x1F_label", comment: ""),
        0x20: NSLocalizedString("keyboard_hid_0x20_label", comment: ""),
        0x21: NSLocalizedString("keyboard_hid_0x21_label", comment: ""),
        0x22: NSLocalizedString("keyboard_hid_0x22_label", comment: ""),
        0x23: NSLocalizedString("keyboard_hid_0x23_label", comment: ""),
        0x24: NSLocalizedString("keyboard_hid_0x24_label", comment: ""),
        0x25: NSLocalizedString("keyboard_hid_0x25_label", comment: ""),
        0x26: NSLocalizedString("keyboard_hid_0x26_label", comment: ""),
        0x27: NSLocalizedString("keyboard_hid_0x27_label", comment: ""),
        0x28: NSLocalizedString("keyboard_hid_0x28_label", comment: ""),
        0x29: NSLocalizedString("keyboard_hid_0x29_label", comment: ""),
        0x2A: NSLocalizedString("keyboard_hid_0x2A_label", comment: ""),
        0x2B: NSLocalizedString("keyboard_hid_0x2B_label", comment: ""),
        0x2C: NSLocalizedString("keyboard_hid_0x2C_label", comment: ""),
        0x2D: NSLocalizedString("keyboard_hid_0x2D_label", comment: ""),
        0x2E: NSLocalizedString("keyboard_hid_0x2E_label", comment: ""),
        0x2F: NSLocalizedString("keyboard_hid_0x2F_label", comment: ""),
        0x30: NSLocalizedString("keyboard_hid_0x30_label", comment: ""),
        0x31: NSLocalizedString("keyboard_hid_0x31_label", comment: ""),
        0x32: NSLocalizedString("keyboard_hid_0x32_label", comment: ""),
        0x33: NSLocalizedString("keyboard_hid_0x33_label", comment: ""),
        0x34: NSLocalizedString("keyboard_hid_0x34_label", comment: ""),
        0x35: NSLocalizedString("keyboard_hid_0x35_label", comment: ""),
        0x36: NSLocalizedString("keyboard_hid_0x36_label", comment: ""),
        0x37: NSLocalizedString("keyboard_hid_0x37_label", comment: ""),
        0x38: NSLocalizedString("keyboard_hid_0x38_label", comment: ""),
        0x39: NSLocalizedString("keyboard_hid_0x39_label", comment: ""),
        0x3A: NSLocalizedString("keyboard_hid_0x3A_label", comment: ""),
        0x3B: NSLocalizedString("keyboard_hid_0x3B_label", comment: ""),
        0x3C: NSLocalizedString("keyboard_hid_0x3C_label", comment: ""),
        0x3D: NSLocalizedString("keyboard_hid_0x3D_label", comment: ""),
        0x3E: NSLocalizedString("keyboard_hid_0x3E_label", comment: ""),
        0x3F: NSLocalizedString("keyboard_hid_0x3F_label", comment: ""),
        0x40: NSLocalizedString("keyboard_hid_0x40_label", comment: ""),
        0x41: NSLocalizedString("keyboard_hid_0x41_label", comment: ""),
        0x42: NSLocalizedString("keyboard_hid_0x42_label", comment: ""),
        0x43: NSLocalizedString("keyboard_hid_0x43_label", comment: ""),
        0x44: NSLocalizedString("keyboard_hid_0x44_label", comment: ""),
        0x45: NSLocalizedString("keyboard_hid_0x45_label", comment: ""),
        0x46: NSLocalizedString("keyboard_hid_0x46_label", comment: ""),
        0x47: NSLocalizedString("keyboard_hid_0x47_label", comment: ""),
        0x48: NSLocalizedString("keyboard_hid_0x48_label", comment: ""),
        0x49: NSLocalizedString("keyboard_hid_0x49_label", comment: ""),
        0x4A: NSLocalizedString("keyboard_hid_0x4A_label", comment: ""),
        0x4B: NSLocalizedString("keyboard_hid_0x4B_label", comment: ""),
        0x4C: NSLocalizedString("keyboard_hid_0x4C_label", comment: ""),
        0x4D: NSLocalizedString("keyboard_hid_0x4D_label", comment: ""),
        0x4E: NSLocalizedString("keyboard_hid_0x4E_label", comment: ""),
        0x4F: NSLocalizedString("keyboard_hid_0x4F_label", comment: ""),
        0x50: NSLocalizedString("keyboard_hid_0x50_label", comment: ""),
        0x51: NSLocalizedString("keyboard_hid_0x51_label", comment: ""),
        0x52: NSLocalizedString("keyboard_hid_0x52_label", comment: ""),
        0x53: NSLocalizedString("keyboard_hid_0x53_label", comment: ""),
        0x54: NSLocalizedString("keyboard_hid_0x54_label", comment: ""),
        0x55: NSLocalizedString("keyboard_hid_0x55_label", comment: ""),
        0x56: NSLocalizedString("keyboard_hid_0x56_label", comment: ""),
        0x57: NSLocalizedString("keyboard_hid_0x57_label", comment: ""),
        0x58: NSLocalizedString("keyboard_hid_0x58_label", comment: ""),
        0x59: NSLocalizedString("keyboard_hid_0x59_label", comment: ""),
        0x5A: NSLocalizedString("keyboard_hid_0x5A_label", comment: ""),
        0x5B: NSLocalizedString("keyboard_hid_0x5B_label", comment: ""),
        0x5C: NSLocalizedString("keyboard_hid_0x5C_label", comment: ""),
        0x5D: NSLocalizedString("keyboard_hid_0x5D_label", comment: ""),
        0x5E: NSLocalizedString("keyboard_hid_0x5E_label", comment: ""),
        0x5F: NSLocalizedString("keyboard_hid_0x5F_label", comment: ""),
        0x60: NSLocalizedString("keyboard_hid_0x60_label", comment: ""),
        0x61: NSLocalizedString("keyboard_hid_0x61_label", comment: ""),
        0x62: NSLocalizedString("keyboard_hid_0x62_label", comment: ""),
        0x63: NSLocalizedString("keyboard_hid_0x63_label", comment: ""),
        0x64: NSLocalizedString("keyboard_hid_0x64_label", comment: ""),
        0x65: NSLocalizedString("keyboard_hid_0x65_label", comment: ""),
        0x66: NSLocalizedString("keyboard_hid_0x66_label", comment: ""),
        0x67: NSLocalizedString("keyboard_hid_0x67_label", comment: ""),
        0x68: NSLocalizedString("keyboard_hid_0x68_label", comment: ""),
        0x69: NSLocalizedString("keyboard_hid_0x69_label", comment: ""),
        0x6A: NSLocalizedString("keyboard_hid_0x6A_label", comment: ""),
        0x6B: NSLocalizedString("keyboard_hid_0x6B_label", comment: ""),
        0x6C: NSLocalizedString("keyboard_hid_0x6C_label", comment: ""),
        0x6D: NSLocalizedString("keyboard_hid_0x6D_label", comment: ""),
        0x6E: NSLocalizedString("keyboard_hid_0x6E_label", comment: ""),
        0x6F: NSLocalizedString("keyboard_hid_0x6F_label", comment: ""),
        0x70: NSLocalizedString("keyboard_hid_0x70_label", comment: ""),
        0x71: NSLocalizedString("keyboard_hid_0x71_label", comment: ""),
        0x72: NSLocalizedString("keyboard_hid_0x72_label", comment: ""),
        0x73: NSLocalizedString("keyboard_hid_0x73_label", comment: ""),
        0x74: NSLocalizedString("keyboard_hid_0x74_label", comment: ""),
        0x75: NSLocalizedString("keyboard_hid_0x75_label", comment: ""),
        0x76: NSLocalizedString("keyboard_hid_0x76_label", comment: ""),
        0x77: NSLocalizedString("keyboard_hid_0x77_label", comment: ""),
        0x78: NSLocalizedString("keyboard_hid_0x78_label", comment: ""),
        0x79: NSLocalizedString("keyboard_hid_0x79_label", comment: ""),
        0x7A: NSLocalizedString("keyboard_hid_0x7A_label", comment: ""),
        0x7B: NSLocalizedString("keyboard_hid_0x7B_label", comment: ""),
        0x7C: NSLocalizedString("keyboard_hid_0x7C_label", comment: ""),
        0x7D: NSLocalizedString("keyboard_hid_0x7D_label", comment: ""),
        0x7E: NSLocalizedString("keyboard_hid_0x7E_label", comment: ""),
        0x7F: NSLocalizedString("keyboard_hid_0x7F_label", comment: ""),
        0x80: NSLocalizedString("keyboard_hid_0x80_label", comment: ""),
        0x81: NSLocalizedString("keyboard_hid_0x81_label", comment: ""),
        0x82: NSLocalizedString("keyboard_hid_0x82_label", comment: ""),
        0x83: NSLocalizedString("keyboard_hid_0x83_label", comment: ""),
        0x84: NSLocalizedString("keyboard_hid_0x84_label", comment: ""),
        0x85: NSLocalizedString("keyboard_hid_0x85_label", comment: ""),
        0x86: NSLocalizedString("keyboard_hid_0x86_label", comment: ""),
        0x87: NSLocalizedString("keyboard_hid_0x87_label", comment: ""),
        0x88: NSLocalizedString("keyboard_hid_0x88_label", comment: ""),
        0x89: NSLocalizedString("keyboard_hid_0x89_label", comment: ""),
        0x8A: NSLocalizedString("keyboard_hid_0x8A_label", comment: ""),
        0x8B: NSLocalizedString("keyboard_hid_0x8B_label", comment: ""),
        0x8C: NSLocalizedString("keyboard_hid_0x8C_label", comment: ""),
        0x8D: NSLocalizedString("keyboard_hid_0x8D_label", comment: ""),
        0x8E: NSLocalizedString("keyboard_hid_0x8E_label", comment: ""),
        0x8F: NSLocalizedString("keyboard_hid_0x8F_label", comment: ""),
        0x90: NSLocalizedString("keyboard_hid_0x90_label", comment: ""),
        0x91: NSLocalizedString("keyboard_hid_0x91_label", comment: ""),
        0x92: NSLocalizedString("keyboard_hid_0x92_label", comment: ""),
        0x93: NSLocalizedString("keyboard_hid_0x93_label", comment: ""),
        0x94: NSLocalizedString("keyboard_hid_0x94_label", comment: ""),
        0x95: NSLocalizedString("keyboard_hid_0x95_label", comment: ""),
        0x96: NSLocalizedString("keyboard_hid_0x96_label", comment: ""),
        0x97: NSLocalizedString("keyboard_hid_0x97_label", comment: ""),
        0x98: NSLocalizedString("keyboard_hid_0x98_label", comment: ""),
        0x99: NSLocalizedString("keyboard_hid_0x99_label", comment: ""),
        0x9A: NSLocalizedString("keyboard_hid_0x9A_label", comment: ""),
        0x9B: NSLocalizedString("keyboard_hid_0x9B_label", comment: ""),
        0x9C: NSLocalizedString("keyboard_hid_0x9C_label", comment: ""),
        0x9D: NSLocalizedString("keyboard_hid_0x9D_label", comment: ""),
        0x9E: NSLocalizedString("keyboard_hid_0x9E_label", comment: ""),
        0x9F: NSLocalizedString("keyboard_hid_0x9F_label", comment: ""),
        0xA0: NSLocalizedString("keyboard_hid_0xA0_label", comment: ""),
        0xA1: NSLocalizedString("keyboard_hid_0xA1_label", comment: ""),
        0xA2: NSLocalizedString("keyboard_hid_0xA2_label", comment: ""),
        0xA3: NSLocalizedString("keyboard_hid_0xA3_label", comment: ""),
        0xA4: NSLocalizedString("keyboard_hid_0xA4_label", comment: ""),
        0xE0: NSLocalizedString("keyboard_hid_0xE0_label", comment: ""),
        0xE1: NSLocalizedString("keyboard_hid_0xE1_label", comment: ""),
        0xE2: NSLocalizedString("keyboard_hid_0xE2_label", comment: ""),
        0xE3: NSLocalizedString("keyboard_hid_0xE3_label", comment: ""),
        0xE4: NSLocalizedString("keyboard_hid_0xE4_label", comment: ""),
        0xE5: NSLocalizedString("keyboard_hid_0xE5_label", comment: ""),
        0xE6: NSLocalizedString("keyboard_hid_0xE6_label", comment: ""),
        0xE7: NSLocalizedString("keyboard_hid_0xE7_label", comment: "")
    ]
    
    let consumerCodes: KeyValuePairs = [
        0x00: NSLocalizedString("hid_0x00_label", comment: ""),
        0x01: NSLocalizedString("consumer_hid_0x01_label", comment: ""),
        0x02: NSLocalizedString("consumer_hid_0x02_label", comment: ""),
        0x03: NSLocalizedString("consumer_hid_0x03_label", comment: ""),
        0x20: NSLocalizedString("consumer_hid_0x20_label", comment: ""),
        0x21: NSLocalizedString("consumer_hid_0x21_label", comment: ""),
        0x22: NSLocalizedString("consumer_hid_0x22_label", comment: ""),
        0x30: NSLocalizedString("consumer_hid_0x30_label", comment: ""),
        0x31: NSLocalizedString("consumer_hid_0x31_label", comment: ""),
        0x32: NSLocalizedString("consumer_hid_0x32_label", comment: ""),
        0x33: NSLocalizedString("consumer_hid_0x33_label", comment: ""),
        0x34: NSLocalizedString("consumer_hid_0x34_label", comment: ""),
        0x35: NSLocalizedString("consumer_hid_0x35_label", comment: ""),
        0x36: NSLocalizedString("consumer_hid_0x36_label", comment: ""),
        0x40: NSLocalizedString("consumer_hid_0x40_label", comment: ""),
        0x41: NSLocalizedString("consumer_hid_0x41_label", comment: ""),
        0x42: NSLocalizedString("consumer_hid_0x42_label", comment: ""),
        0x43: NSLocalizedString("consumer_hid_0x43_label", comment: ""),
        0x44: NSLocalizedString("consumer_hid_0x44_label", comment: ""),
        0x45: NSLocalizedString("consumer_hid_0x45_label", comment: ""),
        0x46: NSLocalizedString("consumer_hid_0x46_label", comment: ""),
        0x47: NSLocalizedString("consumer_hid_0x47_label", comment: ""),
        0x48: NSLocalizedString("consumer_hid_0x48_label", comment: ""),
        0x60: NSLocalizedString("consumer_hid_0x60_label", comment: ""),
        0x61: NSLocalizedString("consumer_hid_0x61_label", comment: ""),
        0x62: NSLocalizedString("consumer_hid_0x62_label", comment: ""),
        0x63: NSLocalizedString("consumer_hid_0x63_label", comment: ""),
        0x64: NSLocalizedString("consumer_hid_0x64_label", comment: ""),
        0x65: NSLocalizedString("consumer_hid_0x65_label", comment: ""),
        0x66: NSLocalizedString("consumer_hid_0x66_label", comment: ""),
        0x80: NSLocalizedString("consumer_hid_0x80_label", comment: ""),
        0x81: NSLocalizedString("consumer_hid_0x81_label", comment: ""),
        0x82: NSLocalizedString("consumer_hid_0x82_label", comment: ""),
        0x83: NSLocalizedString("consumer_hid_0x83_label", comment: ""),
        0x84: NSLocalizedString("consumer_hid_0x84_label", comment: ""),
        0x85: NSLocalizedString("consumer_hid_0x85_label", comment: ""),
        0x86: NSLocalizedString("consumer_hid_0x86_label", comment: ""),
        0x87: NSLocalizedString("consumer_hid_0x87_label", comment: ""),
        0x88: NSLocalizedString("consumer_hid_0x88_label", comment: ""),
        0x89: NSLocalizedString("consumer_hid_0x89_label", comment: ""),
        0x8A: NSLocalizedString("consumer_hid_0x8A_label", comment: ""),
        0x8B: NSLocalizedString("consumer_hid_0x8B_label", comment: ""),
        0x8C: NSLocalizedString("consumer_hid_0x8C_label", comment: ""),
        0x8D: NSLocalizedString("consumer_hid_0x8D_label", comment: ""),
        0x8E: NSLocalizedString("consumer_hid_0x8E_label", comment: ""),
        0x8F: NSLocalizedString("consumer_hid_0x8F_label", comment: ""),
        0x90: NSLocalizedString("consumer_hid_0x90_label", comment: ""),
        0x91: NSLocalizedString("consumer_hid_0x91_label", comment: ""),
        0x92: NSLocalizedString("consumer_hid_0x92_label", comment: ""),
        0x93: NSLocalizedString("consumer_hid_0x93_label", comment: ""),
        0x94: NSLocalizedString("consumer_hid_0x94_label", comment: ""),
        0x95: NSLocalizedString("consumer_hid_0x95_label", comment: ""),
        0x96: NSLocalizedString("consumer_hid_0x96_label", comment: ""),
        0x97: NSLocalizedString("consumer_hid_0x97_label", comment: ""),
        0x98: NSLocalizedString("consumer_hid_0x98_label", comment: ""),
        0x99: NSLocalizedString("consumer_hid_0x99_label", comment: ""),
        0x9A: NSLocalizedString("consumer_hid_0x9A_label", comment: ""),
        0x9B: NSLocalizedString("consumer_hid_0x9B_label", comment: ""),
        0x9C: NSLocalizedString("consumer_hid_0x9C_label", comment: ""),
        0x9D: NSLocalizedString("consumer_hid_0x9D_label", comment: ""),
        0x9E: NSLocalizedString("consumer_hid_0x9E_label", comment: ""),
        0xA0: NSLocalizedString("consumer_hid_0xA0_label", comment: ""),
        0xA1: NSLocalizedString("consumer_hid_0xA1_label", comment: ""),
        0xA2: NSLocalizedString("consumer_hid_0xA2_label", comment: ""),
        0xA3: NSLocalizedString("consumer_hid_0xA3_label", comment: ""),
        0xA4: NSLocalizedString("consumer_hid_0xA4_label", comment: ""),
        0xB0: NSLocalizedString("consumer_hid_0xB0_label", comment: ""),
        0xB1: NSLocalizedString("consumer_hid_0xB1_label", comment: ""),
        0xB2: NSLocalizedString("consumer_hid_0xB2_label", comment: ""),
        0xB3: NSLocalizedString("consumer_hid_0xB3_label", comment: ""),
        0xB4: NSLocalizedString("consumer_hid_0xB4_label", comment: ""),
        0xB5: NSLocalizedString("consumer_hid_0xB5_label", comment: ""),
        0xB6: NSLocalizedString("consumer_hid_0xB6_label", comment: ""),
        0xB7: NSLocalizedString("consumer_hid_0xB7_label", comment: ""),
        0xB8: NSLocalizedString("consumer_hid_0xB8_label", comment: ""),
        0xB9: NSLocalizedString("consumer_hid_0xB9_label", comment: ""),
        0xBA: NSLocalizedString("consumer_hid_0xBA_label", comment: ""),
        0xBB: NSLocalizedString("consumer_hid_0xBB_label", comment: ""),
        0xBC: NSLocalizedString("consumer_hid_0xBC_label", comment: ""),
        0xBD: NSLocalizedString("consumer_hid_0xBD_label", comment: ""),
        0xBE: NSLocalizedString("consumer_hid_0xBE_label", comment: ""),
        0xBF: NSLocalizedString("consumer_hid_0xBF_label", comment: ""),
        0xC0: NSLocalizedString("consumer_hid_0xC0_label", comment: ""),
        0xC1: NSLocalizedString("consumer_hid_0xC1_label", comment: ""),
        0xC2: NSLocalizedString("consumer_hid_0xC2_label", comment: ""),
        0xC3: NSLocalizedString("consumer_hid_0xC3_label", comment: ""),
        0xC4: NSLocalizedString("consumer_hid_0xC4_label", comment: ""),
        0xC5: NSLocalizedString("consumer_hid_0xC5_label", comment: ""),
        0xC6: NSLocalizedString("consumer_hid_0xC6_label", comment: ""),
        0xC7: NSLocalizedString("consumer_hid_0xC7_label", comment: ""),
        0xC8: NSLocalizedString("consumer_hid_0xC8_label", comment: ""),
        0xC9: NSLocalizedString("consumer_hid_0xC9_label", comment: ""),
        0xCA: NSLocalizedString("consumer_hid_0xCA_label", comment: ""),
        0xCB: NSLocalizedString("consumer_hid_0xCB_label", comment: ""),
        0xE0: NSLocalizedString("consumer_hid_0xE0_label", comment: ""),
        0xE1: NSLocalizedString("consumer_hid_0xE1_label", comment: ""),
        0xE2: NSLocalizedString("consumer_hid_0xE2_label", comment: ""),
        0xE3: NSLocalizedString("consumer_hid_0xE3_label", comment: ""),
        0xE4: NSLocalizedString("consumer_hid_0xE4_label", comment: ""),
        0xE5: NSLocalizedString("consumer_hid_0xE5_label", comment: ""),
        0xE6: NSLocalizedString("consumer_hid_0xE6_label", comment: ""),
        0xE7: NSLocalizedString("consumer_hid_0xE7_label", comment: ""),
        0xE8: NSLocalizedString("consumer_hid_0xE8_label", comment: ""),
        0xE9: NSLocalizedString("consumer_hid_0xE9_label", comment: ""),
        0xEA: NSLocalizedString("consumer_hid_0xEA_label", comment: ""),
        0xF0: NSLocalizedString("consumer_hid_0xF0_label", comment: ""),
        0xF1: NSLocalizedString("consumer_hid_0xF1_label", comment: ""),
        0xF2: NSLocalizedString("consumer_hid_0xF2_label", comment: ""),
        0xF3: NSLocalizedString("consumer_hid_0xF3_label", comment: ""),
        0xF4: NSLocalizedString("consumer_hid_0xF4_label", comment: ""),
        0xF5: NSLocalizedString("consumer_hid_0xF5_label", comment: "")
    ]
    
    func getKeyPosition(action: Int) -> Int{
        var position:Int = 0
        let wlqData = WLQ.shared
        switch (action){
        case wlqData.fullScrollUp:
            if(wlqData.fullScrollUpKeyType == wlqData.KEYBOARD_HID){
                if let index = keyboardCodes.firstIndex(where: { $0.0 == wlqData.fullScrollUpKey! }) {
                    position = index
                }
            } else if(wlqData.fullScrollUpKeyType == wlqData.CONSUMER_HID){
                if let index = consumerCodes.firstIndex(where: { $0.0 == wlqData.fullScrollUpKey! }) {
                    position = index
                }
            }
        case wlqData.fullScrollDown:
            if(wlqData.fullScrollDownKeyType == wlqData.KEYBOARD_HID){
                if let index = keyboardCodes.firstIndex(where: { $0.0 == wlqData.fullScrollDownKey! }) {
                    position = index
                }
            } else if(wlqData.fullScrollDownKeyType == wlqData.CONSUMER_HID){
                if let index = consumerCodes.firstIndex(where: { $0.0 == wlqData.fullScrollDownKey! }) {
                    position = index
                }
            }
        case wlqData.fullToggleRight:
            if(wlqData.fullRightPressKeyType == wlqData.KEYBOARD_HID){
                if let index = keyboardCodes.firstIndex(where: { $0.0 == wlqData.fullRightPressKey! }) {
                    position = index
                }
            } else if(wlqData.fullRightPressKeyType == wlqData.CONSUMER_HID){
                if let index = consumerCodes.firstIndex(where: { $0.0 == wlqData.fullRightPressKey! }) {
                    position = index
                }
            }
        case wlqData.fullToggleRightLongPress:
            if(wlqData.fullRightLongPressKeyType == wlqData.KEYBOARD_HID){
                if let index = keyboardCodes.firstIndex(where: { $0.0 == wlqData.fullRightLongPressKey! }) {
                    position = index
                }
            } else if(wlqData.fullRightLongPressKeyType == wlqData.CONSUMER_HID){
                if let index = consumerCodes.firstIndex(where: { $0.0 == wlqData.fullRightLongPressKey! }) {
                    position = index
                }
            }
        case wlqData.fullToggleLeft:
            if(wlqData.fullLeftPressKeyType == wlqData.KEYBOARD_HID){
                if let index = keyboardCodes.firstIndex(where: { $0.0 == wlqData.fullLeftPressKey! }) {
                    position = index
                }
            } else if(wlqData.fullLeftPressKeyType == wlqData.CONSUMER_HID){
                if let index = consumerCodes.firstIndex(where: { $0.0 == wlqData.fullLeftPressKey! }) {
                    position = index
                }
            }
        case wlqData.fullToggleLeftLongPress:
            if(wlqData.fullLeftLongPressKeyType == wlqData.KEYBOARD_HID){
                if let index = keyboardCodes.firstIndex(where: { $0.0 == wlqData.fullLeftLongPressKey! }) {
                    position = index
                }
            } else if(wlqData.fullLeftLongPressKeyType == wlqData.CONSUMER_HID){
                if let index = consumerCodes.firstIndex(where: { $0.0 == wlqData.fullLeftLongPressKey! }) {
                    position = index
                }
            }
        case wlqData.fullSignalCancel:
            if(wlqData.fullSignalPressKeyType == wlqData.KEYBOARD_HID){
                if let index = keyboardCodes.firstIndex(where: { $0.0 == wlqData.fullSignalPressKey! }) {
                    position = index
                }
            } else if(wlqData.fullSignalPressKeyType == wlqData.CONSUMER_HID){
                if let index = consumerCodes.firstIndex(where: { $0.0 == wlqData.fullSignalPressKey! }) {
                    position = index
                }
            }
        case wlqData.fullSignalCancelLongPress:
            if(wlqData.fullSignalLongPressKeyType == wlqData.KEYBOARD_HID){
                if let index = keyboardCodes.firstIndex(where: { $0.0 == wlqData.fullSignalLongPressKey! }) {
                    position = index
                }
            } else if(wlqData.fullSignalLongPressKeyType == wlqData.CONSUMER_HID){
                if let index = consumerCodes.firstIndex(where: { $0.0 == wlqData.fullSignalLongPressKey! }) {
                    position = index
                }
            }
        case wlqData.RTKPage:
            if(wlqData.RTKPagePressKeyType == wlqData.KEYBOARD_HID){
                if let index = keyboardCodes.firstIndex(where: { $0.0 == wlqData.RTKPagePressKey! }) {
                    position = index
                }
            } else if(wlqData.RTKPagePressKeyType == wlqData.CONSUMER_HID){
                if let index = consumerCodes.firstIndex(where: { $0.0 == wlqData.RTKPagePressKey! }) {
                    position = index
                }
            }
        case wlqData.RTKPageDoublePress:
            if(wlqData.RTKPageDoublePressKeyType == wlqData.KEYBOARD_HID){
                if let index = keyboardCodes.firstIndex(where: { $0.0 == wlqData.RTKPageDoublePressKey! }) {
                    position = index
                }
            } else if(wlqData.RTKPageDoublePressKeyType == wlqData.CONSUMER_HID){
                if let index = consumerCodes.firstIndex(where: { $0.0 == wlqData.RTKPageDoublePressKey! }) {
                    position = index
                }
            }
        case wlqData.RTKZoomPlus:
            if(wlqData.RTKZoomPPressKeyType == wlqData.KEYBOARD_HID){
                if let index = keyboardCodes.firstIndex(where: { $0.0 == wlqData.RTKZoomPPressKey! }) {
                    position = index
                }
            } else if(wlqData.RTKZoomPPressKeyType == wlqData.CONSUMER_HID){
                if let index = consumerCodes.firstIndex(where: { $0.0 == wlqData.RTKZoomPPressKey! }) {
                    position = index
                }
            }
        case wlqData.RTKZoomPlusDoublePress:
            if(wlqData.RTKZoomPDoublePressKeyType == wlqData.KEYBOARD_HID){
                if let index = keyboardCodes.firstIndex(where: { $0.0 == wlqData.RTKZoomPDoublePressKey! }) {
                    position = index
                }
            } else if(wlqData.RTKZoomPDoublePressKeyType == wlqData.CONSUMER_HID){
                if let index = consumerCodes.firstIndex(where: { $0.0 == wlqData.RTKZoomPDoublePressKey! }) {
                    position = index
                }
            }
        case wlqData.RTKZoomMinus:
            if(wlqData.RTKZoomMPressKeyType == wlqData.KEYBOARD_HID){
                if let index = keyboardCodes.firstIndex(where: { $0.0 == wlqData.RTKZoomMPressKey! }) {
                    position = index
                }
            } else if(wlqData.RTKZoomMPressKeyType == wlqData.CONSUMER_HID){
                if let index = consumerCodes.firstIndex(where: { $0.0 == wlqData.RTKZoomMPressKey! }) {
                    position = index
                }
            }
        case wlqData.RTKZoomMinusDoublePress:
            if(wlqData.RTKZoomMDoublePressKeyType == wlqData.KEYBOARD_HID){
                if let index = keyboardCodes.firstIndex(where: { $0.0 == wlqData.RTKZoomMDoublePressKey! }) {
                    position = index
                }
            } else if(wlqData.RTKZoomMDoublePressKeyType == wlqData.CONSUMER_HID){
                if let index = consumerCodes.firstIndex(where: { $0.0 == wlqData.RTKZoomMDoublePressKey! }) {
                    position = index
                }
            }
        case wlqData.RTKSpeak:
            if(wlqData.RTKSpeakPressKeyType == wlqData.KEYBOARD_HID){
                if let index = keyboardCodes.firstIndex(where: { $0.0 == wlqData.RTKSpeakPressKey! }) {
                    position = index
                }
            } else if(wlqData.RTKSpeakPressKeyType == wlqData.CONSUMER_HID){
                if let index = consumerCodes.firstIndex(where: { $0.0 == wlqData.RTKSpeakPressKey! }) {
                    position = index
                }
            }
        case wlqData.RTKSpeakDoublePress:
            if(wlqData.RTKSpeakDoublePressKeyType == wlqData.KEYBOARD_HID){
                if let index = keyboardCodes.firstIndex(where: { $0.0 == wlqData.RTKSpeakDoublePressKey! }) {
                    position = index
                }
            } else if(wlqData.RTKSpeakDoublePressKeyType == wlqData.CONSUMER_HID){
                if let index = consumerCodes.firstIndex(where: { $0.0 == wlqData.RTKSpeakDoublePressKey! }) {
                    position = index
                }
            }
        case wlqData.RTKMute:
            if(wlqData.RTKMutePressKeyType == wlqData.KEYBOARD_HID){
                if let index = keyboardCodes.firstIndex(where: { $0.0 == wlqData.RTKMutePressKey! }) {
                    position = index
                }
            } else if(wlqData.RTKMutePressKeyType == wlqData.CONSUMER_HID){
                if let index = consumerCodes.firstIndex(where: { $0.0 == wlqData.RTKMutePressKey! }) {
                    position = index
                }
            }
        case wlqData.RTKMuteDoublePress:
            if(wlqData.RTKMuteDoublePressKeyType == wlqData.KEYBOARD_HID){
                if let index = keyboardCodes.firstIndex(where: { $0.0 == wlqData.RTKMuteDoublePressKey! }) {
                    position = index
                }
            } else if(wlqData.RTKMuteDoublePressKeyType == wlqData.CONSUMER_HID){
                if let index = consumerCodes.firstIndex(where: { $0.0 == wlqData.RTKMuteDoublePressKey! }) {
                    position = index
                }
            }
        case wlqData.RTKDisplayOff:
            if(wlqData.RTKDisplayPressKeyType == wlqData.KEYBOARD_HID){
                if let index = keyboardCodes.firstIndex(where: { $0.0 == wlqData.RTKDisplayPressKey! }) {
                    position = index
                }
            } else if(wlqData.RTKDisplayPressKeyType == wlqData.CONSUMER_HID){
                if let index = consumerCodes.firstIndex(where: { $0.0 == wlqData.RTKDisplayPressKey! }) {
                    position = index
                }
            }
        case wlqData.RTKDisplayOffDoublePress:
            if(wlqData.RTKDisplayDoublePressKeyType == wlqData.KEYBOARD_HID){
                if let index = keyboardCodes.firstIndex(where: { $0.0 == wlqData.RTKDisplayDoublePressKey! }) {
                    position = index
                }
            } else if(wlqData.RTKDisplayDoublePressKeyType == wlqData.CONSUMER_HID){
                if let index = consumerCodes.firstIndex(where: { $0.0 == wlqData.RTKDisplayDoublePressKey! }) {
                    position = index
                }
            }
        default:
            position = 0
        }
        return position
    }
    
    func getKey(action: Int) -> String{
        var returnString = NSLocalizedString("hid_0x00_label", comment: "")
        let wlqData = WLQ.shared
        switch (action){
        case wlqData.fullScrollUp:
            if(wlqData.fullScrollUpKeyType == wlqData.KEYBOARD_HID){
                if let index = keyboardCodes.firstIndex(where: { $0.0 == wlqData.fullScrollUpKey! }) {
                    let name = keyboardCodes[index].1
                    returnString = name
                }
            } else if(wlqData.fullScrollUpKeyType == wlqData.CONSUMER_HID){
                if let index = consumerCodes.firstIndex(where: { $0.0 == wlqData.fullScrollUpKey! }) {
                    let name = consumerCodes[index].1
                    returnString = name
                }
            }
        case wlqData.fullScrollDown:
            if(wlqData.fullScrollDownKeyType == wlqData.KEYBOARD_HID){
                if let index = keyboardCodes.firstIndex(where: { $0.0 == wlqData.fullScrollDownKey! }) {
                    let name = keyboardCodes[index].1
                    returnString = name
                }
            } else if(wlqData.fullScrollDownKeyType == wlqData.CONSUMER_HID){
                if let index = consumerCodes.firstIndex(where: { $0.0 == wlqData.fullScrollDownKey! }) {
                    let name = consumerCodes[index].1
                    returnString = name
                }
            }
        case wlqData.fullToggleRight:
            if(wlqData.fullRightPressKeyType == wlqData.KEYBOARD_HID){
                if let index = keyboardCodes.firstIndex(where: { $0.0 == wlqData.fullRightPressKey! }) {
                    let name = keyboardCodes[index].1
                    returnString = name
                }
            } else if(wlqData.fullRightPressKeyType == wlqData.CONSUMER_HID){
                if let index = consumerCodes.firstIndex(where: { $0.0 == wlqData.fullRightPressKey! }) {
                    let name = consumerCodes[index].1
                    returnString = name
                }
            }
        case wlqData.fullToggleRightLongPress:
            if(wlqData.fullRightLongPressKeyType == wlqData.KEYBOARD_HID){
                if let index = keyboardCodes.firstIndex(where: { $0.0 == wlqData.fullRightLongPressKey! }) {
                    let name = keyboardCodes[index].1
                    returnString = name
                }
            } else if(wlqData.fullRightLongPressKeyType == wlqData.CONSUMER_HID){
                if let index = consumerCodes.firstIndex(where: { $0.0 == wlqData.fullRightLongPressKey! }) {
                    let name = consumerCodes[index].1
                    returnString = name
                }
            }
        case wlqData.fullToggleLeft:
            if(wlqData.fullLeftPressKeyType == wlqData.KEYBOARD_HID){
                if let index = keyboardCodes.firstIndex(where: { $0.0 == wlqData.fullLeftPressKey! }) {
                    let name = keyboardCodes[index].1
                    returnString = name
                }
            } else if(wlqData.fullLeftPressKeyType == wlqData.CONSUMER_HID){
                if let index = consumerCodes.firstIndex(where: { $0.0 == wlqData.fullLeftPressKey! }) {
                    let name = consumerCodes[index].1
                    returnString = name
                }
            }
        case wlqData.fullToggleLeftLongPress:
            if(wlqData.fullLeftLongPressKeyType == wlqData.KEYBOARD_HID){
                if let index = keyboardCodes.firstIndex(where: { $0.0 == wlqData.fullLeftLongPressKey! }) {
                    let name = keyboardCodes[index].1
                    returnString = name
                }
            } else if(wlqData.fullLeftLongPressKeyType == wlqData.CONSUMER_HID){
                if let index = consumerCodes.firstIndex(where: { $0.0 == wlqData.fullLeftLongPressKey! }) {
                    let name = consumerCodes[index].1
                    returnString = name
                }
            }
        case wlqData.fullSignalCancel:
            if(wlqData.fullSignalPressKeyType == wlqData.KEYBOARD_HID){
                if let index = keyboardCodes.firstIndex(where: { $0.0 == wlqData.fullSignalPressKey! }) {
                    let name = keyboardCodes[index].1
                    returnString = name
                }
            } else if(wlqData.fullSignalPressKeyType == wlqData.CONSUMER_HID){
                if let index = consumerCodes.firstIndex(where: { $0.0 == wlqData.fullSignalPressKey! }) {
                    let name = consumerCodes[index].1
                    returnString = name
                }
            }
        case wlqData.fullSignalCancelLongPress:
            if(wlqData.fullSignalLongPressKeyType == wlqData.KEYBOARD_HID){
                if let index = keyboardCodes.firstIndex(where: { $0.0 == wlqData.fullSignalLongPressKey! }) {
                    let name = keyboardCodes[index].1
                    returnString = name
                }
            } else if(wlqData.fullSignalLongPressKeyType == wlqData.CONSUMER_HID){
                if let index = consumerCodes.firstIndex(where: { $0.0 == wlqData.fullSignalLongPressKey! }) {
                    let name = consumerCodes[index].1
                    returnString = name
                }
            }
        case wlqData.RTKPage:
            if(wlqData.RTKPagePressKeyType == wlqData.KEYBOARD_HID){
                if let index = keyboardCodes.firstIndex(where: { $0.0 == wlqData.RTKPagePressKey! }) {
                    let name = keyboardCodes[index].1
                    returnString = name
                }
            } else if(wlqData.RTKPagePressKeyType == wlqData.CONSUMER_HID){
                if let index = consumerCodes.firstIndex(where: { $0.0 == wlqData.RTKPagePressKey! }) {
                    let name = consumerCodes[index].1
                    returnString = name
                }
            }
        case wlqData.RTKPageDoublePress:
            if(wlqData.RTKPageDoublePressKeyType == wlqData.KEYBOARD_HID){
                if let index = keyboardCodes.firstIndex(where: { $0.0 == wlqData.RTKPageDoublePressKey! }) {
                    let name = keyboardCodes[index].1
                    returnString = name
                }
            } else if(wlqData.RTKPageDoublePressKeyType == wlqData.CONSUMER_HID){
                if let index = consumerCodes.firstIndex(where: { $0.0 == wlqData.RTKPageDoublePressKey! }) {
                    let name = consumerCodes[index].1
                    returnString = name
                }
            }
        case wlqData.RTKZoomPlus:
            if(wlqData.RTKZoomPPressKeyType == wlqData.KEYBOARD_HID){
                if let index = keyboardCodes.firstIndex(where: { $0.0 == wlqData.RTKZoomPPressKey! }) {
                    let name = keyboardCodes[index].1
                    returnString = name
                }
            } else if(wlqData.RTKZoomPPressKeyType == wlqData.CONSUMER_HID){
                if let index = consumerCodes.firstIndex(where: { $0.0 == wlqData.RTKZoomPPressKey! }) {
                    let name = consumerCodes[index].1
                    returnString = name
                }
            }
        case wlqData.RTKZoomPlusDoublePress:
            if(wlqData.RTKZoomPDoublePressKeyType == wlqData.KEYBOARD_HID){
                if let index = keyboardCodes.firstIndex(where: { $0.0 == wlqData.RTKZoomPDoublePressKey! }) {
                    let name = keyboardCodes[index].1
                    returnString = name
                }
            } else if(wlqData.RTKZoomPDoublePressKeyType == wlqData.CONSUMER_HID){
                if let index = consumerCodes.firstIndex(where: { $0.0 == wlqData.RTKZoomPDoublePressKey! }) {
                    let name = consumerCodes[index].1
                    returnString = name
                }
            }
        case wlqData.RTKZoomMinus:
            if(wlqData.RTKZoomMPressKeyType == wlqData.KEYBOARD_HID){
                if let index = keyboardCodes.firstIndex(where: { $0.0 == wlqData.RTKZoomMPressKey! }) {
                    let name = keyboardCodes[index].1
                    returnString = name
                }
            } else if(wlqData.RTKZoomMPressKeyType == wlqData.CONSUMER_HID){
                if let index = consumerCodes.firstIndex(where: { $0.0 == wlqData.RTKZoomMPressKey! }) {
                    let name = consumerCodes[index].1
                    returnString = name
                }
            }
        case wlqData.RTKZoomMinusDoublePress:
            if(wlqData.RTKZoomMDoublePressKeyType == wlqData.KEYBOARD_HID){
                if let index = keyboardCodes.firstIndex(where: { $0.0 == wlqData.RTKZoomMDoublePressKey! }) {
                    let name = keyboardCodes[index].1
                    returnString = name
                }
            } else if(wlqData.RTKZoomMDoublePressKeyType == wlqData.CONSUMER_HID){
                if let index = consumerCodes.firstIndex(where: { $0.0 == wlqData.RTKZoomMDoublePressKey! }) {
                    let name = consumerCodes[index].1
                    returnString = name
                }
            }
        case wlqData.RTKSpeak:
            if(wlqData.RTKSpeakPressKeyType == wlqData.KEYBOARD_HID){
                if let index = keyboardCodes.firstIndex(where: { $0.0 == wlqData.RTKSpeakPressKey! }) {
                    let name = keyboardCodes[index].1
                    returnString = name
                }
            } else if(wlqData.RTKSpeakPressKeyType == wlqData.CONSUMER_HID){
                if let index = consumerCodes.firstIndex(where: { $0.0 == wlqData.RTKSpeakPressKey! }) {
                    let name = consumerCodes[index].1
                    returnString = name
                }
            }
        case wlqData.RTKSpeakDoublePress:
            if(wlqData.RTKSpeakDoublePressKeyType == wlqData.KEYBOARD_HID){
                if let index = keyboardCodes.firstIndex(where: { $0.0 == wlqData.RTKSpeakDoublePressKey! }) {
                    let name = keyboardCodes[index].1
                    returnString = name
                }
            } else if(wlqData.RTKSpeakDoublePressKeyType == wlqData.CONSUMER_HID){
                if let index = consumerCodes.firstIndex(where: { $0.0 == wlqData.RTKSpeakDoublePressKey! }) {
                    let name = consumerCodes[index].1
                    returnString = name
                }
            }
        case wlqData.RTKMute:
            if(wlqData.RTKMutePressKeyType == wlqData.KEYBOARD_HID){
                if let index = keyboardCodes.firstIndex(where: { $0.0 == wlqData.RTKMutePressKey! }) {
                    let name = keyboardCodes[index].1
                    returnString = name
                }
            } else if(wlqData.RTKMutePressKeyType == wlqData.CONSUMER_HID){
                if let index = consumerCodes.firstIndex(where: { $0.0 == wlqData.RTKMutePressKey! }) {
                    let name = consumerCodes[index].1
                    returnString = name
                }
            }
        case wlqData.RTKMuteDoublePress:
            if(wlqData.RTKMuteDoublePressKeyType == wlqData.KEYBOARD_HID){
                if let index = keyboardCodes.firstIndex(where: { $0.0 == wlqData.RTKMuteDoublePressKey! }) {
                    let name = keyboardCodes[index].1
                    returnString = name
                }
            } else if(wlqData.RTKMuteDoublePressKeyType == wlqData.CONSUMER_HID){
                if let index = consumerCodes.firstIndex(where: { $0.0 == wlqData.RTKMuteDoublePressKey! }) {
                    let name = consumerCodes[index].1
                    returnString = name
                }
            }
        case wlqData.RTKDisplayOff:
            if(wlqData.RTKDisplayPressKeyType == wlqData.KEYBOARD_HID){
                if let index = keyboardCodes.firstIndex(where: { $0.0 == wlqData.RTKDisplayPressKey! }) {
                    let name = keyboardCodes[index].1
                    returnString = name
                }
            } else if(wlqData.RTKDisplayPressKeyType == wlqData.CONSUMER_HID){
                if let index = consumerCodes.firstIndex(where: { $0.0 == wlqData.RTKDisplayPressKey! }) {
                    let name = consumerCodes[index].1
                    returnString = name
                }
            }
        case wlqData.RTKDisplayOffDoublePress:
            if(wlqData.RTKDisplayDoublePressKeyType == wlqData.KEYBOARD_HID){
                if let index = keyboardCodes.firstIndex(where: { $0.0 == wlqData.RTKDisplayDoublePressKey! }) {
                    let name = keyboardCodes[index].1
                    returnString = name
                }
            } else if(wlqData.RTKDisplayDoublePressKeyType == wlqData.CONSUMER_HID){
                if let index = consumerCodes.firstIndex(where: { $0.0 == wlqData.RTKDisplayDoublePressKey! }) {
                    let name = consumerCodes[index].1
                    returnString = name
                }
            }
        default:
            returnString = "Unknown Action Number: \(action)"
        }
        return returnString
    }
    
    func getModifiers(action: Int) -> UInt8{
        var modifiers:UInt8 = 0x00
        let wlqData = WLQ.shared
        switch (action){
        case wlqData.fullScrollUp:
            modifiers = wlqData.fullScrollUpKeyModifier!
        case wlqData.fullScrollDown:
            modifiers = wlqData.fullScrollDownKeyModifier!
        case wlqData.fullToggleRight:
            modifiers = wlqData.fullRightPressKeyModifier!
        case wlqData.fullToggleRightLongPress:
            modifiers = wlqData.fullRightLongPressKeyModifier!
        case wlqData.fullToggleLeft:
            modifiers = wlqData.fullLeftPressKeyModifier!
        case wlqData.fullToggleLeftLongPress:
            modifiers = wlqData.fullLeftLongPressKeyModifier!
        case wlqData.fullSignalCancel:
            modifiers = wlqData.fullSignalPressKeyModifier!
        case wlqData.fullSignalCancelLongPress:
            modifiers = wlqData.fullSignalLongPressKeyModifier!
        case wlqData.RTKPage:
            modifiers = wlqData.RTKPagePressKeyModifier!
        case wlqData.RTKPageDoublePress:
            modifiers = wlqData.RTKPageDoublePressKeyModifier!
        case wlqData.RTKZoomPlus:
            modifiers = wlqData.RTKZoomPPressKeyModifier!
        case wlqData.RTKZoomPlusDoublePress:
            modifiers = wlqData.RTKZoomPDoublePressKeyModifier!
        case wlqData.RTKZoomMinus:
            modifiers = wlqData.RTKZoomMPressKeyModifier!
        case wlqData.RTKZoomMinusDoublePress:
            modifiers = wlqData.RTKZoomMDoublePressKeyModifier!
        case wlqData.RTKSpeak:
            modifiers = wlqData.RTKSpeakPressKeyModifier!
        case wlqData.RTKSpeakDoublePress:
            modifiers = wlqData.RTKSpeakDoublePressKeyModifier!
        case wlqData.RTKMute:
            modifiers = wlqData.RTKMutePressKeyModifier!
        case wlqData.RTKMuteDoublePress:
            modifiers = wlqData.RTKMuteDoublePressKeyModifier!
        case wlqData.RTKDisplayOff:
            modifiers = wlqData.RTKDisplayPressKeyModifier!
        case wlqData.RTKDisplayOffDoublePress:
            modifiers = wlqData.RTKDisplayDoublePressKeyModifier!
        default:
            modifiers = 0x00
        }
        return modifiers
    }
}
