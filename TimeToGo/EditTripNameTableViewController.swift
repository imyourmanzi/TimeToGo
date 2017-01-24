//
//  EditTripNameTableViewController.swift
//  TimeToGo
//
//  Created by Matteo Manzi on 7/4/15.
//  Copyright (c) 2015 VMM Software. All rights reserved.
//

import UIKit
import CoreData

class EditTripNameTableViewController: UITableViewController, UITextFieldDelegate {

	// Interface Builder variables
	@IBOutlet var tripNameTextfield: UITextField!

	// CoreData variables
	var moc: NSManagedObjectContext?
	var currentTrip: Trip!
	
	// Current VC variables
	var tripName: String!
	
    override func viewDidLoad() {
        super.viewDidLoad()

		// Assign the moc CoreData variable by referencing the AppDelegate's
		moc = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
		
		// Set up the tripNameTextfield
		tripNameTextfield.delegate = self
		tripNameTextfield.text = tripName
		
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

	@IBAction func tripNameDidChange(_ sender: UITextField) {
		
		// Update the tripName varaible with the contents of the textfield
		tripName = sender.text!.trimmingCharacters(in: CharacterSet.whitespaces)
		
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
	
		// Update the tripName varaible with the contents of the textfield
		tripName = textField.text!.trimmingCharacters(in: CharacterSet.whitespaces)
		
		textField.resignFirstResponder()
		
		return true
		
	}

	
	// MARK: - Navigation
	
	override func viewWillDisappear(_ animated: Bool) {
		
		if tripNameTextfield.text!.isEmpty || tripNameTextfield.text == nil {
			
			// Alert the user that an entry cannot be saved if it does not have a tripLabel
			let alertVC = UIAlertController(title: "Empty Field!", message: "Changes were not saved because the Trip Name field was empty.", preferredStyle: UIAlertControllerStyle.alert)
			let okBtn = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction) in
				alertVC.dismiss(animated: true, completion: nil)
			})
			alertVC.addAction(okBtn)
			parent?.present(alertVC, animated: true, completion: nil)
			
		} else {
			
			currentTrip.tripName = self.tripName
			
			guard let moc = self.moc else {
				return
			}
			
			if moc.hasChanges {
				
				do {
					try moc.save()
				} catch {
					
				}
				
			}
		
			// Update the currentTripName so that other views will reference the updated name
			UserDefaults.standard.set(self.tripName, forKey: "currentTripName")
			
			tripNameTextfield.resignFirstResponder()
			
		}
		
	}
	
}
