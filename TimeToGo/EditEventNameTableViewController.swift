//
//  EditEventNameTableViewController.swift
//  TimeToGo
//
//  Created by Matt Manzi on 7/4/15.
//  Copyright (c) 2017 MRM Software. All rights reserved.
//

import UIKit
import CoreData

class EditEventNameTableViewController: UITableViewController, UITextFieldDelegate, CoreDataHelper {

	// Interface Builder variables
	@IBOutlet var eventNameTextfield: UITextField!

	// CoreData variables
	var event: Trip!
	
	// Current VC variables
	var eventName: String = UIConstants.NOT_FOUND
    
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
    
    func prepareForUpdate() {
        
        event.tripName = self.eventName
        
    }
    
    
	// MARK: - Navigation
	
	override func viewWillDisappear(_ animated: Bool) {
		
		if eventNameTextfield.text!.isEmpty || eventNameTextfield.text == nil {
            
            // Alert the user that an entry cannot be saved if it does not have a eventName
            if let parentVC = parent {
                displayAlert(title: "Empty Field!", message: "Changes were not saved because the Event Name field was empty.", on: parentVC, dismissHandler: nil)
            }
			
		} else {
			
            // Update the currentTripName so that other views will reference the updated eventName
            CoreDataConnector.setCurrentEventName(to: eventName)
            CoreDataConnector.updateStore(from: self)
			
			eventNameTextfield.resignFirstResponder()
			
		}
		
	}
	
}
