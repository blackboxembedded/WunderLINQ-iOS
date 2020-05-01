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

class GeoDataViewController: UIViewController {

    @IBOutlet weak var tripsView: UIStackView!
    @IBOutlet weak var waypointsView: UIStackView!
    
    @objc func leftScreen() {
        _ = navigationController?.popViewController(animated: true)
        //performSegue(withIdentifier: "GeoDataToMotorcycle", sender: [])
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizer.Direction.right {
            _ = navigationController?.popViewController(animated: true)
            //performSegue(withIdentifier: "GeoDataToMotorcycle", sender: [])
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AppUtility.lockOrientation(.portrait)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        let backBtn = UIButton()
        backBtn.setImage(UIImage(named: "Left")?.withRenderingMode(.alwaysTemplate), for: .normal)
        if #available(iOS 13.0, *) {
            backBtn.tintColor = UIColor(named: "imageTint")
        }
        backBtn.addTarget(self, action: #selector(leftScreen), for: .touchUpInside)
        let backButton = UIBarButtonItem(customView: backBtn)
        let backButtonWidth = backButton.customView?.widthAnchor.constraint(equalToConstant: 30)
        backButtonWidth?.isActive = true
        let backButtonHeight = backButton.customView?.heightAnchor.constraint(equalToConstant: 30)
        backButtonHeight?.isActive = true
        self.navigationItem.title = NSLocalizedString("geodata_label", comment: "")
        self.navigationItem.leftBarButtonItems = [backButton]

        let tripsTouch = UITapGestureRecognizer(target: self, action:  #selector(self.tripsBtnAction(sender:)))
        self.tripsView.addGestureRecognizer(tripsTouch)
        let waypointsTouch = UITapGestureRecognizer(target: self, action:  #selector(self.waypointsBtnAction(sender:)))
        self.waypointsView.addGestureRecognizer(waypointsTouch)

    }

    @objc func tripsBtnAction(sender : UITapGestureRecognizer) {
        performSegue(withIdentifier: "GeoDataToTrips", sender: [])
    }
    
    @objc func waypointsBtnAction(sender : UITapGestureRecognizer) {
        performSegue(withIdentifier: "GeoDataToWaypoints", sender: [])
    }
    
}
