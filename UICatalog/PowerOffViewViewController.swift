//
//  PowerOffViewViewController.swift
//  UICatalog
//
//  Created by Kip Nicol on 8/7/16.
//  Copyright © 2016 Kip Nicol. All rights reserved.
//

import UIKit

// TODO: fix name here
class PowerOffViewViewController: UIViewController {
    
    required init() {
        super.init(nibName: String(PowerOffViewViewController.self), bundle: nil)
        
        title = "Power Off"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented. Use init()")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}
