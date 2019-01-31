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
    
    func setLabel(label: String) {
        headerLabel.text = label
    }
    func setValue(value: String) {
        valueLabel.text = value
    }
    
    func setColors(backgroundColor: UIColor, textColor: UIColor){
        headerLabel.textColor = textColor
        valueLabel.textColor = textColor
        contentView.backgroundColor = backgroundColor
    }
}
