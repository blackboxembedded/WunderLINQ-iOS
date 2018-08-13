//
//  ContactsTableViewContoller.swift
//  WunderLINQ
//
//  Created by Keith Conger on 10/2/17.
//  Copyright © 2017 Black Box Embedded, LLC. All rights reserved.
//

import Foundation
import UIKit
import Contacts

class ContactsTableViewController: UITableViewController {
    //MARK: Properties
    
    var phoneContacts = [PhoneContacts]()
    
    var itemRow = 0
    
    //MARK: Private Methods
    func getContacts() {
        let store = CNContactStore()
        
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            self.retrieveContactsWithStore(store: store)
        case .denied:
            // Not allowed
            print("Not Allowed to access contacts")
        case .restricted, .notDetermined:
            store.requestAccess(for: .contacts) { granted, error in
                if granted {
                    self.retrieveContactsWithStore(store: store)
                } else {
                    // Not allowed
                    print("Not Allowed to access contacts")
                }
            }
        }
    }
    
    func retrieveContactsWithStore(store: CNContactStore) {
        
        let contactStore = CNContactStore()
        let keysToFetch = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactPhoneNumbersKey,
            CNContactImageDataAvailableKey,
            CNContactImageDataKey] as [Any]
        
        // Get all the containers
        var allContainers: [CNContainer] = []
        do {
            allContainers = try contactStore.containers(matching: nil)
        } catch {
            print("Error fetching containers")
        }
        
        var contacts: [CNContact] = []
        // Iterate all containers and append their contacts to our results array
        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
            do {
                let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
                contacts.append(contentsOf: containerResults)
                for contact in contacts {
                    for phoneNumber in contact.phoneNumbers {
                        if phoneNumber.value != nil && phoneNumber.label != nil {
                            let number = phoneNumber.value
                            let label = phoneNumber.label!
                            if (!label.contains("FAX") && (label.contains("iPhone") || label.contains("Home") || label.contains("Mobile") || label.contains("Work"))){
                                let localizedLabel = CNLabeledValue<CNPhoneNumber>.localizedString(forLabel: label)
                                let formatter = CNContactFormatter()
                                var photo = UIImage(named: "Contact")?.withRenderingMode(.alwaysTemplate)
                                if contact.imageDataAvailable {
                                    // there is an image for this contact
                                    photo = UIImage(data: contact.imageData!)?.withRenderingMode(.alwaysTemplate)
                                    
                                }
                                guard let phoneContact = PhoneContacts(name: formatter.string(from: contact)!, number: number.stringValue, numberDescription: localizedLabel, photo: photo) else {
                                    fatalError("Unable to instantiate Call Contact Task")
                                }
                                self.phoneContacts += [phoneContact]
                            }
                        }
                    }
                }
            } catch {
                print("Error fetching results for container")
            }
        }
        self.tableView.reloadData()
    }
    
    //MARK: - Handling User Interaction
    override var keyCommands: [UIKeyCommand]? {
        
        let commands = [
            UIKeyCommand(input: "\u{d}", modifierFlags:[], action: #selector(selectItem), discoverabilityTitle: "Select item"),
            UIKeyCommand(input: UIKeyInputUpArrow, modifierFlags:[], action: #selector(upRow), discoverabilityTitle: "Go up"),
            UIKeyCommand(input: UIKeyInputDownArrow, modifierFlags:[], action: #selector(downRow), discoverabilityTitle: "Go down"),
            UIKeyCommand(input: UIKeyInputLeftArrow, modifierFlags:[], action: #selector(leftScreen), discoverabilityTitle: "Go left"),
            UIKeyCommand(input: UIKeyInputRightArrow, modifierFlags:[], action: #selector(rightScreen), discoverabilityTitle: "Go right")
        ]
        return commands
    }
    
    @objc func selectItem() {
        call_contact(contactID: itemRow)
    }
    @objc func upRow() {
        if (itemRow == 0){
            let nextRow = phoneContacts.count - 1
            if UserDefaults.standard.bool(forKey: "nightmode_preference") {
                self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.contentView.backgroundColor = UIColor.black
                self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.textLabel?.backgroundColor = UIColor.black
            } else {
                self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.contentView.backgroundColor = UIColor.white
                self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.textLabel?.backgroundColor = UIColor.white
            }
            self.tableView.cellForRow(at: IndexPath(row: nextRow, section: 0) as IndexPath)?.contentView.backgroundColor = UIColor.blue
            self.tableView.cellForRow(at: IndexPath(row: nextRow, section: 0) as IndexPath)?.textLabel?.backgroundColor = UIColor.blue
            self.tableView.scrollToRow(at: IndexPath(row: nextRow, section: 0), at: .middle, animated: true)
            itemRow = nextRow
        } else if (itemRow < phoneContacts.count ){
            let nextRow = itemRow - 1
            if UserDefaults.standard.bool(forKey: "nightmode_preference") {
                self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.contentView.backgroundColor = UIColor.black
                self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.textLabel?.backgroundColor = UIColor.black
            } else {
                self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.contentView.backgroundColor = UIColor.white
                self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.textLabel?.backgroundColor = UIColor.white
            }
            self.tableView.cellForRow(at: IndexPath(row: nextRow, section: 0) as IndexPath)?.contentView.backgroundColor = UIColor.blue
            self.tableView.cellForRow(at: IndexPath(row: nextRow, section: 0) as IndexPath)?.textLabel?.backgroundColor = UIColor.blue
            self.tableView.scrollToRow(at: IndexPath(row: nextRow, section: 0), at: .middle, animated: true)
            itemRow = nextRow
        }
        self.tableView.reloadData()
    }
    @objc func downRow() {
        if (itemRow == (phoneContacts.count - 1)){
            let nextRow = 0
            if UserDefaults.standard.bool(forKey: "nightmode_preference") {
                self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.contentView.backgroundColor = UIColor.black
                self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.textLabel?.backgroundColor = UIColor.black
            } else {
                self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.contentView.backgroundColor = UIColor.white
                self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.textLabel?.backgroundColor = UIColor.white
            }
            self.tableView.cellForRow(at: IndexPath(row: nextRow, section: 0) as IndexPath)?.contentView.backgroundColor = UIColor.blue
            self.tableView.cellForRow(at: IndexPath(row: nextRow, section: 0) as IndexPath)?.textLabel?.backgroundColor = UIColor.blue
            self.tableView.scrollToRow(at: IndexPath(row: nextRow, section: 0), at: .middle, animated: true)
            itemRow = nextRow
        } else if (itemRow < phoneContacts.count ){
            let nextRow = itemRow + 1
            if UserDefaults.standard.bool(forKey: "nightmode_preference") {
                self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.contentView.backgroundColor = UIColor.black
                self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.textLabel?.backgroundColor = UIColor.black
            } else {
                self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.contentView.backgroundColor = UIColor.white
                self.tableView.cellForRow(at: IndexPath(row: itemRow, section: 0) as IndexPath)?.textLabel?.backgroundColor = UIColor.white
            }
            self.tableView.cellForRow(at: IndexPath(row: nextRow, section: 0) as IndexPath)?.contentView.backgroundColor = UIColor.blue
            self.tableView.cellForRow(at: IndexPath(row: nextRow, section: 0) as IndexPath)?.textLabel?.backgroundColor = UIColor.blue
            self.tableView.scrollToRow(at: IndexPath(row: nextRow, section: 0), at: .middle, animated: true)
            itemRow = nextRow
        }
        self.tableView.reloadData()
    }
    @objc func leftScreen() {
        performSegue(withIdentifier: "backToTasks", sender: [])
    }    
    @objc func rightScreen() {
        
    }
    
    func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizerDirection.right {
            performSegue(withIdentifier: "backToTasks", sender: [])
        }
    }
    
    func call_contact(contactID:Int){
        var validPhoneNumber = ""
        phoneContacts[contactID].number.characters.forEach {(character) in
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserDefaults.standard.bool(forKey: "nightmode_preference") {
            Theme.dark.apply()
            self.navigationController?.isNavigationBarHidden = true
            self.navigationController?.isNavigationBarHidden = false
        } else {
            Theme.default.apply()
            self.navigationController?.isNavigationBarHidden = true
            self.navigationController?.isNavigationBarHidden = false
        }
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        let backBtn = UIButton()
        backBtn.setImage(UIImage(named: "Left")?.withRenderingMode(.alwaysTemplate), for: .normal)
        backBtn.addTarget(self, action: #selector(leftScreen), for: .touchUpInside)
        let backButton = UIBarButtonItem(customView: backBtn)
        let backButtonWidth = backButton.customView?.widthAnchor.constraint(equalToConstant: 30)
        backButtonWidth?.isActive = true
        let backButtonHeight = backButton.customView?.heightAnchor.constraint(equalToConstant: 30)
        backButtonHeight?.isActive = true
        self.navigationItem.title = NSLocalizedString("contactlist_title", comment: "")
        self.navigationItem.leftBarButtonItems = [backButton]
        
        self.getContacts()

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
        return phoneContacts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure the cell...
        // Table view cells are reused and should be dequeued using a cell identifier.
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactsTableViewCell", for: indexPath)
        
        let contact = self.phoneContacts[indexPath.row]
        cell.textLabel?.text = contact.name + " (" + contact.numberDescription + ")"
        cell.imageView?.image = contact.photo
        if UserDefaults.standard.bool(forKey: "nightmode_preference") {
            cell.imageView?.tintColor = UIColor.white
        } else {
            cell.imageView?.tintColor = UIColor.black
        }
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        call_contact(contactID: indexPath.row)
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
