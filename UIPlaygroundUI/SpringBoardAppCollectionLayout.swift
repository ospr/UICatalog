//
//  SpringBoardAppCollectionLayout.swift
//  UIPlayground
//
//  Created by Kip Nicol on 10/14/16.
//  Copyright © 2016 Kip Nicol. All rights reserved.
//

import UIKit

struct SpringBoardAppCollectionLayout {
    let iconLength: CGFloat
    let itemSize: CGSize
    let sectionInset: UIEdgeInsets
    let minimumInteritemSpacing: CGFloat
    let minimumLineSpacing: CGFloat
    let pageControlOfffset: CGFloat
}

extension SpringBoardAppCollectionLayout {
    
    init(screen: UIScreen) {
        let screenSize = screen.bounds.size
        
        switch screenSize.width {
        case 320:
            self.init(iconLength: 60,
                      itemSize: CGSize(width: 74, height: 78),
                      sectionInset: UIEdgeInsets(top: 27, left: 10, bottom: 0, right: 10),
                      minimumInteritemSpacing: 0,
                      minimumLineSpacing: 7,
                      pageControlOfffset: -11)
            
        case 375:
            self.init(iconLength: 60,
                      itemSize: CGSize(width: 74, height: 80),
                      sectionInset: UIEdgeInsets(top: 28, left: 20, bottom: 0, right: 20),
                      minimumInteritemSpacing: 0,
                      minimumLineSpacing: 9,
                      pageControlOfffset: 0)
            
        case 414:
            self.init(iconLength: 60,
                      itemSize: CGSize(width: 74, height: 80),
                      sectionInset: UIEdgeInsets(top: 38, left: 28, bottom: 0, right: 28),
                      minimumInteritemSpacing: 20,
                      minimumLineSpacing: 24,
                      pageControlOfffset: 0)
            
        case 768:
            self.init(iconLength: 76,
                      itemSize: CGSize(width: 79, height: 99),
                      sectionInset: UIEdgeInsets(top: 88, left: 80, bottom: 0, right: 80),
                      minimumInteritemSpacing: 97,
                      minimumLineSpacing: 62,
                      pageControlOfffset: 0)
            
        default:
            assertionFailure("Unsupported screen size")
            self.init(iconLength: 60,
                      itemSize: CGSize(width: 74, height: 80),
                      sectionInset: UIEdgeInsets(top: 28, left: 20, bottom: 0, right: 20),
                      minimumInteritemSpacing: 0,
                      minimumLineSpacing: 9,
                      pageControlOfffset: 0)
        }
    }
}
