//
//  AboutViewController.swift
//  WunderLINQ
//
//  Created by Keith Conger on 11/13/18.
//  Copyright © 2018 Black Box Embedded, LLC. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var creditsTextView: UITextView!
    
    @IBAction func appNameBtnPressed(_ sender: Any) {
        guard let url = URL(string: "http://www.wunderlinq.com") else {
            return //be safe
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    @IBAction func corpNameBtnPressed(_ sender: Any) {
        guard let url = URL(string: "https://www.blackboxembedded.com") else {
            return //be safe
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    @objc func leftScreen() {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizerDirection.right {
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
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.async(execute: { () -> Void in
             self.creditsTextView.scrollRangeToVisible(NSMakeRange(0, 0))
        })
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
