//
//  BikeInfoViewController.swift
//  WunderLINQ
//
//  Created by Keith Conger on 8/9/19.
//  Copyright © 2019 Black Box Embedded, LLC. All rights reserved.
//

import UIKit
import MessageUI
import MobileCoreServices

class BikeInfoViewController: UIViewController {
    
    @IBOutlet weak var vinValueLabel: UILabel!
    @IBOutlet weak var nextServiceDateLabel: UILabel!
    @IBOutlet weak var nextServiceLabel: UILabel!
    
    let motorcycleData = MotorcycleData.shared
    
    @objc func leftScreen() {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
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
        self.navigationItem.title = NSLocalizedString("bike_info_title", comment: "")
        self.navigationItem.leftBarButtonItems = [backButton]
        
        if UserDefaults.standard.bool(forKey: "display_brightness_preference") {
            UIScreen.main.brightness = CGFloat(1.0)
        } else {
            UIScreen.main.brightness = CGFloat(UserDefaults.standard.float(forKey: "systemBrightness"))
        }
        
        if (motorcycleData.vin != nil){
            vinValueLabel.text = motorcycleData.getVIN()
        }
        if (motorcycleData.nextServiceDate != nil){
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/d"
            nextServiceDateLabel.text = formatter.string(from: motorcycleData.getNextServiceDate())
        }
        if (motorcycleData.nextService != nil){
            if UserDefaults.standard.integer(forKey: "distance_unit_preference") == 1 {
                nextServiceLabel.text = "\(Int(round(Utility.kmToMiles(Double(motorcycleData.getNextService())))))(mi)"
            } else {
                nextServiceLabel.text = "\(motorcycleData.getNextService())(km)"
            }
        }
        
    }
}
