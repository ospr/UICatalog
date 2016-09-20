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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    func setup() {
        clipsToBounds = true
        layer.cornerRadius = cornerRadius
        
        // TODO: update this
        backgroundColor = .blue
    }
}
