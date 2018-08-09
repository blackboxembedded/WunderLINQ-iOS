//
//  LocalisableLabel.swift
//  WunderLINQ
//
//  Created by Keith Conger on 8/9/18.
//  Copyright © 2018 Black Box Embedded, LLC. All rights reserved.
//

import Foundation
import UIKit

class LocalisableLabel: UILabel {
    
    @IBInspectable var localisedKey: String? {
        didSet {
            guard let key = localisedKey else { return }
            text = NSLocalizedString(key, comment: "")
        }
    }
}
