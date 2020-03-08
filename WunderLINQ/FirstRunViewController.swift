//
//  FirstRunViewController.swift
//  WunderLINQ
//
//  Created by Keith Conger on 3/2/20.
//  Copyright © 2020 Black Box Embedded, LLC. All rights reserved.
//

import AVFoundation
import Contacts
import CoreLocation
import MediaPlayer
import Photos
import UIKit
import UserNotifications

class FirstRunViewController: UIViewController {
    
    var step:Int = 0
    
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var nextButton: LocalisableButton!
    @IBOutlet weak var messageTextField: LocalisableLabel!
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        switch (step){
        case 0:
            messageTextField.text = NSLocalizedString("contacts_alert_body", comment: "")
            step = step + 1
        case 1:
            //Contacts
            messageTextField.text = NSLocalizedString("camera_alert_body", comment: "")
            
            let store = CNContactStore()
            store.requestAccess(for: .contacts) { granted, error in
                if granted {
                    // Authorized
                    //Nothing to do
                    NSLog("Allowed to access contacts")
                } else {
                    // Not allowed
                    NSLog("Not Allowed to access contacts")
                }
            }
            step = step + 1
            break
        case 2:
            //  Camera permission
            messageTextField.text = NSLocalizedString("record_audio_alert_body", comment: "")
            
            AVCaptureDevice.requestAccess(for: AVMediaType(rawValue: AVMediaType.video.rawValue), completionHandler: { (granted: Bool) -> Void in
                if granted == true {
                    // Authorized
                    //Nothing to do
                    NSLog("Allowed to access to Camera")
                } else {
                    // Not allowed
                    // Prompt with warning and button to settings
                    NSLog("Not Allowed to access Camera")
                }
            })
            step = step + 1
            break
        case 3:
            // Microphone permission
            messageTextField.text = NSLocalizedString("write_photo_alert_body", comment: "")

            AVCaptureDevice.requestAccess(for: AVMediaType(rawValue: AVMediaType.audio.rawValue), completionHandler: { (granted: Bool) -> Void in
                if granted == true {
                    // Authorized
                    //Nothing to do
                    NSLog("Allowed to access to Microphone")
                } else {
                    // Not allowed
                    // Prompt with warning and button to settings
                    NSLog("Not Allowed to access to Microphone")
                }
            })
            step = step + 1
            break
        case 4:
            //Save to Photo Library Permission
            messageTextField.text = NSLocalizedString("read_media_alert_body", comment: "")
            
            PHPhotoLibrary.requestAuthorization({status in
                if status == .authorized{
                    // Authorized
                    //Nothing to do
                    NSLog("Allowed to access the Photo Library")
                } else {
                    NSLog("Not Allowed to access the Photo Library")
                }
            })
            step = step + 1
            break
        case 5:
            //Play from Media Library Permission
            messageTextField.text = NSLocalizedString("location_alert_body", comment: "")
            
            MPMediaLibrary.requestAuthorization() { status in
                if status == .authorized{
                    // Authorized
                    //Nothing to do
                    NSLog("Allowed to access the Media Library")
                } else {
                    NSLog("Not Allowed to access the Media Library")
                }
            }
            step = step + 1
            break
        case 6:
            //Location
            messageTextField.text = NSLocalizedString("notification_alert_body", comment: "")

            if CLLocationManager.authorizationStatus() == .authorizedAlways {
                NSLog("Allowed Always Location Access")
            } else {
                NSLog("Not Allowed Location Access")
                locationManager.requestAlwaysAuthorization()
            }
            step = step + 1
            break
        case 7:
            // Notification Permissions
            messageTextField.text = NSLocalizedString("firstrun_end", comment: "")
            
            UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                if (settings.authorizationStatus == .authorized){
                    NSLog("Allowed to use Notifications")
                } else {
                    if #available(iOS 10.0, *) {
                        let center  = UNUserNotificationCenter.current()

                        center.requestAuthorization(options: [.sound, .alert, .badge]) { (granted, error) in
                            if error == nil{
                                NSLog("Allowed to use Notifications")
                            }
                        }

                    }
                    NSLog("Not Allowed to use Notifications")
                }
            }
            step = step + 1
            break
        case 8:
            UserDefaults.standard.set(true, forKey: "firstRun")
            
            let story = UIStoryboard(name: "Main", bundle:nil)
            let vc = story.instantiateViewController(withIdentifier: "NavController")
            UIApplication.shared.windows.first?.rootViewController = vc
            UIApplication.shared.windows.first?.makeKeyAndVisible()
            break
        default:
            let story = UIStoryboard(name: "Main", bundle:nil)
            let vc = story.instantiateViewController(withIdentifier: "NavController")
            UIApplication.shared.windows.first?.rootViewController = vc
            UIApplication.shared.windows.first?.makeKeyAndVisible()
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageTextField.text = NSLocalizedString("firstrun_start", comment: "")
        
    }
    
}
