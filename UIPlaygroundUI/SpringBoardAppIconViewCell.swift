//
//  SpringBoardAppIconViewCell.swift
//  UIPlayground
//
//  Created by Kip Nicol on 9/20/16.
//  Copyright © 2016 Kip Nicol. All rights reserved.
//

import UIKit

class SpringBoardAppIconViewCell: UICollectionViewCell {
    
    weak var delegate: SpringBoardAppIconViewCellDelegate?
    
    let appNameFont = UIFont.systemFont(ofSize: 12)
    
    let appNameLabel = UILabel()
    let appIconButtonView = UIButton()
    
    var appIconLength: CGFloat {
        get { return appIconContentViewHeightConstraint.constant }
        set {
            appIconContentViewHeightConstraint.constant = newValue
            appIconButtonView.layer.mask?.frame.size = CGSize(width: newValue, height: newValue)
        }
    }
    
    var appIconImage: UIImage? {
        get { return appIconButtonView.image(for: .normal) }
        set { appIconButtonView.setImage(newValue, for: .normal) }
    }
    
    private var appIconContentViewHeightConstraint: NSLayoutConstraint!
    
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
        stackView.spacing = 4
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.anchorConstraintsToFitSuperview()
        
        appIconContentView.addSubview(appIconButtonView)
        appIconContentView.translatesAutoresizingMaskIntoConstraints = false
        appIconContentViewHeightConstraint = appIconContentView.heightAnchor.constraint(equalToConstant: 60)
        appIconContentViewHeightConstraint.isActive = true
        appIconContentView.heightAnchor.constraint(equalTo: appIconContentView.widthAnchor, multiplier: 1).isActive = true
        
        let mask = CALayer()
        mask.contents = UIImage(named: "AppIconMask", inBundleForObject: self)!.cgImage
        mask.frame = CGRect(x: 0, y: 0, width: appIconLength, height: appIconLength)
        mask.contentsGravity = kCAGravityResize
        appIconButtonView.layer.mask = mask
        appIconButtonView.layer.masksToBounds = true
        appIconButtonView.contentMode = .scaleAspectFill
        appIconButtonView.contentHorizontalAlignment = .fill
        appIconButtonView.contentVerticalAlignment = .fill
        appIconButtonView.translatesAutoresizingMaskIntoConstraints = false
        appIconButtonView.anchorConstraintsToFitSuperview()
        
        appNameLabel.textColor = .white
        appNameLabel.font = appNameFont
        appNameLabel.allowsDefaultTighteningForTruncation = true
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress))
        appIconButtonView.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    func didLongPress(recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            delegate?.springBoardAppIconViewCell(didLongPress: self)
        }
    }
}

protocol SpringBoardAppIconViewCellDelegate: class {
    
    func springBoardAppIconViewCell(didLongPress springBoardAppIconViewCell: SpringBoardAppIconViewCell)
}
