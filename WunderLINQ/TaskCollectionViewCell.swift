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
        taskImage.backgroundColor = UIColor.blue
        taskLabel.backgroundColor = UIColor.blue
        contentView.backgroundColor = UIColor.blue
    }
    
    func removeHighlight(color: UIColor){
        taskImage.backgroundColor = color
        taskLabel.backgroundColor = color
        contentView.backgroundColor = color
    }
    
}
