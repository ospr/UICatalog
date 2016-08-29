//
//  CarouselView.swift
//  UICatalog
//
//  Created by Kip Nicol on 8/18/16.
//  Copyright © 2016 Kip Nicol. All rights reserved.
//

import UIKit
import QuartzCore

// TODO: remove this?
class TransformView: UIView {
//    override var layer: CALayer {
//        return CATransformLayer()
//    }
}

// TODO: use exsiting struct for this?
struct Point3D {
    var x: CGFloat
    var y: CGFloat
    var z: CGFloat
}

public class CarouselView: UIView {

    public weak var dataSource: CarouselViewDataSource?
    
    private var itemViews: [UIView] = []
    // TODO: clean up property names here
    private var transformView = TransformView()
    private var rootOffset = CGFloat(0)
    private var viewPositions: [Point3D] = []
    
    var decelerateDisplayLinkProgressor: DisplayLinkProgressor?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    private func setup() {
        // TODO: remove the transform view??
        addSubview(transformView)
        transformView.translatesAutoresizingMaskIntoConstraints = false
        transformView.anchorConstraintsToFitSuperview()
        
//        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(viewWasPanned))
//        addGestureRecognizer(panGesture)
//        panGesture.enabled = true
    }
    
    // MARK: - Handling gestures
    
    var animator: UIDynamicAnimator?
    
    func viewWasPanned(recognizer: UIPanGestureRecognizer) {
        print("view was panned: \(recognizer.view!.tag), view: \(recognizer.view!)")
        
        switch recognizer.state {
        case .Possible, .Began:
            decelerateDisplayLinkProgressor = nil
            
        case .Changed:
            let translation = recognizer.translationInView(self)
            recognizer.setTranslation(CGPointZero, inView: self)
            shiftItemViews(byOffset: translation.x)
            
            print("translation: \(translation)")
            
        case .Ended, .Cancelled, .Failed:
            // TODO: have views settle back to their desired location based on where they currently are

            var velocityX = Double(recognizer.velocityInView(self).x)
            
            decelerateDisplayLinkProgressor = DisplayLinkProgressor.run({ [weak self] (timeDelta) -> Bool in
                guard let `self` = self else { return false }
                
                let frictionConstant = -4.0
                
                let force = velocityX * frictionConstant
                velocityX += force * timeDelta
                let offset = velocityX * timeDelta
                
                self.shiftItemViews(byOffset: CGFloat(offset))
                
                print("force: \(force), time: \(timeDelta), offset: \(offset), speed: \(velocityX)")

                return abs(velocityX) > 0.1
            })
        }
    }
    
    // MARK: - Working with Data
    
    public func reloadData() {
        for itemView in itemViews {
            itemView.removeFromSuperview()
        }
        viewPositions.removeAll()
        
        itemViews = {
            guard let dataSource = dataSource else {
                return []
            }
            
            let numberOfItems = dataSource.numberOfItemsInCarouselView(self)
            
            // TODO: make this more dynamic so that we don't ask for everything all at once
            return (0..<numberOfItems).map { (index) -> UIView in
                dataSource.carouselView(self, viewForItemAtIndex: index)
            }
        }()
        
        for (index, itemView) in itemViews.enumerate() {
            transformView.insertSubview(itemView, atIndex: 0)
            itemView.frame.size = CGSize(width: 300, height: 500) // TODO: change hardcoded values
            
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(viewWasPanned))
            itemView.addGestureRecognizer(panGesture)
            panGesture.enabled = true
            
             // TODO: remove this? useful for debugging
            itemView.tag = index + 1
            print("tag: \(itemView.tag), view: \(itemView)")
        }
        
        layoutItemViews()
    }
    
    private func shiftItemViews(byOffset offset: CGFloat) {
        // TODO: clean this up
        
        rootOffset += offset
        
        for (index, itemView) in itemViews.enumerate() {
            var transform = CATransform3DIdentity
            transform.m34 = 1.0 / -1000.0
            
            // Use the current root offset to determine progress through animation
            // We subtract from the root offset to put cards further behind each other
            let progress = ((rootOffset - CGFloat(index * 50)) / 10.0)
            
            var point = viewPositions[index]
            // Z grows linearly when progress is past 0
            point.z = progress > 0 ? 3 * progress : 0
            // X grows using an exponential function to ensure that as progress
            // goes further negative that we only ever get closer to 0
            // TODO: should probably just have it stop around 0 like we do with Z
            point.x = pow(2, ((rootOffset - CGFloat(index * 50)) / 25.0))
            transform = CATransform3DTranslate(transform, point.x, point.y, point.z)
            
            itemView.layer.transform = transform
            viewPositions[index] = point
        }
    }
    
    private func layoutItemViews() {
        for itemView in itemViews {
            itemView.center.y = center.y
            itemView.frame.origin.x = bounds.origin.x
            
            viewPositions.append(Point3D(x: 0, y: 0, z: 0))
        }
    }

}

public protocol CarouselViewDataSource: class {
    
    func numberOfItemsInCarouselView(carouselView: CarouselView) -> Int
    func carouselView(carouselView: CarouselView, viewForItemAtIndex: Int) -> UIView
}
