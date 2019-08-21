//
//  NSLocalizedString.swift
//  WunderLINQ
//
//  Created by Keith Conger on 8/20/19.
//  Copyright © 2019 Black Box Embedded, LLC. All rights reserved.
//

import Foundation

public func NSLocalizedString(_ key: String, tableName: String? = nil, bundle: Bundle = Bundle.main, value: String = "", comment: String) -> String {
    var result = Bundle.main.localizedString(forKey: key, value: nil, table: nil)
    if result == key || result == ""{
        let fallbackLanguage = "Base"
        guard let fallbackBundlePath = Bundle.main.path(forResource: fallbackLanguage, ofType: "lproj") else { return key }
        guard let fallbackBundle = Bundle(path: fallbackBundlePath) else { return key }
        result = fallbackBundle.localizedString(forKey: key, value: comment, table: nil)
    }
    return result
}
