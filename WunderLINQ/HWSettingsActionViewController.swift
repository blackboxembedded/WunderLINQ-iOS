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

import UIKit
import UIMultiPicker
import CoreBluetooth
import os.log

class HWSettingsActionViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var actionLabel: UILabel!
    @IBOutlet weak var typePicker: UIPickerView!
    @IBOutlet weak var keyPicker: UIPickerView!
    @IBOutlet weak var modifierMultiPicker: UIMultiPicker!
    @IBOutlet weak var saveButton: LocalisableButton!
    @IBOutlet weak var cancelButton: LocalisableButton!
    
    let keyboardHID = KeyboardHID.shared
    let wlqData = WLQ.shared
    let bleData = BLE.shared

    var actionID: Int?
    
    var modePickerData = [NSLocalizedString("hid_0x00_label", comment: ""),
                          NSLocalizedString("hid_keyboard_label", comment: ""),
                          NSLocalizedString("hid_consumer_label", comment: "")]
    
    var modePickerDataHW1 = [NSLocalizedString("hid_0x00_label", comment: ""),
                          NSLocalizedString("hid_keyboard_label", comment: "")]
    
    var keymodesPickerData = [NSLocalizedString("keymode_default_label", comment: ""),
                          NSLocalizedString("keymode_custom_label", comment: ""),
                          NSLocalizedString("keymode_media_label", comment: ""),
                          NSLocalizedString("keymode_dmd2_label", comment: "")]
    
    var usbPickerData = [NSLocalizedString("usbcontrol_on_label", comment: ""),
                          NSLocalizedString("usbcontrol_engine_label", comment: ""),
                          NSLocalizedString("usbcontrol_off_label", comment: "")]
    

    @IBAction func savePressed(_ sender: Any) {
        if(actionID == WLQ_N_DEFINES.KEYMODE || actionID == WLQ_X_DEFINES.KEYMODE || actionID == WLQ_S_DEFINES.KEYMODE){ // Mode
            if (wlqData.getKeyMode() != self.typePicker.selectedRow(inComponent: 0)){
                setHWMode(mode: UInt8(self.typePicker.selectedRow(inComponent: 0)))
            }
        } else if(actionID == WLQ_N_DEFINES.USB){ // USB
            if ((self.typePicker.selectedRow(inComponent: 0) == 0) && (wlqData.getVINThreshold() != 0x0000)){
                wlqData.setVINThreshold(value: [0x00,0x00])
            } else if ((self.typePicker.selectedRow(inComponent: 0) == 1) && (wlqData.getVINThreshold() != 0x02BC)){
                wlqData.setVINThreshold(value: [0x02,0xBC])
            } else if ((self.typePicker.selectedRow(inComponent: 0) == 2) && (wlqData.getVINThreshold() != 0xFFFF)){
                wlqData.setVINThreshold(value: [0xFF,0xFF])
            }
        } else if(actionID == WLQ_N_DEFINES.RTKDoublePressSensitivity || actionID == WLQ_X_DEFINES.RTKDoublePressSensitivity){ // RTK Sensititvity
            wlqData.setDoublePressSensitivity(value: (UInt8)(self.typePicker.selectedRow(inComponent: 0) + 1))
        } else if(actionID == WLQ_N_DEFINES.fullLongPressSensitivity || actionID == WLQ_X_DEFINES.fullLongPressSensitivity){ // Full Sensititvity
            wlqData.setLongPressSensitivity(value: (UInt8)(self.typePicker.selectedRow(inComponent: 0) + 1))
        } else {    //  Key
            let keyType:UInt8 = (UInt8)(self.typePicker.selectedRow(inComponent: 0))
            var key:UInt8 = 0x00
            var modifiers:UInt8 = 0x00
            if (keyType == wlqData.KEYBOARD_HID()){
                key = UInt8(keyboardHID.keyboardCodes[self.keyPicker.selectedRow(inComponent: 0)].key)
                let selected = modifierMultiPicker.selectedIndexes
                for modifier in selected {
                    if(modifier == 0){
                        modifiers = modifiers + 0x01
                    } else if(modifier == 1){
                        modifiers = modifiers + 0x02
                    } else if(modifier == 2){
                        modifiers = modifiers + 0x04
                    } else if(modifier == 3){
                        modifiers = modifiers + 0x08
                    } else if(modifier == 4){
                        modifiers = modifiers + 0x10
                    } else if(modifier == 5){
                        modifiers = modifiers + 0x20
                    } else if(modifier == 6){
                        modifiers = modifiers + 0x40
                    } else if(modifier == 7){
                        modifiers = modifiers + 0x80
                    }
                }
            } else if (keyType == wlqData.CONSUMER_HID()){
                key = UInt8(keyboardHID.keyboardCodes[self.keyPicker.selectedRow(inComponent: 0)].key)
            }
            wlqData.setActionKey(action: actionID, key: [keyType, modifiers, key])
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @objc func leftScreen() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func setup(with actionID: Int) {
        self.actionID = actionID
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let backBtn = UIButton()
        backBtn.setImage(UIImage(named: "Left")?.withRenderingMode(.alwaysTemplate), for: .normal)
        backBtn.tintColor = UIColor(named: "imageTint")
        backBtn.addTarget(self, action: #selector(leftScreen), for: .touchUpInside)
        let backButton = UIBarButtonItem(customView: backBtn)
        let backButtonWidth = backButton.customView?.widthAnchor.constraint(equalToConstant: 30)
        backButtonWidth?.isActive = true
        let backButtonHeight = backButton.customView?.heightAnchor.constraint(equalToConstant: 30)
        backButtonHeight?.isActive = true
        self.navigationItem.title = wlqData.getActionName(action: actionID!)
        self.navigationItem.leftBarButtonItems = [backButton]
        
        actionLabel.text = wlqData.getActionName(action: actionID!)
        
        // Connect data
        typePicker.tag = 1
        keyPicker.tag = 2;
        typePicker.delegate = self
        typePicker.dataSource = self
        keyPicker.delegate = self
        keyPicker.dataSource = self
        
        if(actionID == WLQ_N_DEFINES.KEYMODE || actionID == WLQ_X_DEFINES.KEYMODE || actionID == WLQ_S_DEFINES.KEYMODE){ // KEYMODE
            typePicker.selectRow(Int(wlqData.getKeyMode()), inComponent: 0, animated: true)
            keyPicker.isHidden = true
            modifierMultiPicker.isHidden = true
        } else if(actionID == WLQ_N_DEFINES.USB){ // USB
            if (wlqData.getVINThreshold() == 0x0000){
                typePicker.selectRow(0, inComponent: 0, animated: true)
            } else if (wlqData.getVINThreshold() == 0xFFFF){
                typePicker.selectRow(2, inComponent: 0, animated: true)
            } else {
                typePicker.selectRow(1, inComponent: 0, animated: true)
            }
            keyPicker.isHidden = true
            modifierMultiPicker.isHidden = true
        } else if(actionID == WLQ_N_DEFINES.RTKDoublePressSensitivity || actionID == WLQ_X_DEFINES.RTKDoublePressSensitivity){ // RTK Sensititvity
            typePicker.selectRow((Int)(wlqData.getDoublePressSensitivity()) - 1, inComponent: 0, animated: true)
            keyPicker.isHidden = true
            modifierMultiPicker.isHidden = true
        } else if(actionID == WLQ_N_DEFINES.fullLongPressSensitivity || actionID == WLQ_X_DEFINES.fullLongPressSensitivity){ // Full Sensititvity
            typePicker.selectRow((Int)(wlqData.getLongPressSensitivity()) - 1, inComponent: 0, animated: true)
            keyPicker.isHidden = true
            modifierMultiPicker.isHidden = true
        } else {                // Key Action
            modifierMultiPicker.options = keyboardHID.modifierCodes
            modifierMultiPicker.color = .gray
            modifierMultiPicker.tintColor = .black
            modifierMultiPicker.font = .systemFont(ofSize: 20, weight: .bold)
            modifierMultiPicker.addTarget(self, action: #selector(self.selected(_:)), for: .valueChanged)
            
            let keyMode = (Int)(wlqData.getActionKeyType(action: actionID))
            typePicker.selectRow(keyMode, inComponent: 0, animated: true)
            keyPicker.selectRow(wlqData.getActionKeyPosition(action: actionID!), inComponent: 0, animated: true)
            
            if (keyMode == wlqData.UNDEFINED()){
                keyPicker.isHidden = true
                modifierMultiPicker.isHidden = true
            } else if (keyMode == wlqData.KEYBOARD_HID()){
                keyPicker.isHidden = false
                modifierMultiPicker.isHidden = false
                let mask = wlqData.getActionKeyModifiers(action: actionID!)
                var selectedModifiers:[Int] = []
                if (mask != 0x00) {
                    if (isSet(value: mask, bit: 0x01)) {
                        selectedModifiers.append(0)
                    }
                    if (isSet(value: mask, bit: 0x02)) {
                        selectedModifiers.append(1)
                    }
                    if (isSet(value: mask, bit: 0x04)) {
                        selectedModifiers.append(2)
                    }
                    if (isSet(value: mask, bit: 0x08)) {
                        selectedModifiers.append(3)
                    }
                    if (isSet(value: mask, bit: 0x10)) {
                        selectedModifiers.append(4)
                    }
                    if (isSet(value: mask, bit: 0x20)) {
                        selectedModifiers.append(5)
                    }
                    if (isSet(value: mask, bit: 0x40)) {
                        selectedModifiers.append(6)
                    }
                    if (isSet(value: mask, bit: 0x80)) {
                        selectedModifiers.append(7)
                    }
                    modifierMultiPicker.selectedIndexes = selectedModifiers
                }
            } else if (keyMode == wlqData.CONSUMER_HID()){
                keyPicker.isHidden = false
                modifierMultiPicker.isHidden = true
            }
        }
    }
    
    @objc func selected(_ sender: UIMultiPicker) {
        saveButton.isHidden = false
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == typePicker {
            if(actionID == WLQ_N_DEFINES.KEYMODE || actionID == WLQ_X_DEFINES.KEYMODE || actionID == WLQ_S_DEFINES.KEYMODE){ // KEYMODE
                return keymodesPickerData.count
            } else if(actionID == WLQ_N_DEFINES.USB){ // USB
                return usbPickerData.count
            } else if(actionID == WLQ_N_DEFINES.RTKDoublePressSensitivity || actionID == WLQ_X_DEFINES.RTKDoublePressSensitivity){ // RTK Sensititvity
                return 20
            } else if(actionID == WLQ_N_DEFINES.fullLongPressSensitivity || actionID == WLQ_X_DEFINES.fullLongPressSensitivity){ // Full Sensititvity
                return 30
            } else {
                if (wlqData.gethardwareVersion() == WLQ_N_DEFINES.hardwareVersion1){
                    return modePickerDataHW1.count
                } else {
                    return modePickerData.count
                }
            }
        } else if pickerView == keyPicker{
            if (typePicker.selectedRow(inComponent: 0) == 0){
                return 1
            } else if (typePicker.selectedRow(inComponent: 0) == 1){
                return keyboardHID.keyboardCodes.count
            } else if (typePicker.selectedRow(inComponent: 0) == 2){
                return keyboardHID.consumerCodes.count
            }
        }
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (pickerView == typePicker) {
            if(actionID == WLQ_N_DEFINES.KEYMODE || actionID == WLQ_X_DEFINES.KEYMODE || actionID == WLQ_S_DEFINES.KEYMODE){ // KEYMODE
                return keymodesPickerData[row]
            } else if(actionID == WLQ_N_DEFINES.USB){ // USB
                return usbPickerData[row]
            } else if(actionID == WLQ_N_DEFINES.RTKDoublePressSensitivity || actionID == WLQ_X_DEFINES.RTKDoublePressSensitivity){ // RTK Sensititvity
                return "\((row + 1) * 50)"
            } else if(actionID == WLQ_N_DEFINES.fullLongPressSensitivity || actionID == WLQ_X_DEFINES.fullLongPressSensitivity){ // Full Sensititvity
                return "\((row + 1) * 50)"
            } else {
                if (wlqData.gethardwareVersion() == WLQ_N_DEFINES.hardwareVersion1){
                    return modePickerDataHW1[row]
                } else {
                    return modePickerData[row]
                }
                
            }
        } else if (pickerView == keyPicker){
            if (typePicker.selectedRow(inComponent: 0) == 0){
                return ""
            } else if (typePicker.selectedRow(inComponent: 0) == 1){
                return Array(keyboardHID.keyboardCodes)[row].value
            } else if (typePicker.selectedRow(inComponent: 0) == 2){
                return Array(keyboardHID.consumerCodes)[row].value
            }
        }
        return ""
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == typePicker {
            if (actionID == WLQ_N_DEFINES.KEYMODE || actionID == WLQ_X_DEFINES.KEYMODE || actionID == WLQ_S_DEFINES.KEYMODE){ // KEYMODE
                if (wlqData.getKeyMode() != row) {
                    saveButton.isHidden = false
                } else {
                    saveButton.isHidden = true
                }
            } else if (actionID == WLQ_N_DEFINES.USB){ // USB
                if (wlqData.getVINThreshold() == 0x0000 && row == 0){
                    saveButton.isHidden = true
                } else if (wlqData.getVINThreshold() == 0xFFFF && row == 2){
                    saveButton.isHidden = true
                } else if (wlqData.getVINThreshold() != 0x0000 && wlqData.getVINThreshold() != 0xFFFF && row == 1){
                    saveButton.isHidden = true
                } else {
                    saveButton.isHidden = false
                }
            } else if (actionID == WLQ_N_DEFINES.RTKDoublePressSensitivity || actionID == WLQ_X_DEFINES.RTKDoublePressSensitivity){ // RTK Sensititvity
                if (wlqData.getDoublePressSensitivity() != typePicker.selectedRow(inComponent: 0) + 1){
                    saveButton.isHidden = false
                } else {
                    saveButton.isHidden = true
                }
            } else if (actionID == WLQ_N_DEFINES.fullLongPressSensitivity || actionID == WLQ_X_DEFINES.fullLongPressSensitivity){ // Full Sensititvity
                if (wlqData.getLongPressSensitivity() != typePicker.selectedRow(inComponent: 0) + 1){
                    saveButton.isHidden = false
                } else {
                    saveButton.isHidden = true
                }
            } else {
                if (typePicker.selectedRow(inComponent: 0) == 0){
                    keyPicker.isHidden = true
                    keyPicker.reloadAllComponents()
                    modifierMultiPicker.isHidden = true
                } else if (typePicker.selectedRow(inComponent: 0) == 1){
                    keyPicker.isHidden = false
                    keyPicker.reloadAllComponents()
                    modifierMultiPicker.isHidden = false
                } else if (typePicker.selectedRow(inComponent: 0) == 2){
                    keyPicker.isHidden = false
                    keyPicker.reloadAllComponents()
                    modifierMultiPicker.isHidden = true
                }
            }
        } else if pickerView == keyPicker{
            saveButton.isHidden = false
        }
    }

    func isSet(value: UInt8, bit: UInt8) -> Bool{
       return ( (value & bit) == bit )
    }
    
    func setHWMode(mode: UInt8){
        os_log("HWSettingsActionViewController: Set WLQ Mode")
        let value:[UInt8] = [mode]
        let alertController = UIAlertController(
            title: NSLocalizedString("hwsave_alert_title", comment: ""),
            message: NSLocalizedString("hwsave_alert_body", comment: ""),
            preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: NSLocalizedString("hwsave_alert_btn_cancel", comment: ""), style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        let openAction = UIAlertAction(title: NSLocalizedString("hwsave_alert_btn_ok", comment: ""), style: .default) { (action) in
            let command = self.wlqData.WRITE_MODE_CMD() + value + self.wlqData.CMD_EOM()
            let writeData =  Data(_: command)
            if (self.bleData.getPeripheral() != nil && self.bleData.getcmdCharacteristic() != nil){
                self.bleData.getPeripheral().writeValue(writeData, for: self.bleData.getcmdCharacteristic(), type: CBCharacteristicWriteType.withResponse)
            }
            self.navigationController?.popToRootViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(openAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
