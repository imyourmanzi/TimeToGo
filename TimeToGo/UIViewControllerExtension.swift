//
//  UIViewControllerExtension.swift
//  TimeToGo
//
//  Created by Matt Manzi on 1/30/17.
//  Copyright © 2017 MRM Software. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func displayDataErrorAlert(on vc: UIViewController, dismissHandler: ((UIAlertAction) -> Void)?) {
        
        displayAlert(title: "Error Retrieving Data", message: "There was an error retrieving saved data.", on: vc, dismissHandler: dismissHandler)
        
    }
    
    func displayNoEventsAlert(on vc: UIViewController, dismissHandler: ((UIAlertAction) -> Void)?) {
        
        displayAlert(title: "No Events Found", message: "You can create new events on the Home tab.", on: vc, dismissHandler: dismissHandler)
        
    }
    
    func displayGoToSettingsCalendarAlert(on vc: UIViewController) {
        
        let alertController = UIAlertController(title: "Not Allowed", message: "Access to Calendars was denied, press Allow to go to Settings now.\n(Settings > It's Time To Go > Turn on Calendars)", preferredStyle: .alert)
        let allowAction = UIAlertAction(title: "Allow", style: .default) {
            (_) in
            
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
            
        }
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        
        alertController.addAction(allowAction)
        alertController.addAction(dismissAction)
        
        vc.present(alertController, animated: true, completion: nil)
        
    }
    
    func displayAlert(title: String?, message: String?, on vc: UIViewController, dismissHandler: ((UIAlertAction) -> Void)?) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .default, handler: dismissHandler)
        
        alertController.addAction(dismissAction)
        
        vc.present(alertController, animated: true, completion: nil)
        
    }
    
}
