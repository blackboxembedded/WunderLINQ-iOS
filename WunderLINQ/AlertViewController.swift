//
//  AlertViewController.swift
//  WunderLINQ
//
//  Created by Keith Conger on 10/28/18.
//  Copyright © 2018 Black Box Embedded, LLC. All rights reserved.
//

import MapKit
import UIKit

class AlertViewController: UIViewController {
    
    var ID: Int?
    
    @IBOutlet weak var alertLabel: UILabel!

    override var keyCommands: [UIKeyCommand]? {
        
        let commands = [
            UIKeyCommand(input: UIKeyInputLeftArrow, modifierFlags:[], action: #selector(left), discoverabilityTitle: "Close"),
            UIKeyCommand(input: UIKeyInputLeftArrow, modifierFlags:[], action: #selector(right), discoverabilityTitle: "Ok")
        ]
        return commands
    }
    
    @objc func left() {
        //Close
    }
    
    @objc func right() {
        //Ok
    }
    
    func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizerDirection.right {
            //Close
            
        }
    }
    
    @IBAction func okBtn(_ sender: Any) {
        switch (ID){
        case 1:
            //Navigation
            let navApp = UserDefaults.standard.integer(forKey: "nav_app_preference")
            switch (navApp){
            case 0:
                //Apple Maps
                if let googleMapsURL = URL(string: "http://maps.apple.com/?q=fuel+station") {
                    if (UIApplication.shared.canOpenURL(googleMapsURL)) {
                        if #available(iOS 10, *) {
                            UIApplication.shared.open(googleMapsURL, options: [:], completionHandler: nil)
                        } else {
                            UIApplication.shared.openURL(googleMapsURL as URL)
                        }
                    }
                }
            case 1:
                //Google Maps
                //google.navigation:q=fuel+station
                if let googleMapsURL = URL(string: "comgooglemaps-x-callback://?q=fuel+station&directionsmode=driving&x-success=wunderlinq://?resume=true&x-source=WunderLINQ") {
                    if (UIApplication.shared.canOpenURL(googleMapsURL)) {
                        if #available(iOS 10, *) {
                            UIApplication.shared.open(googleMapsURL, options: [:], completionHandler: nil)
                        } else {
                            UIApplication.shared.openURL(googleMapsURL as URL)
                        }
                    }
                }
            case 4:
                //Waze
                if let wazeURL = URL(string: "https://waze.com/ul?q=fuel+station&navigate=yes") {
                    if (UIApplication.shared.canOpenURL(wazeURL)) {
                        if #available(iOS 10, *) {
                            UIApplication.shared.open(wazeURL, options: [:], completionHandler: nil)
                        } else {
                            UIApplication.shared.openURL(wazeURL as URL)
                        }
                    }
                }
            default:
                //Apple Maps
                if let googleMapsURL = URL(string: "http://maps.apple.com/?q=fuel+station") {
                    if (UIApplication.shared.canOpenURL(googleMapsURL)) {
                        if #available(iOS 10, *) {
                            UIApplication.shared.open(googleMapsURL, options: [:], completionHandler: nil)
                        } else {
                            UIApplication.shared.openURL(googleMapsURL as URL)
                        }
                    }
                }
            }
        default:
            print("Unknown Alert ID")
        }
    }
    
    @IBAction func closeBtn(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UserDefaults.standard.bool(forKey: "nightmode_preference") {
            Theme.dark.apply()
            self.navigationController?.isNavigationBarHidden = true
            self.navigationController?.isNavigationBarHidden = false
        } else {
            Theme.default.apply()
            self.navigationController?.isNavigationBarHidden = true
            self.navigationController?.isNavigationBarHidden = false
        }
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        self.navigationItem.title = NSLocalizedString("alert_title_fuel", comment: "")
        
        if UserDefaults.standard.bool(forKey: "display_brightness_preference") {
            UIScreen.main.brightness = CGFloat(1.0)
        } else {
            UIScreen.main.brightness = CGFloat(UserDefaults.standard.float(forKey: "systemBrightness"))
        }
        
        switch (ID){
        case 1:
            alertLabel.text = NSLocalizedString("alert_label_fuel", comment: "")
        default:
            print("Unknown Alert ID")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
