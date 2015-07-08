//
//  EntriesViewController.swift
//  TravelTimerBasics5
//
//  Created by Matteo Manzi on 6/24/15.
//	Edited by Matteo Manzi on 6/26/15.
//  Copyright (c) 2015 VMM Softwares. All rights reserved.
//

import UIKit
import CoreData

class EntriesViewController: UITableViewController {
	
	var moc: NSManagedObjectContext?
	var currentTripName: String!
	var currentTrip: Trip!
	var entries = [Interval]()

	var flightDate: NSDate!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.navigationItem.leftBarButtonItem = self.editButtonItem()
		
		moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
		
    }

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	override func viewWillAppear(animated: Bool) {
		
		currentTripName = (UIApplication.sharedApplication().delegate as! AppDelegate).currentTripNameMaster
		let fetchRequest = NSFetchRequest(entityName: "Trip")
		fetchRequest.predicate = NSPredicate(format: "tripName == %@", currentTripName)
		var fetchingError: NSError?
		let trips = moc!.executeFetchRequest(fetchRequest, error: &fetchingError) as! [Trip]
		currentTrip = trips[0]
		self.entries = currentTrip.entries as! [Interval]
		self.flightDate = currentTrip.flightDate
		
		tableView.reloadData()
		
	}
	
	
	// MARK: - Table view data source
	
	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "M/d/yy '@' h:mm a"
		
		return "Flight: \(dateFormatter.stringFromDate(flightDate))"
		
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
	
		return entries.count
		
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		let cell = self.tableView.dequeueReusableCellWithIdentifier("EntryCell", forIndexPath: indexPath) as! UITableViewCell
		
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
	
	override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		
		if editingStyle == UITableViewCellEditingStyle.Delete {
			
			entries.removeAtIndex(indexPath.row)
			
			tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
			
			performUpdateOnCoreData()
			
		}
		
	}
	
	override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
		
		let movedEntry = entries.removeAtIndex(sourceIndexPath.row)
		entries.insert(movedEntry, atIndex: destinationIndexPath.row)
		
		performUpdateOnCoreData()
		
	}
	
	private func performUpdateOnCoreData() {
		
		currentTrip.entries = self.entries
		
		var savingError: NSError?
		if moc!.save(&savingError) == false {
			
			if let error = savingError {
				
				println("Failed to save the trip.\nError = \(error)")
				
			}
			
		}
		
	}
		
	
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

		let indexPath: NSIndexPath! = tableView.indexPathForSelectedRow()
		
		if let destVC = segue.destinationViewController as? SelectedEntryTableViewController {
			
			let selectedEntry = entries[indexPath.row]
			
			destVC.currentTripName = currentTripName
			destVC.mainLabel = selectedEntry.mainLabel
			destVC.schedLabel = selectedEntry.scheduleLabel
			destVC.timeValueHours = selectedEntry.timeValueHours
			destVC.timeValueMins = selectedEntry.timeValueMins
			destVC.intervalTimeStr = selectedEntry.stringFromTimeValue()
			
		}
		
    }

}
