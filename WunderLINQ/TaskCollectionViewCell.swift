//
//  TaskCollectionViewCell.swift
//  WunderLINQ
//
//  Created by Keith Conger on 12/5/18.
//  Copyright © 2018 Black Box Embedded, LLC. All rights reserved.
//

import UIKit

class TaskCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var taskImage: UIImageView!
    @IBOutlet weak var taskLabel: UILabel!
    public var icon: UIImageView!
    public var label: UILabel!
    
    func displayContent(icon: UIImage, label: String) {
        taskImage.image = icon
        taskLabel.text = label
    }
    
    func highlightEffect(){
        taskImage.tintColor = UIColor.white
        taskImage.backgroundColor = UIColor(named: "accent")!
        taskLabel.backgroundColor = UIColor(named: "accent")!
        taskLabel.textColor = UIColor.white
        contentView.backgroundColor = UIColor(named: "accent")!
    }
    
    func removeHighlight(){
        if #available(iOS 13.0, *) {
            taskImage.tintColor = UIColor(named: "imageTint")
            taskImage.backgroundColor = UIColor(named: "backgrounds")
            contentView.backgroundColor = UIColor(named: "backgrounds")
            taskLabel.backgroundColor = UIColor(named: "backgrounds")
            taskLabel.textColor = UIColor(named: "imageTint")
        } else {
            switch(UserDefaults.standard.integer(forKey: "darkmode_preference")){
            case 0:
                //OFF
                taskImage.tintColor = UIColor.black
                taskImage.backgroundColor = UIColor.white
                contentView.backgroundColor = UIColor.white
                taskLabel.backgroundColor = UIColor.white
                taskLabel.textColor = UIColor.black
            case 1:
                //On
                taskImage.tintColor = UIColor.white
                taskImage.backgroundColor = UIColor.black
                contentView.backgroundColor = UIColor.black
                taskLabel.backgroundColor = UIColor.black
                taskLabel.textColor = UIColor.white
            default:
                //Default
                taskImage.tintColor = UIColor.black
                taskImage.backgroundColor = UIColor.white
                contentView.backgroundColor = UIColor.white
                taskLabel.backgroundColor = UIColor.white
                taskLabel.textColor = UIColor.black
            }
        }
    }
}
