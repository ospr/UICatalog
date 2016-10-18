//
//  CarouselView.swift
//  UIPlayground
//
//  Created by Kip Nicol on 8/18/16.
//  Copyright © 2016 Kip Nicol. All rights reserved.
//

import UIKit
import QuartzCore

open class CarouselView: UIView, UIGestureRecognizerDelegate {

    open weak var dataSource: CarouselViewDataSource?
    open weak var delegate: CarouselViewDelegate?
    
    // A 1 here means that the resitance increases linearly from 0 to 1 between the item origin and item offscreen
    open var itemViewPanDownResistance = CGFloat(1.8)
    open var itemViewPanDownResistanceMax = CGFloat(0.9)
    open var itemViewPanDownResistanceMin = CGFloat(0.0)
    
    open var itemViewRemovalEscapeVelocity = CGFloat(-100)
    open var itemViewRemovalAnimationDuration = 0.15
    open var itemViewRemovalFailureAnimationDuration = 0.25
    
    var animateViewItemOpacity = true
    
    fileprivate var itemViews: [UIView] = []
    fileprivate var absoluteOffset = CGFloat(0)
    fileprivate var viewPositions: [UIView: Point3D] = [:]
    fileprivate var horizontalPanGesture: UIPanGestureRecognizer!
    fileprivate var decelerateDisplayLinkProgressor: DisplayLinkProgressor?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    fileprivate func setup() {
        horizontalPanGesture = UIPanGestureRecognizer(target: self, action: #selector(viewWasPanned))
        addGestureRecognizer(horizontalPanGesture)
        horizontalPanGesture.isEnabled = true
        horizontalPanGesture.delegate = self
        
        // Setup perspective
        var perspectiveTransform = CATransform3DIdentity
        perspectiveTransform.m34 = 1.0 / -1000.0
        layer.sublayerTransform = perspectiveTransform
    }
    
    // MARK: - Handling gestures
    
    func viewWasPanned(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .possible:
            break
            
        case .began:
            stopDecelerationAnimation()
            
        case .changed:
            let translation = recognizer.translation(in: self)
            recognizer.setTranslation(CGPoint.zero, in: self)

            // Find which view the user's finger is currently panning over
            // and shift all views relative to that view
            let pannedView = itemViews.findFirst({ (view) -> Bool in
                let localPoint = recognizer.location(in: view)
                return view.point(inside: localPoint, with: nil)
            })

            if let pannedView = pannedView {
                didPanHorizontally(byOffset: translation.x, forView: pannedView)
            }
            
        case .ended:
            let velocity = recognizer.velocity(in: self)
            animatePanEndDeceleration(withVelocity: velocity)
            
        case .cancelled, .failed:
            break
        }
    }
    
    func itemViewDidPan(_ recognizer: UIPanGestureRecognizer) {
        let pannedView = recognizer.view!
        let viewPosition = viewPositions[pannedView]!
        
        switch recognizer.state {
        case .possible:
            break
            
        case .began:
            break
            
        case .changed:
            let translation = recognizer.translation(in: self)
            recognizer.setTranslation(CGPoint.zero, in: self)
            
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
            
        case .ended:
            let velocity = recognizer.velocity(in: self)
            
            // If the user swipes up with a great enough velocity or
            // if the panned view has been moved up enough, then remove it
            if velocity.y < itemViewRemovalEscapeVelocity || pannedView.frame.maxY < center.y {
                animateRemoval(ofItemView: pannedView)
            }
            // Otherwise animate a snapping back of the view into its position
            else {
                UIView.animate(withDuration: itemViewRemovalFailureAnimationDuration, animations: {
                    var newPosition = viewPosition
                    // TODO: make the resting location common code
                    newPosition.y = self.bounds.height / 2.0 - pannedView.bounds.height / 2.0
                    self.updateItemView(pannedView, withPosition: newPosition)
                })
            }
            
        case .cancelled, .failed:
            break
        }
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        stopDecelerationAnimation()
    }
    
    // MARK: - Working with Data
    
    open func reloadData() {
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
            insertSubview(itemView, at: 0)
            
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(itemViewDidPan))
            itemView.addGestureRecognizer(panGesture)
            panGesture.isEnabled = true
            // Give presedence to the horizontal pan gesture 
            panGesture.require(toFail: horizontalPanGesture)
        }
        
        layoutItemViews()
        didPanHorizontally(byOffset: 0)
    }
    
    // MARK: - Updating item views
    
    fileprivate func updateAbsoluteOffset(_ newAbsoluteOffset: CGFloat) {
        absoluteOffset = newAbsoluteOffset
        
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
        
        for (index, itemView) in itemViews.enumerated() {
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
                if !animateViewItemOpacity {
                    return 1
                }
                
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
    
    fileprivate func didPanHorizontally(byOffset offset: CGFloat, forView view: UIView? = nil) {
        // Calculate the new x origin point for the view that was panned.
        // Then use that value to backwards calculate the new root offset
        // based on the view that was actually panned. This allows us to 
        // keep the currently "selected" view under the user's finger 
        // while it's being panned, but still allow for the other card
        // animations to behave properly
        let newAbsoluteOffset: CGFloat = {
            if let view = view {
                let nextViewXPoint = max(0, viewPositions[view]!.x + offset)
                return absoluteOffsetForItemView(view, atXPosition: nextViewXPoint)
            }
            else {
                return absoluteOffset + offset
            }
        }()

        updateAbsoluteOffset(newAbsoluteOffset)
    }
    
    public func animateIn() {
        guard let firstItemView = itemViews.first else {
            return
        }

        // Turn off opacity animation here so that we don't get a weird
        // opacity animation effect while animating in
        let previousAnimateViewItemOpacity = animateViewItemOpacity
        animateViewItemOpacity = false
        updateAbsoluteOffset(0)
        
        let animator = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 4.56) {
            self.didPanHorizontally(byOffset: self.bounds.midX, forView: firstItemView)
        }
        animator.addCompletion { (position) in
            self.animateViewItemOpacity = previousAnimateViewItemOpacity
        }
        animator.startAnimation()
    }
    
    fileprivate func animateRemoval(ofItemView itemView: UIView) {
        var position = viewPositions[itemView]!
        position.y = -itemView.frame.height
        
        UIView.animate(withDuration: itemViewRemovalAnimationDuration, delay: 0, options: [.curveLinear], animations: {
            self.updateItemView(itemView, withPosition: position)
            
            }, completion: { (finished) in
                if finished {
                    itemView.removeFromSuperview()
                    self.itemViews.remove(at: self.itemViews.index(of: itemView)!)
                    self.viewPositions.removeValue(forKey: itemView)
                }
        })
    }
    
    fileprivate func animatePanEndDeceleration(withVelocity velocity: CGPoint) {
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
    
    fileprivate func layoutItemViews() {
        for itemView in itemViews {
            itemView.layer.transform = CATransform3DIdentity
            itemView.frame.origin = bounds.origin
            
            let position = Point3D(x: 0, y: bounds.height / 2.0 - itemView.bounds.height / 2.0, z: 0)
            updateItemView(itemView, withPosition: position)
            
            delegate?.carouselView(self, didUpdateItemView: itemView)
        }
    }

    fileprivate func updateItemView(_ itemView: UIView, withPosition position: Point3D) {
        let transform = CATransform3DMakeTranslation(position.x, position.y, position.z)
        
        itemView.layer.transform = transform
        viewPositions[itemView] = position
    }
    
    fileprivate func absoluteOffsetForItemView(_ itemView: UIView, atXPosition xPosition: CGFloat) -> CGFloat {
        let viewIndex = itemViews.index(of: itemView)!
        return (25 * log2orZero(xPosition)) + (CGFloat(viewIndex) * 50)
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // Fail the horizontal gesture recognizer if the user is swiping up/down with
        // a greater velocity to allow the per-itemView recognizers to handle that
        if gestureRecognizer === horizontalPanGesture {
            let velocity = horizontalPanGesture.velocity(in: self)
            return fabs(velocity.x) > fabs(velocity.y)
        }
        
        return true
    }
}

public protocol CarouselViewDataSource: class {
    
    func numberOfItemsInCarouselView(_ carouselView: CarouselView) -> Int
    func carouselView(_ carouselView: CarouselView, viewForItemAtIndex index: Int) -> UIView
}

public protocol CarouselViewDelegate: class {
    
    func carouselView(_ carouselView: CarouselView, didUpdateItemView itemView: UIView)
}
