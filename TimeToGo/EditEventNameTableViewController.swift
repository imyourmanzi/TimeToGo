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
	var event: Trip!
	
	// Current VC variables
	var eventName: String!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Set up the eventNameTextfield
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
            
//            print(parent?.description ?? "uh oh")
            
            // Alert the user that an entry cannot be saved if it does not have a eventName
            if let parentVC = parent {
                displayAlert(title: "Empty Field!", message: "Changes were not saved because the Event Name field was empty.", on: parentVC, dismissHandler: nil)
            }
			
		} else {
			
			performUpdateOnCoreData()
		
			// Update the currentTripName so that other views will reference the updated eventName
			UserDefaults.standard.set(self.eventName, forKey: "currentTripName")
			
			eventNameTextfield.resignFirstResponder()
			
		}
		
	}
	
}
