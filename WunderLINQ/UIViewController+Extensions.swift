//
//  UIViewController+Extensions.swift
//  WunderLINQ
//
//  Created by Keith Conger on 6/22/18.
//  Copyright © 2018 Black Box Embedded, LLC. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func showToast(message : String) {
        let toastLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width - 20, height: 70))
        toastLabel.center = self.view.center
        toastLabel.numberOfLines = 0
        if #available(iOS 13.0, *) {
            toastLabel.backgroundColor = UIColor(named: "imageTint")
            toastLabel.textColor = UIColor(named: "backgrounds")
        } else {
            switch(UserDefaults.standard.integer(forKey: "darkmode_preference")){
            case 0:
                //OFF
                toastLabel.backgroundColor = UIColor.black
                toastLabel.textColor = UIColor.white
            case 1:
                //On
                toastLabel.backgroundColor = UIColor.white
                toastLabel.textColor = UIColor.black
            default:
                //Default
                toastLabel.backgroundColor = UIColor.black
                toastLabel.textColor = UIColor.white
            }
        }
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont.boldSystemFont(ofSize: 20)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 5.0, delay: 1.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}

