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

class MainCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    public var header: UILabel!
    public var value: UILabel!
    public var icon: UIImageView!
    
    func setHeader(label: String) {
        headerLabel.adjustsFontSizeToFitWidth = true
        headerLabel.text = label
    }
    
    func setValue(value: String) {
        valueLabel.text = value
    }
    
    func setIcon(icon: UIImage) {
        iconImageView.image = icon
    }
    
    func setValueColor(labelColor: UIColor){
        valueLabel.textColor = labelColor
    }
    
    func setColors(backgroundColor: UIColor, textColor: UIColor){
        headerLabel.textColor = textColor
        valueLabel.textColor = textColor
        contentView.backgroundColor = backgroundColor
    }
}
