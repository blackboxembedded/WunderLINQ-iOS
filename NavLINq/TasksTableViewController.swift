//
//  TasksTableViewController.swift
//  NavLINq
//
//  Created by Keith Conger on 8/16/17.
//  Copyright © 2017 Keith Conger. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class TasksTableViewController: UITableViewController {
    //MARK: Properties
    
    var tasks = [Tasks]()
    
    //MARK: Private Methods
    
    private func loadTasks() {
        // Go Home Task
        guard let task1 = Tasks(label: NSLocalizedString("Go Home", comment: ""), icon: UIImage(named: "Home")) else {
            fatalError("Unable to instantiate Go Home Task")
        }
        // Call Home Task
        guard let task2 = Tasks(label: NSLocalizedString("Call Home", comment: ""), icon: UIImage(named: "Phone")) else {
            fatalError("Unable to instantiate Call Home Task")
        }
        // Call Contact Task
        guard let task3 = Tasks(label: NSLocalizedString("Call Contact", comment: ""), icon: UIImage(named: "Contacts")) else {
            fatalError("Unable to instantiate Call Contact Task")
        }
        
        tasks += [task1, task2, task3]
        
    }
    
    // MARK: - Handling User Interaction
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func forward(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "unwindToContainerVC", sender: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadTasks();
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tasks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure the cell...
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskTableViewCell", for: indexPath)

        let tasks = self.tasks[indexPath.row]
        
        cell.textLabel?.text = tasks.label
        cell.imageView?.image = tasks.icon
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("row: \(indexPath.row)")
        switch indexPath.row {
        case 0:
            print("Go Home")
            if let homeAddress = UserDefaults.standard.string(forKey: "gohome_address_preference"){
                if homeAddress != "" {
                    let geocoder = CLGeocoder()
                    geocoder.geocodeAddressString(homeAddress) {
                        placemarks, error in
                        let placemark = placemarks?.first
                        let lat = placemark?.location?.coordinate.latitude
                        let lon = placemark?.location?.coordinate.longitude
                        print("Lat: \(lat), Lon: \(lon)")
                        
                        let destLatitude: CLLocationDegrees = lat!
                        let destLongitude: CLLocationDegrees = lon!
                        let coordinates = CLLocationCoordinate2DMake(destLatitude, destLongitude)
                        let navPlacemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
                        let mapitem = MKMapItem(placemark: navPlacemark)
                        let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
                        mapitem.openInMaps(launchOptions: options)
                    }
                } else {
                    // the alert view
                    let alert = UIAlertController(title: "", message: "No Go Home address set in Settings", preferredStyle: .alert)
                    self.present(alert, animated: true, completion: nil)
                    
                    // change to desired number of seconds (in this case 2 seconds)
                    let when = DispatchTime.now() + 2
                    DispatchQueue.main.asyncAfter(deadline: when){
                        // your code with delay
                        alert.dismiss(animated: true, completion: nil)
                    }
                }
            }
        case 1:
            print("Call Home")
            if let phoneNumber = UserDefaults.standard.string(forKey: "callhome_number_preference"){
                if phoneNumber != "" {
                    var validPhoneNumber = ""
                    phoneNumber.characters.forEach {(character) in
                        switch character {
                        case "0"..."9":
                            validPhoneNumber.characters.append(character)
                        default:
                            break
                        }
                    }
                    if let phoneCallURL = URL(string: "telprompt:\(validPhoneNumber)") {
                        if (UIApplication.shared.canOpenURL(phoneCallURL)) {
                            if #available(iOS 10, *) {
                                UIApplication.shared.open(phoneCallURL, options: [:], completionHandler: nil)
                            } else {
                                UIApplication.shared.openURL(phoneCallURL as URL)
                            }
                        }
                    }
                } else {
                    // the alert view
                    let alert = UIAlertController(title: "", message: "No Call Home phone number set in Settings", preferredStyle: .alert)
                    self.present(alert, animated: true, completion: nil)
                    
                    // change to desired number of seconds (in this case 2 seconds)
                    let when = DispatchTime.now() + 2
                    DispatchQueue.main.asyncAfter(deadline: when){
                        // your code with delay
                        alert.dismiss(animated: true, completion: nil)
                    }

                }
                
            }
        case 2:
            print("Call Contact")
            let cell = tableView.cellForRow(at: indexPath)
            performSegue(withIdentifier: "showContacts", sender: cell)
            
        default:
            print("Unknown Task")
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
