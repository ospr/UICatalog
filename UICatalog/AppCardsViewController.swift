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
        carouselView.delegate = self
        carouselView.reloadData()
    }
}

extension AppCardsViewController: CarouselViewDataSource {
    
    // TODO: update this
    func numberOfItemsInCarouselView(carouselView: CarouselView) -> Int {
        return 10
    }
    
    // TODO: update this and fix the name (label for the index)
    func carouselView(carouselView: CarouselView, viewForItemAtIndex: Int) -> UIView {
        let cardView = CardView()
        cardView.headerLabel.text = "UICatalog"
        cardView.mainImageView.image = UIImage(named: "AppCard-Main-1")
        
        cardView.headerImageView.image = UIImage(named: "AppCard-Icon-1")
        cardView.headerImageView.layer.cornerRadius = 7.5
        
        return cardView
    }
}

extension AppCardsViewController: CarouselViewDelegate {
    
    func carouselView(carouselView: CarouselView, didUpdateItemView itemView: UIView) {
        let cardView = itemView as! CardView
        let progressX = cardView.frame.origin.x / carouselView.bounds.maxX
        
        // TODO: formalize this into its own interpolation class
        cardView.headerLabel.alpha = {
            if progressX >= 0 && progressX <= 0.1 {
                return (progressX - 0) / (0.1 - 0)
            }
            else if progressX > 0.1 && progressX < 0.6 {
                return 1
            }
            else if progressX >= 0.6 && progressX <= 0.7 {
                return 1 - ((progressX - 0.6) / (0.7 - 0.6))
            }
            else {
                return 0
            }
        }()
    }
}
