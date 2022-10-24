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
import MediaPlayer

class VolumeViewController: UIViewController {
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var progressBar: UIProgressView!
    
    var preMuteVolume:Float = 0.0
    
    var hiddenSystemVolumeSlider: UISlider!
    
    var systemVolume:Float {
        get {
            return hiddenSystemVolumeSlider.value
        }
        set {
            hiddenSystemVolumeSlider.value = newValue
            if (newValue == 0.0){
                image.image = UIImage(named: "Mute")?.withRenderingMode(.alwaysTemplate)
            } else {
                image.image = UIImage(named: "Speaker")?.withRenderingMode(.alwaysTemplate)
            }
        }
    }
    
    @objc func onTouch() {

    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizer.Direction.right {
            right()
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
            UIKeyCommand(input: UIKeyCommand.inputRightArrow, modifierFlags:[], action: #selector(right), discoverabilityTitle: "Right")
        ]
        return commands
    }
    
    
    @objc func enter() {

    }
    
    @objc func up() {
        systemVolume = systemVolume + 0.1
        progressBar.progress = systemVolume
    }
    
    @objc func down() {
        systemVolume = systemVolume - 0.1
        progressBar.progress = systemVolume
    }
    
    @objc func leftScreen() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @objc func right() {
        if (systemVolume == 0.0){
            systemVolume = preMuteVolume
            progressBar.progress = systemVolume
        } else {
            preMuteVolume = systemVolume;
            systemVolume = 0.0
            progressBar.progress = systemVolume
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        self.navigationItem.title = NSLocalizedString("systemvolume_title", comment: "")
        self.navigationItem.leftBarButtonItems = [backButton]
        
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
        
        var highlightColor: UIColor?
        if let colorData = UserDefaults.standard.data(forKey: "highlight_color_preference"){
            highlightColor = NSKeyedUnarchiver.unarchiveObject(with: colorData) as? UIColor
        } else {
            highlightColor = UIColor(named: "accent")
        }
        progressBar.progressTintColor = highlightColor
        progressBar.transform = progressBar.transform.scaledBy(x: 1, y: 15)
        
        let volumeView = MPVolumeView(frame: CGRect(x: -CGFloat.greatestFiniteMagnitude, y:0, width:0, height:0))
        view.addSubview(volumeView)
            hiddenSystemVolumeSlider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            if (self.systemVolume == 0.0){
                self.image.image = UIImage(named: "Mute")?.withRenderingMode(.alwaysTemplate)
            } else {
                self.image.image = UIImage(named: "Speaker")?.withRenderingMode(.alwaysTemplate)
            }
            self.progressBar.progress = self.systemVolume
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
