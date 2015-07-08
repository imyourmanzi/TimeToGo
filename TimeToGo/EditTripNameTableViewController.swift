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

	@IBOutlet var tripNameTextfield: UITextField!

	var moc: NSManagedObjectContext?
	var currentTripName: String!
	var currentTrip: Trip!
	
	var tripName: String!
	
    override func viewDidLoad() {
        super.viewDidLoad()

		moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
		
		tripNameTextfield.delegate = self
		tripNameTextfield.text = tripName
		
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	@IBAction func tripNameDidChange(sender: UITextField) {
		
		tripName = sender.text
		
	}
	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
	
		tripName = textField.text
		
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
	
		(UIApplication.sharedApplication().delegate as! AppDelegate).currentTripNameMaster = self.tripName
		
		tripNameTextfield.resignFirstResponder()
		
	}
	
}
