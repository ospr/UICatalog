//
//  SpringBoardAppIconViewCell.swift
//  UIPlayground
//
//  Created by Kip Nicol on 9/20/16.
//  Copyright © 2016 Kip Nicol. All rights reserved.
//

import UIKit

class SpringBoardAppIconViewCell: UICollectionViewCell {
    
    let appIconLength = CGFloat(60)
    let appNameFont = UIFont.systemFont(ofSize: 12)
    
    let appNameLabel = UILabel()
    let appIconButtonView = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    func setup() {
        let appIconContentView = UIView()
        
        let stackView = UIStackView(arrangedSubviews: [
            appIconContentView,
            appNameLabel,
        ])
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.alignment = .center
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.anchorConstraintsToFitSuperview()
        
        appIconContentView.addSubview(appIconButtonView)
        appIconContentView.translatesAutoresizingMaskIntoConstraints = false
        appIconContentView.heightAnchor.constraint(equalToConstant: appIconLength).isActive = true
        appIconContentView.heightAnchor.constraint(equalTo: appIconContentView.widthAnchor, multiplier: 1).isActive = true
        
        let mask = CALayer()
        mask.contents = UIImage(named: "AppIconMask", inBundleForObject: self)!.cgImage
        mask.frame = CGRect(x: 0, y: 0, width: appIconLength, height: appIconLength)
        mask.contentsGravity = kCAGravityResize
        appIconButtonView.layer.mask = mask
        appIconButtonView.layer.masksToBounds = true
        appIconButtonView.translatesAutoresizingMaskIntoConstraints = false
        appIconButtonView.anchorConstraintsToFitSuperview()
        
        appNameLabel.textColor = .white
        appNameLabel.font = appNameFont
        appNameLabel.allowsDefaultTighteningForTruncation = true
    }
}
