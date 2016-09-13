//
//  CardView.swift
//  UIPlayground
//
//  Created by Kip Nicol on 8/18/16.
//  Copyright © 2016 Kip Nicol. All rights reserved.
//

import UIKit
import QuartzCore

open class CardView: UIView {

    @IBOutlet open fileprivate(set) weak var headerLabel: UILabel!
    @IBOutlet open fileprivate(set) weak var headerImageView: UIImageView!
    @IBOutlet open fileprivate(set) weak var mainImageView: UIImageView!
    @IBOutlet fileprivate weak var shadowView: UIView!
    @IBOutlet fileprivate weak var contentStackView: UIStackView!
    
    open var auxViewPadding: CGFloat {
        get { return contentStackView.spacing }
        set { contentStackView.spacing = newValue }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    fileprivate func setup() {
        let _ = addOwnedViewFrom(nibNamed: String(describing: CardView.self))
        
        mainImageView.clipsToBounds = true
        mainImageView.layer.cornerRadius = 6
        
        shadowView.backgroundColor = .clear
        shadowView.layer.shadowOffset = CGSize.zero
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOpacity = 0.1
        shadowView.layer.shadowRadius = 6.0
        
        headerLabel.text = nil
        headerLabel.textColor = .white
    }

}
