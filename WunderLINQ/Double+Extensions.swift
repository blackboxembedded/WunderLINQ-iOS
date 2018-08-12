//
//  Double+Extensions.swift
//  WunderLINQ
//
//  Created by Keith Conger on 8/10/18.
//  Copyright © 2018 Black Box Embedded, LLC. All rights reserved.
//

import Foundation

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
