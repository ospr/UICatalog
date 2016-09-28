//
//  SpringBoardLaunchedAppViewController.swift
//  UIPlayground
//
//  Created by Kip Nicol on 9/27/16.
//  Copyright © 2016 Kip Nicol. All rights reserved.
//

import UIKit

class SpringBoardLaunchedAppViewController: UIViewController {

    let exitButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .red
        
        view.addSubview(exitButton)
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        exitButton.anchorConstraintsToCenterInSuperview()
        exitButton.setTitle("Exit", for: .normal)
        exitButton.titleLabel?.font = .systemFont(ofSize: 16)
        exitButton.addTarget(self, action: #selector(exitPressed), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    func exitPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
