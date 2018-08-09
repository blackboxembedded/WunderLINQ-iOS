//
//  Tasks.swift
//  WunderLINQ
//
//  Created by Keith Conger on 9/2/17.
//  Copyright © 2017 Keith Conger. All rights reserved.
//

import Foundation
import UIKit

class Tasks {
    
    //MARK: Properties
    
    var label: String
    var icon: UIImage?
    
    //MARK: Initialization
    
    init?(label: String, icon: UIImage?) {
        
        // The name must not be empty
        guard !label.isEmpty else {
            return nil
        }
        
        // Initialize stored properties.
        self.label = label
        self.icon = icon
        
    }
}
