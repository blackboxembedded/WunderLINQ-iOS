//
//  CircularCollectionViewLayout.swift
//  WunderLINQ
//
//  Created by Keith Conger on 3/11/20.
//  Copyright © 2020 Black Box Embedded, LLC. All rights reserved.
//
// From:
// https://www.raywenderlich.com/1702-uicollectionview-custom-layout-tutorial-a-spinning-wheel

import UIKit

class CircularCollectionViewLayoutAttributes: UICollectionViewLayoutAttributes {
    
    var anchorPoint = CGPoint(x: 0.5, y: 0.5)
    var angle: CGFloat = 0 {
      didSet {
        zIndex = Int(angle * 1000000)
          transform = CGAffineTransform(rotationAngle: angle)
      }
    }
    
    override func copy(with zone: NSZone?) -> Any {
        let copy = super.copy(with: zone) as! CircularCollectionViewLayoutAttributes
        copy.anchorPoint = self.anchorPoint
        copy.angle = self.angle
        return copy
    }
}

class CircularCollectionViewLayout: UICollectionViewLayout {
    
    let itemSize = CGSize(width: 120, height: 120)

    var angleAtExtreme: CGFloat {
        return collectionView!.numberOfItems(inSection: 0) > 0 ?
            -CGFloat(collectionView!.numberOfItems(inSection: 0) - 1) * anglePerItem : 0
    }
    
    var angle: CGFloat {
        return angleAtExtreme * collectionView!.contentOffset.x / (collectionViewContentSize.width - collectionView!.bounds.width)
    }

    var radius: CGFloat = 500 {
      didSet {
        invalidateLayout()
      }
    }
    
    var anglePerItem: CGFloat {
      return atan((itemSize.width + 50) / radius)
    }
    
    var attributesList = [CircularCollectionViewLayoutAttributes]()
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: CGFloat(collectionView!.numberOfItems(inSection: 0)) * itemSize.width,
                      height: collectionView!.bounds.height)
    }
    
    override public class var layoutAttributesClass: AnyClass {
      return CircularCollectionViewLayoutAttributes.self
    }
    
    override func prepare() {
        super.prepare()

        let centerX = collectionView!.contentOffset.x + (collectionView!.bounds.width / 2.0)

        let anchorPointY = ((itemSize.height / 2.0) + radius) / itemSize.height
        
        let theta = atan2(collectionView!.bounds.width / 2.0, radius + (itemSize.height / 2.0) - (collectionView!.bounds.height / 2.0))
        
        var startIndex = 0
        var endIndex = collectionView!.numberOfItems(inSection: 0) - 1
        
        if (angle < -theta) {
          startIndex = Int(floor((-theta - angle) / anglePerItem))
        }
        
        endIndex = min(endIndex, Int(ceil((theta - angle) / anglePerItem)))
        
        if (endIndex < startIndex) {
          endIndex = 0
          startIndex = 0
        }
        attributesList = (0..<collectionView!.numberOfItems(inSection: 0)).map { (i)
          -> CircularCollectionViewLayoutAttributes in
            
            let attributes = CircularCollectionViewLayoutAttributes(forCellWith: NSIndexPath(item: i, section: 0) as IndexPath)
            attributes.size = self.itemSize
            
            // Adjusts where top icon is centered
            attributes.center = CGPoint(x: centerX, y: 70)
            
            attributes.angle = self.angle + (self.anglePerItem * CGFloat(i))
            attributes.anchorPoint = CGPoint(x: 0.5, y: anchorPointY)
            
            return attributes
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
      return attributesList
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
      return attributesList[indexPath.row]
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
      return true
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        var finalContentOffset = proposedContentOffset
        
        let factor = -angleAtExtreme/(collectionViewContentSize.width - collectionView!.bounds.width)

        let proposedAngle = proposedContentOffset.x*factor
        let ratio = proposedAngle/anglePerItem
        var multiplier: CGFloat
        if (velocity.x > 0) {
          multiplier = ceil(ratio)
        } else if (velocity.x < 0) {
          multiplier = floor(ratio)
        } else {
          multiplier = round(ratio)
        }
        finalContentOffset.x = multiplier*anglePerItem/factor
        return finalContentOffset
    }
}
