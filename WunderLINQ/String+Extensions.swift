//
//  String+Extensions.swift
//  WunderLINQ
//
//  Created by Keith Conger on 7/26/18.
//  Copyright © 2018 Black Box Embedded, LLC. All rights reserved.
//

import Foundation
extension String {
    func toDouble() -> Double? {
        return NumberFormatter().number(from: self)?.doubleValue
    }
}
