/*
WunderLINQ Client Application
Copyright (C) 2020  Keith Conger, Black Box Embedded, LLC

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

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
