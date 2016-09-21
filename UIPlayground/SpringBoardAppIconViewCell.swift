//
//  SpringBoardAppIconViewCell.swift
//  UIPlayground
//
//  Created by Kip Nicol on 9/20/16.
//  Copyright © 2016 Kip Nicol. All rights reserved.
//

import UIKit

class SpringBoardAppIconViewCell: UICollectionViewCell {
    
    let cornerRadius = CGFloat(12)
    let appIconLength = CGFloat(60)
    let appNameFont = UIFont.systemFont(ofSize: 12)
    
    let appNameLabel = UILabel()
    let appIconImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    func setup() {
        let stackView = UIStackView(arrangedSubviews: [
            appIconImageView,
            appNameLabel,
        ])
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.alignment = .center
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.anchorConstraintsToFitSuperview()
        
        appIconImageView.clipsToBounds = true
        appIconImageView.layer.cornerRadius = cornerRadius
        appIconImageView.heightAnchor.constraint(equalToConstant: appIconLength).isActive = true
        appIconImageView.heightAnchor.constraint(equalTo: appIconImageView.widthAnchor, multiplier: 1).isActive = true
        
        appNameLabel.textColor = .white
        appNameLabel.font = appNameFont
        appNameLabel.allowsDefaultTighteningForTruncation = true
    }
}
