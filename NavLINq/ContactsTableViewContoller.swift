//
//  ContactsTableViewContoller.swift
//  NavLINq
//
//  Created by Keith Conger on 10/2/17.
//  Copyright © 2017 Keith Conger. All rights reserved.
//

import Foundation
import UIKit
import Contacts

class ContactsTableViewController: UITableViewController {
    //MARK: Properties
    
    var phoneContacts = [PhoneContacts]()
    
    //MARK: Private Methods
    func getContacts() {
        let store = CNContactStore()
        
        if CNContactStore.authorizationStatus(for: .contacts) == .notDetermined {
            store.requestAccess(for: .contacts, completionHandler: { (authorized: Bool, error: NSError?) -> Void in
                if authorized {
                    self.retrieveContactsWithStore(store: store)
                }
                } as! (Bool, Error?) -> Void)
        } else if CNContactStore.authorizationStatus(for: .contacts) == .authorized {
            self.retrieveContactsWithStore(store: store)
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
                        if let number = phoneNumber.value as? CNPhoneNumber,
                            // TODO: Filter out unneeded numbers like fax
                            let label = phoneNumber.label {
                            let localizedLabel = CNLabeledValue<CNPhoneNumber>.localizedString(forLabel: label)
                            print("\(localizedLabel)  \(number.stringValue)")
                            
                            let formatter = CNContactFormatter()
                            var photo = UIImage(named: "Contact")
                            if contact.imageDataAvailable {
                                // there is an image for this contact
                                photo = UIImage(data: contact.imageData!)
                            }
                            guard let phoneContact = PhoneContacts(name: formatter.string(from: contact)!, number: number.stringValue, numberDescription: localizedLabel, photo: photo) else {
                                fatalError("Unable to instantiate Call Contact Task")
                            }
                            
                            self.phoneContacts += [phoneContact]
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var validPhoneNumber = ""
        phoneContacts[indexPath.row].number.characters.forEach {(character) in
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
