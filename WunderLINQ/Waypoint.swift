//
//  Waypoint.swift
//  WunderLINQ
//
//  Created by Keith Conger on 6/22/18.
//  Copyright © 2018 Black Box Embedded, LLC. All rights reserved.
//

import Foundation
class Waypoint {
    
    var id: Int
    var date: String?
    var longitude: String?
    var latitude: String?
    var label: String?
    
    init(id: Int, date: String?, latitude: String?, longitude: String?, label: String?){
        self.id = id
        self.date = date
        self.longitude = longitude
        self.latitude = latitude
        self.label = label
    }
}
