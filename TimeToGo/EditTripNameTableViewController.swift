//
//  EditTripNameTableViewController.swift
//  TravelTimerBasics10
//
//  Created by Matteo Manzi on 7/1/15.
//  Copyright (c) 2015 VMM Softwares. All rights reserved.
//

import UIKit
import CoreData

class EditTripNameTableViewController: UITableViewController, UITextFieldDelegate {

	// Interface Builder variables
	@IBOutlet var tripNameTextfield: UITextField!

	// CoreData variables
	var moc: NSManagedObjectContext?
	var currentTripName: String!
	var currentTrip: Trip!
	
	// Current VC variables
	var tripName: String!
	
    override func viewDidLoad() {
        super.viewDidLoad()

		// Assign the moc CoreData variable by referencing the AppDelegate's
		moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
		
		// Set up the tripNameTextfield
		tripNameTextfield.delegate = self
		tripNameTextfield.text = tripName
		
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

	@IBAction func tripNameDidChange(sender: UITextField) {
		
		// Update the tripName varaible with the contents of the textfield
		tripName = sender.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
		
	}
	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
	
		// Update the tripName varaible with the contents of the textfield
		tripName = textField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
		
		textField.resignFirstResponder()
		
		return true
		
	}

	
	// MARK: - Navigation
	
	override func viewWillDisappear(animated: Bool) {
		
		currentTrip.tripName = self.tripName
		
		var savingError: NSError?
		if moc!.save(&savingError) == false {
			
			if let error = savingError {
				
				println("Failed to save the trip.\nError = \(error)")
				
			}
			
		}
	
		// Update the currentTripNameMaster in the AppDelegate so that other views will reference the updated name
		(UIApplication.sharedApplication().delegate as! AppDelegate).currentTripNameMaster = self.tripName
		
		tripNameTextfield.resignFirstResponder()
		
	}
	
}
