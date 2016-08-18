//
//  CardView.swift
//  UICatalog
//
//  Created by Kip Nicol on 8/18/16.
//  Copyright © 2016 Kip Nicol. All rights reserved.
//

import UIKit

public class CardView: UIView {

    @IBOutlet public private(set) weak var headerLabel: UILabel!
    @IBOutlet public private(set) weak var headerImageView: UIImageView!
    @IBOutlet public private(set) weak var mainImageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    private func setup() {
        let view = addOwnedViewFrom(nibNamed: String(CardView.self))
        
    }

}
