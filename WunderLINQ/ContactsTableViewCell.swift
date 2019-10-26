//
//  TableViewCell.swift
//  WunderLINQ
//
//  Created by Keith Conger on 1/19/19.
//  Copyright © 2019 Black Box Embedded, LLC. All rights reserved.
//

import UIKit

class ContactsTableViewCell: UITableViewCell {
    @IBOutlet weak var contactImage: UIImageView!
    @IBOutlet weak var contactLabel: UILabel!
    public var icon: UIImageView!
    public var label: UILabel!
    
    func displayContent(icon: UIImage, label: String) {
        contactImage.image = icon
        contactLabel.text = label
    }
    
    func highlightEffect(){
        contactImage.backgroundColor = UIColor(named: "accent")!
        contactLabel.backgroundColor = UIColor(named: "accent")!
        contentView.backgroundColor = UIColor(named: "accent")!
    }
    
    func removeHighlight(color: UIColor){
        contactImage.backgroundColor = color
        contactLabel.backgroundColor = color
        contentView.backgroundColor = color
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
