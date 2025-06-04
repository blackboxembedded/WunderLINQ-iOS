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
import os.log

class HWSettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    let bleData = BLE.shared
    let wlqData = WLQ.shared
    let keyboardHID = KeyboardHID.shared
    
    var peripheral: CBPeripheral?
    var characteristic: CBCharacteristic?
    
    @IBOutlet weak var firmwareVersionLabel: UILabel!
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

        let backBtn = UIButton()
        backBtn.setImage(UIImage(named: "Left")?.withRenderingMode(.alwaysTemplate), for: .normal)
        backBtn.tintColor = UIColor(named: "imageTint")
        backBtn.addTarget(self, action: #selector(leftScreen), for: .touchUpInside)
        let backButton = UIBarButtonItem(customView: backBtn)
        let backButtonWidth = backButton.customView?.widthAnchor.constraint(equalToConstant: 30)
        backButtonWidth?.isActive = true
        let backButtonHeight = backButton.customView?.heightAnchor.constraint(equalToConstant: 30)
        backButtonHeight?.isActive = true
        menuBtn = UIButton()
        menuBtn.setImage(UIImage(named: "Reset")?.withRenderingMode(.alwaysTemplate), for: .normal)
        menuBtn.tintColor = UIColor(named: "imageTint")
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
        } else {
            if (self.actionID[indexPath.row] == WLQ_DEFINES.KEYMODE
                || self.actionID[indexPath.row] == WLQ_DEFINES.pdmChannel1 || self.actionID[indexPath.row] == WLQ_DEFINES.pdmChannel2
                || self.actionID[indexPath.row] == WLQ_DEFINES.pdmChannel3 || self.actionID[indexPath.row] == WLQ_DEFINES.pdmChannel4){
                selectedActionID = self.actionID[indexPath.row]
                performSegue(withIdentifier: "hwSettingsToSettingsAction", sender: [])
            }
        }
    }
    
    func updateDisplay(){
        menuBtn.isHidden = true
        configButton.isHidden = true
        if (wlqData.getfirmwareVersion() != "Unknown"){
            firmwareVersionLabel.text = NSLocalizedString("fw_version_label", comment: "") + " " + wlqData.getfirmwareVersion()
        }
        if (wlqData.gethardwareType() == wlqData.TYPE_N()){
            if (wlqData.getfirmwareVersion() != "Unknown"){
                if (wlqData.getfirmwareVersion().toDouble()! >= 2.0) {      // FW >2.0
                    if (wlqData.getKeyMode() == wlqData.KEYMODE_DEFAULT() || wlqData.getKeyMode() == wlqData.KEYMODE_CUSTOM() || wlqData.getKeyMode() == wlqData.KEYMODE_MEDIA() || wlqData.getKeyMode() == wlqData.KEYMODE_DMD2()) {
                        actionTableLabels = [NSLocalizedString("keymode_label", comment: ""),       //KEYMODE
                                             NSLocalizedString("usb_threshold_label", comment: ""),       //USB
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
                                                          
                        actionTableMappingLabels = [wlqData.getActionValue(action: WLQ_DEFINES.KEYMODE),   //KEYMODE
                                                    wlqData.getActionValue(action: WLQ_DEFINES.USB),   //USB
                                                    "",       //Full
                                                    wlqData.getActionValue(action: WLQ_DEFINES.longPressSensitivity),
                                                    wlqData.getActionValue(action: WLQ_DEFINES.fullScrollUp),
                                                    wlqData.getActionValue(action: WLQ_DEFINES.fullScrollDown),
                                                    wlqData.getActionValue(action: WLQ_DEFINES.fullToggleRight),
                                                    wlqData.getActionValue(action: WLQ_DEFINES.fullToggleRightLongPress),
                                                    wlqData.getActionValue(action: WLQ_DEFINES.fullToggleLeft),
                                                    wlqData.getActionValue(action: WLQ_DEFINES.fullToggleLeftLongPress),
                                                    wlqData.getActionValue(action: WLQ_DEFINES.fullSignalCancel),
                                                    wlqData.getActionValue(action: WLQ_DEFINES.fullSignalCancelLongPress),
                                                    "",       //RT/K1600
                                                    wlqData.getActionValue(action: WLQ_DEFINES.doublePressSensitivity),
                                                    wlqData.getActionValue(action: WLQ_DEFINES.RTKPage),
                                                    wlqData.getActionValue(action: WLQ_DEFINES.RTKPageDoublePress),
                                                    wlqData.getActionValue(action: WLQ_DEFINES.RTKZoomPlus),
                                                    wlqData.getActionValue(action: WLQ_DEFINES.RTKZoomPlusDoublePress),
                                                    wlqData.getActionValue(action: WLQ_DEFINES.RTKZoomMinus),
                                                    wlqData.getActionValue(action: WLQ_DEFINES.RTKZoomMinusDoublePress),
                                                    wlqData.getActionValue(action: WLQ_DEFINES.RTKSpeak),
                                                    wlqData.getActionValue(action: WLQ_DEFINES.RTKSpeakDoublePress),
                                                    wlqData.getActionValue(action: WLQ_DEFINES.RTKMute),
                                                    wlqData.getActionValue(action: WLQ_DEFINES.RTKMuteDoublePress),
                                                    wlqData.getActionValue(action: WLQ_DEFINES.RTKDisplayOff),
                                                    wlqData.getActionValue(action: WLQ_DEFINES.RTKDisplayOffDoublePress)]
                        
                        actionID = [WLQ_DEFINES.KEYMODE,    //KEYMODE
                                    WLQ_DEFINES.USB,    //USB
                                    -1,       //Full
                                    WLQ_DEFINES.longPressSensitivity,
                                    WLQ_DEFINES.fullScrollUp,
                                    WLQ_DEFINES.fullScrollDown,
                                    WLQ_DEFINES.fullToggleRight,
                                    WLQ_DEFINES.fullToggleRightLongPress,
                                    WLQ_DEFINES.fullToggleLeft,
                                    WLQ_DEFINES.fullToggleLeftLongPress,
                                    WLQ_DEFINES.fullSignalCancel,
                                    WLQ_DEFINES.fullSignalCancelLongPress,
                                    -1,       //RT/K1600
                                    WLQ_DEFINES.doublePressSensitivity,
                                    WLQ_DEFINES.RTKPage,
                                    WLQ_DEFINES.RTKPageDoublePress,
                                    WLQ_DEFINES.RTKZoomPlus,
                                    WLQ_DEFINES.RTKZoomPlusDoublePress,
                                    WLQ_DEFINES.RTKZoomMinus,
                                    WLQ_DEFINES.RTKZoomMinusDoublePress,
                                    WLQ_DEFINES.RTKSpeak,
                                    WLQ_DEFINES.RTKSpeakDoublePress,
                                    WLQ_DEFINES.RTKMute,
                                    WLQ_DEFINES.RTKMuteDoublePress,
                                    WLQ_DEFINES.RTKDisplayOff,
                                    WLQ_DEFINES.RTKDisplayOffDoublePress]
                        
                        if (wlqData.getKeyMode() == wlqData.KEYMODE_CUSTOM()){
                            menuBtn.isHidden = false
                        }
                        if (!wlqData.getConfig().elementsEqual(wlqData.getTempConfig())){
                            print("HWSettingsViewController: !!!Change detected!!!")
                            configButton.setTitle(NSLocalizedString("config_write_label", comment: ""), for: .normal)
                            configButton.isHidden = false
                            configButton.tag = 1
                        }
                    } else {
                        configButton.setTitle(NSLocalizedString("config_reset_label", comment: ""), for: .normal)
                        configButton.isHidden = false
                        configButton.tag = 0
                    }
                }
            }
        } else if (wlqData.gethardwareType() == wlqData.TYPE_X()){
            if (wlqData.getKeyMode() == wlqData.KEYMODE_DEFAULT() || wlqData.getKeyMode() == wlqData.KEYMODE_CUSTOM()
                || wlqData.getKeyMode() == wlqData.KEYMODE_MEDIA()) {
                actionTableLabels = [NSLocalizedString("keymode_label", comment: ""),       //KEYMODE
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
                                                  
                actionTableMappingLabels = [wlqData.getActionValue(action: WLQ_DEFINES.KEYMODE),   //KEYMODE
                                            "",       //Full
                                            wlqData.getActionValue(action: WLQ_DEFINES.longPressSensitivity),
                                            wlqData.getActionValue(action: WLQ_DEFINES.fullScrollUp),
                                            wlqData.getActionValue(action: WLQ_DEFINES.fullScrollDown),
                                            wlqData.getActionValue(action: WLQ_DEFINES.fullToggleRight),
                                            wlqData.getActionValue(action: WLQ_DEFINES.fullToggleRightLongPress),
                                            wlqData.getActionValue(action: WLQ_DEFINES.fullToggleLeft),
                                            wlqData.getActionValue(action: WLQ_DEFINES.fullToggleLeftLongPress),
                                            wlqData.getActionValue(action: WLQ_DEFINES.fullSignalCancel),
                                            wlqData.getActionValue(action: WLQ_DEFINES.fullSignalCancelLongPress),
                                            "",       //RT/K1600
                                            wlqData.getActionValue(action: WLQ_DEFINES.doublePressSensitivity),
                                            wlqData.getActionValue(action: WLQ_DEFINES.RTKPage),
                                            wlqData.getActionValue(action: WLQ_DEFINES.RTKPageDoublePress),
                                            wlqData.getActionValue(action: WLQ_DEFINES.RTKZoomPlus),
                                            wlqData.getActionValue(action: WLQ_DEFINES.RTKZoomPlusDoublePress),
                                            wlqData.getActionValue(action: WLQ_DEFINES.RTKZoomMinus),
                                            wlqData.getActionValue(action: WLQ_DEFINES.RTKZoomMinusDoublePress),
                                            wlqData.getActionValue(action: WLQ_DEFINES.RTKSpeak),
                                            wlqData.getActionValue(action: WLQ_DEFINES.RTKSpeakDoublePress),
                                            wlqData.getActionValue(action: WLQ_DEFINES.RTKMute),
                                            wlqData.getActionValue(action: WLQ_DEFINES.RTKMuteDoublePress),
                                            wlqData.getActionValue(action: WLQ_DEFINES.RTKDisplayOff),
                                            wlqData.getActionValue(action: WLQ_DEFINES.RTKDisplayOffDoublePress)]
                
                actionID = [WLQ_DEFINES.KEYMODE,    //KEYMODE
                            -1,       //Full
                            WLQ_DEFINES.longPressSensitivity,
                            WLQ_DEFINES.fullScrollUp,
                            WLQ_DEFINES.fullScrollDown,
                            WLQ_DEFINES.fullToggleRight,
                            WLQ_DEFINES.fullToggleRightLongPress,
                            WLQ_DEFINES.fullToggleLeft,
                            WLQ_DEFINES.fullToggleLeftLongPress,
                            WLQ_DEFINES.fullSignalCancel,
                            WLQ_DEFINES.fullSignalCancelLongPress,
                            -1,       //RT/K1600
                            WLQ_DEFINES.doublePressSensitivity,
                            WLQ_DEFINES.RTKPage,
                            WLQ_DEFINES.RTKPageDoublePress,
                            WLQ_DEFINES.RTKZoomPlus,
                            WLQ_DEFINES.RTKZoomPlusDoublePress,
                            WLQ_DEFINES.RTKZoomMinus,
                            WLQ_DEFINES.RTKZoomMinusDoublePress,
                            WLQ_DEFINES.RTKSpeak,
                            WLQ_DEFINES.RTKSpeakDoublePress,
                            WLQ_DEFINES.RTKMute,
                            WLQ_DEFINES.RTKMuteDoublePress,
                            WLQ_DEFINES.RTKDisplayOff,
                            WLQ_DEFINES.RTKDisplayOffDoublePress]
                if (wlqData.getAccessories() > 0){
                    actionTableLabels.append(NSLocalizedString("pdm_label", comment: ""))
                    actionTableLabels.append(NSLocalizedString("pdm_channel1_label", comment: ""))
                    actionTableLabels.append(NSLocalizedString("pdm_channel2_label", comment: ""))
                    actionTableMappingLabels.append("")
                    actionTableMappingLabels.append(wlqData.getActionValue(action: WLQ_DEFINES.pdmChannel1))
                    actionTableMappingLabels.append(wlqData.getActionValue(action: WLQ_DEFINES.pdmChannel2))
                    actionID.append(-1)
                    actionID.append(WLQ_DEFINES.pdmChannel1)
                    actionID.append(WLQ_DEFINES.pdmChannel2)
                }
                
                if (wlqData.getKeyMode() == wlqData.KEYMODE_CUSTOM()){
                    menuBtn.isHidden = false
                }
                if (!wlqData.getConfig().elementsEqual(wlqData.getTempConfig())){
                    print("HWSettingsViewController: !!!Change detected!!!")
                    configButton.setTitle(NSLocalizedString("config_write_label", comment: ""), for: .normal)
                    configButton.isHidden = false
                    configButton.tag = 1
                }
            } else {
                configButton.setTitle(NSLocalizedString("config_reset_label", comment: ""), for: .normal)
                configButton.isHidden = false
                configButton.tag = 0
            }
        } else if (wlqData.gethardwareType() == wlqData.TYPE_U()){
            if (wlqData.getKeyMode() == wlqData.KEYMODE_DEFAULT() || wlqData.getKeyMode() == wlqData.KEYMODE_CUSTOM()
                || wlqData.getKeyMode() == wlqData.KEYMODE_MEDIA()) {

                actionTableLabels = [NSLocalizedString("keymode_label", comment: ""),       //KEYMODE
                                     NSLocalizedString("orientation_label", comment: ""),
                                     NSLocalizedString("long_press_label", comment: ""),
                                     NSLocalizedString("up_label", comment: ""),
                                     NSLocalizedString("up_long_label", comment: ""),
                                     NSLocalizedString("down_label", comment: ""),
                                     NSLocalizedString("down_long_label", comment: ""),
                                     NSLocalizedString("left_label", comment: ""),
                                     NSLocalizedString("left_long_label", comment: ""),
                                     NSLocalizedString("right_label", comment: ""),
                                     NSLocalizedString("right_long_label", comment: ""),
                                     NSLocalizedString("fx1_label", comment: ""),
                                     NSLocalizedString("fx1_long_label", comment: ""),
                                     NSLocalizedString("fx2_label", comment: ""),
                                     NSLocalizedString("fx2_long_label", comment: "")]
                                                  
                actionTableMappingLabels = [wlqData.getActionValue(action: WLQ_DEFINES.KEYMODE),
                                            wlqData.getActionValue(action: WLQ_DEFINES.ORIENTATION),
                                            wlqData.getActionValue(action: WLQ_DEFINES.longPressSensitivity),
                                            wlqData.getActionValue(action: WLQ_DEFINES.up),
                                            wlqData.getActionValue(action: WLQ_DEFINES.upLong),
                                            wlqData.getActionValue(action: WLQ_DEFINES.down),
                                            wlqData.getActionValue(action: WLQ_DEFINES.downLong),
                                            wlqData.getActionValue(action: WLQ_DEFINES.left),
                                            wlqData.getActionValue(action: WLQ_DEFINES.leftLong),
                                            wlqData.getActionValue(action: WLQ_DEFINES.right),
                                            wlqData.getActionValue(action: WLQ_DEFINES.rightLong),
                                            wlqData.getActionValue(action: WLQ_DEFINES.fx1),
                                            wlqData.getActionValue(action: WLQ_DEFINES.fx1Long),
                                            wlqData.getActionValue(action: WLQ_DEFINES.fx2),
                                            wlqData.getActionValue(action: WLQ_DEFINES.fx2Long)]
                
                actionID = [WLQ_DEFINES.KEYMODE,
                            WLQ_DEFINES.ORIENTATION,
                            WLQ_DEFINES.longPressSensitivity,
                            WLQ_DEFINES.up,
                            WLQ_DEFINES.upLong,
                            WLQ_DEFINES.down,
                            WLQ_DEFINES.downLong,
                            WLQ_DEFINES.left,
                            WLQ_DEFINES.leftLong,
                            WLQ_DEFINES.right,
                            WLQ_DEFINES.rightLong,
                            WLQ_DEFINES.fx1,
                            WLQ_DEFINES.fx1Long,
                            WLQ_DEFINES.fx2,
                            WLQ_DEFINES.fx2Long]
                
                if (wlqData.getAccessories() > 0){
                    actionTableLabels.append(NSLocalizedString("pdm_label", comment: ""))
                    actionTableLabels.append(NSLocalizedString("pdm_channel1_label", comment: ""))
                    actionTableLabels.append(NSLocalizedString("pdm_channel2_label", comment: ""))
                    actionTableMappingLabels.append("")
                    actionTableMappingLabels.append(wlqData.getActionValue(action: WLQ_DEFINES.pdmChannel1))
                    actionTableMappingLabels.append(wlqData.getActionValue(action: WLQ_DEFINES.pdmChannel2))
                    actionID.append(-1)
                    actionID.append(WLQ_DEFINES.pdmChannel1)
                    actionID.append(WLQ_DEFINES.pdmChannel2)
                }
                
                if (wlqData.getKeyMode() == wlqData.KEYMODE_CUSTOM()){
                    menuBtn.isHidden = true
                }
                if (!wlqData.getConfig().elementsEqual(wlqData.getTempConfig())){
                    print("HWSettingsViewController: !!!Change detected!!!")
                    configButton.setTitle(NSLocalizedString("config_write_label", comment: ""), for: .normal)
                    configButton.isHidden = false
                    configButton.tag = 1
                }
            
            } else {
                configButton.setTitle(NSLocalizedString("config_reset_label", comment: ""), for: .normal)
                configButton.isHidden = false
                configButton.tag = 0
            }
        } else if (wlqData.gethardwareType() == wlqData.TYPE_S()){
            if (wlqData.getKeyMode() == wlqData.KEYMODE_DEFAULT() || wlqData.getKeyMode() == wlqData.KEYMODE_CUSTOM()
                || wlqData.getKeyMode() == wlqData.KEYMODE_MEDIA()) {

                actionTableLabels = [NSLocalizedString("keymode_label", comment: ""),       //KEYMODE
                                     NSLocalizedString("long_press_label", comment: ""),
                                     NSLocalizedString("up_label", comment: ""),
                                     NSLocalizedString("up_long_label", comment: ""),
                                     NSLocalizedString("down_label", comment: ""),
                                     NSLocalizedString("down_long_label", comment: ""),
                                     NSLocalizedString("left_label", comment: ""),
                                     NSLocalizedString("left_long_label", comment: ""),
                                     NSLocalizedString("right_label", comment: ""),
                                     NSLocalizedString("right_long_label", comment: ""),
                                     NSLocalizedString("fx1_label", comment: ""),
                                     NSLocalizedString("fx1_long_label", comment: ""),
                                     NSLocalizedString("fx2_label", comment: ""),
                                     NSLocalizedString("fx2_long_label", comment: "")]
                                                  
                actionTableMappingLabels = [wlqData.getActionValue(action: WLQ_DEFINES.KEYMODE),
                                            wlqData.getActionValue(action: WLQ_DEFINES.longPressSensitivity),
                                            wlqData.getActionValue(action: WLQ_DEFINES.up),
                                            wlqData.getActionValue(action: WLQ_DEFINES.upLong),
                                            wlqData.getActionValue(action: WLQ_DEFINES.down),
                                            wlqData.getActionValue(action: WLQ_DEFINES.downLong),
                                            wlqData.getActionValue(action: WLQ_DEFINES.left),
                                            wlqData.getActionValue(action: WLQ_DEFINES.leftLong),
                                            wlqData.getActionValue(action: WLQ_DEFINES.right),
                                            wlqData.getActionValue(action: WLQ_DEFINES.rightLong),
                                            wlqData.getActionValue(action: WLQ_DEFINES.fx1),
                                            wlqData.getActionValue(action: WLQ_DEFINES.fx1Long),
                                            wlqData.getActionValue(action: WLQ_DEFINES.fx2),
                                            wlqData.getActionValue(action: WLQ_DEFINES.fx2Long)]
                
                actionID = [WLQ_DEFINES.KEYMODE,
                            WLQ_DEFINES.longPressSensitivity,
                            WLQ_DEFINES.up,
                            WLQ_DEFINES.upLong,
                            WLQ_DEFINES.down,
                            WLQ_DEFINES.downLong,
                            WLQ_DEFINES.left,
                            WLQ_DEFINES.leftLong,
                            WLQ_DEFINES.right,
                            WLQ_DEFINES.rightLong,
                            WLQ_DEFINES.fx1,
                            WLQ_DEFINES.fx1Long,
                            WLQ_DEFINES.fx2,
                            WLQ_DEFINES.fx2Long]
                
                if (wlqData.getAccessories() > 0){
                    actionTableLabels.append(NSLocalizedString("pdm_label", comment: ""))
                    actionTableLabels.append(NSLocalizedString("pdm_channel1_label", comment: ""))
                    actionTableLabels.append(NSLocalizedString("pdm_channel2_label", comment: ""))
                    actionTableMappingLabels.append("")
                    actionTableMappingLabels.append(wlqData.getActionValue(action: WLQ_DEFINES.pdmChannel1))
                    actionTableMappingLabels.append(wlqData.getActionValue(action: WLQ_DEFINES.pdmChannel2))
                    actionID.append(-1)
                    actionID.append(WLQ_DEFINES.pdmChannel1)
                    actionID.append(WLQ_DEFINES.pdmChannel2)
                }
                
                if (wlqData.getKeyMode() == wlqData.KEYMODE_CUSTOM()){
                    menuBtn.isHidden = true
                }
                if (!wlqData.getConfig().elementsEqual(wlqData.getTempConfig())){
                    print("HWSettingsViewController: !!!Change detected!!!")
                    configButton.setTitle(NSLocalizedString("config_write_label", comment: ""), for: .normal)
                    configButton.isHidden = false
                    configButton.tag = 1
                }
            
            } else {
                configButton.setTitle(NSLocalizedString("config_reset_label", comment: ""), for: .normal)
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
        print("HWSettingsViewController: resetHWConfig()")
        let alertController = UIAlertController(
            title: NSLocalizedString("hwsave_alert_title", comment: ""),
            message: NSLocalizedString("hwreset_alert_body", comment: ""),
            preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: NSLocalizedString("hwsave_alert_btn_cancel", comment: ""), style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        let openAction = UIAlertAction(title: NSLocalizedString("hwsave_alert_btn_ok", comment: ""), style: .default) { [self] (action) in
            let command = self.wlqData.WRITE_CONFIG_CMD() + wlqData.getDefaultConfig() + self.wlqData.CMD_EOM()
            let writeData =  Data(_: command)
            self.peripheral?.writeValue(writeData, for: self.characteristic!, type: CBCharacteristicWriteType.withResponse)
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(openAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func applyHWConfig(){
        print("HWSettingsViewController: applyHWConfig()")
        let alertController = UIAlertController(
            title: NSLocalizedString("hwsave_alert_title", comment: ""),
            message: NSLocalizedString("hwsave_alert_body", comment: ""),
            preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: NSLocalizedString("hwsave_alert_btn_cancel", comment: ""), style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        let openAction = UIAlertAction(title: NSLocalizedString("hwsave_alert_btn_ok", comment: ""), style: .default) { (action) in
            let command = self.wlqData.WRITE_CONFIG_CMD() + self.wlqData.getTempConfig() + self.wlqData.CMD_EOM()
            let writeData =  Data(_: command)
            self.peripheral?.writeValue(writeData, for: self.characteristic!, type: CBCharacteristicWriteType.withResponse)
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(openAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}
