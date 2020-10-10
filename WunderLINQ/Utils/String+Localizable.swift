//
//  String+Localizable.swift
//  WunderLINQ
//
//  Created by Matteo Comisso on 07/10/2020.
//  Copyright © 2020 Black Box Embedded, LLC. All rights reserved.
//

import Foundation

extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}
