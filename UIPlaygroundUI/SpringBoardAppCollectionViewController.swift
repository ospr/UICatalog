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
    func springBoardAppCollectionViewControllerDidUpdateEditMode(_ viewController: SpringBoardAppCollectionViewController)
}

private let reuseIdentifier = "Cell"

struct SpringBoardAppInfo {
    let appName: String
    let image: UIImage
}

class SpringBoardAppCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let appCollectionLayout: SpringBoardAppCollectionLayout
    let appInfoItems: [SpringBoardAppInfo]
    
    var editModeEnabled: Bool = false {
        didSet {
            if editModeEnabled != oldValue {
                // Reload cells to start/stop animations
                collectionView!.reloadData()
            }
        }
    }
    
    weak var delegate: SpringBoardAppCollectionViewControllerDelegate?
    
    fileprivate var appInfoByAppIconButtons = [UIButton : SpringBoardAppInfo]()
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // The cells stop animating sometimes when the view disappears 
        // (eg spring board page view transitions)
        for cell in collectionView!.visibleCells {
            if let cell = cell as? SpringBoardAppIconViewCell {
                updateCellAnimations(cell)
            }
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return appInfoItems.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let appInfo = appInfoItems[indexPath.row]
        
        let appIconCell = collectionView.dequeueReusableCell(withReuseIdentifier: "AppIconCell", for: indexPath) as! SpringBoardAppIconViewCell
        appIconCell.delegate = self
        
        appIconCell.appNameLabel.text = appInfo.appName
        appIconCell.appIconImage = appInfo.image
        appIconCell.appIconLength = appCollectionLayout.iconLength
        
        appIconCell.appIconButtonView.removeTarget(nil, action: nil, for: .allEvents)
        appIconCell.appIconButtonView.addTarget(self, action: #selector(appIconButtonWasTapped), for: .touchUpInside)
        appInfoByAppIconButtons[appIconCell.appIconButtonView] = appInfo
        
        updateCellAnimations(appIconCell)
        
        return appIconCell
    }
    
    // MARK: - Working with Animations
    
    func updateCellAnimations(_ cell: SpringBoardAppIconViewCell) {
        let jitterAnimationKey = "Jitter"
        
        if editModeEnabled {
            if cell.layer.animation(forKey: jitterAnimationKey) == nil {
                let jitterAnimation = CAAnimation.jitterAnimation()
                // Add a offset to the animation time to cause the cells
                // to jitter at different offsets
                jitterAnimation.timeOffset = CACurrentMediaTime() + drand48()
                cell.layer.add(jitterAnimation, forKey: jitterAnimationKey)
            }
        }
        else {
            cell.layer.removeAnimation(forKey: jitterAnimationKey)
        }
        cell.appIconButtonView.isUserInteractionEnabled = !editModeEnabled
    }
    
    // MARK: - Handling touch events
    
    func appIconButtonWasTapped(sender: UIButton) {
        let appInfo = appInfoByAppIconButtons[sender]!
        delegate?.springBoardAppCollectionViewController(self, didSelectAppInfo: appInfo, selectedAppIconButton: sender)
    }
}

extension SpringBoardAppCollectionViewController: SpringBoardAppIconViewCellDelegate {
    
    func springBoardAppIconViewCell(didLongPress springBoardAppIconViewCell: SpringBoardAppIconViewCell) {
        delegate?.springBoardAppCollectionViewControllerDidUpdateEditMode(self)
    }
}
