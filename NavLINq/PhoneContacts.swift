//
//  PhoneContact.swift
//  NavLINq
//
//  Created by Keith Conger on 10/2/17.
//  Copyright © 2017 Keith Conger. All rights reserved.
//

import Foundation
import UIKit

class PhoneContacts {
    
    //MARK: Properties
    
    var name: String
    var number: String
    var numberDescription: String
    var photo: UIImage?
    
    //MARK: Initialization
    
    init?(name: String, number: String, numberDescription: String, photo: UIImage?) {
    
    // The number must not be empty
    guard !number.isEmpty else {
    return nil
    }
    
    // Initialize stored properties.
    self.name = name
    self.number = number
    self.numberDescription = numberDescription
    self.photo = photo
    
    }
}
