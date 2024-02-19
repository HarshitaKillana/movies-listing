//
//  RootTabBarController.swift
//  MoviesListing
//
//  Created by Harshita Killana on 13/02/24.
//

import UIKit



final class RootTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
    }
    
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let viewControllers = tabBarController.viewControllers {
            if let listingVC = viewControllers.last as? ListingViewController {
                listingVC.isFromTabBar = true
            }
        
            }
        }
}
