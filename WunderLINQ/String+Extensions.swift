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
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        return formatter.number(from: self)?.doubleValue
    }
    
    func toInt() -> Int? {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        return formatter.number(from: self)?.intValue
    }
}
