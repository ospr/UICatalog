//
//  ThumbSliderView.swift
//  UICatalog
//
//  Created by Kip Nicol on 8/7/16.
//  Copyright © 2016 Kip Nicol. All rights reserved.
//

import UIKit

@IBDesignable
class ThumbSliderView: UIView {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var thumbView: UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    func setup() {
        let view = addOwnedViewFrom(nibNamed: String(ThumbSliderView.self))
        view.backgroundColor = .clearColor()
        
        backgroundView.backgroundColor = .purpleColor()
        thumbView.backgroundColor = .greenColor() // TODO: remove this
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        // TODO: rounded corners don't look quite right
        backgroundView.layer.cornerRadius = backgroundView.bounds.size.height / 2.0
        thumbView.roundCornersToFormCircle()
    }
}
