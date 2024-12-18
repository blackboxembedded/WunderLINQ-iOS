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

class TaskCollectionViewCell: UICollectionViewCell {
    

    @IBOutlet weak var uiView: UIView!
    @IBOutlet weak var taskImage: UIImageView!
    @IBOutlet weak var taskLabel: UILabel!
    public var icon: UIImageView!
    public var label: String!
    
    func displayContent(icon: UIImage, label: String) {
        taskImage.image = icon
        taskImage.tintColor = UIColor(named: "imageTint")
        taskLabel.text = label
    }
    
    func highlightEffect(){
        
        uiView.layer.cornerRadius = 2.0
        uiView.clipsToBounds = true
        uiView.layer.masksToBounds = false
        uiView.layer.borderWidth = 0
        
        var highlightColor: UIColor?
        if let colorData = UserDefaults.standard.data(forKey: "highlight_color_preference"){
            highlightColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData)
        } else {
            highlightColor = UIColor(named: "accent")
        }
        contentView.backgroundColor = highlightColor
        uiView.backgroundColor = highlightColor
        taskImage.tintColor = UIColor.white
        taskLabel.textColor = UIColor.white
    }
    
    func removeHighlight(){
        uiView.backgroundColor = UIColor.clear
        taskImage.tintColor = UIColor(named: "imageTint")
        taskLabel.textColor = UIColor(named: "imageTint")
        contentView.backgroundColor = .clear
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        
        // Check if the cell is currently focused
        if isFocused {
            coordinator.addCoordinatedAnimations {
                self.highlightEffect()
            }
        } else {
            coordinator.addCoordinatedAnimations {
                self.removeHighlight()
            }
        }
    }
}
