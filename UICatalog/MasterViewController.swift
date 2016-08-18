//
//  MasterViewController.swift
//  UICatalog
//
//  Created by Kip Nicol on 8/7/16.
//  Copyright © 2016 Kip Nicol. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    var catalogItems: [CatalogItem] = [
        .PowerOff,
        .AppCards,
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: revert this back
        let catalogItem = catalogItems[1]
        updateDetailView(withCatalogItem: catalogItem)
    }

    override func viewWillAppear(animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.collapsed
        super.viewWillAppear(animated)
    }

    // MARK: - Table View

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return catalogItems.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        let catalogItem = catalogItems[indexPath.row]
        cell.textLabel?.text = catalogItem.viewController().title
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
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

        // TODO: this isn't ideal. Is there a more generic way of doing this?
        if splitViewController.collapsed {
            detailNavigationController.pushViewController(nextViewController, animated: true)
        }
        else {
            detailNavigationController.setViewControllers([nextViewController], animated: false)
        }
        
        nextViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem()
        nextViewController.navigationItem.leftItemsSupplementBackButton = true
    }
}

extension MasterViewController {
    enum CatalogItem {
        case PowerOff
        case AppCards
        
        func viewController() -> UIViewController {
            switch self {
            case .PowerOff:
                return PowerOffViewController()
                
            case .AppCards:
                return AppCardsViewController()
            }
        }
    }
}

