//
//  TabsController.swift
//  DriverWelfare
//
//  Created by Anderson Calixto on 02/11/19.
//  Copyright © 2019 Anderson Calixto. All rights reserved.
//

import Foundation
import UIKit

class TabsController : UITabBarController {
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
    }
    
    override class func didChange(_ changeKind: NSKeyValueChange, valuesAt indexes: IndexSet, forKey key: String) {
        print("didChange()")
        print(changeKind)
        print(indexes)
        print(key)
        super.didChange(changeKind, valuesAt: indexes, forKey: key)
    }
    
    override func setViewControllers(_ viewControllers: [UIViewController]?, animated: Bool) {
        print("setViewControllers()")
        super.setViewControllers(viewControllers, animated: animated)
    }
    
    override func targetViewController(forAction action: Selector, sender: Any?) -> UIViewController? {
        print("targetViewController()")
        return super.targetViewController(forAction: action, sender: sender)
    }
}
