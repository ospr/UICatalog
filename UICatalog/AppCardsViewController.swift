//
//  AppCardsViewController.swift
//  UICatalog
//
//  Created by Kip Nicol on 8/18/16.
//  Copyright © 2016 Kip Nicol. All rights reserved.
//

import UIKit
import UICatalogElements

class AppCardsViewController: UIViewController {

    @IBOutlet weak var carouselView: CarouselView!
    
    required init() {
        super.init(nibName: String(AppCardsViewController.self), bundle: nil)
        
        title = "App Cards"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented. Use init()")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        carouselView.dataSource = self
        carouselView.reloadData()
    }
}

extension AppCardsViewController: CarouselViewDataSource {
    
    // TODO: update this
    func numberOfItemsInCarouselView(carouselView: CarouselView) -> Int {
        return 10
    }
    
    // TODO: update this
    func carouselView(carouselView: CarouselView, viewForItemAtIndex: Int) -> UIView {
        let cardView = CardView()
        cardView.headerLabel.text = "UICatalog"
        cardView.headerImageView.image = UIImage(named: "OffCircleButton")
        cardView.mainImageView.image = UIImage(named: "AppCard-Main-1")
        
        return cardView
    }
}
