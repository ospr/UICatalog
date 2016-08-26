//
//  CardView.swift
//  UICatalog
//
//  Created by Kip Nicol on 8/18/16.
//  Copyright © 2016 Kip Nicol. All rights reserved.
//

import UIKit
import QuartzCore

public class CardView: UIView {

    @IBOutlet public private(set) weak var headerLabel: UILabel!
    @IBOutlet public private(set) weak var headerImageView: UIImageView!
    @IBOutlet public private(set) weak var mainImageView: UIImageView!
    @IBOutlet private weak var shadowView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    private func setup() {
        addOwnedViewFrom(nibNamed: String(CardView.self))
        
        mainImageView.clipsToBounds = true
        mainImageView.layer.cornerRadius = 6
        
        shadowView.backgroundColor = .clearColor()
        shadowView.layer.shadowOffset = CGSizeZero
        shadowView.layer.shadowColor = UIColor.blackColor().CGColor
        shadowView.layer.shadowOpacity = 0.1
        shadowView.layer.shadowRadius = 6.0
        
        headerLabel.textColor = .whiteColor()
    }

}
