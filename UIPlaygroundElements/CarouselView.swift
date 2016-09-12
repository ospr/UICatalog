//
//  CarouselView.swift
//  UIPlayground
//
//  Created by Kip Nicol on 8/18/16.
//  Copyright © 2016 Kip Nicol. All rights reserved.
//

import UIKit
import QuartzCore

public class CarouselView: UIView, UIGestureRecognizerDelegate {

    public weak var dataSource: CarouselViewDataSource?
    public weak var delegate: CarouselViewDelegate?
    
    // A 1 here means that the resitance increases linearly from 0 to 1 between the item origin and item offscreen
    public var itemViewPanDownResistance = CGFloat(1.8)
    public var itemViewPanDownResistanceMax = CGFloat(0.9)
    public var itemViewPanDownResistanceMin = CGFloat(0.0)
    
    public var itemViewRemovalEscapeVelocity = CGFloat(-100)
    public var itemViewRemovalAnimationDuration = 0.15
    public var itemViewRemovalFailureAnimationDuration = 0.25
    
    private var itemViews: [UIView] = []
    private var absoluteOffset = CGFloat(0)
    private var viewPositions: [UIView: Point3D] = [:]
    private var horizontalPanGesture: UIPanGestureRecognizer!
    private var decelerateDisplayLinkProgressor: DisplayLinkProgressor?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    private func setup() {
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
            let pannedView = itemViews.findFirst({ (view) -> Bool in
                let localPoint = recognizer.locationInView(view)
                return view.pointInside(localPoint, withEvent: nil)
            })

            if let pannedView = pannedView {
                didPanHorizontally(byOffset: translation.x, forView: pannedView)
            }
            
        case .Ended:
            let velocity = recognizer.velocityInView(self)
            animatePanEndDeceleration(withVelocity: velocity)
            
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
                // add a resistance to the dragging to simulate it being on a rubber band
                // TODO: make the resting location common code
                if translation.y >= 0 && pannedView.frame.midY > bounds.midY {
                    let originY = bounds.midY - (pannedView.frame.height / 2.0)
                    let offScreenDistance = bounds.maxY - originY
                    let currentDistance = pannedView.frame.origin.y - originY
                    let resistance = currentDistance / (offScreenDistance / itemViewPanDownResistance)
                    
                    return min(max(resistance, itemViewPanDownResistanceMin), itemViewPanDownResistanceMax)
                }
                return 0
            }()
            
            var newPosition = viewPosition
            newPosition.y += translation.y * (1 - resistance)
            
            updateItemView(pannedView, withPosition: newPosition)
            
        case .Ended:
            let velocity = recognizer.velocityInView(self)
            
            // If the user swipes up with a great enough velocity or
            // if the panned view has been moved up enough, then remove it
            if velocity.y < itemViewRemovalEscapeVelocity || pannedView.frame.maxY < center.y {
                animateRemoval(ofItemView: pannedView)
            }
            // Otherwise animate a snapping back of the view into its position
            else {
                UIView.animateWithDuration(itemViewRemovalFailureAnimationDuration, animations: {
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
        // TODO: could put this all in a struct and have it all reset properly each time rather than trying to maintain the state here
        for itemView in itemViews {
            itemView.removeFromSuperview()
        }
        viewPositions.removeAll()
        absoluteOffset = 0
        
        itemViews = {
            guard let dataSource = dataSource else {
                return []
            }
            
            let numberOfItems = dataSource.numberOfItemsInCarouselView(self)
            
            return (0..<numberOfItems).map { (index) -> UIView in
                dataSource.carouselView(self, viewForItemAtIndex: index)
            }
        }()
        
        for itemView in itemViews {
            insertSubview(itemView, atIndex: 0)
            
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(itemViewDidPan))
            itemView.addGestureRecognizer(panGesture)
            panGesture.enabled = true
            // Give presedence to the horizontal pan gesture 
            panGesture.requireGestureRecognizerToFail(horizontalPanGesture)
        }
        
        layoutItemViews()
        didPanHorizontally(byOffset: 0)
    }
    
    // MARK: - Updating item views
    
    private func didPanHorizontally(byOffset offset: CGFloat, forView view: UIView? = nil) {
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
        }
        else {
            absoluteOffset += offset
        }

        // Force the last view to only ever get to the mid point of the carousel view
        if let lastItemView = itemViews.last {
            let finalLastViewXPoint = bounds.midX
            let finalLastAbsoluteOffset = absoluteOffsetForItemView(lastItemView, atXPosition: finalLastViewXPoint)
            
            absoluteOffset = min(finalLastAbsoluteOffset, absoluteOffset)
        }
        // Force the first view to only ever get to the far left of the carousel view
        if let firstItemView = itemViews.first {
            let finalFirstViewXPoint = bounds.minX
            let finalFirstAbsoluteOffset = absoluteOffsetForItemView(firstItemView, atXPosition: finalFirstViewXPoint)
            
            absoluteOffset = max(finalFirstAbsoluteOffset, absoluteOffset)
        }
        
        for (index, itemView) in itemViews.enumerate() {
            // Use the current root offset to determine progress through animation
            // We subtract from the root offset to put cards further behind each other
            let itemOffset = CGFloat(50)
            let localOffset = absoluteOffset - (CGFloat(index) * itemOffset)
            
            var itemPosition = viewPositions[itemView]!
            // Z grows linearly when progress is past 0
            itemPosition.z = localOffset > 0 ? 0.3 * localOffset : 0
            // X grows using an exponential function to ensure that as progress
            // goes further negative that we only ever get closer to 0
            itemPosition.x = localOffset > 0 ? pow(2, localOffset / 25.0) : 0

            // Hide views when they are no longer visible (far behind in the deck)
            itemView.alpha = {
                if localOffset < -itemOffset {
                    return 0
                }
                else if localOffset >= 0 {
                    return 1
                }
                
                return localOffset / itemOffset + 1
            }()
            
            updateItemView(itemView, withPosition: itemPosition)
            
            delegate?.carouselView(self, didUpdateItemView: itemView)
        }
    }
    
    private func animateRemoval(ofItemView itemView: UIView) {
        var position = viewPositions[itemView]!
        position.y = -itemView.frame.height
        
        UIView.animateWithDuration(itemViewRemovalAnimationDuration, delay: 0, options: [.CurveLinear], animations: {
            self.updateItemView(itemView, withPosition: position)
            
            }, completion: { (finished) in
                if finished {
                    itemView.removeFromSuperview()
                    self.itemViews.removeAtIndex(self.itemViews.indexOf(itemView)!)
                    self.viewPositions.removeValueForKey(itemView)
                }
        })
    }
    
    private func animatePanEndDeceleration(withVelocity velocity: CGPoint) {
        var velocityX = Double(velocity.x)
        
        decelerateDisplayLinkProgressor = DisplayLinkProgressor.run({ [weak self] (timeDelta) -> Bool in
            guard let `self` = self else { return false }
            
            let frictionConstant = -6.0
            
            let force = velocityX * frictionConstant
            velocityX += force * timeDelta
            let offset = velocityX * timeDelta
            
            self.didPanHorizontally(byOffset: CGFloat(offset))
            
//            print("force: \(force), time: \(timeDelta), offset: \(offset), speed: \(velocityX)")
            
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
    func carouselView(carouselView: CarouselView, viewForItemAtIndex index: Int) -> UIView
}

public protocol CarouselViewDelegate: class {
    
    func carouselView(carouselView: CarouselView, didUpdateItemView itemView: UIView)
}
