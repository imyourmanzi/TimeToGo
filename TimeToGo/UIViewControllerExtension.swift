//
//  UIViewControllerExtension.swift
//  TimeToGo
//
//  Created by Matt Manzi on 1/30/17.
//  Copyright © 2017 MRM Software. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func displayAlert(title: String?, message: String?, on vc: UIViewController, dismissHandler: ((UIAlertAction) -> Void)?) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .default, handler: dismissHandler)
        
        alertController.addAction(dismissAction)
        
        vc.present(alertController, animated: true, completion: nil)
        
    }
    
    func disableTabBarIfNeeded(events: [Trip], sender: UIViewController) {
        
        if events.count <= 0 {
            
            if sender is HomeViewController {
                setTabBar(enabled: false)
            } else {
                
                guard let destVC = storyboard?.instantiateViewController(withIdentifier: "mainTabVC") else {
                    return
                }
                
                destVC.modalTransitionStyle = .crossDissolve
                present(destVC, animated: true, completion: nil)
                
            }
            
        } else {
            setTabBar(enabled: true)
        }
        
    }
    
    fileprivate func setTabBar(enabled: Bool) {
        
        guard let tabs = tabBarController?.tabBar.items else {
            return
        }
        
        for tab in tabs {
            
            if tab.title != "Home" {
                tab.isEnabled = enabled
            }
            
        }
        
    }
    
}
