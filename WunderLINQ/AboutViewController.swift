//
//  AboutViewController.swift
//  WunderLINQ
//
//  Created by Keith Conger on 11/13/18.
//  Copyright © 2018 Black Box Embedded, LLC. All rights reserved.
//

import UIKit
import MessageUI
import MobileCoreServices

class AboutViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var creditsTextView: UITextView!
    
    @IBAction func corpNameBtnPressed(_ sender: Any) {
        guard let url = URL(string: "https://www.blackboxembedded.com") else {
            return //be safe
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    @IBAction func sendLogsBtnPressed(_ sender: Any) {
        if MFMailComposeViewController.canSendMail() {
            let mailComposer = MFMailComposeViewController()
            mailComposer.setSubject("WunderLINQ Debug Logs")
            mailComposer.setMessageBody("App Version: \(getAppInfo())\niOS Version: \(getOSInfo())\nDevice: \(UIDevice.current.modelName)\n\(NSLocalizedString("sendlogs_body", comment: ""))", isHTML: false)
            mailComposer.setToRecipients(["support@blackboxembedded.com"])
            // Get the documents folder url
            let documentDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            // Destination url for the log file to be saved
            let fileURL = documentDirectory.appendingPathComponent("dbg")
            let logURL = documentDirectory.appendingPathComponent("wunderlinq.log")
            do {
                let attachmentData = try Data(contentsOf: fileURL)
                mailComposer.addAttachmentData(attachmentData, mimeType: "text/csv", fileName: "dbg")
            } catch let error {
                NSLog("We have encountered error \(error.localizedDescription)")
            }
            do {
                let logAttachmentData = try Data(contentsOf: logURL)
                mailComposer.addAttachmentData(logAttachmentData, mimeType: "text/log", fileName: "wunderlinq.log")
            } catch let error {
                NSLog("We have encountered error \(error.localizedDescription)")
            }
            mailComposer.mailComposeDelegate = self
            self.present(mailComposer, animated: true
                , completion: nil)
            
        } else {
            NSLog("Email is not configured in settings app or we are not able to send an email")
        }
    }
    
    @objc func leftScreen() {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func logoTap() {
        guard let url = URL(string: "http://www.wunderlinq.com") else {
            return //be safe
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizer.Direction.right {
            navigationController?.popViewController(animated: true)
            dismiss(animated: true, completion: nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        AppUtility.lockOrientation(.portrait)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
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
        self.navigationItem.title = NSLocalizedString("about_title", comment: "")
        self.navigationItem.leftBarButtonItems = [backButton]
        
        if UserDefaults.standard.bool(forKey: "display_brightness_preference") {
            UIScreen.main.brightness = CGFloat(1.0)
        } else {
            UIScreen.main.brightness = CGFloat(UserDefaults.standard.float(forKey: "systemBrightness"))
        }
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            let versionLabelString = NSLocalizedString("version_label", comment: "")
            self.versionLabel.text = "\(versionLabelString) \(version)"
        }
        
        logoImageView.isUserInteractionEnabled = true
        let singleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(logoTap))
        singleTap.numberOfTapsRequired = 1;
        logoImageView.addGestureRecognizer(singleTap)
        
        self.view.addSubview(logoImageView)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.async(execute: { () -> Void in
             self.creditsTextView.scrollRangeToVisible(NSMakeRange(0, 0))
        })
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        UserDefaults.standard.set(false, forKey: "debug_logging_preference")
        var shouldDelete = true
        switch result {
        case .cancelled:
            NSLog("User cancelled")
            shouldDelete = false
            break
        case .saved:
            NSLog("Mail is saved by user")
            shouldDelete = true
            break
        case .sent:
            NSLog("Mail is sent successfully")
            shouldDelete = true
            break
        case .failed:
            NSLog("Sending mail is failed")
            shouldDelete = false
            break
        default:
            break
        }
        if (shouldDelete){
            // Get the documents folder url
            let documentDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            // Destination url for the log file to be saved
            let fileURL = documentDirectory.appendingPathComponent("dbg")
            do {
                try FileManager.default.removeItem(at: fileURL)
            } catch _ as NSError {
                //NSLog("Error: \(error.domain)")
            }
        }
        controller.dismiss(animated: true)
    }
    
    func getOSInfo()->String {
        let os = ProcessInfo().operatingSystemVersion
        return String(os.majorVersion) + "." + String(os.minorVersion) + "." + String(os.patchVersion)
    }
    
    func getAppInfo()->String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        return version + "(" + build + ")"
    }
}

extension UIDevice {
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
