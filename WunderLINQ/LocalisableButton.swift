//
//  LocalisableButton.swift
//  WunderLINQ
//
//  Created by Keith Conger on 8/9/18.
//  Copyright © 2018 Black Box Embedded, LLC. All rights reserved.
//

import Foundation
import UIKit

class LocalisableButton: UIButton {
    
    @IBInspectable var localisedKey: String? {
        didSet {
            guard let key = localisedKey else { return }
            UIView.performWithoutAnimation {
                setTitle(NSLocalizedString(key, comment: ""), for: .normal)
                layoutIfNeeded()
            }
        }
    }
}
