//
//  SavedTripViewController.swift
//  TimeToGo
//
//  Created by Matteo Manzi on 7/4/15.
//  Copyright (c) 2015 VMM Software. All rights reserved.
//

import UIKit

class SavedTripViewController: UIViewController, UITableViewDataSource {
	
	// Interface Builder variables
	@IBOutlet var tableView: UITableView!
	@IBOutlet var flightDateLabel: UILabel!
	
	// CoreData variables
	var tripName: String!
	var flightDate: NSDate!
	
	// Current VC variables
	var entries: [Interval]!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		// Set up the dateFormatter
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "M/d/yy '@' h:mm a"
		
		
		// Set the Interface Builder variables
		flightDateLabel.text = "Flight Date and Time:\n\(dateFormatter.stringFromDate(flightDate))"

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
	
	
	// MARK: - Table view data source
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return entries.count
		
	}
	
	
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		
		return "Entries"
		
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCellWithIdentifier("entryCell", forIndexPath: indexPath)
		
		var entry: Interval!
		entry = entries[indexPath.row]
		
		cell.textLabel?.text = entry.mainLabel
		
		if entry.scheduleLabel == nil || entry.scheduleLabel.isEmpty {
			
			cell.detailTextLabel?.text = entry.stringFromTimeValue()
			
		} else {
			
			cell.detailTextLabel?.text = "\(entry.stringFromTimeValue()) - \(entry.scheduleLabel)"
			
		}
		
		return cell
		
	}
	
	@IBAction func loadTrip(sender: UIBarButtonItem) {
		
		// Update currentTripNameMaster in the AppDelegate to the chosen tripName
		(UIApplication.sharedApplication().delegate as! AppDelegate).currentTripNameMaster = self.tripName
		
		// Transition to the Scheudle VC
		let mainTabVC = self.storyboard?.instantiateViewControllerWithIdentifier("mainTabVC") as! UITabBarController
		mainTabVC.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
		self.presentViewController(mainTabVC, animated: true, completion: nil)
		
	}
	
}
