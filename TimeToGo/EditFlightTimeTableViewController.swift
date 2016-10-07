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
	var flightDate = Date()
	let dateFormatter = DateFormatter()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Assign the moc CoreData variable by referencing the AppDelegate's
		moc = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
		
		// Define the date format and apply it to the flight time display
		dateFormatter.dateFormat = "M/d/yy '@' h:mm a"
		flightDateCell.detailTextLabel?.text = dateFormatter.string(from: flightDate)
		
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
	
	@IBAction func flightDateChanged(_ sender: UIDatePicker) {
		
		// Update the flight time and its display
		flightDate = sender.date
		flightDateCell.detailTextLabel?.text = dateFormatter.string(from: flightDatePicker.date)
		
	}
	
	
    // MARK: - Table view data source

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if pickerHidden {
			
			return 1
			
		} else {
			
			return 2
			
		}
		
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		if (indexPath as NSIndexPath).row == 0 {
			
			togglePicker()
			
		}
		
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		
		if pickerHidden {
			
			return tableView.rowHeight
			
		} else {
			
			if (indexPath as NSIndexPath).row == 1 {
				
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
			self.tableView.insertRows(at: [IndexPath(row: 1, section: 0)], with: UITableViewRowAnimation.fade)
			tableView.isScrollEnabled = false
			
		} else {
			
			self.tableView.deleteRows(at: [IndexPath(row: 1, section: 0)], with: UITableViewRowAnimation.fade)
			tableView.isScrollEnabled = true
			
		}
		
		pickerHidden = !pickerHidden
		
		self.tableView.endUpdates()
		
		self.tableView.deselectRow(at: IndexPath(row: 0, section: 0), animated: true)
		
	}
	
	
	// MARK: - Navigation
	
	override func viewWillDisappear(_ animated: Bool) {
		
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
