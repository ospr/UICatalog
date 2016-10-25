//
//  CardView.swift
//  UIPlayground
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
    @IBOutlet private weak var contentStackView: UIStackView!
    
    public var auxViewPadding: CGFloat {
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
    
    private func setup() {
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
