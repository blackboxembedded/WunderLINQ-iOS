//
//  CompassViewController.swift
//  NavLINq
//
//  Created by Keith Conger on 8/13/17.
//  Copyright © 2017 Keith Conger. All rights reserved.
//

import UIKit
import CoreLocation

class CompassViewController: UIViewController {
    @IBOutlet weak var compassLabel: UILabel!
    
    let locationDelegate = LocationDelegate()
    var latestLocation: CLLocation? = nil
    var yourLocationBearing: CGFloat { return latestLocation?.bearingToLocationRadian(self.yourLocation) ?? 0 }
    var yourLocation: CLLocation {
        get { return UserDefaults.standard.currentLocation }
        set { UserDefaults.standard.currentLocation = newValue }
    }
    
    let locationManager: CLLocationManager = {
        $0.requestWhenInUseAuthorization()
        $0.desiredAccuracy = kCLLocationAccuracyBest
        $0.startUpdatingLocation()
        $0.startUpdatingHeading()
        return $0
    }(CLLocationManager())
    
    private func orientationAdjustment() -> CGFloat {
        let isFaceDown: Bool = {
            switch UIDevice.current.orientation {
            case .faceDown: return true
            default: return false
            }
        }()
        
        let adjAngle: CGFloat = {
            switch UIApplication.shared.statusBarOrientation {
            case .landscapeLeft:  return 90
            case .landscapeRight: return -90
            case .portrait, .unknown: return 0
            case .portraitUpsideDown: return isFaceDown ? 180 : -180
            }
        }()
        return adjAngle
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = locationDelegate
        
        locationDelegate.locationCallback = { location in
            self.latestLocation = location
        }
        
        locationDelegate.headingCallback = { newHeading in
            
            func computeNewAngle(with newAngle: CGFloat) -> CGFloat {
                let heading: CGFloat = {
                    let originalHeading = self.yourLocationBearing - newAngle.degreesToRadians
                    switch UIDevice.current.orientation {
                    case .faceDown: return -originalHeading
                    default: return originalHeading
                    }
                }()
                
                return CGFloat(self.orientationAdjustment().degreesToRadians + heading)
            }
            let angle = computeNewAngle(with: CGFloat(newHeading))
            let degrees = abs(Int(angle.radiansToDegrees))
            var bearing = "-"
            
            if degrees > 331 || degrees <= 28 {
                bearing = "N"
            } else if degrees > 28 && degrees <= 73 {
                bearing = "NE"
            } else if degrees > 73 && degrees <= 118 {
                bearing = "E"
            } else if degrees > 118 && degrees <= 163 {
                bearing = "SE"
            } else if degrees > 163 && degrees <= 208 {
                bearing = "S"
            } else if degrees > 208 && degrees <= 253 {
                bearing = "SW"
            } else if degrees > 253 && degrees <= 298 {
                bearing = "W"
            } else if degrees > 298 && degrees <= 331 {
                bearing = "NW"
            } else {
                bearing = "-"
            }
            self.compassLabel.text = bearing

        }
        
    }
}
