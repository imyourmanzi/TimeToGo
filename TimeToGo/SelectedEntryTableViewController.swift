//
//  SelectedEntryTableViewController.swift
//  TravelTimerBasics7
//
//  Created by Matteo Manzi on 6/25/15.
//	Edited by Matteo Manzi on 6/26/15.
//  Copyright (c) 2015 VMM Softwares. All rights reserved.
//

// close keyboard when picker wheel opens
// change hours and minutes label on picker wheel

import UIKit
import CoreData

class SelectedEntryTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {

	@IBOutlet var mainLabelTextfield: UITextField!
	@IBOutlet var schedLabelTextfield: UITextField!
	@IBOutlet var intervalLabelCell: UITableViewCell!
	@IBOutlet var intervalTimePicker: UIPickerView!
	
	var moc: NSManagedObjectContext?
	var currentTripName: String!
	var currentTrip: Trip!
	var entries = [Interval]()
	
	var parentVC: EntriesViewController!
	var indexPath: NSIndexPath!
	var currentEntry: Interval!
	
	var mainLabel: String!
	var schedLabel: String!
	var timeValueHours: Int!
	var timeValueMins: Int!
	var intervalTimeStr: String!
	
	var pickerHidden = true
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
		let fetchRequest = NSFetchRequest(entityName: "Trip")
		fetchRequest.predicate = NSPredicate(format: "tripName == %@", currentTripName)
		var fetchingError: NSError?
		let trips = moc!.executeFetchRequest(fetchRequest, error: &fetchingError) as! [Trip]
		currentTrip = trips[0]
		self.entries = currentTrip.entries as! [Interval]
		
		parentVC = self.navigationController?.viewControllers[0] as! EntriesViewController
		indexPath = parentVC.tableView.indexPathForSelectedRow()
		currentEntry = self.entries[indexPath.row]
		
		mainLabelTextfield.delegate = self
		mainLabelTextfield.text = mainLabel
		
		schedLabelTextfield.delegate = self
		schedLabelTextfield.text = schedLabel
		
		intervalLabelCell.detailTextLabel?.text = intervalTimeStr
		
		intervalTimePicker.dataSource = self
		intervalTimePicker.delegate = self
		
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	
	// MARK: - Text field delegate and action
	
	@IBAction func mainLabelDidChange(sender: UITextField) {
		
		mainLabel = sender.text
		
	}
	
	@IBAction func schedLabelDidChange(sender: UITextField) {
		
		schedLabel = sender.text
		
	}
	
	func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
		
		if pickerHidden == false {
			
			togglePicker()
			
		}
		
		return true
		
	}
	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		
		textField.resignFirstResponder()
		
		if textField == mainLabelTextfield {
			
			mainLabel = textField.text
			
		} else if textField == schedLabelTextfield {
			
			schedLabel = textField.text
			
		}
		
		return true
		
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
				
				return 44.0
				
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
			currentEntry.timeValueHours = row
			
		}
		
		if component == 2 {
			
			timeValueMins = row
			currentEntry.timeValueMins = row
			
		}
		
		intervalLabelCell.detailTextLabel?.text = currentEntry.stringFromTimeValue()
		intervalTimeStr = currentEntry.stringFromTimeValue()
		
	}
	
	func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
		
		if component == 1 {
			
			return 15.0
			
		} else if component == 0 {
			
			return ((view.frame.width - 15) / 2.5)
			
		} else {
			
			return (view.frame.width - ((view.frame.width - 15) / 2.5) - 10)
			
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
		
		currentEntry.mainLabel = self.mainLabel
		currentEntry.scheduleLabel = self.schedLabel
		currentEntry.timeValueHours = self.timeValueHours
		currentEntry.timeValueMins = self.timeValueMins
		currentEntry.timeValueStr = self.intervalTimeStr
		
		self.entries[indexPath.row] = currentEntry
		currentTrip.entries = self.entries
		
		var savingError: NSError?
		if moc!.save(&savingError) == false {
			
			if let error = savingError {
				
				println("Failed to save the trip.\nError = \(error)")
				
			}
			
		}

		
		mainLabelTextfield.resignFirstResponder()
		schedLabelTextfield.resignFirstResponder()
		
	}
	
}
