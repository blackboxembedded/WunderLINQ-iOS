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
import CoreBluetooth

class HWSettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    let bleData = BLE.shared
    let wlqData = WLQ.shared
    let keyboardHID = KeyboardHID.shared
    
    var peripheral: CBPeripheral?
    var characteristic: CBCharacteristic?
    
    @IBOutlet weak var firmwareVersionLabel: UILabel!
    @IBOutlet weak var modeLabel: UILabel!
    @IBOutlet weak var actionsTableView: UITableView!
    @IBOutlet weak var configButton: LocalisableButton!
    
    var menuBtn: UIButton!
    
    let cellReuseIdentifier = "hwActionCell"
    
    var actionTableLabels: [String] = [""]
    var actionTableMappingLabels: [String] = [""]
    var actionID: [Int] = [-1]
    var selectedActionID:Int = -1

    @IBAction func configPressed(_ sender: Any) {
        if (self.peripheral != nil && self.characteristic != nil){
            if (self.configButton.tag == 0){
                self.resetHWConfig()
            } else if (self.configButton.tag == 1){
                self.applyHWConfig()
            } else if (self.configButton.tag == 2){
                self.setHWMode()
            }
        }
    }
    
    @objc func leftScreen() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @objc func menuButtonTapped() {
        resetHWConfig()
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
        menuBtn = UIButton()
        menuBtn.setImage(UIImage(named: "Reset")?.withRenderingMode(.alwaysTemplate), for: .normal)
        if #available(iOS 13.0, *) {
            menuBtn.tintColor = UIColor(named: "imageTint")
        }
        menuBtn.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
        let menuButton = UIBarButtonItem(customView: menuBtn)
        let menuButtonWidth = menuButton.customView?.widthAnchor.constraint(equalToConstant: 30)
        menuButtonWidth?.isActive = true
        let menuButtonHeight = menuButton.customView?.heightAnchor.constraint(equalToConstant: 30)
        menuButtonHeight?.isActive = true
        self.navigationItem.title = NSLocalizedString("fw_config_title", comment: "")
        self.navigationItem.leftBarButtonItems = [backButton]
        self.navigationItem.rightBarButtonItems = [menuButton]
        menuBtn.isHidden = true
        
        actionsTableView.delegate = self
        actionsTableView.dataSource = self
        
        peripheral = bleData.getPeripheral()
        characteristic = bleData.getcmdCharacteristic()

        updateDisplay()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateDisplay()
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.actionTableLabels.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cell:HWSettingsTableViewCell = self.actionsTableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! HWSettingsTableViewCell
        
        cell.hwActionLabel.text = self.actionTableLabels[indexPath.row]
        cell.hwActionMappingLabel.text = self.actionTableMappingLabels[indexPath.row]
        cell.actionID = self.actionID[indexPath.row]
        if(self.actionTableMappingLabels[indexPath.row] == ""){
            cell.hwActionLabel.font = cell.hwActionLabel.font.withSize(25)
        } else {
            cell.hwActionLabel.font = cell.hwActionLabel.font.withSize(17)
        }
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (wlqData.getfirmwareVersion() != "Unknown"){
            if (wlqData.getfirmwareVersion().toDouble()! >= 2.0) {
                if (wlqData.keyMode == wlqData.keyMode_custom){
                    if (self.actionID[indexPath.row] != -1){
                        selectedActionID = self.actionID[indexPath.row]
                        performSegue(withIdentifier: "hwSettingsToSettingsAction", sender: [])
                    }
                }
            } else {
                if (self.actionID[indexPath.row] == wlqData.OldSensitivity){
                    selectedActionID = self.actionID[indexPath.row]
                    performSegue(withIdentifier: "hwSettingsToSettingsAction", sender: [])
                }
            }
        }
    }
    
    func updateDisplay(){
        if (wlqData.getfirmwareVersion() != "Unknown"){
            firmwareVersionLabel.text = NSLocalizedString("fw_version_label", comment: "") + " " + wlqData.getfirmwareVersion()
            if (wlqData.getfirmwareVersion().toDouble()! >= 2.0) {      // FW >2.0
                if (wlqData.keyMode == wlqData.keyMode_default || wlqData.keyMode == wlqData.keyMode_custom) {
                    if (wlqData.keyMode == wlqData.keyMode_default) { // Default Config
                        modeLabel.text = "\(NSLocalizedString("mode_label", comment: "")) \(NSLocalizedString("keymode_default_label", comment: ""))"
                        menuBtn.isHidden = true
                    } else if (wlqData.keyMode == wlqData.keyMode_custom) { // Custom Config
                        modeLabel.text = "\(NSLocalizedString("mode_label", comment: "")) \(NSLocalizedString("keymode_custom_label", comment: ""))"
                        menuBtn.isHidden = false
                    }
                    modeLabel.isHidden = false
                    
                    //Check for config from FW 1.x
                    if (wlqData.keyMode == wlqData.keyMode_custom &&
                            wlqData.flashConfig![0] == wlqData.defaultConfig1[0] &&
                            wlqData.flashConfig![1] == wlqData.defaultConfig1[1] &&
                            wlqData.flashConfig![2] == wlqData.defaultConfig1[2] &&
                            wlqData.flashConfig![3] == wlqData.defaultConfig1[3]){
                        
                        modeLabel.text = NSLocalizedString("corrupt_config_label", comment: "")
                        modeLabel.isHidden = false
                        configButton.setTitle(NSLocalizedString("config_reset_label", comment: ""), for: .normal)
                        configButton.isHidden = false
                        configButton.tag = 0
                    } else {
                        if (wlqData.keyMode == wlqData.keyMode_default){
                            configButton.setTitle(NSLocalizedString("customize_btn_label", comment: ""), for: .normal)
                            configButton.isHidden = false
                            configButton.tag = 2
                        } else if (!wlqData.flashConfig!.elementsEqual(wlqData.tempConfig!)){
                            print("!!!Change detected!!!")
                            configButton.setTitle(NSLocalizedString("config_write_label", comment: ""), for: .normal)
                            configButton.isHidden = false
                            configButton.tag = 1
                        } else if (wlqData.keyMode == wlqData.keyMode_custom){
                            configButton.setTitle(NSLocalizedString("default_btn_label", comment: ""), for: .normal)
                            configButton.isHidden = false
                            configButton.tag = 2
                        } else {
                            configButton.isHidden = true
                        }
                        actionTableLabels = [NSLocalizedString("usb_threshold_label", comment: ""),       //USB
                                             NSLocalizedString("wwMode1", comment: ""),       //Full
                                             NSLocalizedString("long_press_label", comment: ""),
                                             NSLocalizedString("full_scroll_up_label", comment: ""),
                                             NSLocalizedString("full_scroll_down_label", comment: ""),
                                             NSLocalizedString("full_toggle_right_label", comment: ""),
                                             NSLocalizedString("full_toggle_right_long_label", comment: ""),
                                             NSLocalizedString("full_toggle_left_label", comment: ""),
                                             NSLocalizedString("full_toggle_left_long_label", comment: ""),
                                             NSLocalizedString("full_signal_cancel_label", comment: ""),
                                             NSLocalizedString("full_signal_cancel_long_label", comment: ""),
                                             NSLocalizedString("wwMode2", comment: ""),       //RT/K1600
                                             NSLocalizedString("double_press_label", comment: ""),
                                             NSLocalizedString("rtk_page_label", comment: ""),
                                             NSLocalizedString("rtk_page_double_label", comment: ""),
                                             NSLocalizedString("rtk_zoomp_label", comment: ""),
                                             NSLocalizedString("rtk_zoomp_double_label", comment: ""),
                                             NSLocalizedString("rtk_zoomm_label", comment: ""),
                                             NSLocalizedString("rtk_zoomm_double_label", comment: ""),
                                             NSLocalizedString("rtk_speak_label", comment: ""),
                                             NSLocalizedString("rtk_speak_double_label", comment: ""),
                                             NSLocalizedString("rtk_mute_label", comment: ""),
                                             NSLocalizedString("rtk_mute_double_label", comment: ""),
                                             NSLocalizedString("rtk_display_label", comment: ""),
                                             NSLocalizedString("rtk_display_double_label", comment: "")]
                                                          
                        actionTableMappingLabels = [wlqData.getActionValue(action: wlqData.USB),   //USB
                                                    "",       //Full
                                                    wlqData.getActionValue(action: wlqData.fullLongPressSensitivity),
                                                    wlqData.getActionValue(action: wlqData.fullScrollUp),
                                                    wlqData.getActionValue(action: wlqData.fullScrollDown),
                                                    wlqData.getActionValue(action: wlqData.fullToggleRight),
                                                    wlqData.getActionValue(action: wlqData.fullToggleRightLongPress),
                                                    wlqData.getActionValue(action: wlqData.fullToggleLeft),
                                                    wlqData.getActionValue(action: wlqData.fullToggleLeftLongPress),
                                                    wlqData.getActionValue(action: wlqData.fullSignalCancel),
                                                    wlqData.getActionValue(action: wlqData.fullSignalCancelLongPress),
                                                    "",       //RT/K1600
                                                    wlqData.getActionValue(action: wlqData.RTKDoublePressSensitivity),
                                                    wlqData.getActionValue(action: wlqData.RTKPage),
                                                    wlqData.getActionValue(action: wlqData.RTKPageDoublePress),
                                                    wlqData.getActionValue(action: wlqData.RTKZoomPlus),
                                                    wlqData.getActionValue(action: wlqData.RTKZoomPlusDoublePress),
                                                    wlqData.getActionValue(action: wlqData.RTKZoomMinus),
                                                    wlqData.getActionValue(action: wlqData.RTKZoomMinusDoublePress),
                                                    wlqData.getActionValue(action: wlqData.RTKSpeak),
                                                    wlqData.getActionValue(action: wlqData.RTKSpeakDoublePress),
                                                    wlqData.getActionValue(action: wlqData.RTKMute),
                                                    wlqData.getActionValue(action: wlqData.RTKMuteDoublePress),
                                                    wlqData.getActionValue(action: wlqData.RTKDisplayOff),
                                                    wlqData.getActionValue(action: wlqData.RTKDisplayOffDoublePress)]
                        
                        actionID = [wlqData.USB,    //USB
                                    -1,       //Full
                                    wlqData.fullLongPressSensitivity,
                                    wlqData.fullScrollUp,
                                    wlqData.fullScrollDown,
                                    wlqData.fullToggleRight,
                                    wlqData.fullToggleRightLongPress,
                                    wlqData.fullToggleLeft,
                                    wlqData.fullToggleLeftLongPress,
                                    wlqData.fullSignalCancel,
                                    wlqData.fullSignalCancelLongPress,
                                    -1,       //RT/K1600
                                    wlqData.RTKDoublePressSensitivity,
                                    wlqData.RTKPage,
                                    wlqData.RTKPageDoublePress,
                                    wlqData.RTKZoomPlus,
                                    wlqData.RTKZoomPlusDoublePress,
                                    wlqData.RTKZoomMinus,
                                    wlqData.RTKZoomMinusDoublePress,
                                    wlqData.RTKSpeak,
                                    wlqData.RTKSpeakDoublePress,
                                    wlqData.RTKMute,
                                    wlqData.RTKMuteDoublePress,
                                    wlqData.RTKDisplayOff,
                                    wlqData.RTKDisplayOffDoublePress]
                    }
                } else {
                    configButton.setTitle(NSLocalizedString("config_reset_label", comment: ""), for: .normal)
                    modeLabel.isHidden = true
                    configButton.isHidden = false
                    configButton.tag = 0
                }
            } else {            // FW <2.0
                if (wlqData.wheelMode == wlqData.wheelMode_full || wlqData.wheelMode == wlqData.wheelMode_rtk) {
                    modeLabel.isHidden = false
                    if(wlqData.sensitivity != wlqData.tempSensitivity){
                        configButton.setTitle(NSLocalizedString("config_write_label", comment: ""), for: .normal)
                        configButton.isHidden = false
                        configButton.tag = 1
                    } else {
                        if (wlqData.wheelMode == wlqData.wheelMode_full) {
                            configButton.setTitle(NSLocalizedString("wwMode2", comment: ""), for: .normal)
                        } else if (wlqData.wheelMode == wlqData.wheelMode_rtk){
                            configButton.setTitle(NSLocalizedString("wwMode1", comment: ""), for: .normal)
                        }
                        configButton.isHidden = false
                        configButton.tag = 2
                    }
                    if (wlqData.wheelMode == wlqData.wheelMode_full) { //Full
                        modeLabel.text = "\(NSLocalizedString("wwtype_label", comment: "")) \(NSLocalizedString("wwMode1", comment: ""))"
                        actionTableLabels = [NSLocalizedString("long_press_label", comment: ""),
                                             NSLocalizedString("full_scroll_up_label", comment: ""),
                                             NSLocalizedString("full_scroll_down_label", comment: ""),
                                             NSLocalizedString("full_toggle_right_label", comment: ""),
                                             NSLocalizedString("full_toggle_right_long_label", comment: ""),
                                             NSLocalizedString("full_toggle_left_label", comment: ""),
                                             NSLocalizedString("full_toggle_left_long_label", comment: ""),
                                             NSLocalizedString("full_signal_cancel_long_label", comment: "")]
                                                           
                        actionTableMappingLabels = ["\(wlqData.sensitivity!)",
                                                    NSLocalizedString("keyboard_hid_0x52_label", comment: ""),
                                                    NSLocalizedString("keyboard_hid_0x51_label", comment: ""),
                                                    NSLocalizedString("keyboard_hid_0x4F_label", comment: ""),
                                                    NSLocalizedString("keyboard_hid_0x28_label", comment: ""),
                                                    NSLocalizedString("keyboard_hid_0x50_label", comment: ""),
                                                    NSLocalizedString("keyboard_hid_0x29_label", comment: ""),
                                                    NSLocalizedString("consumer_hid_0xB8_label", comment: "")]
                        
                        actionID = [wlqData.OldSensitivity,
                                    -1,
                                    -1,
                                    -1,
                                    -1,
                                    -1,
                                    -1,
                                    -1]
                    } else if (wlqData.wheelMode == wlqData.wheelMode_rtk) { //RTK1600
                        modeLabel.text = "\(NSLocalizedString("wwtype_label", comment: "")) \(NSLocalizedString("wwMode2", comment: ""))"
                        actionTableLabels = [NSLocalizedString("double_press_label", comment: ""),
                                             NSLocalizedString("rtk_page_label", comment: ""),
                                             NSLocalizedString("rtk_page_double_label", comment: ""),
                                             NSLocalizedString("rtk_zoomp_label", comment: ""),
                                             NSLocalizedString("rtk_zoomm_label", comment: ""),
                                             NSLocalizedString("rtk_speak_label", comment: ""),
                                             NSLocalizedString("rtk_speak_double_label", comment: ""),
                                             NSLocalizedString("rtk_display_label", comment: "")]

                        actionTableMappingLabels = ["\(wlqData.sensitivity!)",
                                                    NSLocalizedString("keyboard_hid_0x4F_label", comment: ""),
                                                    NSLocalizedString("keyboard_hid_0x28_label", comment: ""),
                                                    NSLocalizedString("keyboard_hid_0x52_label", comment: ""),
                                                    NSLocalizedString("keyboard_hid_0x51_label", comment: ""),
                                                    NSLocalizedString("keyboard_hid_0x50_label", comment: ""),
                                                    NSLocalizedString("keyboard_hid_0x29_label", comment: ""),
                                                    NSLocalizedString("consumer_hid_0xB8_label", comment: "")]
                        actionID = [wlqData.OldSensitivity,
                                    -1,
                                    -1,
                                    -1,
                                    -1,
                                    -1,
                                    -1,
                                    -1]
                    }
                }  else {
                    configButton.setTitle(NSLocalizedString("config_reset_label", comment: ""), for: .normal)
                    modeLabel.isHidden = true
                    configButton.isHidden = false
                    configButton.tag = 0
                }
            }
        }
        self.actionsTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? HWSettingsActionViewController {
            destinationViewController.setup(with: selectedActionID)
        }
    }
    
    func resetHWConfig(){
        print("resetHWConfig()")
        let alertController = UIAlertController(
            title: NSLocalizedString("hwsave_alert_title", comment: ""),
            message: NSLocalizedString("hwreset_alert_body", comment: ""),
            preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: NSLocalizedString("hwsave_alert_btn_cancel", comment: ""), style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        let openAction = UIAlertAction(title: NSLocalizedString("hwsave_alert_btn_ok", comment: ""), style: .default) { (action) in
            if (self.wlqData.getfirmwareVersion() != "Unknown"){
                if (self.wlqData.getfirmwareVersion().toDouble()! >= 2.0) {
                    let command = self.wlqData.WRITE_CONFIG_CMD + self.wlqData.defaultConfig2 + self.wlqData.CMD_EOM
                    let writeData =  Data(_: command)
                    self.peripheral?.writeValue(writeData, for: self.characteristic!, type: CBCharacteristicWriteType.withResponse)
                } else {
                    let command = self.wlqData.WRITE_CONFIG_CMD + self.wlqData.defaultConfig1 + self.wlqData.CMD_EOM
                    let writeData =  Data(_: command)
                    self.peripheral?.writeValue(writeData, for: self.characteristic!, type: CBCharacteristicWriteType.withResponse)
                }
            }
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(openAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func applyHWConfig(){
        print("applyHWConfig()")
        let alertController = UIAlertController(
            title: NSLocalizedString("hwsave_alert_title", comment: ""),
            message: NSLocalizedString("hwsave_alert_body", comment: ""),
            preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: NSLocalizedString("hwsave_alert_btn_cancel", comment: ""), style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        let openAction = UIAlertAction(title: NSLocalizedString("hwsave_alert_btn_ok", comment: ""), style: .default) { (action) in
            if (self.wlqData.getfirmwareVersion() != "Unknown"){
                if (self.wlqData.getfirmwareVersion().toDouble()! >= 2.0) {
                    let command = self.wlqData.WRITE_CONFIG_CMD + self.wlqData.tempConfig! + self.wlqData.CMD_EOM
                    let writeData =  Data(_: command)
                    self.peripheral?.writeValue(writeData, for: self.characteristic!, type: CBCharacteristicWriteType.withResponse)
                } else {
                    if (self.wlqData.sensitivity != self.wlqData.tempSensitivity){
                        let prefix:[UInt8] = [self.wlqData.wheelMode!, 0x45]
                        let sensInt:Int = (Int)(self.wlqData.tempSensitivity!)
                        let sensString:String = (String)(sensInt)
                        let sensCharacters = Array(sensString)
                        let sensUInt8Array = String(sensCharacters).utf8.map{ UInt8($0) }
                        let command = self.wlqData.WRITE_SENSITIVITY_CMD + prefix + sensUInt8Array + self.wlqData.CMD_EOM
                        let writeData =  Data(_: command)
                        self.peripheral?.writeValue(writeData, for: self.characteristic!, type: CBCharacteristicWriteType.withResponse)
                    }
                }
            }
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(openAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func setHWMode(){
        print("Set WLQ Mode")
        let alertController = UIAlertController(
            title: NSLocalizedString("hwsave_alert_title", comment: ""),
            message: NSLocalizedString("hwsave_alert_body", comment: ""),
            preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: NSLocalizedString("hwsave_alert_btn_cancel", comment: ""), style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        let openAction = UIAlertAction(title: NSLocalizedString("hwsave_alert_btn_ok", comment: ""), style: .default) { (action) in
            if (self.wlqData.getfirmwareVersion() != "Unknown"){
                if (self.wlqData.getfirmwareVersion().toDouble()! >= 2.0) {
                    var value:[UInt8] = [self.wlqData.keyMode_custom]
                    if (self.wlqData.keyMode == self.wlqData.keyMode_custom){
                        value = [self.wlqData.keyMode_default]
                    }
                    let command = self.wlqData.WRITE_MODE_CMD + value + self.wlqData.CMD_EOM
                    let writeData =  Data(_: command)
                    self.peripheral?.writeValue(writeData, for: self.characteristic!, type: CBCharacteristicWriteType.withResponse)
                } else {
                    var value:[UInt8] = [self.wlqData.wheelMode_full]
                    if (self.wlqData.wheelMode == self.wlqData.wheelMode_full){
                        value = [self.wlqData.wheelMode_rtk]
                    }
                    let command = self.wlqData.WRITE_MODE_CMD + value + self.wlqData.CMD_EOM
                    let writeData =  Data(_: command)
                    self.peripheral?.writeValue(writeData, for: self.characteristic!, type: CBCharacteristicWriteType.withResponse)
                }
            }
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(openAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}
