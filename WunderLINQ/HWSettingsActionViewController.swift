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

class HWSettingsActionViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var actionLabel: UILabel!
    @IBOutlet weak var typePicker: UIPickerView!
    @IBOutlet weak var keyPicker: UIPickerView!
    @IBOutlet weak var modifierMultiPicker: UIMultiPicker!
    @IBOutlet weak var saveButton: LocalisableButton!
    @IBOutlet weak var cancelButton: LocalisableButton!
    
    let keyboardHID = KeyboardHID.shared
    let wlqData = WLQ.shared

    var actionID: Int?
    
    var modePickerData = [NSLocalizedString("hid_0x00_label", comment: ""),
                          NSLocalizedString("hid_keyboard_label", comment: ""),
                          NSLocalizedString("hid_consumer_label", comment: "")]
    
    var usbPickerData = [NSLocalizedString("usbcontrol_on_label", comment: ""),
                          NSLocalizedString("usbcontrol_engine_label", comment: ""),
                          NSLocalizedString("usbcontrol_off_label", comment: "")]
    

    @IBAction func savePressed(_ sender: Any) {
        if (wlqData.getfirmwareVersion() != "Unknown"){
            if (wlqData.getfirmwareVersion().toDouble()! >= 2.0) {
                if(actionID == 1){ // USB
                    if ((self.typePicker.selectedRow(inComponent: 0) == 0) && (wlqData.USBVinThreshold != 0x0000)){
                        wlqData.tempConfig![wlqData.USBVinThresholdHigh_INDEX] = 0x00
                        wlqData.tempConfig![wlqData.USBVinThresholdLow_INDEX] = 0x00
                    } else if ((self.typePicker.selectedRow(inComponent: 0) == 1) && (wlqData.USBVinThreshold != 0x02BC)){
                        wlqData.tempConfig![wlqData.USBVinThresholdHigh_INDEX] = 0x02
                        wlqData.tempConfig![wlqData.USBVinThresholdLow_INDEX] = 0xBC
                    } else if ((self.typePicker.selectedRow(inComponent: 0) == 2) && (wlqData.USBVinThreshold != 0xFFFF)){
                        wlqData.tempConfig![wlqData.USBVinThresholdHigh_INDEX] = 0xFF
                        wlqData.tempConfig![wlqData.USBVinThresholdLow_INDEX] = 0xFF
                    }
                } else if(actionID == 2){ // RTK Sensititvity
                    wlqData.tempConfig![wlqData.RTKSensitivity_INDEX] = (UInt8)(self.typePicker.selectedRow(inComponent: 0) + 1)
                } else if(actionID == 3){ // Full Sensititvity
                    wlqData.tempConfig![wlqData.fullSensitivity_INDEX] = (UInt8)(self.typePicker.selectedRow(inComponent: 0) + 1)
                } else {    //  Key
                    let keyType:UInt8 = (UInt8)(self.typePicker.selectedRow(inComponent: 0))
                    var key:UInt8 = 0x00
                    var modifiers:UInt8 = 0x00
                    if (keyType == wlqData.KEYBOARD_HID){
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
                    } else if (keyType == wlqData.CONSUMER_HID){
                        key = UInt8(keyboardHID.keyboardCodes[self.keyPicker.selectedRow(inComponent: 0)].key)
                    }
                    print("Modifiers: \(modifiers)")
                    wlqData.setKey(action: actionID, key: [keyType, modifiers, key])
                }
            } else {
                if(actionID == 2 || actionID == 3){ // Sensitivity
                    wlqData.tempSensitivity = (UInt8)(self.typePicker.selectedRow(inComponent: 0) + 1)
                }
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        print("Cancel pressed")
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
        AppUtility.lockOrientation(.portrait)
        
        let backBtn = UIButton()
        backBtn.setImage(UIImage(named: "Left")?.withRenderingMode(.alwaysTemplate), for: .normal)
        if #available(iOS 13.0, *) {
            backBtn.tintColor = UIColor(named: "imageTint")
        }
        backBtn.addTarget(self, action: #selector(leftScreen), for: .touchUpInside)
        let backButton = UIBarButtonItem(customView: backBtn)
        let backButtonWidth = backButton.customView?.widthAnchor.constraint(equalToConstant: 30)
        backButtonWidth?.isActive = true
        let backButtonHeight = backButton.customView?.heightAnchor.constraint(equalToConstant: 30)
        backButtonHeight?.isActive = true
        self.navigationItem.title = wlqData.actionNames[actionID!]
        self.navigationItem.leftBarButtonItems = [backButton]
        
        actionLabel.text = wlqData.actionNames[actionID!]
        
        // Connect data
        typePicker.tag = 1
        keyPicker.tag = 2;
        typePicker.delegate = self
        typePicker.dataSource = self
        keyPicker.delegate = self
        keyPicker.dataSource = self
        
        if (wlqData.getfirmwareVersion() != "Unknown"){
            if (wlqData.getfirmwareVersion().toDouble()! >= 2.0) {
                if(actionID == 1){ // USB
                    if (wlqData.USBVinThreshold == 0x0000){
                        typePicker.selectRow(0, inComponent: 0, animated: true)
                    } else if (wlqData.USBVinThreshold == 0xFFFF){
                        typePicker.selectRow(2, inComponent: 0, animated: true)
                    } else {
                        typePicker.selectRow(1, inComponent: 0, animated: true)
                    }
                    keyPicker.isHidden = true
                    modifierMultiPicker.isHidden = true
                } else if(actionID == 2){ // RTK Sensititvity
                    typePicker.selectRow((Int)(wlqData.RTKSensitivity!) - 1, inComponent: 0, animated: true)
                    keyPicker.isHidden = true
                    modifierMultiPicker.isHidden = true
                } else if(actionID == 3){ // Full Sensititvity
                    typePicker.selectRow((Int)(wlqData.fullSensitivity!) - 1, inComponent: 0, animated: true)
                    keyPicker.isHidden = true
                    modifierMultiPicker.isHidden = true
                } else {                // Key Action
                    modifierMultiPicker.options = keyboardHID.modifierCodes
                    modifierMultiPicker.color = .gray
                    modifierMultiPicker.tintColor = .black
                    modifierMultiPicker.font = .systemFont(ofSize: 20, weight: .bold)
                    modifierMultiPicker.addTarget(self, action: #selector(self.selected(_:)), for: .valueChanged)
                    
                    let keyMode = (Int)(wlqData.getActionKeyMode(action: actionID))
                    typePicker.selectRow(keyMode, inComponent: 0, animated: true)
                    keyPicker.selectRow(keyboardHID.getKeyPosition(action: actionID!), inComponent: 0, animated: true)
                    
                    if (keyMode == wlqData.UNDEFINED){
                        keyPicker.isHidden = true
                        modifierMultiPicker.isHidden = true
                    } else if (keyMode == wlqData.KEYBOARD_HID){
                        keyPicker.isHidden = false
                        modifierMultiPicker.isHidden = false
                        let mask = keyboardHID.getModifiers(action: actionID!)
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
                    } else if (keyMode == wlqData.CONSUMER_HID){
                        keyPicker.isHidden = false
                        modifierMultiPicker.isHidden = true
                    }
                }
            } else {
                if(actionID == 2 || actionID == 3){ // Sensititvity
                    typePicker.selectRow((Int)(wlqData.sensitivity!) - 1, inComponent: 0, animated: true)
                    keyPicker.isHidden = true
                    modifierMultiPicker.isHidden = true
                }
            }
        }
    }
    
    @objc func selected(_ sender: UIMultiPicker) {
        saveButton.isHidden = false
        print(sender.selectedIndexes)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == typePicker {
            if(actionID == 1){ // USB
                return usbPickerData.count
            } else if(actionID == 2){ // RTK Sensititvity
                return 20
            } else if(actionID == 3){ // Full Sensititvity
                return 30
            } else {
                return modePickerData.count
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
            if(actionID == 1){ // USB
                return usbPickerData[row]
            } else if(actionID == 2){ // RTK Sensititvity
                return "\(row + 1)"
            } else if(actionID == 3){ // Full Sensititvity
                return "\(row + 1)"
            } else {
                return modePickerData[row]
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
            if (actionID == 1){ // USB
                if (wlqData.USBVinThreshold == 0x0000 && row == 0){
                    saveButton.isHidden = true
                } else if (wlqData.USBVinThreshold == 0xFFFF && row == 2){
                    saveButton.isHidden = true
                } else if (wlqData.USBVinThreshold != 0x0000 && wlqData.USBVinThreshold != 0xFFFF && row == 1){
                    saveButton.isHidden = true
                } else {
                    saveButton.isHidden = false
                }
            } else if (actionID == 2){ // RTK Sensititvity
                if (wlqData.RTKSensitivity! != typePicker.selectedRow(inComponent: 0) + 1){
                    saveButton.isHidden = false
                } else {
                    saveButton.isHidden = true
                }
            } else if (actionID == 3){ // Full Sensititvity
                if (wlqData.fullSensitivity! != typePicker.selectedRow(inComponent: 0) + 1){
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
}
