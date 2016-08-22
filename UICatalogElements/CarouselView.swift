//
//  CarouselView.swift
//  UICatalog
//
//  Created by Kip Nicol on 8/18/16.
//  Copyright © 2016 Kip Nicol. All rights reserved.
//

import UIKit

public class CarouselView: UIView {

    public weak var dataSource: CarouselViewDataSource?
    
    private var itemViews: [UIView] = []
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    private func setup() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(viewWasPanned))
        addGestureRecognizer(panGesture)
        panGesture.enabled = true
    }
    
    // MARK: - Handling gestures
    
    var animator: UIDynamicAnimator?
    
    func viewWasPanned(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .Possible, .Began:
            break
            
        case .Changed:
            let translation = recognizer.translationInView(self)
            recognizer.setTranslation(CGPointZero, inView: self)
            shiftItemViews(byOffset: translation.x)
            
        case .Ended, .Cancelled, .Failed:
            // TODO: have views settle back to their desired location based on where they currently are
            break
        }

    }
    
    // MARK: - Working with Data
    
    public func reloadData() {
        for itemView in itemViews {
            itemView.removeFromSuperview()
        }
        
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
            addSubview(itemView)
            itemView.frame.size = CGSize(width: 300, height: 500) // TODO: change hardcoded values
        }
        
        layoutItemViews()
    }
    
    private func shiftItemViews(byOffset offset: CGFloat) {
        for itemView in itemViews {
            itemView.frame.origin.x += offset
        }
    }
    
    private func layoutItemViews() {
        for (index, itemView) in itemViews.enumerate() {
            itemView.center = center
            itemView.frame.origin.x = bounds.origin.x + CGFloat(index * 200) // TODO: change this hardcoded value
        }
    }

}

public protocol CarouselViewDataSource: class {
    
    func numberOfItemsInCarouselView(carouselView: CarouselView) -> Int
    func carouselView(carouselView: CarouselView, viewForItemAtIndex: Int) -> UIView
}
