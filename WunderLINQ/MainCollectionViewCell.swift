//
//  MainCollectionViewCell.swift
//  WunderLINQ
//
//  Created by Keith Conger on 1/27/19.
//  Copyright © 2019 Black Box Embedded, LLC. All rights reserved.
//

import UIKit

class MainCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    public var header: UILabel!
    public var value: UILabel!
    
    func displayContent(header: String, value: String) {
        headerLabel.text = header
        valueLabel.text = value
    }
    
    func setColors(backgroundColor: UIColor, textColor: UIColor){
        headerLabel.textColor = textColor
        valueLabel.textColor = textColor
        contentView.backgroundColor = backgroundColor
    }
}
