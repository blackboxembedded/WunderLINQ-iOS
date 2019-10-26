//
//  GeoDataViewController.swift
//  WunderLINQ
//
//  Created by Keith Conger on 2/18/19.
//  Copyright © 2019 Black Box Embedded, LLC. All rights reserved.
//

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
