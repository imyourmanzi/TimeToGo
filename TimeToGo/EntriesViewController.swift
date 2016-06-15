//
//  EntriesViewController.swift
//  TimeToGo
//
//  Created by Matteo Manzi on 7/4/15.
//  Copyright (c) 2015 VMM Software. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class EntriesViewController: UITableViewController {
	
	// CoreData variables
	var moc: NSManagedObjectContext?
	var currentTripName: String!
	var currentTrip: Trip!
	var entries = [Interval]()
	var flightDate: NSDate!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Use auto-implemented 'Edit' button on right side of navigation bar
		self.navigationItem.leftBarButtonItem = self.editButtonItem()
		
		// Assign the moc CoreData variable by referencing the AppDelegate's
		moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
		
    }

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	override func viewWillAppear(animated: Bool) {
		
		// Fetch the current trip from the persistent store and assign the CoreData variables
		currentTripName = NSUserDefaults.standardUserDefaults().objectForKey("currentTripName") as! String
		let fetchRequest = NSFetchRequest(entityName: "Trip")
		fetchRequest.predicate = NSPredicate(format: "tripName == %@", currentTripName)
		let trips = (try! moc!.executeFetchRequest(fetchRequest)) as! [Trip]
		currentTrip = trips[0]
		self.entries = currentTrip.entries as! [Interval]
		self.flightDate = currentTrip.flightDate
		
		performUpdateOnCoreData()
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
		
		let cell = self.tableView.dequeueReusableCellWithIdentifier("EntryCell", forIndexPath: indexPath) 
		
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
		
	
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

		// Prepare a selection's view to have all of the information of the current selection's row and associated data
		let indexPath: NSIndexPath! = tableView.indexPathForSelectedRow
		
		guard let destVC = segue.destinationViewController as? SelectedEntryTableViewController else {
			return
		}
		let selectedEntry = entries[indexPath.row]
		
		destVC.currentTripName = currentTripName
		destVC.mainLabel = selectedEntry.mainLabel
		destVC.schedLabel = selectedEntry.scheduleLabel
		destVC.timeValueHours = selectedEntry.timeValueHours
		destVC.timeValueMins = selectedEntry.timeValueMins
		destVC.intervalTimeStr = selectedEntry.stringFromTimeValue()
		destVC.notes = selectedEntry.notesStr
		if selectedEntry.useLocation == true && selectedEntry.startLocation != nil && selectedEntry.endLocation != nil {
			
			destVC.startLocation = MKMapItem(placemark: selectedEntry.startLocation!)
			destVC.endLocation = MKMapItem(placemark: selectedEntry.endLocation!)
			
		}
		
    }

}
