//
//  NavigationControllerWithTraitOverride.swift
//  WunderLINQ
//
//  Created by Keith Conger on 6/16/20.
//  Copyright © 2020 Black Box Embedded, LLC. All rights reserved.
//

import UIKit

class NavigationControllerWithTraitOverride: UINavigationController {

    // If you make a navigationController a member of this class the descendentVCs of that navigationController will have their trait collection overridden with compact vertical size class if the user is on an iPad and the device is horizontal.

    override func overrideTraitCollection(forChild childViewController: UIViewController) -> UITraitCollection? {
        if UIDevice.current.userInterfaceIdiom == .pad && UIDevice.current.orientation.isLandscape {
            return UITraitCollection(traitsFrom:[UITraitCollection(verticalSizeClass: .compact), UITraitCollection(horizontalSizeClass: .regular)])
        }
        return super.overrideTraitCollection(forChild: childViewController)
    }
}
