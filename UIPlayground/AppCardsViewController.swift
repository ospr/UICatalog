//
//  AppCardsViewController.swift
//  UIPlayground
//
//  Created by Kip Nicol on 8/18/16.
//  Copyright © 2016 Kip Nicol. All rights reserved.
//

import UIKit
import UIPlaygroundElements

class AppCardsViewController: UIViewController {

    @IBOutlet weak var carouselView: CarouselView!
    
    var needsCarouselViewReload = true
    
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
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if needsCarouselViewReload {
            carouselView.reloadData()
            needsCarouselViewReload = false
        }
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
        cardView.headerLabel.text = "UIPlayground"
        let cardImage = UIImage(named: "AppCard-Main-1")!
        cardView.mainImageView.image = cardImage
        
        cardView.headerImageView.image = UIImage(named: "AppCard-Icon-1")
        cardView.headerImageView.clipsToBounds = true
        cardView.headerImageView.layer.cornerRadius = 7.5
        
        // Size the cards properly so that the app screenshot image stays
        // proportional to its original size on different screen sizes
        let carouselHeight = carouselView.frame.height
        let cardOriginalWidth = cardImage.size.width
        let cardOriginalHeight = cardImage.size.height
        let cardAuxViewHeight = CGFloat(40) // TODO: don't hardcode here
        
        let relativePadding = CGFloat(0.20)
        let cardProportionalHeight = carouselHeight - (carouselHeight * relativePadding)
        let cardViewProportionalWidth = cardProportionalHeight * (cardOriginalWidth / cardOriginalHeight)
        let cardViewProportionalHeight = cardProportionalHeight + cardAuxViewHeight
        
        cardView.frame.size = CGSize(width: cardViewProportionalWidth, height: cardViewProportionalHeight)
        
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
