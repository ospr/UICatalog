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
    
    var appInfoItems = [SpringBoardAppInfo]()
    
    weak var delegate: SpringBoardAppCollectionViewControllerDelegate?
    
    private var appInfoByAppIconButtons = [UIButton : SpringBoardAppInfo]()
    
    init() {
        let viewLayout = UICollectionViewFlowLayout()
        // TODO: don't hardcode here
        viewLayout.itemSize = CGSize(width: 74, height: 80)
        viewLayout.sectionInset = UIEdgeInsets(top: 28, left: 20, bottom: 28, right: 20)
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
        appIconCell.appIconButtonView.setImage(appInfo.image, for: .normal)
        appIconCell.appIconButtonView.contentMode = .scaleAspectFill
        appIconCell.appIconButtonView.contentHorizontalAlignment = .fill
        appIconCell.appIconButtonView.contentVerticalAlignment = .fill
        
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
