//
//  TripViewController.swift
//  WunderLINQ
//
//  Created by Keith Conger on 7/23/18.
//  Copyright © 2018 Black Box Embedded, LLC. All rights reserved.
//

import UIKit

class TripViewController: UIViewController {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var gearShiftsLabel: UILabel!
    @IBOutlet weak var brakesLabel: UILabel!
    @IBOutlet weak var ambientTempLabel: UILabel!
    @IBOutlet weak var engineTempLabel: UILabel!
    
    var fileName: String?
    
    @objc func leftScreen() {
        performSegue(withIdentifier: "tripToTrips", sender: [])
    }
    
    func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizerDirection.right {
            print("Swipe Right")
            performSegue(withIdentifier: "tripToTrips", sender: [])
        }
    }
    
    @IBAction func shareBtn(_ sender: Any) {
        let dictToSave: [String: Any] = [
            "someKey": "someValue"
        ]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dictToSave, options: .prettyPrinted)
            
            let filename = "\(self.getDocumentsDirectory())/\(fileName ?? "file").csv"
            let fileURL = URL(fileURLWithPath: filename)
            try jsonData.write(to: fileURL, options: .atomic)
            
            let vc = UIActivityViewController(activityItems: [fileURL], applicationActivities: [])
            
            self.present(vc, animated: true)
        } catch {
            print("had a problem")
        }

    }
    @IBAction func deleteBtn(_ sender: Any) {
        let fileManager = FileManager.default
        let filename = "\(self.getDocumentsDirectory())/\(fileName ?? "file").csv"
        
        do {
            try fileManager.removeItem(atPath: filename)
        } catch {
            print("Could not delete file: \(error)")
        }
        performSegue(withIdentifier: "tripToTrips", sender: [])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        
        let backBtn = UIButton()
        backBtn.setImage(UIImage(named: "Left"), for: .normal)
        backBtn.addTarget(self, action: #selector(leftScreen), for: .touchUpInside)
        let backButton = UIBarButtonItem(customView: backBtn)
        let backButtonWidth = backButton.customView?.widthAnchor.constraint(equalToConstant: 30)
        backButtonWidth?.isActive = true
        let backButtonHeight = backButton.customView?.heightAnchor.constraint(equalToConstant: 30)
        backButtonHeight?.isActive = true
        self.navigationItem.leftBarButtonItems = [backButton]
        
        print("Open \(fileName)")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func getDocumentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

}
