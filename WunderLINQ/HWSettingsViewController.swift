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
    
    @objc func leftScreen() {
        performSegue(withIdentifier: "hwSettingsToMotorcycle", sender: [])
    }
    
    @IBAction func savePressed(_ sender: Any) {
        var wwModeCommand:[UInt8] = [0x57,0x57,0x53,0x53,0x00]
        if (self.modePicker.selectedRow(inComponent: 0) != 0){
            wwModeCommand = [0x57,0x57,0x53,0x53,0x22]
        }

        if (peripheral != nil && characteristic != nil){
            print("Setting WW mode")
            let writeData =  Data(bytes: wwModeCommand)
            peripheral?.writeValue(writeData, for: characteristic!, type: CBCharacteristicWriteType.withResponse)
        }
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
        
        if wlqData.getwwMode() == 0x22 {
            modePicker.selectRow(1, inComponent: 0, animated: true)
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
    }
}
