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

import MapKit
import UIKit

class AlertViewController: UIViewController {
    
    var ID: Int?
    var PHOTO: UIImage?
    
    @IBOutlet var alertUIView: UIView!
    @IBOutlet weak var okButton: LocalisableButton!
    @IBOutlet weak var closeButton: LocalisableButton!
    @IBOutlet weak var alertLabel: UILabel!
    
    let motorcycleData = MotorcycleData.shared

    override var keyCommands: [UIKeyCommand]? {
        
        let commands = [
            UIKeyCommand(input: UIKeyCommand.inputLeftArrow, modifierFlags:[], action: #selector(left)),
            UIKeyCommand(input: UIKeyCommand.inputRightArrow, modifierFlags:[], action: #selector(right))
        ]
        if #available(iOS 15, *) {
            commands.forEach { $0.wantsPriorityOverSystemBehavior = true }
        }
        return commands
    }
    
    @objc func left() {
        //Close
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func right() {
        //Ok
        switch (ID){
        case 1:
            //Navigation
            if let currentLocation = motorcycleData.getLocation() {
                if (!NavAppHelper.navigateToFuel(currentLatitude: currentLocation.coordinate.latitude, currentLongitude: currentLocation.coordinate.longitude)){
                    alertLabel.text = NSLocalizedString("nav_app_feature_not_supported", comment: "")
                }
            }
        case 3:
            exit(0)
        default:
            NSLog("AlertViewController: Unknown Alert ID")
        }
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizer.Direction.right {
            //Close
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func okBtn(_ sender: Any) {
        switch (ID){
        case 1:
            //Navigation
            if let currentLocation = motorcycleData.getLocation() {
                if (!NavAppHelper.navigateToFuel(currentLatitude: currentLocation.coordinate.latitude, currentLongitude: currentLocation.coordinate.longitude)){
                    alertLabel.text = NSLocalizedString("nav_app_feature_not_supported", comment: "")
                }
            }
        case 3:
            exit(0)
        default:
            NSLog("AlertViewController: Unknown Alert ID")
        }
    }
    
    @IBAction func closeBtn(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        if UserDefaults.standard.bool(forKey: "display_brightness_preference") {
            UIScreen.main.brightness = CGFloat(1.0)
        } else {
            UIScreen.main.brightness = CGFloat(UserDefaults.standard.float(forKey: "systemBrightness"))
        }
        
        switch (ID){
        case 1:
            self.navigationItem.title = NSLocalizedString("alert_title_fuel", comment: "")
            alertLabel.text = NSLocalizedString("alert_label_fuel", comment: "")
        case 2:
            self.navigationItem.title = NSLocalizedString("alert_title_photopreview", comment: "")
            alertLabel.text = ""
            okButton.isHidden = true;
            let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
            backgroundImage.image = PHOTO
            backgroundImage.contentMode =  UIView.ContentMode.scaleAspectFill
            self.view.insertSubview(backgroundImage, at: 0)
        case 3:
            self.navigationItem.title = NSLocalizedString("alert_title_ignition", comment: "")
            alertLabel.text = NSLocalizedString("alert_label_ignition", comment: "")
        default:
            NSLog("AlertViewController: Unknown Alert ID")
        }
        
        //Dismiss ViewController after 10secs
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            //Close
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
