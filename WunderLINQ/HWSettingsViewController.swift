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
        if (wlqData.getKeyMode() == wlqData.KEYMODE_CUSTOM()){
            if (self.actionID[indexPath.row] != -1){
                selectedActionID = self.actionID[indexPath.row]
                performSegue(withIdentifier: "hwSettingsToSettingsAction", sender: [])
            }
        }
    }
    
    func updateDisplay(){
        if (wlqData.getfirmwareVersion() != "Unknown"){
            firmwareVersionLabel.text = NSLocalizedString("fw_version_label", comment: "") + " " + wlqData.getfirmwareVersion()
        }
        if (wlqData.gethardwareType() == wlqData.TYPE_NAVIGATOR()){
            if (wlqData.getfirmwareVersion() != "Unknown"){
                if (wlqData.getfirmwareVersion().toDouble()! >= 2.0) {      // FW >2.0
                    if (wlqData.getKeyMode() == wlqData.KEYMODE_DEFAULT() || wlqData.getKeyMode() == wlqData.KEYMODE_CUSTOM()) {
                        if (wlqData.getKeyMode() == wlqData.KEYMODE_DEFAULT()) { // Default Config
                            modeLabel.text = "\(NSLocalizedString("mode_label", comment: "")) \(NSLocalizedString("keymode_default_label", comment: ""))"
                            menuBtn.isHidden = true
                        } else if (wlqData.getKeyMode() == wlqData.KEYMODE_CUSTOM()) { // Custom Config
                            modeLabel.text = "\(NSLocalizedString("mode_label", comment: "")) \(NSLocalizedString("keymode_custom_label", comment: ""))"
                            menuBtn.isHidden = false
                        }
                        modeLabel.isHidden = false
                        
                        if (wlqData.getKeyMode() == wlqData.KEYMODE_DEFAULT()){
                            configButton.setTitle(NSLocalizedString("customize_btn_label", comment: ""), for: .normal)
                            configButton.isHidden = false
                            configButton.tag = 2
                        } else if (!wlqData.getConfig().elementsEqual(wlqData.getTempConfig())){
                            print("!!!Change detected!!!")
                            configButton.setTitle(NSLocalizedString("config_write_label", comment: ""), for: .normal)
                            configButton.isHidden = false
                            configButton.tag = 1
                        } else if (wlqData.getKeyMode() == wlqData.KEYMODE_CUSTOM()){
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
                                                          
                        actionTableMappingLabels = [wlqData.getActionValue(action: WLQ_N().USB),   //USB
                                                    "",       //Full
                                                    wlqData.getActionValue(action: WLQ_N().fullLongPressSensitivity),
                                                    wlqData.getActionValue(action: WLQ_N().fullScrollUp),
                                                    wlqData.getActionValue(action: WLQ_N().fullScrollDown),
                                                    wlqData.getActionValue(action: WLQ_N().fullToggleRight),
                                                    wlqData.getActionValue(action: WLQ_N().fullToggleRightLongPress),
                                                    wlqData.getActionValue(action: WLQ_N().fullToggleLeft),
                                                    wlqData.getActionValue(action: WLQ_N().fullToggleLeftLongPress),
                                                    wlqData.getActionValue(action: WLQ_N().fullSignalCancel),
                                                    wlqData.getActionValue(action: WLQ_N().fullSignalCancelLongPress),
                                                    "",       //RT/K1600
                                                    wlqData.getActionValue(action: WLQ_N().RTKDoublePressSensitivity),
                                                    wlqData.getActionValue(action: WLQ_N().RTKPage),
                                                    wlqData.getActionValue(action: WLQ_N().RTKPageDoublePress),
                                                    wlqData.getActionValue(action: WLQ_N().RTKZoomPlus),
                                                    wlqData.getActionValue(action: WLQ_N().RTKZoomPlusDoublePress),
                                                    wlqData.getActionValue(action: WLQ_N().RTKZoomMinus),
                                                    wlqData.getActionValue(action: WLQ_N().RTKZoomMinusDoublePress),
                                                    wlqData.getActionValue(action: WLQ_N().RTKSpeak),
                                                    wlqData.getActionValue(action: WLQ_N().RTKSpeakDoublePress),
                                                    wlqData.getActionValue(action: WLQ_N().RTKMute),
                                                    wlqData.getActionValue(action: WLQ_N().RTKMuteDoublePress),
                                                    wlqData.getActionValue(action: WLQ_N().RTKDisplayOff),
                                                    wlqData.getActionValue(action: WLQ_N().RTKDisplayOffDoublePress)]
                        
                        actionID = [WLQ_N().USB,    //USB
                                    -1,       //Full
                                    WLQ_N().fullLongPressSensitivity,
                                    WLQ_N().fullScrollUp,
                                    WLQ_N().fullScrollDown,
                                    WLQ_N().fullToggleRight,
                                    WLQ_N().fullToggleRightLongPress,
                                    WLQ_N().fullToggleLeft,
                                    WLQ_N().fullToggleLeftLongPress,
                                    WLQ_N().fullSignalCancel,
                                    WLQ_N().fullSignalCancelLongPress,
                                    -1,       //RT/K1600
                                    WLQ_N().RTKDoublePressSensitivity,
                                    WLQ_N().RTKPage,
                                    WLQ_N().RTKPageDoublePress,
                                    WLQ_N().RTKZoomPlus,
                                    WLQ_N().RTKZoomPlusDoublePress,
                                    WLQ_N().RTKZoomMinus,
                                    WLQ_N().RTKZoomMinusDoublePress,
                                    WLQ_N().RTKSpeak,
                                    WLQ_N().RTKSpeakDoublePress,
                                    WLQ_N().RTKMute,
                                    WLQ_N().RTKMuteDoublePress,
                                    WLQ_N().RTKDisplayOff,
                                    WLQ_N().RTKDisplayOffDoublePress]
                    } else {
                        configButton.setTitle(NSLocalizedString("config_reset_label", comment: ""), for: .normal)
                        modeLabel.isHidden = true
                        configButton.isHidden = false
                        configButton.tag = 0
                    }
                }
            }
        } else if (wlqData.gethardwareType() == wlqData.TYPE_COMNMANDER()){
            if (wlqData.getKeyMode() == wlqData.KEYMODE_DEFAULT() || wlqData.getKeyMode() == wlqData.KEYMODE_CUSTOM()) {
                if (wlqData.getKeyMode() == wlqData.KEYMODE_DEFAULT()) { // Default Config
                    modeLabel.text = "\(NSLocalizedString("mode_label", comment: "")) \(NSLocalizedString("keymode_default_label", comment: ""))"
                    menuBtn.isHidden = true
                } else if (wlqData.getKeyMode() == wlqData.KEYMODE_CUSTOM()) { // Custom Config
                    modeLabel.text = "\(NSLocalizedString("mode_label", comment: "")) \(NSLocalizedString("keymode_custom_label", comment: ""))"
                    menuBtn.isHidden = false
                }
                modeLabel.isHidden = false
                
                if (wlqData.getKeyMode() == wlqData.KEYMODE_DEFAULT()){
                    configButton.setTitle(NSLocalizedString("customize_btn_label", comment: ""), for: .normal)
                    configButton.isHidden = false
                    configButton.tag = 2
                } else if (!wlqData.getConfig().elementsEqual(wlqData.getTempConfig())){
                    print("!!!Change detected!!!")
                    configButton.setTitle(NSLocalizedString("config_write_label", comment: ""), for: .normal)
                    configButton.isHidden = false
                    configButton.tag = 1
                } else if (wlqData.getKeyMode() == wlqData.KEYMODE_CUSTOM()){
                    configButton.setTitle(NSLocalizedString("default_btn_label", comment: ""), for: .normal)
                    configButton.isHidden = false
                    configButton.tag = 2
                } else {
                    configButton.isHidden = true
                }
                actionTableLabels = [NSLocalizedString("long_press_label", comment: ""),
                                     NSLocalizedString("full_scroll_up_label", comment: ""),
                                     NSLocalizedString("full_scroll_down_label", comment: ""),
                                     NSLocalizedString("full_toggle_right_label", comment: ""),
                                     NSLocalizedString("full_toggle_right_long_label", comment: ""),
                                     NSLocalizedString("full_toggle_left_label", comment: ""),
                                     NSLocalizedString("full_toggle_left_long_label", comment: ""),
                                     NSLocalizedString("full_menu_up_label", comment: ""),
                                     NSLocalizedString("full_menu_up_long_label", comment: ""),
                                     NSLocalizedString("full_menu_down_label", comment: ""),
                                     NSLocalizedString("full_menu_down_long_label", comment: "")]
                                                  
                actionTableMappingLabels = [wlqData.getActionValue(action: WLQ_C().longPressSensitivity),
                                            wlqData.getActionValue(action: WLQ_C().wheelScrollUp),
                                            wlqData.getActionValue(action: WLQ_C().wheelScrollDown),
                                            wlqData.getActionValue(action: WLQ_C().wheelToggleRight),
                                            wlqData.getActionValue(action: WLQ_C().wheelToggleRightLongPress),
                                            wlqData.getActionValue(action: WLQ_C().wheelToggleLeft),
                                            wlqData.getActionValue(action: WLQ_C().wheelToggleLeftLongPress),
                                            wlqData.getActionValue(action: WLQ_C().menuUp),
                                            wlqData.getActionValue(action: WLQ_C().menuUpLongPress),
                                            wlqData.getActionValue(action: WLQ_C().menuDown),
                                            wlqData.getActionValue(action: WLQ_C().menuDownLongPress)]
                
                actionID = [WLQ_C().longPressSensitivity,
                            WLQ_C().wheelScrollUp,
                            WLQ_C().wheelScrollDown,
                            WLQ_C().wheelToggleRight,
                            WLQ_C().wheelToggleRightLongPress,
                            WLQ_C().wheelToggleLeft,
                            WLQ_C().wheelToggleLeftLongPress,
                            WLQ_C().menuUp,
                            WLQ_C().menuUpLongPress,
                            WLQ_C().menuDown,
                            WLQ_C().menuDownLongPress]
            } else {
                configButton.setTitle(NSLocalizedString("config_reset_label", comment: ""), for: .normal)
                modeLabel.isHidden = true
                configButton.isHidden = false
                configButton.tag = 0
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
        let openAction = UIAlertAction(title: NSLocalizedString("hwsave_alert_btn_ok", comment: ""), style: .default) { [self] (action) in
            if (wlqData.gethardwareType() == wlqData.TYPE_NAVIGATOR()){
                if (self.wlqData.getfirmwareVersion() != "Unknown"){
                    if (self.wlqData.getfirmwareVersion().toDouble()! >= 2.0) {
                        var command = self.wlqData.WRITE_CONFIG_CMD() + WLQ_N().defaultConfig2 + self.wlqData.CMD_EOM()
                        if (self.wlqData.gethardwareVersion() == WLQ_N().hardwareVersion1){
                            command = self.wlqData.WRITE_CONFIG_CMD() + WLQ_N().defaultConfig2HW1 + self.wlqData.CMD_EOM()
                        }
                        let writeData =  Data(_: command)
                        self.peripheral?.writeValue(writeData, for: self.characteristic!, type: CBCharacteristicWriteType.withResponse)
                    }
                }
            } else if (wlqData.gethardwareType() == wlqData.TYPE_COMNMANDER()){
                let command = self.wlqData.WRITE_CONFIG_CMD() + WLQ_C().defaultConfig + self.wlqData.CMD_EOM()
                let writeData =  Data(_: command)
                self.peripheral?.writeValue(writeData, for: self.characteristic!, type: CBCharacteristicWriteType.withResponse)
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
            if (self.wlqData.gethardwareType() == self.wlqData.TYPE_NAVIGATOR()){
                if (self.wlqData.getfirmwareVersion() != "Unknown"){
                    if (self.wlqData.getfirmwareVersion().toDouble()! >= 2.0) {
                        let command = self.wlqData.WRITE_CONFIG_CMD() + self.wlqData.getTempConfig() + self.wlqData.CMD_EOM()
                        let writeData =  Data(_: command)
                        self.peripheral?.writeValue(writeData, for: self.characteristic!, type: CBCharacteristicWriteType.withResponse)
                    }
                }
            } else if (self.wlqData.gethardwareType() == self.wlqData.TYPE_COMNMANDER()){
                let command = self.wlqData.WRITE_CONFIG_CMD() + self.wlqData.getTempConfig() + self.wlqData.CMD_EOM()
                let writeData =  Data(_: command)
                self.peripheral?.writeValue(writeData, for: self.characteristic!, type: CBCharacteristicWriteType.withResponse)
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
            if (self.wlqData.gethardwareType() == self.wlqData.TYPE_NAVIGATOR()){
                if (self.wlqData.getfirmwareVersion() != "Unknown"){
                    if (self.wlqData.getfirmwareVersion().toDouble()! >= 2.0) {
                        var value:[UInt8] = [self.wlqData.KEYMODE_CUSTOM()]
                        if (self.wlqData.getKeyMode() == self.wlqData.KEYMODE_CUSTOM()){
                            value = [self.wlqData.KEYMODE_DEFAULT()]
                        }
                        let command = self.wlqData.WRITE_MODE_CMD() + value + self.wlqData.CMD_EOM()
                        let writeData =  Data(_: command)
                        self.peripheral?.writeValue(writeData, for: self.characteristic!, type: CBCharacteristicWriteType.withResponse)
                    }
                }
            } else if (self.wlqData.gethardwareType() == self.wlqData.TYPE_COMNMANDER()){
                var value:[UInt8] = [self.wlqData.KEYMODE_CUSTOM()]
                if (self.wlqData.getKeyMode() == self.wlqData.KEYMODE_CUSTOM()){
                    value = [self.wlqData.KEYMODE_DEFAULT()]
                }
                let command = self.wlqData.WRITE_MODE_CMD() + value + self.wlqData.CMD_EOM()
                let writeData =  Data(_: command)
                self.peripheral?.writeValue(writeData, for: self.characteristic!, type: CBCharacteristicWriteType.withResponse)
            }
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(openAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}
