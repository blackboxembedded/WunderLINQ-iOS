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

class ZoomAndSnapFlowLayout: UICollectionViewFlowLayout {

    let activeDistance: CGFloat = 200
    let zoomFactor: CGFloat = 0.3

    override init() {
        super.init()

        scrollDirection = .horizontal
        minimumLineSpacing = 40
        itemSize = CGSize(width: 200, height: 200)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("ZoomAndSnapFlowLayout: init(coder:) has not been implemented")
    }

    override func prepare() {
        guard let collectionView = collectionView else { fatalError() }
        itemSize = CGSize(width: 200, height: 200)
        let verticalInsets = (collectionView.frame.height - collectionView.adjustedContentInset.top - collectionView.adjustedContentInset.bottom - itemSize.height) / 2
        let horizontalInsets = (collectionView.frame.width - collectionView.adjustedContentInset.right - collectionView.adjustedContentInset.left - itemSize.width) / 2
        sectionInset = UIEdgeInsets(top: verticalInsets, left: horizontalInsets, bottom: verticalInsets, right: horizontalInsets)

        super.prepare()
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView else { return nil }
        let rectAttributes = super.layoutAttributesForElements(in: rect)!.map { $0.copy() as! UICollectionViewLayoutAttributes }
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.frame.size)
        let visibleAttributes = rectAttributes.filter { $0.frame.intersects(visibleRect) }

        if UIDevice.current.orientation.isLandscape {
            // Keep the spacing between cells the same.
            // Each cell shifts the next cell by half of it's enlarged size.
            // Calculated separately for each direction.
            func adjustXPosition(_ toProcess: [UICollectionViewLayoutAttributes], direction: CGFloat, zoom: Bool = false) {
                var dx: CGFloat = 0

                for attributes in toProcess {
                    let distance = visibleRect.midX - attributes.center.x
                    attributes.frame.origin.x += dx

                    if distance.magnitude < activeDistance {
                        let normalizedDistance = distance / activeDistance
                        let zoomAddition = zoomFactor * (1 - normalizedDistance.magnitude)
                        let widthAddition = attributes.frame.width * zoomAddition / 2
                        dx = dx + widthAddition * direction

                        if zoom {
                            let scale = 1 + zoomAddition
                            attributes.transform3D = CATransform3DMakeScale(scale, scale, 1)
                        }
                    }
                }
            }

            // Adjust the x position first from left to right.
            // Then adjust the x position from right to left.
            // Lastly zoom the cells when they reach the center of the screen (zoom: true).
            adjustXPosition(visibleAttributes, direction: +1)
            adjustXPosition(visibleAttributes.reversed(), direction: -1, zoom: true)
        } else {
            // Keep the spacing between cells the same.
            // Each cell shifts the next cell by half of it's enlarged size.
            // Calculated separately for each direction.
            func adjustYPosition(_ toProcess: [UICollectionViewLayoutAttributes], direction: CGFloat, zoom: Bool = false) {
                var dx: CGFloat = 0

                for attributes in toProcess {
                    let distance = visibleRect.midY - attributes.center.y
                    attributes.frame.origin.y += dx

                    if distance.magnitude < activeDistance {
                        let normalizedDistance = distance / activeDistance
                        let zoomAddition = zoomFactor * (1 - normalizedDistance.magnitude)
                        let heightAddition = attributes.frame.height * zoomAddition / 2
                        dx = dx + heightAddition * direction

                        if zoom {
                            let scale = 1 + zoomAddition
                            attributes.transform3D = CATransform3DMakeScale(scale, scale, 1)
                        }
                    }
                }
            }

            // Adjust the y position first from down to up.
            // Then adjust the y position from up to down.
            // Lastly zoom the cells when they reach the center of the screen (zoom: true).
            adjustYPosition(visibleAttributes, direction: +1)
            adjustYPosition(visibleAttributes.reversed(), direction: -1, zoom: true)
        }

        return rectAttributes
    }

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { return .zero }

        if UIDevice.current.orientation.isLandscape {
            // Add some snapping behaviour so that the zoomed cell is always centered
            let targetRect = CGRect(x: proposedContentOffset.x, y: 0, width: collectionView.frame.width, height: collectionView.frame.height)
            guard let rectAttributes = super.layoutAttributesForElements(in: targetRect) else { return .zero }

            var offsetAdjustment = CGFloat.greatestFiniteMagnitude
            let horizontalCenter = proposedContentOffset.x + collectionView.frame.width / 2

            for layoutAttributes in rectAttributes {
                let itemHorizontalCenter = layoutAttributes.center.x
                if (itemHorizontalCenter - horizontalCenter).magnitude < offsetAdjustment.magnitude {
                    offsetAdjustment = itemHorizontalCenter - horizontalCenter
                }
            }

            return CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
        } else {
            // Add some snapping behaviour so that the zoomed cell is always centered
            let targetRect = CGRect(x: 0, y: proposedContentOffset.y, width: collectionView.frame.width, height: collectionView.frame.height)
            guard let rectAttributes = super.layoutAttributesForElements(in: targetRect) else { return .zero }

            var offsetAdjustment = CGFloat.greatestFiniteMagnitude
            let verticalCenter = proposedContentOffset.y + collectionView.frame.height / 2

            for layoutAttributes in rectAttributes {
                let itemVerticalCenter = layoutAttributes.center.y
                if (itemVerticalCenter - verticalCenter).magnitude < offsetAdjustment.magnitude {
                    offsetAdjustment = itemVerticalCenter - verticalCenter
                }
            }

            return CGPoint(x: proposedContentOffset.x, y: proposedContentOffset.y + offsetAdjustment)
        }
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        // Invalidate layout so that every cell get a chance to be zoomed when it reaches the center of the screen
        return true
    }

    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds) as! UICollectionViewFlowLayoutInvalidationContext
        context.invalidateFlowLayoutDelegateMetrics = newBounds.size != collectionView?.bounds.size
        return context
    }

}
