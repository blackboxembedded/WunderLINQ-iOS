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

class AccessoryViewController: UIViewController, UITextFieldDelegate {
    
    var backButton: UIBarButtonItem!
    var faultsBtn: UIButton!
    var faultsButton: UIBarButtonItem!
    
    @IBOutlet weak var channelOneView: UIView!
    @IBOutlet weak var channelTwoView: UIView!
    
    @IBOutlet weak var channelOneLabel: UILabel!
    @IBOutlet weak var channelTwoLabel: UILabel!
    @IBOutlet weak var channelOneTextField: UITextField!
    @IBOutlet weak var channelTwoTextField: UITextField!
    
    @IBOutlet weak var channelOneProgress: UIProgressView!
    @IBOutlet weak var channelTwoProgress: UIProgressView!
    
    private let notificationCenter = NotificationCenter.default
    

    let bleData = BLE.shared
    let wlqData = WLQ.shared
    let motorcycleData = MotorcycleData.shared
    let faults = Faults.shared
    
    var peripheral: CBPeripheral?
    var commandCharacteristic: CBCharacteristic?
    
    var timer = Timer()
    var refreshTimer = Timer()
    var seconds = 10
    var isTimerRunning = false
    
    func runTimer() {
        if UserDefaults.standard.bool(forKey: "hide_navbar_preference") {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
            isTimerRunning = true
        }
    }
    
    @objc func updateTimer() {
        if seconds < 1 {
            timer.invalidate()
            isTimerRunning = false
            seconds = 10
            // Hide the navigation bar on the this view controller
            DispatchQueue.main.async(){
                self.navigationController?.setNavigationBarHidden(true, animated: true)
            }
        } else {
            seconds -= 1
        }
    }
    
    @objc func onTouch() {
        DispatchQueue.main.async(){
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
        if isTimerRunning == false {
            runTimer()
        }
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizer.Direction.right {
            rightScreen()
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.left {
            leftScreen()
        }
    }
    
    @objc func longPressOne(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state == UIGestureRecognizer.State.began {
            channelOneLabel.isHidden = true
            channelTwoLabel.isHidden = false
            channelOneTextField.isHidden = false
            channelTwoTextField.isHidden = true
        }
    }
    
    @objc func longPressTwo(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state == UIGestureRecognizer.State.began {
            channelOneLabel.isHidden = false
            channelTwoLabel.isHidden = true
            channelOneTextField.isHidden = true
            channelTwoTextField.isHidden = false
        }
    }
    
    override var keyCommands: [UIKeyCommand]? {
        
        let commands = [
            UIKeyCommand(input: UIKeyCommand.inputLeftArrow, modifierFlags:[], action: #selector(leftScreen)),
            UIKeyCommand(input: UIKeyCommand.inputRightArrow, modifierFlags:[], action: #selector(rightScreen))
        ]
        if #available(iOS 15, *) {
            commands.forEach { $0.wantsPriorityOverSystemBehavior = true }
        }
        return commands
    }
    
    @objc func leftScreen() {
        SoundManager().playSoundEffect("directional")
        let secondViewController = self.storyboard!.instantiateViewController(withIdentifier: "TasksCollectionViewController") as! TasksCollectionViewController
        if let viewControllers = self.navigationController?.viewControllers
        {
            if viewControllers.contains(where: {
                return $0 is TasksCollectionViewController
            })
            {
                 _ = navigationController?.popViewController(animated: true)
                
            } else {
                self.navigationController!.pushViewController(secondViewController, animated: true)
            }
        }
    }
    
    @objc func rightScreen() {
        SoundManager().playSoundEffect("directional")
        navigationController?.popToRootViewController(animated: true)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField == channelOneTextField){
            let channelOneName = channelOneTextField.text
            UserDefaults.standard.set(channelOneName, forKey: "ACC_CHAN_1")
            channelOneLabel.text = channelOneName
            channelOneTextField.text = channelOneName
            channelOneLabel.isHidden = false
            channelTwoLabel.isHidden = false
            channelOneTextField.isHidden = true
            channelTwoTextField.isHidden = true
        } else  if (textField == channelTwoTextField){
            let channelTwoName = channelTwoTextField.text
            UserDefaults.standard.set(channelTwoName, forKey: "ACC_CHAN_2")
            channelTwoLabel.text = channelTwoName
            channelTwoTextField.text = channelTwoName
            channelOneLabel.isHidden = false
            channelTwoLabel.isHidden = false
            channelOneTextField.isHidden = true
            channelTwoTextField.isHidden = true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isTimerRunning == false {
            runTimer()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserDefaults.standard.bool(forKey: "display_brightness_preference") {
            UIScreen.main.brightness = CGFloat(1.0)
        } else {
            UIScreen.main.brightness = CGFloat(UserDefaults.standard.float(forKey: "systemBrightness"))
        }

        let backBtn = UIButton()
        backBtn.setImage(UIImage(named: "Left")?.withRenderingMode(.alwaysTemplate), for: .normal)
        backBtn.tintColor = UIColor(named: "imageTint")
        backBtn.addTarget(self, action: #selector(leftScreen), for: .touchUpInside)
        backButton = UIBarButtonItem(customView: backBtn)
        let backButtonWidth = backButton.customView?.widthAnchor.constraint(equalToConstant: 30)
        backButtonWidth?.isActive = true
        let backButtonHeight = backButton.customView?.heightAnchor.constraint(equalToConstant: 30)
        backButtonHeight?.isActive = true
        
        let forwardBtn = UIButton()
        forwardBtn.setImage(UIImage(named: "Right")?.withRenderingMode(.alwaysTemplate), for: .normal)
        forwardBtn.tintColor = UIColor(named: "imageTint")
        forwardBtn.addTarget(self, action: #selector(rightScreen), for: .touchUpInside)
        let forwardButton = UIBarButtonItem(customView: forwardBtn)
        let forwardButtonWidth = forwardButton.customView?.widthAnchor.constraint(equalToConstant: 30)
        forwardButtonWidth?.isActive = true
        let forwardButtonHeight = forwardButton.customView?.heightAnchor.constraint(equalToConstant: 30)
        forwardButtonHeight?.isActive = true
        faultsBtn = UIButton(type: .custom)
        let faultsImage = UIImage(named: "Alert")?.withRenderingMode(.alwaysTemplate)
        faultsBtn.setImage(faultsImage, for: .normal)
        faultsBtn.tintColor = UIColor.clear
        faultsBtn.accessibilityIgnoresInvertColors = true
        faultsBtn.addTarget(self, action: #selector(self.faultsButtonTapped), for: .touchUpInside)
        faultsButton = UIBarButtonItem(customView: faultsBtn)
        faultsButton.accessibilityRespondsToUserInteraction = false
        faultsButton.isAccessibilityElement = false
        let faultsButtonWidth = faultsButton.customView?.widthAnchor.constraint(equalToConstant: 30)
        faultsButtonWidth?.isActive = true
        let faultsButtonHeight = faultsButton.customView?.heightAnchor.constraint(equalToConstant: 30)
        faultsButtonHeight?.isActive = true
        // Update Buttons
        if (faults.getallActiveDesc().isEmpty){
            faultsBtn.tintColor = UIColor.clear
            faultsButton.isEnabled = false
        } else {
            faultsBtn.tintColor = UIColor(named: "motorrad_red")
            faultsButton.isEnabled = true
        }
        self.navigationItem.title = NSLocalizedString("accessory_title", comment: "")
        self.navigationItem.leftBarButtonItems = [backButton, faultsButton]
        self.navigationItem.rightBarButtonItems = [forwardButton]
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        let longPressOneRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressOne(longPressGestureRecognizer:)))
        self.channelOneView.addGestureRecognizer(longPressOneRecognizer)
        let longPressTwoRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressTwo(longPressGestureRecognizer:)))
        self.channelTwoView.addGestureRecognizer(longPressTwoRecognizer)
        
        let touchRecognizer = UITapGestureRecognizer(target: self, action:  #selector(onTouch))
        self.view.addGestureRecognizer(touchRecognizer)
        
        self.channelOneTextField.delegate = self
        self.channelTwoTextField.delegate = self
        
        self.channelOneProgress.transform = self.channelOneProgress.transform.scaledBy(x: 1, y: 15)
        self.channelTwoProgress.transform = self.channelTwoProgress.transform.scaledBy(x: 1, y: 15)
        
        peripheral = bleData.getPeripheral()
        commandCharacteristic = bleData.getcmdCharacteristic()
        
        notificationCenter.addObserver(self, selector:#selector(self.updateDisplay), name: NSNotification.Name("StatusUpdate"), object: nil)
        
        updateDisplay()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer.invalidate()
        refreshTimer.invalidate()
        seconds = 0
        // Show the navigation bar on other view controllers
        DispatchQueue.main.async(){
            self.navigationController?.setNavigationBarHidden(false, animated: animated)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Updating UI
    @objc func updateDisplay(){
        let channelOneName = UserDefaults.standard.string(forKey: "ACC_CHAN_1")
        if channelOneName != nil {
            channelOneLabel.text = channelOneName
            channelOneTextField.text = channelOneName
        } else {
            channelOneLabel.text = NSLocalizedString("default_accessory_one_name", comment: "")
            channelOneTextField.text = NSLocalizedString("default_accessory_one_name", comment: "")
        }
        let channelTwoName = UserDefaults.standard.string(forKey: "ACC_CHAN_2")
        if channelTwoName != nil {
            channelTwoLabel.text = channelTwoName
            channelTwoTextField.text = channelTwoName
        } else {
            channelTwoLabel.text = NSLocalizedString("default_accessory_two_name", comment: "")
            channelTwoTextField.text = NSLocalizedString("default_accessory_two_name", comment: "")
        }
        if (wlqData.getStatus() != nil){
            var highlightColor: UIColor?
            if let colorData = UserDefaults.standard.data(forKey: "highlight_color_preference"){
                highlightColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData)
            } else {
                highlightColor = UIColor(named: "accent")
            }
            let channelActive = wlqData.getAccActive()
            switch (channelActive) {
            case 2:
                channelOneView.layer.borderWidth = 10
                channelOneView.layer.borderColor = highlightColor?.cgColor
                channelTwoView.layer.borderWidth = 0
                channelTwoView.layer.borderColor = nil
                channelOneProgress.tintColor = highlightColor
                channelTwoProgress.tintColor = UIColor(named: "imageTint")
                break
            case 3:
                channelOneView.layer.borderWidth = 0
                channelOneView.layer.borderColor = nil
                channelTwoView.layer.borderWidth = 10
                channelTwoView.layer.borderColor = highlightColor?.cgColor
                channelOneProgress.tintColor = UIColor(named: "imageTint")
                channelTwoProgress.tintColor = highlightColor
                break
            default:
                channelOneView.layer.borderWidth = 0
                channelOneView.layer.borderColor = nil
                channelTwoView.layer.borderWidth = 0
                channelTwoView.layer.borderColor = nil
                channelOneProgress.tintColor = UIColor(named: "imageTint")
                channelTwoProgress.tintColor = UIColor(named: "imageTint")
                break
            }
            channelOneProgress.setProgress((Float(wlqData.getAccChannelValue(positon: 1)) / 4.0), animated: true)
            channelTwoProgress.setProgress((Float(wlqData.getAccChannelValue(positon: 2)) / 4.0), animated: true)
        } else {
            let writeData =  Data(_: wlqData.GET_STATUS_CMD())
            peripheral!.writeValue(writeData, for: commandCharacteristic!, type: CBCharacteristicWriteType.withResponse)
        }
    }
    
    @objc func faultsButtonTapped() {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "FaultsTableViewController") as! FaultsTableViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
