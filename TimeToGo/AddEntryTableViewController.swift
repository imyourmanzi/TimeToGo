//
//  AddEntryTableViewController.swift
//  TravelTimerBasics8
//
//  Created by Matteo Manzi on 6/26/15.
//  Copyright (c) 2015 VMM Softwares. All rights reserved.
//

// close keyboard when picker wheel opens
// change hours and minutes label on picker wheel

import UIKit
import CoreData

class AddEntryTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
	
	// Interface Builder outlets
	@IBOutlet var mainLabelTextfield: UITextField!
	@IBOutlet var schedLabelTextfield: UITextField!
	@IBOutlet var intervalLabelCell: UITableViewCell!
	@IBOutlet var intervalTimePicker: UIPickerView!
	
	// CoreData variables
	var moc: NSManagedObjectContext?
	var currentTripName: String!
	var currentTrip: Trip!
	var entries = [Interval]()
	
	// Current VC variables
	var mainLabel: String!
	var schedLabel: String!
	var timeValueHours: Int = 0
	var timeValueMins: Int = 15
	var intervalTimeStr: String!
	var pickerHidden = true
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Fetch the current trip from the persistent store and assign the CoreData variables
		moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
		currentTripName = (UIApplication.sharedApplication().delegate as! AppDelegate).currentTripNameMaster
		let fetchRequest = NSFetchRequest(entityName: "Trip")
		fetchRequest.predicate = NSPredicate(format: "tripName == %@", currentTripName)
		var fetchingError: NSError?
		let trips = moc!.executeFetchRequest(fetchRequest, error: &fetchingError) as! [Trip]
		currentTrip = trips[0]
		self.entries = currentTrip.entries as! [Interval]
		
		// Customized setup of the Interface Builder variables
		mainLabelTextfield.delegate = self
		mainLabelTextfield.text = mainLabel
		
		schedLabelTextfield.delegate = self
		schedLabelTextfield.text = schedLabel
		
		intervalTimeStr = Interval.stringFromTimeValue(timeValueHours, timeValueMins: timeValueMins)
		intervalLabelCell.detailTextLabel?.text = intervalTimeStr
		
		intervalTimePicker.dataSource = self
		intervalTimePicker.delegate = self
		
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	override func viewDidAppear(animated: Bool) {
		
		// Show the keyboard for the mainLabelTextfield when the view has appeared
		mainLabelTextfield.becomeFirstResponder()
		
	}
	
	@IBAction func saveEntry(sender: UIBarButtonItem) {
		
		if mainLabelTextfield.text.isEmpty {
			
			// Alert the user that an entry cannot be saved if it does not have a mainLabel
			let alertVC = UIAlertController(title: "Empty Field!", message: "Cannot leave Main Label empty", preferredStyle: UIAlertControllerStyle.Alert)
			let okBtn = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(alert: UIAlertAction!) in
				alertVC.dismissViewControllerAnimated(true, completion: nil)
			})
			alertVC.addAction(okBtn)
			presentViewController(alertVC, animated: true, completion: nil)
		
		} else {
			
			// Fill in any empty values, save to the persistent store, and close the view controller
			if !mainLabelTextfield.text.isEmpty && (schedLabelTextfield.text.isEmpty || schedLabelTextfield.text == nil) {
			
				schedLabel = mainLabel
				
				entries.append(Interval(mainLabel: mainLabel, scheduleLabel: schedLabel, timeValueHours: timeValueHours, timeValueMins: timeValueMins))
				
			} else {
				
				entries.append(Interval(mainLabel: mainLabel, scheduleLabel: schedLabel, timeValueHours: timeValueHours, timeValueMins: timeValueMins))
					
			}
			
			performUpdateOnCoreData()
			dismissViewControllerAnimated(true, completion: nil)
			
		}
		
	}
	
	@IBAction func cancelEntry(sender: UIBarButtonItem) {
		
		// Close the view controller without committing any changes to the persistent store
		dismissViewControllerAnimated(true, completion: nil)
		
	}
	
	
	// MARK: - Text field delegate and action
	
	@IBAction func mainLabelDidChange(sender: UITextField) {

		// Set the mainLabel with it's textfield
		mainLabel = sender.text
		
	}
	
	@IBAction func schedLabelDidChange(sender: UITextField) {
		
		// Set the schedLabel with it's textfield
		schedLabel = sender.text
		
	}
	
	func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
		
		// Hide the flightDatePicker if beginning to edit the textfield
		if pickerHidden == false {
			
			togglePicker()
			
		}
		
		return true
		
	}
	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		
		textField.resignFirstResponder()
		
		if textField == mainLabelTextfield {
			
			// Set the mainLabel with it's textfield
			mainLabel = textField.text
			
		} else if textField == schedLabelTextfield {
			
			// Set the schedLabel with it's textfield
			schedLabel = textField.text
			
		}
		
		return true
		
	}
	
	// Update the new entry in the currentTrip
	private func performUpdateOnCoreData() {
		
		currentTrip.entries = self.entries
		
		var savingError: NSError?
		if moc!.save(&savingError) == false {
			
			if let error = savingError {
				
				println("Failed to save the trip.\nError = \(error)")
				
			}
			
		}
		
	}
	
	// MARK: - Table view data source
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if pickerHidden {
			
			return 3
			
		} else {
			
			return 4
			
		}
		
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		
		if indexPath.row == 2 {
			
			togglePicker()
			
		}
		
	}
	
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		
		if pickerHidden {
			
			return tableView.rowHeight
			
		} else {
			
			if indexPath.row == 3 {
				
				return intervalTimePicker.frame.height
				
			} else {
				
				return tableView.rowHeight
				
			}
			
		}
		
	}
	
	
	// MARK: - Picker view data source and delegate
	
	func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
		
		return 3
		
	}
	
	func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		
		if component == 0 {
			
			return 24
			
		} else if component == 1 {
			
			return 1
			
		} else {
			
			return 60
			
		}
		
	}
	
	func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
		
		if component == 0 {
			
			if row == 1 {
				
				return "\(row) hour"
				
			} else {
				
				return "\(row) hours"
				
			}
			
		} else if component == 1 {
			
			return ":"
			
		} else {
			
			if row == 1 {
				
				return "\(row) min"
				
			} else {
				
				return "\(row) mins"
				
			}
			
		}
		
	}
	
	func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		
		if component == 0 {
			
			timeValueHours = row
			
		}
		
		if component == 2 {
			
			timeValueMins = row
			
		}
		
		intervalLabelCell.detailTextLabel?.text = Interval.stringFromTimeValue(timeValueHours, timeValueMins: timeValueMins)
		
	}
	
	func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
		
		if component == 1 {
			
			return 15.0
			
		} else if component == 0 {
			
			return ((view.frame.width - 15) / 2.5)
			
		} else {
			
			return (view.frame.width - ((view.frame.width - 15) / 2.5))
			
		}
		
	}
	
	
	// MARK: - Picker view show/hide
	
	func togglePicker() {
		
		self.tableView.beginUpdates()
		
		if pickerHidden {
			
			intervalTimePicker.selectRow(timeValueHours, inComponent: 0, animated: false)
			intervalTimePicker.selectRow(timeValueMins, inComponent: 2, animated: false)
			self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 3, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
			mainLabelTextfield.resignFirstResponder()
			schedLabelTextfield.resignFirstResponder()
			tableView.scrollEnabled = false
			
		} else {
			
			self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: 3, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
			tableView.scrollEnabled = true
			
		}
		
		pickerHidden = !pickerHidden
		
		self.tableView.endUpdates()
		
		self.tableView.deselectRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0), animated: true)
		
	}
	
	
	// MARK: - Navigation
	
	override func viewWillDisappear(animated: Bool) {
		
		// Make sure that the keyboards are all away
		mainLabelTextfield.resignFirstResponder()
		schedLabelTextfield.resignFirstResponder()
		
	}

}
