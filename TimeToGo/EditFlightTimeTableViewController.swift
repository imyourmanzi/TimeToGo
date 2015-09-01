//
//  EditFlightTimeTableViewController.swift
//  TimeToGo
//
//  Created by Matteo Manzi on 7/4/15.
//  Copyright (c) 2015 VMM Software. All rights reserved.
//

import UIKit
import CoreData

class EditFlightTimeTableViewController: UITableViewController {
	
	// Interface Builder variables
	@IBOutlet var flightDatePicker: UIDatePicker!
	@IBOutlet var flightDateCell: UITableViewCell!

	// CoreData variables
	var moc: NSManagedObjectContext?
	var currentTripName: String!
	var currentTrip: Trip!
	
	// Current VC variables
	var pickerHidden = true
	var flightDate = NSDate()
	let dateFormatter = NSDateFormatter()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Assign the moc CoreData variable by referencing the AppDelegate's
		moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
		
		// Define the date format and apply it to the flight time display
		dateFormatter.dateFormat = "M/d/yy '@' h:mm a"
		flightDateCell.detailTextLabel?.text = dateFormatter.stringFromDate(flightDate)
		
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
	
	@IBAction func flightDateChanged(sender: UIDatePicker) {
		
		// Update the flight time and its display
		flightDate = sender.date
		flightDateCell.detailTextLabel?.text = dateFormatter.stringFromDate(flightDatePicker.date)
		
	}
	
	
    // MARK: - Table view data source

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if pickerHidden {
			
			return 1
			
		} else {
			
			return 2
			
		}
		
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		
		if indexPath.row == 0 {
			
			togglePicker()
			
		}
		
	}
	
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		
		if pickerHidden {
			
			return tableView.rowHeight
			
		} else {
			
			if indexPath.row == 1 {
				
				return flightDatePicker.frame.height
				
			} else {
				
				return tableView.rowHeight
				
			}
			
		}
		
	}
	
	
	// MARK: - Date picker show/hide
	
	func togglePicker() {
		
		self.tableView.beginUpdates()
		
		if pickerHidden {
			
			flightDatePicker.setDate(flightDate, animated: true)
			self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
			tableView.scrollEnabled = false
			
		} else {
			
			self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
			tableView.scrollEnabled = true
			
		}
		
		pickerHidden = !pickerHidden
		
		self.tableView.endUpdates()
		
		self.tableView.deselectRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), animated: true)
		
	}
	
	
	// MARK: - Navigation
	
	override func viewWillDisappear(animated: Bool) {
		
		currentTrip.flightDate = self.flightDate
		
		guard let moc = self.moc else {
			return
		}
		
		if moc.hasChanges {
			
			do {
				try moc.save()
			} catch {
				
			}
			
		}

	}

}
