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
    var firstRun = true
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
        default:
            print("Unknown status to access contacts")
        }
    }
    
    func retrieveContactsWithStore(store: CNContactStore) {
        
        
        let contactStore = CNContactStore()
        let keysToFetch = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactPhoneNumbersKey,
            CNContactImageDataAvailableKey,
            CNContactImageDataKey] as [Any]
        
        let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch as! [CNKeyDescriptor])

        // sort by name given
        if UserDefaults.standard.integer(forKey: "contact_sort_preference") == 0 {
            fetchRequest.sortOrder = CNContactSortOrder.familyName
        } else {
            fetchRequest.sortOrder = CNContactSortOrder.givenName
        }
        
        do {
            try contactStore.enumerateContacts(with: fetchRequest) {
                (contact, cursor) -> Void in
                if (!contact.phoneNumbers.isEmpty){
                    for phoneNumber in contact.phoneNumbers {
                        if phoneNumber.label != nil {
                            let number = phoneNumber.value
                            let label = phoneNumber.label!
                            if (!label.contains("FAX") && (label.contains("iPhone") || label.contains("Home") || label.contains("Mobile") || label.contains("Work") || label.contains("phone"))){
                                let localizedLabel = CNLabeledValue<CNPhoneNumber>.localizedString(forLabel: label)
                                let formatter = CNContactFormatter()
                                var photo = UIImage(named: "Contact")?.withRenderingMode(.alwaysTemplate)
                                if contact.imageDataAvailable {
                                    if contact.imageData != nil {
                                        // there is an image for this contact
                                        if let contactPhoto = UIImage(data: contact.imageData!){
                                            photo = contactPhoto
                                        }
                                    }
                                }
                                if formatter.string(from: contact) != nil && photo != nil {
                                    if let phoneContact = PhoneContacts(name: formatter.string(from: contact)!, number: number.stringValue, numberDescription: localizedLabel, photo: photo){
                                        self.phoneContacts += [phoneContact]
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        catch{
            print("Handle the error please")
        }
        self.tableView.reloadData()
    }
    
    //MARK: - Handling User Interaction
    override var keyCommands: [UIKeyCommand]? {
        
        let commands = [
            UIKeyCommand(input: "\u{d}", modifierFlags:[], action: #selector(selectItem), discoverabilityTitle: "Select item"),
            UIKeyCommand(input: UIKeyCommand.inputUpArrow, modifierFlags:[], action: #selector(upRow), discoverabilityTitle: "Go up"),
            UIKeyCommand(input: UIKeyCommand.inputDownArrow, modifierFlags:[], action: #selector(downRow), discoverabilityTitle: "Go down"),
            UIKeyCommand(input: UIKeyCommand.inputLeftArrow, modifierFlags:[], action: #selector(leftScreen), discoverabilityTitle: "Go left"),
            UIKeyCommand(input: UIKeyCommand.inputRightArrow, modifierFlags:[], action: #selector(rightScreen), discoverabilityTitle: "Go right")
        ]
        return commands
    }
    
    @objc func selectItem() {
        call_contact(contactID: itemRow)
    }
    
    @objc func upRow() {
        print("upRow(): \(itemRow)")
        if (itemRow == 0){
            let nextRow = phoneContacts.count - 1
            itemRow = nextRow
        } else if (itemRow < phoneContacts.count ){
            let nextRow = itemRow - 1
            itemRow = nextRow
        }
        let indexPath = IndexPath(row: itemRow, section: 0)
        let deadlineTime = DispatchTime.now() + .milliseconds(1)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            self.tableView.scrollToRow(at: indexPath, at: .middle, animated: false)
        }
        self.tableView.reloadData()
    }
    
    @objc func downRow() {
        print("downRow(): \(itemRow)")
        if (itemRow == (phoneContacts.count - 1)){
            let nextRow = 0
            itemRow = nextRow
        } else if (itemRow < phoneContacts.count ){
            let nextRow = itemRow + 1
            itemRow = nextRow
        }
        let indexPath = IndexPath(row: itemRow, section: 0)
        let deadlineTime = DispatchTime.now() + .milliseconds(1)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            self.tableView.scrollToRow(at: indexPath, at: .middle, animated: false)
        }
        self.tableView.reloadData()
    }
    @objc func leftScreen() {
        performSegue(withIdentifier: "contactsToTaskGrid", sender: [])
    }    
    @objc func rightScreen() {
        
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizer.Direction.right {
            performSegue(withIdentifier: "contactsToTaskGrid", sender: [])
        }
    }
    
    func call_contact(contactID:Int){
        phoneContacts[contactID].number.makeAColl()
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
        
        if UserDefaults.standard.bool(forKey: "display_brightness_preference") {
            UIScreen.main.brightness = CGFloat(1.0)
        } else {
            UIScreen.main.brightness = CGFloat(UserDefaults.standard.float(forKey: "systemBrightness"))
        }
        
        self.getContacts()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactsTableViewCell", for: indexPath) as! ContactsTableViewCell
        
        let contact = self.phoneContacts[indexPath.row]
        cell.displayContent(icon: contact.photo!, label: contact.name + " (" + contact.numberDescription + ")")
        
        if (itemRow == indexPath.row){
            cell.highlightEffect()
        } else {
            if UserDefaults.standard.bool(forKey: "nightmode_preference") {
                cell.removeHighlight(color: UIColor.black)
            } else {
                cell.removeHighlight(color: UIColor.white)
            }
        }
        
        if UserDefaults.standard.bool(forKey: "nightmode_preference") {
            cell.contactImage.tintColor = UIColor.white
        } else {
            cell.contactImage.tintColor = UIColor.black
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

extension String {
    
    enum RegularExpressions: String {
        case phone = "^\\s*(?:\\+?(\\d{1,3}))?([-. (]*(\\d{3})[-. )]*)?((\\d{3})[-. ]*(\\d{2,4})(?:[-.x ]*(\\d+))?)\\s*$"
    }
    
    func isValid(regex: RegularExpressions) -> Bool {
        return isValid(regex: regex.rawValue)
    }
    
    func isValid(regex: String) -> Bool {
        let matches = range(of: regex, options: .regularExpression)
        return matches != nil
    }
    
    func onlyDigits() -> String {
        let filtredUnicodeScalars = unicodeScalars.filter{CharacterSet.decimalDigits.contains($0)}
        return String(String.UnicodeScalarView(filtredUnicodeScalars))
    }
    
    func makeAColl() {
        if isValid(regex: .phone) {
            if let url = URL(string: "tel://\(self.onlyDigits())"), UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }
}
