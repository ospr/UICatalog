//
//  MasterViewController.swift
//  UIPlayground
//
//  Created by Kip Nicol on 8/7/16.
//  Copyright © 2016 Kip Nicol. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    var catalogItems: [CatalogItem] = [
        .powerOff,
        .appCards,
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        splitViewController?.presentsWithGesture = false

        // TODO: revert this back
        let catalogItem = catalogItems[1]
        updateDetailView(withCatalogItem: catalogItem)
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    // MARK: - Table View

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return catalogItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let catalogItem = catalogItems[indexPath.row]
        cell.textLabel?.text = catalogItem.viewController().title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let catalogItem = catalogItems[indexPath.row]

        updateDetailView(withCatalogItem: catalogItem)
    }
    
    // MARK: - Working with Detail View
    
    func updateDetailView(withCatalogItem catalogItem: CatalogItem) {
        guard let splitViewController = splitViewController else {
            assertionFailure("splitViewController unexpectedly nil.")
            return
        }
        
        let nextViewController = catalogItem.viewController()
        let detailNavigationController = splitViewController.viewControllers.last as! UINavigationController

        if splitViewController.isCollapsed {
            detailNavigationController.pushViewController(nextViewController, animated: true)
        }
        else {
            detailNavigationController.setViewControllers([nextViewController], animated: false)
        }
        
        nextViewController.edgesForExtendedLayout = UIRectEdge()
        nextViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        nextViewController.navigationItem.leftItemsSupplementBackButton = true
    }
}

extension MasterViewController {
    enum CatalogItem {
        case powerOff
        case appCards
        
        func viewController() -> UIViewController {
            switch self {
            case .powerOff:
                return PowerOffViewController()
                
            case .appCards:
                return AppCardsViewController()
            }
        }
    }
}

