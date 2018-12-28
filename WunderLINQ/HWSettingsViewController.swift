//
//  HWSettingsViewController.swift
//  WunderLINQ
//
//  Created by Keith Conger on 12/21/18.
//  Copyright © 2018 Black Box Embedded, LLC. All rights reserved.
//

import UIKit
import CoreBluetooth

class HWSettingsViewController: UIViewController, CBPeripheralDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let bleData = BLE.shared
    let wlqData = WLQ.shared
    
    var peripheral: CBPeripheral?
    var characteristic: CBCharacteristic?
    
    @IBOutlet weak var modeLabel: LocalisableLabel!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var modePicker: UIPickerView!
    @IBOutlet weak var sensitivityLabel: LocalisableLabel!
    @IBOutlet weak var sensitivityValueLabel: UILabel!
    @IBOutlet weak var sensitivitySlider: UISlider!
    
    @objc func leftScreen() {
        performSegue(withIdentifier: "hwSettingsToMotorcycle", sender: [])
    }
    
    @IBAction func savePressed(_ sender: Any) {
        if (wlqData.getwwMode() == 0x32 && self.modePicker.selectedRow(inComponent: 0) == 0){
            let sensInt:Int = (Int)(sensitivitySlider.value)
            let sensString:String = (String)(sensInt)
            let sensCharacters = Array(sensString)
            let sensUInt8Array = String(sensCharacters).utf8.map{ UInt8($0) }
            if sensUInt8Array.count == 1 {
                let wwSensCommand:[UInt8] = [0x57,0x57,0x43,0x53,0x32,0x45,sensUInt8Array[0],0x0D,0x0A]
                if (peripheral != nil && characteristic != nil){
                    print("Setting WW Sensitivity")
                    let writeData =  Data(bytes: wwSensCommand)
                    peripheral?.writeValue(writeData, for: characteristic!, type: CBCharacteristicWriteType.withResponse)
                }
            } else {
                let wwSensCommand:[UInt8] = [0x57,0x57,0x43,0x53,0x32,0x45,sensUInt8Array[0],sensUInt8Array[1],0x0D,0x0A]
                if (peripheral != nil && characteristic != nil){
                    print("Setting WW Sensitivity")
                    let writeData =  Data(bytes: wwSensCommand)
                    peripheral?.writeValue(writeData, for: characteristic!, type: CBCharacteristicWriteType.withResponse)
                }
            }
        } else if (wlqData.getwwMode() == 0x34 && self.modePicker.selectedRow(inComponent: 0) == 1){
            let sensInt:Int = (Int)(sensitivitySlider.value)
            let sensString:String = (String)(sensInt)
            let sensCharacters = Array(sensString)
            let sensUInt8Array = String(sensCharacters).utf8.map{ UInt8($0) }
            if sensUInt8Array.count == 1 {
                let wwSensCommand:[UInt8] = [0x57,0x57,0x43,0x53,0x34,0x45,sensUInt8Array[0],0x0D,0x0A]
                if (peripheral != nil && characteristic != nil){
                    print("Setting WW Sensitivity")
                    let writeData =  Data(bytes: wwSensCommand)
                    peripheral?.writeValue(writeData, for: characteristic!, type: CBCharacteristicWriteType.withResponse)
                }
            } else {
                let wwSensCommand:[UInt8] = [0x57,0x57,0x43,0x53,0x34,0x45,sensUInt8Array[0],sensUInt8Array[1],0x0D,0x0A]
                if (peripheral != nil && characteristic != nil){
                    print("Setting WW Sensitivity")
                    let writeData =  Data(bytes: wwSensCommand)
                    peripheral?.writeValue(writeData, for: characteristic!, type: CBCharacteristicWriteType.withResponse)
                }
            }
        } else {
            var wwModeCommand:[UInt8] = [0x57,0x57,0x53,0x53,0x32]
            if (self.modePicker.selectedRow(inComponent: 0) != 0){
                wwModeCommand = [0x57,0x57,0x53,0x53,0x34]
            }
            if (peripheral != nil && characteristic != nil){
                print("Setting WW mode")
                let writeData =  Data(bytes: wwModeCommand)
                peripheral?.writeValue(writeData, for: characteristic!, type: CBCharacteristicWriteType.withResponse)
            }
        }
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    var modePickerData: [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backBtn = UIButton()
        backBtn.setImage(UIImage(named: "Left")?.withRenderingMode(.alwaysTemplate), for: .normal)
        backBtn.addTarget(self, action: #selector(leftScreen), for: .touchUpInside)
        let backButton = UIBarButtonItem(customView: backBtn)
        let backButtonWidth = backButton.customView?.widthAnchor.constraint(equalToConstant: 30)
        backButtonWidth?.isActive = true
        let backButtonHeight = backButton.customView?.heightAnchor.constraint(equalToConstant: 30)
        backButtonHeight?.isActive = true
        self.navigationItem.title = NSLocalizedString("fw_config_title", comment: "")
        self.navigationItem.leftBarButtonItems = [backButton]
        
        // Connect data
        self.modePicker.delegate = self
        self.modePicker.dataSource = self
        modePickerData = [NSLocalizedString("wwMode1", comment: ""), NSLocalizedString("wwMode2", comment: "")]
        
        peripheral = bleData.getPeripheral()
        characteristic = bleData.getcmdCharacteristic()
        
        if wlqData.getwwMode() == 0x32 {
            modePicker.selectRow(0, inComponent: 0, animated: true)
            sensitivitySlider.maximumValue = 30
        } else if wlqData.getwwMode() == 0x34 {
            modePicker.selectRow(1, inComponent: 0, animated: true)
            sensitivitySlider.maximumValue = 20
        }
        
        sensitivitySlider.minimumValue = 0
        sensitivitySlider.isContinuous = true
        sensitivitySlider.value = (Float) (wlqData.getwwHoldSensitivity())
        sensitivityValueLabel.text = "\((Int)(sensitivitySlider.value))"
        
        saveButton.isEnabled = false
    }
    
    @IBAction func sensitivitySliderChanged(_ sender: Any) {
        sensitivityValueLabel.text = "\((Int)(sensitivitySlider.value))"
        if ((UInt8)(sensitivitySlider.value) == wlqData.getwwHoldSensitivity()){
            saveButton.isEnabled = false
        } else {
            saveButton.isEnabled = true
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return modePickerData.count
    }
    
    // The data to return fopr the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return modePickerData[row]
    }
    
    // Capture the picker view selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        if ((row == 0) && (wlqData.getwwMode() == 0x32)){
            sensitivitySlider.maximumValue = 30
            sensitivitySlider.isHidden = false
            sensitivityLabel.isHidden = false
            sensitivityValueLabel.isHidden = false
            sensitivitySlider.value = (Float) (wlqData.getwwHoldSensitivity())
            saveButton.isEnabled = false
        } else if ((row == 1) && (wlqData.getwwMode() == 0x34)){
            sensitivitySlider.maximumValue = 20
            sensitivitySlider.isHidden = false
            sensitivityLabel.isHidden = false
            sensitivityValueLabel.isHidden = false
            sensitivitySlider.value = (Float) (wlqData.getwwHoldSensitivity())
            saveButton.isEnabled = false
        } else {
            sensitivitySlider.isHidden = true
            sensitivityLabel.isHidden = true
            sensitivityValueLabel.isHidden = true
            saveButton.isEnabled = true
        }
    }
}
