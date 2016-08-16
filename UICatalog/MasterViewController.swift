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
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: clean this up here
        let catalogItem = catalogItems[0]
        let nextViewController = catalogItem.viewController()
        let vc = splitViewController?.viewControllers[1] as! UINavigationController
        vc.setViewControllers([nextViewController], animated: true)
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
        // TODO: really inefficient way of doing this
        cell.textLabel?.text = catalogItem.viewController().title
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let catalogItem = catalogItems[indexPath.row]
        let nextViewController = catalogItem.viewController()

        // TODO: clean this up here
        let vc = splitViewController?.viewControllers[1] as! UINavigationController
        vc.setViewControllers([nextViewController], animated: true)
    }
}

extension MasterViewController {
    enum CatalogItem {
        case PowerOff
        
        func viewController() -> UIViewController {
            switch self {
            case .PowerOff:
                return PowerOffViewController()
            }
        }
    }
}

