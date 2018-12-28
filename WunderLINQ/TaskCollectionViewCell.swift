//
//  TaskCollectionViewCell.swift
//  WunderLINQ
//
//  Created by Keith Conger on 12/5/18.
//  Copyright © 2018 Black Box Embedded, LLC. All rights reserved.
//

import UIKit

class TaskCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var taskImage: UIImageView!
    @IBOutlet var taskLabel: UILabel!
    
    func displayContent(image: UIImage, title: String) {
        taskImage.image = image
        taskLabel.text = title
    }
    
}
