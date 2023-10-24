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
import MessageUI
import MobileCoreServices

class AboutViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var creditsTextView: UITextView!

    let wlqData = WLQ.shared
    
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
    
    @IBAction func documentationBtnPressed(_ sender: Any) {
        guard let url = URL(string: "https://blackboxembedded.github.io/WunderLINQ-Documentation/") else {
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
            var dateFormatter: DateFormatter {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyyMMdd-HH:mm"
                formatter.locale = Locale(identifier: "en_US")
                formatter.timeZone = TimeZone.current
                return formatter
            }
            let today = dateFormatter.string(from: Date())
            let firmwareVersion = String(UserDefaults.standard.string(forKey: "firmwareVersion") ?? "Unknown")
            let mailComposer = MFMailComposeViewController()
            mailComposer.setSubject("WunderLINQ iOS Support: \(today)")
            mailComposer.setMessageBody("App Version: \(getAppInfo())\nFirmware Version: \(firmwareVersion)\niOS Version: \(getOSInfo())\nDevice: \(UIDevice.current.modelName)\n\(NSLocalizedString("sendlogs_body", comment: ""))", isHTML: false)
            mailComposer.setToRecipients(["support@blackboxembedded.com"])
            // Get the documents folder url
            let documentDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            // Destination url for the log file to be saved
            let logURL = documentDirectory.appendingPathComponent("wunderlinq.log")
            do {
                let logAttachmentData = try Data(contentsOf: logURL)
                mailComposer.addAttachmentData(logAttachmentData, mimeType: "text/log", fileName: "wunderlinq.log")
            } catch let error {
                NSLog("AboutViewController: We have encountered error \(error.localizedDescription)")
            }
            mailComposer.mailComposeDelegate = self
            self.present(mailComposer, animated: true, completion: nil)
            
        } else {
            NSLog("AboutViewController: Email is not configured in settings app or we are not able to send an email")
        }
    }
    
    @objc func leftScreen() {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func logoTap() {
        let url = URL(string: "http://www.wunderlinq.com")!

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
        
        self.versionLabel.text = NSLocalizedString("version_label", comment: "") + " " + NSLocalizedString("app_ver_label", comment: "") + " " + getAppInfo() + " " + NSLocalizedString("fw_ver_label", comment: "") + " " + String(UserDefaults.standard.string(forKey: "firmwareVersion") ?? "Unknown")
        
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
        switch result {
        case .cancelled:
            NSLog("AboutViewController: User cancelled")
            break
        case .saved:
            NSLog("AboutViewController: Mail is saved by user")
            break
        case .sent:
            NSLog("AboutViewController: Mail is sent successfully")
            break
        case .failed:
            NSLog("AboutViewController: Sending mail is failed")
            break
        default:
            break
        }
        controller.dismiss(animated: true)
    }
    
    func getOSInfo() -> String {
        let os = ProcessInfo.processInfo.operatingSystemVersion
        return String(os.majorVersion) + "." + String(os.minorVersion) + "." + String(os.patchVersion)
    }
    
    func getAppInfo() -> String {
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
