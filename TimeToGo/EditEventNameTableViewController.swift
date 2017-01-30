//
//  EditEventNameTableViewController.swift
//  TimeToGo
//
//  Created by Matteo Manzi on 7/4/15.
//  Copyright (c) 2015 VMM Software. All rights reserved.
//

import UIKit
import CoreData

class EditEventNameTableViewController: UITableViewController, UITextFieldDelegate, CoreDataHelper {

	// Interface Builder variables
	@IBOutlet var eventNameTextfield: UITextField!

	// CoreData variables
//	var moc: NSManagedObjectContext?
	var event: Trip!
	
	// Current VC variables
	var eventName: String!
	
    override func viewDidLoad() {
        super.viewDidLoad()

		// Assign the moc CoreData variable by referencing the AppDelegate's
//		moc = getContext()
		
		// Set up the eventNameTextfield
//		tripNameTextfield.delegate = self
		eventNameTextfield.text = eventName
		
	}

	@IBAction func eventNameDidChange(_ sender: UITextField) {
		
		// Update the eventName varaible with the contents of the textfield
		eventName = sender.text!.trimmingCharacters(in: CharacterSet.whitespaces)
		
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
	
		// Update the eventName varaible with the contents of the textfield
		eventName = textField.text!.trimmingCharacters(in: CharacterSet.whitespaces)
		
		textField.resignFirstResponder()
		
		return true
		
	}

	
    // MARK: - Core Data helper
    
    func prepareForUpdateOnCoreData() {
        
        event.tripName = self.eventName
        
    }
    
    
	// MARK: - Navigation
	
	override func viewWillDisappear(_ animated: Bool) {
		
		if eventNameTextfield.text!.isEmpty || eventNameTextfield.text == nil {
			
			// Alert the user that an entry cannot be saved if it does not have a eventName
			let alertVC = UIAlertController(title: "Empty Field!", message: "Changes were not saved because the Event Name field was empty.", preferredStyle: UIAlertControllerStyle.alert)
			let okBtn = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction) in
				alertVC.dismiss(animated: true, completion: nil)
			})
			alertVC.addAction(okBtn)
			parent?.present(alertVC, animated: true, completion: nil)
			
		} else {
			
			performUpdateOnCoreData()
			
//			guard let moc = self.moc else {
//				return
//			}
//			
//			if moc.hasChanges {
//				
//				do {
//					try moc.save()
//				} catch {
//					
//				}
//				
//			}
		
			// Update the currentTripName so that other views will reference the updated name
			UserDefaults.standard.set(self.eventName, forKey: "currentTripName")
			
			eventNameTextfield.resignFirstResponder()
			
		}
		
	}
	
}
