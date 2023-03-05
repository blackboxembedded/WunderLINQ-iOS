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
        var highlightColor: UIColor?
        if let colorData = UserDefaults.standard.data(forKey: "highlight_color_preference"){
            highlightColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData)
        } else {
            highlightColor = UIColor(named: "accent")
        }
        contactImage.backgroundColor = highlightColor
        contactLabel.backgroundColor = highlightColor
        contentView.backgroundColor = highlightColor
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
