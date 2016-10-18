//
//  SpringBoardAppCollectionViewController.swift
//  UIPlayground
//
//  Created by Kip Nicol on 9/20/16.
//  Copyright © 2016 Kip Nicol. All rights reserved.
//

import UIKit

protocol SpringBoardAppCollectionViewControllerDelegate: class {
    
    func springBoardAppCollectionViewController(_ viewController: SpringBoardAppCollectionViewController, didSelectAppInfo appInfo: SpringBoardAppInfo, selectedAppIconButton: UIButton)
}

private let reuseIdentifier = "Cell"

struct SpringBoardAppInfo {
    let appName: String
    let image: UIImage
}

class SpringBoardAppCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let appCollectionLayout: SpringBoardAppCollectionLayout
    let appInfoItems: [SpringBoardAppInfo]
    
    weak var delegate: SpringBoardAppCollectionViewControllerDelegate?
    
    private var appInfoByAppIconButtons = [UIButton : SpringBoardAppInfo]()
    
    init(appInfoItems: [SpringBoardAppInfo], appCollectionLayout: SpringBoardAppCollectionLayout) {
        self.appCollectionLayout = appCollectionLayout
        self.appInfoItems = appInfoItems
        
        let viewLayout = UICollectionViewFlowLayout()
        viewLayout.minimumInteritemSpacing = appCollectionLayout.minimumInteritemSpacing
        viewLayout.minimumLineSpacing = appCollectionLayout.minimumLineSpacing
        viewLayout.itemSize = appCollectionLayout.itemSize
        viewLayout.sectionInset = appCollectionLayout.sectionInset
        
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
        return appInfoItems.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let appInfo = appInfoItems[indexPath.row]
        
        let appIconCell = collectionView.dequeueReusableCell(withReuseIdentifier: "AppIconCell", for: indexPath) as! SpringBoardAppIconViewCell
        
        appIconCell.appNameLabel.text = appInfo.appName
        appIconCell.appIconImage = appInfo.image
        appIconCell.appIconLength = appCollectionLayout.iconLength
        
        appIconCell.appIconButtonView.removeTarget(nil, action: nil, for: .allEvents)
        appIconCell.appIconButtonView.addTarget(self, action: #selector(appIconButtonWasTapped), for: .touchUpInside)
        appInfoByAppIconButtons[appIconCell.appIconButtonView] = appInfo
        
        return appIconCell
    }
    
    // MARK: - Handling touch events
    
    func appIconButtonWasTapped(sender: UIButton) {
        let appInfo = appInfoByAppIconButtons[sender]!
        delegate?.springBoardAppCollectionViewController(self, didSelectAppInfo: appInfo, selectedAppIconButton: sender)
    }
}
