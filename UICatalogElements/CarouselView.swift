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

public class CarouselView: UIView, UIGestureRecognizerDelegate {

    public weak var dataSource: CarouselViewDataSource?
    public weak var delegate: CarouselViewDelegate?
    
    private var itemViews: [UIView] = []
    // TODO: clean up property names here
    private var transformView = TransformView()
    private var absoluteOffset = CGFloat(0)
    private var viewPositions: [UIView: Point3D] = [:]
    private var horizontalPanGesture: UIPanGestureRecognizer!
    
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
        
        horizontalPanGesture = UIPanGestureRecognizer(target: self, action: #selector(viewWasPanned))
        addGestureRecognizer(horizontalPanGesture)
        horizontalPanGesture.enabled = true
        horizontalPanGesture.delegate = self
    }
    
    // MARK: - Handling gestures
    
    func viewWasPanned(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .Possible:
            break
            
        case .Began:
            stopDecelerationAnimation()
            
        case .Changed:
            let translation = recognizer.translationInView(self)
            recognizer.setTranslation(CGPointZero, inView: self)

            // Find which view the user's finger is currently panning over
            // and shift all views relative to that view
            // TODO: Bug where if you slide item to the left, so that it catches
            //       the item just to the right of it, then slide that new right
            //       card to the right, somehow you lose that right card and we
            //       start shifting relative to the left card again.
            let pannedView = itemViews.findFirst({ (view) -> Bool in
                let localPoint = recognizer.locationInView(view)
                return view.pointInside(localPoint, withEvent: nil)
            })

            if let pannedView = pannedView {
                didPanHorizontally(byOffset: translation.x, forView: pannedView)
            }
            
        case .Ended:
            // TODO: have views settle back to their desired location based on where they currently are

            let velocity = recognizer.velocityInView(self)
            animateDeceleration(withVelocity: velocity)
            
        case .Cancelled, .Failed:
            break
        }
    }
    
    func itemViewDidPan(recognizer: UIPanGestureRecognizer) {
        let pannedView = recognizer.view!
        let viewPosition = viewPositions[pannedView]!
        
        switch recognizer.state {
        case .Possible:
            break
            
        case .Began:
            break
            
        case .Changed:
            let translation = recognizer.translationInView(self)
            recognizer.setTranslation(CGPointZero, inView: self)
            
            let resistance: CGFloat = {
                // If the view is being pulled down past the resting spot,
                // add a non-linear resistance to the draggin to simulate
                // it being on a rubber band
                // TODO: make the resting location common code
                if translation.y >= 0 && pannedView.frame.midY > bounds.midY {
                    let distance = pannedView.frame.midY - bounds.midY
                    // TODO: clean up this resistance
                    return (1 - 0.006 * distance)
                }
                return 1.0
            }()
            
            var newPosition = viewPosition
            newPosition.y += translation.y * resistance
            
            updateItemView(pannedView, withPosition: newPosition)
            
        case .Ended:
            let velocity = recognizer.velocityInView(self)
            
            print("velocity: \(velocity)")
            
            // TODO: move constant here and clean up
            // If the user swipes up with a great enough velocity or
            // if the panned view has been moved up enough, then remove it
            if velocity.y < -100 || pannedView.frame.maxY < center.y {
                animateRemoval(ofItemView: pannedView)
            }
            // Otherwise animate a snapping back of the view into its position
            else {
                // TODO: add constant for this duration
                UIView.animateWithDuration(0.25, animations: {
                    var newPosition = viewPosition
                    // TODO: make the resting location common code
                    newPosition.y = self.bounds.height / 2.0 - pannedView.bounds.height / 2.0
                    self.updateItemView(pannedView, withPosition: newPosition)
                })
            }
            
        case .Cancelled, .Failed:
            break
        }
    }
    
    public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        stopDecelerationAnimation()
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
        
        for itemView in itemViews {
            transformView.insertSubview(itemView, atIndex: 0)
            itemView.frame.size = CGSize(width: 300, height: 500) // TODO: change hardcoded values
            
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(itemViewDidPan))
            itemView.addGestureRecognizer(panGesture)
            panGesture.enabled = true
            // Give presedence to the horizontal pan gesture 
            panGesture.requireGestureRecognizerToFail(horizontalPanGesture)
        }
        
        layoutItemViews()
    }
    
    // MARK: - Updating item views
    
    private func didPanHorizontally(byOffset offset: CGFloat, forView view: UIView? = nil) {
        // TODO: clean this up
        
        // Calculate the new x origin point for the view that was panned.
        // Then use that value to backwards calculate the new root offset
        // based on the view that was actually panned. This allows us to 
        // keep the currently "selected" view under the user's finger 
        // while it's being panned, but still allow for the other card
        // animations to behave properly
        // TODO: some better way to abstract this. If a value below changes it
        //       needs to change here as well
        if let view = view {
            let nextViewXPoint = max(0, viewPositions[view]!.x + offset)
            absoluteOffset = absoluteOffsetForItemView(view, atXPosition: nextViewXPoint)
            
            print("nextViewXPoint: \(nextViewXPoint), view index: \(itemViews.indexOf(view)!), absOffset: \(absoluteOffset)")
        }
        else {
            absoluteOffset += offset
        }

        // Force the last view to only ever get to the mid point of the carousel view
        if let lastItemView = itemViews.last {
            let finalViewXPoint = bounds.midX
            let lastAbsoluteOffset = absoluteOffsetForItemView(lastItemView, atXPosition: finalViewXPoint)
            
            absoluteOffset = min(lastAbsoluteOffset, absoluteOffset)
        }
        
        for (index, itemView) in itemViews.enumerate() {
            // Use the current root offset to determine progress through animation
            // We subtract from the root offset to put cards further behind each other
            let itemOffset = 50
            let localOffset = (absoluteOffset - CGFloat(index * itemOffset))
            
            var itemPosition = viewPositions[itemView]!
            // Z grows linearly when progress is past 0
            itemPosition.z = localOffset > 0 ? 0.3 * localOffset : 0
            // X grows using an exponential function to ensure that as progress
            // goes further negative that we only ever get closer to 0
            // TODO: should probably just have it stop around 0 like we do with Z
            itemPosition.x = localOffset > 0 ? pow(2, localOffset / 25.0) : 0

            updateItemView(itemView, withPosition: itemPosition)
            
            delegate?.carouselView(self, didUpdateItemView: itemView)
        }
    }
    
    private func animateRemoval(ofItemView itemView: UIView) {
        var position = viewPositions[itemView]!
        position.y = -itemView.frame.height
        
        // TODO: move constant here
        UIView.animateWithDuration(0.15, delay: 0, options: [.CurveLinear], animations: {
            self.updateItemView(itemView, withPosition: position)
            
            }, completion: { (finished) in
                if finished {
                    itemView.removeFromSuperview()
                    self.itemViews.removeAtIndex(self.itemViews.indexOf(itemView)!)
                    self.viewPositions.removeValueForKey(itemView)
                }
        })

    }
    
    private func animateDeceleration(withVelocity velocity: CGPoint) {
        var velocityX = Double(velocity.x)
        
        decelerateDisplayLinkProgressor = DisplayLinkProgressor.run({ [weak self] (timeDelta) -> Bool in
            guard let `self` = self else { return false }
            
            let frictionConstant = -4.0
            
            let force = velocityX * frictionConstant
            velocityX += force * timeDelta
            let offset = velocityX * timeDelta
            
            self.didPanHorizontally(byOffset: CGFloat(offset))
            
            print("force: \(force), time: \(timeDelta), offset: \(offset), speed: \(velocityX)")
            
            return abs(velocityX) > 0.1
        })
    }
    
    func stopDecelerationAnimation() {
        guard let decelerateDisplayLinkProgressor = decelerateDisplayLinkProgressor else { return }
        
        decelerateDisplayLinkProgressor.stop()
        self.decelerateDisplayLinkProgressor = nil
    }
    
    private func layoutItemViews() {
        for itemView in itemViews {
            itemView.frame.origin = bounds.origin
            
            let position = Point3D(x: 0, y: bounds.height / 2.0 - itemView.bounds.height / 2.0, z: 0)
            updateItemView(itemView, withPosition: position)
            
            delegate?.carouselView(self, didUpdateItemView: itemView)
        }
    }

    private func updateItemView(itemView: UIView, withPosition position: Point3D) {
        var transform = CATransform3DIdentity
        transform.m34 = 1.0 / -1000.0
        transform = CATransform3DTranslate(transform, position.x, position.y, position.z)
        
        itemView.layer.transform = transform
        viewPositions[itemView] = position
    }
    
    private func absoluteOffsetForItemView(itemView: UIView, atXPosition xPosition: CGFloat) -> CGFloat {
        let viewIndex = itemViews.indexOf(itemView)!
        return (25 * log2orZero(xPosition)) + (CGFloat(viewIndex) * 50)
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    public override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        // Fail the horizontal gesture recognizer if the user is swiping up/down with
        // a greater velocity to allow the per-itemView recognizers to handle that
        if gestureRecognizer === horizontalPanGesture {
            let velocity = horizontalPanGesture.velocityInView(self)
            return fabs(velocity.x) > fabs(velocity.y)
        }
        
        return true
    }
}

public protocol CarouselViewDataSource: class {
    
    func numberOfItemsInCarouselView(carouselView: CarouselView) -> Int
    func carouselView(carouselView: CarouselView, viewForItemAtIndex: Int) -> UIView
}

public protocol CarouselViewDelegate: class {
    
    func carouselView(carouselView: CarouselView, didUpdateItemView itemView: UIView)
}

// TODO: move to math extension?
func log2orZero(d: CGFloat) -> CGFloat {
    return d <= 0 ? 0 : log2(d)
}
