//
//  TaskCollectionViewCell.swift
//  WunderLINQ
//
//  Created by Keith Conger on 12/5/18.
//  Copyright © 2018 Black Box Embedded, LLC. All rights reserved.
//

import UIKit

class TaskCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var uiView: UIView!
    @IBOutlet weak var taskImage: UIImageView!
    public var icon: UIImageView!
    public var label: UILabel!
    
    func displayContent(icon: UIImage) {
        taskImage.image = icon
        taskImage.tintColor = UIColor(named: "imageTint")
        
        taskImage.transform = CGAffineTransform.identity
        if UIDevice.current.orientation.isPortrait {
            taskImage.transform = taskImage.transform.rotated(by: CGFloat(.pi / 2.0))
        }
    }
    
    func highlightEffect(){
        
        uiView.layer.cornerRadius = (uiView.frame.size.height / 2.0)
        uiView.clipsToBounds = true
        uiView.layer.masksToBounds = false
        uiView.layer.borderWidth = 0
        uiView.backgroundColor = UIColor(named: "accent")!

        taskImage.tintColor = UIColor.white
    }
    
    func removeHighlight(){
        uiView.backgroundColor = UIColor.clear
        
        if #available(iOS 13.0, *) {
            taskImage.tintColor = UIColor(named: "imageTint")
        } else {
            switch(UserDefaults.standard.integer(forKey: "darkmode_preference")){
            case 0:
                //OFF
                taskImage.tintColor = UIColor.black
            case 1:
                //On
                taskImage.tintColor = UIColor.white
            default:
                //Default
                taskImage.tintColor = UIColor.black
            }
        }
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        let circularlayoutAttributes = layoutAttributes as! CircularCollectionViewLayoutAttributes
        self.layer.anchorPoint = circularlayoutAttributes.anchorPoint
        self.center.y += (circularlayoutAttributes.anchorPoint.y - 0.5) * self.bounds.height
    }
}
