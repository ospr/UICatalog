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
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        view.addSubview(exitButton)
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        exitButton.anchorConstraintsToCenterInSuperview()
        exitButton.contentEdgeInsets = UIEdgeInsets(top: 7, left: 20, bottom: 7, right: 20)
        exitButton.setTitle("Exit", for: .normal)
        exitButton.setTitleColor(.white, for: .normal)
        exitButton.setTitleColor(.red, for: .highlighted)
        exitButton.titleLabel?.font = .systemFont(ofSize: 26)
        exitButton.addTarget(self, action: #selector(exitPressed), for: .touchUpInside)
        exitButton.backgroundColor = .black
        exitButton.clipsToBounds = true
        exitButton.layer.cornerRadius = 8
    }
    
    // MARK: - Actions
    
    func exitPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
