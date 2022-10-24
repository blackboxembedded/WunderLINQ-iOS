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

class AccessoryViewController: UIViewController {
    @IBOutlet weak var channelOneView: UIView!
    @IBOutlet weak var channelTwoView: UIView!
    
    
    @IBOutlet weak var channelOneLabel: UILabel!
    @IBOutlet weak var channelTwoLabel: UILabel!
    
    @IBOutlet weak var channelOneProgress: UIProgressView!
    @IBOutlet weak var channelTwoProgress: UIProgressView!
    
    private let notificationCenter = NotificationCenter.default
    
    let wlqData = WLQ.shared
    
    var timer = Timer()
    var refreshTimer = Timer()
    var seconds = 10
    var isTimerRunning = false
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
        isTimerRunning = true
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
        else if gesture.direction == UISwipeGestureRecognizer.Direction.up {
            up()
        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.down {
            down()
        }
    }
    
    @objc func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        
        if longPressGestureRecognizer.state == UIGestureRecognizer.State.began {
            enter()
        }
    }
    
    override var keyCommands: [UIKeyCommand]? {
        
        let commands = [
            UIKeyCommand(input: "\u{d}", modifierFlags:[], action: #selector(enter), discoverabilityTitle: "Enter"),
            UIKeyCommand(input: UIKeyCommand.inputUpArrow, modifierFlags:[], action: #selector(up), discoverabilityTitle: "Up"),
            UIKeyCommand(input: UIKeyCommand.inputDownArrow, modifierFlags:[], action: #selector(down), discoverabilityTitle: "Down"),
            UIKeyCommand(input: UIKeyCommand.inputLeftArrow, modifierFlags:[], action: #selector(leftScreen), discoverabilityTitle: "Left"),
            UIKeyCommand(input: UIKeyCommand.inputRightArrow, modifierFlags:[], action: #selector(rightScreen), discoverabilityTitle: "Right")
        ]
        return commands
    }
    
    
    @objc func enter() {

    }
    
    @objc func up() {
        
    }
    
    @objc func down() {
        
    }
    
    @objc func leftScreen() {
        performSegue(withIdentifier: "accessoryToTasks", sender: [])
    }
    
    @objc func rightScreen() {
        performSegue(withIdentifier: "accessoryToMotorcycle", sender: [])
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        switch(UserDefaults.standard.integer(forKey: "darkmode_preference")){
        case 0:
            //OFF
            return .default
        case 1:
            //On
            return .lightContent
        default:
            //Default
            if #available(iOS 13.0, *) {
                if traitCollection.userInterfaceStyle == .light {
                    return .darkContent
                } else {
                    return .lightContent
                }
            } else {
                return .default
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isTimerRunning == false {
            runTimer()
        }
        
        switch(UserDefaults.standard.integer(forKey: "darkmode_preference")){
        case 0:
            //OFF
            if #available(iOS 13.0, *) {
                overrideUserInterfaceStyle = .light
                self.navigationController?.isNavigationBarHidden = true
                self.navigationController?.isNavigationBarHidden = false
            } else {
                Theme.default.apply()
                self.navigationController?.isNavigationBarHidden = true
                self.navigationController?.isNavigationBarHidden = false
            }
        case 1:
            //On
            if #available(iOS 13.0, *) {
                overrideUserInterfaceStyle = .dark
                self.navigationController?.isNavigationBarHidden = true
                self.navigationController?.isNavigationBarHidden = false
            } else {
                Theme.dark.apply()
                self.navigationController?.isNavigationBarHidden = true
                self.navigationController?.isNavigationBarHidden = false
            }
        default:
            //Default
            if #available(iOS 13.0, *) {
            } else {
                Theme.default.apply()
                self.navigationController?.isNavigationBarHidden = true
                self.navigationController?.isNavigationBarHidden = false
            }
        }
        
        if UserDefaults.standard.bool(forKey: "display_brightness_preference") {
            UIScreen.main.brightness = CGFloat(1.0)
        } else {
            UIScreen.main.brightness = CGFloat(UserDefaults.standard.float(forKey: "systemBrightness"))
        }

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
        
        let forwardBtn = UIButton()
        forwardBtn.setImage(UIImage(named: "Right")?.withRenderingMode(.alwaysTemplate), for: .normal)
        if #available(iOS 13.0, *) {
            forwardBtn.tintColor = UIColor(named: "imageTint")
        }
        forwardBtn.addTarget(self, action: #selector(rightScreen), for: .touchUpInside)
        let forwardButton = UIBarButtonItem(customView: forwardBtn)
        let forwardButtonWidth = forwardButton.customView?.widthAnchor.constraint(equalToConstant: 30)
        forwardButtonWidth?.isActive = true
        let forwardButtonHeight = forwardButton.customView?.heightAnchor.constraint(equalToConstant: 30)
        forwardButtonHeight?.isActive = true

        
        self.navigationItem.title = NSLocalizedString("accessory_title", comment: "")
        self.navigationItem.leftBarButtonItems = [backButton]
        self.navigationItem.rightBarButtonItems = [forwardButton]
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeUp.direction = .up
        self.view.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(VolumeViewController.longPress(longPressGestureRecognizer:)))
        self.view.addGestureRecognizer(longPressRecognizer)
        
        let touchRecognizer = UITapGestureRecognizer(target: self, action:  #selector(VolumeViewController.onTouch))
        self.view.addGestureRecognizer(touchRecognizer)
        
        notificationCenter.addObserver(self, selector:#selector(self.updateScreen), name: NSNotification.Name("StatusUpdate"), object: nil)
        
        updateScreen()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func updateScreen(){
        var highlightColor: UIColor?
        if let colorData = UserDefaults.standard.data(forKey: "highlight_color_preference"){
            highlightColor = NSKeyedUnarchiver.unarchiveObject(with: colorData) as? UIColor
        } else {
            highlightColor = UIColor(named: "accent")
        }
        let channelActive = wlqData.getStatus()[WLQ_C().ACTIVE_CHAN_INDEX]
        let channel1State = wlqData.getStatus()[WLQ_C().LIN_ACC_CHANNEL1_CONFIG_STATE_INDEX]
        let channel2State = wlqData.getStatus()[WLQ_C().LIN_ACC_CHANNEL2_CONFIG_STATE_INDEX]
        
        
        channelOneProgress.progressTintColor = UIColor(red: CGFloat(wlqData.getStatus()[WLQ_C().LIN_ACC_CHANNEL1_PIXEL_R_INDEX]), green: CGFloat(wlqData.getStatus()[WLQ_C().LIN_ACC_CHANNEL1_PIXEL_G_INDEX]), blue: CGFloat(wlqData.getStatus()[WLQ_C().LIN_ACC_CHANNEL1_PIXEL_B_INDEX]), alpha: 1)
        channelTwoProgress.progressTintColor = UIColor(red: CGFloat(wlqData.getStatus()[WLQ_C().LIN_ACC_CHANNEL2_PIXEL_R_INDEX]), green: CGFloat(wlqData.getStatus()[WLQ_C().LIN_ACC_CHANNEL2_PIXEL_G_INDEX]), blue: CGFloat(wlqData.getStatus()[WLQ_C().LIN_ACC_CHANNEL2_PIXEL_B_INDEX]), alpha: 1)
        
        switch (channelActive) {
        case 1:
            channelOneView.layer.borderWidth = 15
            channelOneView.layer.borderColor = highlightColor as! CGColor
            channelTwoView.layer.borderWidth = 0
            channelTwoView.layer.borderColor = nil
            channelOneProgress.progressTintColor = UIColor(red: CGFloat(wlqData.getStatus()[WLQ_C().LIN_ACC_CHANNEL1_PIXEL_R_INDEX]), green: CGFloat(wlqData.getStatus()[WLQ_C().LIN_ACC_CHANNEL1_PIXEL_G_INDEX]), blue: CGFloat(wlqData.getStatus()[WLQ_C().LIN_ACC_CHANNEL1_PIXEL_B_INDEX]), alpha: 1)
            channelTwoProgress.progressTintColor = UIColor(named: "backgrounds")
            break
        case 2:
            channelOneView.layer.borderWidth = 0
            channelOneView.layer.borderColor = nil
            channelTwoView.layer.borderWidth = 15
            channelTwoView.layer.borderColor = highlightColor as! CGColor
            channelOneProgress.progressTintColor = UIColor(named: "backgrounds")
            channelTwoProgress.progressTintColor = UIColor(red: CGFloat(wlqData.getStatus()[WLQ_C().LIN_ACC_CHANNEL2_PIXEL_R_INDEX]), green: CGFloat(wlqData.getStatus()[WLQ_C().LIN_ACC_CHANNEL2_PIXEL_G_INDEX]), blue: CGFloat(wlqData.getStatus()[WLQ_C().LIN_ACC_CHANNEL2_PIXEL_B_INDEX]), alpha: 1)
            break
        default:
            channelOneView.layer.borderWidth = 0
            channelOneView.layer.borderColor = nil
            channelTwoView.layer.borderWidth = 0
            channelTwoView.layer.borderColor = nil
            channelOneProgress.progressTintColor = UIColor(named: "backgrounds")
            channelTwoProgress.progressTintColor = UIColor(named: "backgrounds")
            break
        }
        if (channel1State == 128) {
            channelOneProgress.progress = (Float(wlqData.getStatus()[WLQ_C().LIN_ACC_CHANNEL1_VAL_RAW_INDEX]) / 254.0)
        } else {
            channelOneProgress.progress = 0
        }
        if (channel2State == 128) {
            channelTwoProgress.progress = (Float(wlqData.getStatus()[WLQ_C().LIN_ACC_CHANNEL2_VAL_RAW_INDEX]) / 254.0)
        } else {
            channelTwoProgress.progress = 0
        }
    }
    
}
