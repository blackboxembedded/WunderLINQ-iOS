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
            highlightColor = NSKeyedUnarchiver.unarchiveObject(with: colorData) as? UIColor
        } else {
            highlightColor = UIColor(named: "accent")
        }
        
        uiView.backgroundColor = highlightColor
        taskImage.tintColor = UIColor.white
        taskLabel.textColor = UIColor.white
    }
    
    func removeHighlight(){
        uiView.backgroundColor = UIColor.clear
        
        if #available(iOS 13.0, *) {
            taskImage.tintColor = UIColor(named: "imageTint")
            taskLabel.textColor = UIColor(named: "imageTint")
        } else {
            switch(UserDefaults.standard.integer(forKey: "darkmode_preference")){
            case 0:
                //OFF
                taskImage.tintColor = UIColor.black
                taskLabel.textColor = UIColor.black
            case 1:
                //On
                taskImage.tintColor = UIColor.white
                taskLabel.textColor = UIColor.white
            default:
                //Default
                taskImage.tintColor = UIColor.black
                taskLabel.textColor = UIColor.black
            }
        }
    }
}
