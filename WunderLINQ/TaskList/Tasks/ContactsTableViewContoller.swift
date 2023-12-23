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
            NSLog("ContactsTableViewController: Not Allowed to access contacts")
        case .restricted, .notDetermined:
            store.requestAccess(for: .contacts) { granted, error in
                if granted {
                    self.retrieveContactsWithStore(store: store)
                } else {
                    // Not allowed
                    NSLog("ContactsTableViewController: Not Allowed to access contacts")
                }
            }
        default:
            NSLog("ContactsTableViewController: Unknown status to access contacts")
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
            NSLog("ContactsTableViewController: Error enumerating contacts")
        }
        self.tableView.reloadData()
    }
    
    //MARK: - Handling User Interaction
    override var keyCommands: [UIKeyCommand]? {
        
        let commands = [
            UIKeyCommand(input: "\u{d}", modifierFlags:[], action: #selector(selectItem)),
            UIKeyCommand(input: UIKeyCommand.inputUpArrow, modifierFlags:[], action: #selector(upRow)),
            UIKeyCommand(input: "+", modifierFlags:[], action: #selector(upRow)),
            UIKeyCommand(input: UIKeyCommand.inputDownArrow, modifierFlags:[], action: #selector(downRow)),
            UIKeyCommand(input: "-", modifierFlags:[], action: #selector(downRow)),
            UIKeyCommand(input: UIKeyCommand.inputLeftArrow, modifierFlags:[], action: #selector(leftScreen)),
            UIKeyCommand(input: UIKeyCommand.inputRightArrow, modifierFlags:[], action: #selector(rightScreen))
        ]
        if #available(iOS 15, *) {
            commands.forEach { $0.wantsPriorityOverSystemBehavior = true }
        }
        return commands
    }
    
    @objc func selectItem() {
        SoundManager().playSoundEffect("enter")
        call_contact(contactID: itemRow)
    }
    
    @objc func upRow() {
        SoundManager().playSoundEffect("directional")
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
        SoundManager().playSoundEffect("directional")
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
        SoundManager().playSoundEffect("directional")
        _ = navigationController?.popViewController(animated: true)
    }
    
    @objc func rightScreen() {
        SoundManager().playSoundEffect("directional")
        if let lastVisibleIndexPath = tableView.indexPathsForVisibleRows?.last {
            itemRow = lastVisibleIndexPath.row
            tableView.scrollToRow(at: lastVisibleIndexPath, at: .middle, animated: true)
            self.tableView.reloadData()
        }
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizer.Direction.right {
            leftScreen()
        } else if gesture.direction == UISwipeGestureRecognizer.Direction.left {
            rightScreen()
        }
    }
    
    func call_contact(contactID:Int){
        phoneContacts[contactID].number.makeAColl()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            
        } else {
            switch(UserDefaults.standard.integer(forKey: "darkmode_preference")){
            case 0:
                //OFF
                Theme.default.apply()
                self.navigationController?.isNavigationBarHidden = true
                self.navigationController?.isNavigationBarHidden = false
            case 1:
                //On
                Theme.dark.apply()
                self.navigationController?.isNavigationBarHidden = true
                self.navigationController?.isNavigationBarHidden = false
            default:
                //Default
                Theme.default.apply()
                self.navigationController?.isNavigationBarHidden = true
                self.navigationController?.isNavigationBarHidden = false
            }
        }
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
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
        self.navigationItem.title = NSLocalizedString("contactlist_title", comment: "")
        self.navigationItem.leftBarButtonItems = [backButton]
        
        if UserDefaults.standard.bool(forKey: "display_brightness_preference") {
            UIScreen.main.brightness = CGFloat(1.0)
        } else {
            UIScreen.main.brightness = CGFloat(UserDefaults.standard.float(forKey: "systemBrightness"))
        }
        
        self.getContacts()
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
            if #available(iOS 13.0, *) {
                cell.removeHighlight(color: UIColor(named: "backgrounds")!)
            } else {
                switch(UserDefaults.standard.integer(forKey: "darkmode_preference")){
                case 0:
                    //OFF
                    cell.removeHighlight(color: UIColor.white)
                case 1:
                    //On
                    cell.removeHighlight(color: UIColor.black)
                default:
                    //Default
                    cell.removeHighlight(color: UIColor.white)
                }
            }
        }
        if #available(iOS 13.0, *) {
            cell.contactImage.tintColor = UIColor(named: "imageTint")
        } else {
            switch(UserDefaults.standard.integer(forKey: "darkmode_preference")){
            case 0:
                //OFF
                cell.contactImage.tintColor = UIColor.black
            case 1:
                //On
                cell.contactImage.tintColor = UIColor.white
            default:
                //Default
                cell.contactImage.tintColor = UIColor.black
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        call_contact(contactID: indexPath.row)
    }
    
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
