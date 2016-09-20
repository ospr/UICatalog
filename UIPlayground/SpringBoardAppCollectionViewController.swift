//
//  SpringBoardAppCollectionViewController.swift
//  UIPlayground
//
//  Created by Kip Nicol on 9/20/16.
//  Copyright © 2016 Kip Nicol. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class SpringBoardAppCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    init() {
        let viewLayout = UICollectionViewFlowLayout()
        // TODO: don't hardcode here
        viewLayout.itemSize = CGSize(width: 60, height: 60)
        viewLayout.sectionInset = UIEdgeInsets(top: 28, left: 27, bottom: 28, right: 27)
        super.init(collectionViewLayout: viewLayout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView!.backgroundColor = .clear
        collectionView!.register(SpringBoardAppIconViewCell.self, forCellWithReuseIdentifier: "AppIconCell")
    }
    
    // MARK: - UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // TODO: return correct values here
        return 15
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // TODO: return correct values here
        let appIconCell = collectionView.dequeueReusableCell(withReuseIdentifier: "AppIconCell", for: indexPath)
        
        return appIconCell
    }
    
    
}
