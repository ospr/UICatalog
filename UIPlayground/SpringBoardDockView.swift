//
//  SpringBoardDockView.swift
//  UIPlayground
//
//  Created by Kip Nicol on 9/20/16.
//  Copyright © 2016 Kip Nicol. All rights reserved.
//

import UIKit
import UIPlaygroundElements

class SpringBoardDockView: UIView {

    let blurView = UIVisualEffectView(effect: nil)    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    private func setup() {
        backgroundColor = .clear
        
        addSubview(blurView)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.effect = UIBlurEffect(style: .light)
        blurView.anchorConstraintsToFitSuperview()
    }
}
