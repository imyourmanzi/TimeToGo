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
	var flightDate: Date!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Use auto-implemented 'Edit' button on right side of navigation bar
		self.navigationItem.leftBarButtonItem = self.editButtonItem
		
		// Assign the moc CoreData variable by referencing the AppDelegate's
		moc = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
		
    }

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		
		// Fetch the current trip from the persistent store and assign the CoreData variables
		currentTripName = UserDefaults.standard.object(forKey: "currentTripName") as! String
		let fetchRequest = NSFetchRequest<Trip>(entityName: "Trip")
		fetchRequest.predicate = NSPredicate(format: "tripName == %@", currentTripName)
		let trips = (try! moc!.fetch(fetchRequest))
		currentTrip = trips[0]
		self.entries = currentTrip.entries as! [Interval]
		self.flightDate = currentTrip.flightDate as Date!
		
		performUpdateOnCoreData()
		tableView.reloadData()
		
	}
	
	
	// MARK: - Table view data source
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "M/d/yy '@' h:mm a"
		
		return "Flight: \(dateFormatter.string(from: flightDate))"
		
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
	
		return entries.count
		
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = self.tableView.dequeueReusableCell(withIdentifier: "EntryCell", for: indexPath) 
		
		var entry: Interval!
		entry = entries[indexPath.row]
		
		cell.textLabel?.text = entry.mainLabel
		
		if entry.scheduleLabel == nil || entry.scheduleLabel.isEmpty {
		
			cell.detailTextLabel?.text = entry.stringFromTimeValue()
		
		} else {
			cell.detailTextLabel?.text = "\(entry.stringFromTimeValue()) - " + entry.scheduleLabel
		}
		
		return cell
		
	}
	
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		
		if editingStyle == UITableViewCellEditingStyle.delete {
			
			entries.remove(at: indexPath.row)
			
			tableView.deleteRows(at: [indexPath], with: .fade)
			
			performUpdateOnCoreData()
			
		}
        
	}
	
	override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		
		let movedEntry = entries.remove(at: (sourceIndexPath as NSIndexPath).row)
		entries.insert(movedEntry, at: (destinationIndexPath as NSIndexPath).row)
		
		performUpdateOnCoreData()
		
	}
	
	fileprivate func performUpdateOnCoreData() {
		
		currentTrip.entries = self.entries as NSArray
		
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

		// Prepare a selection's view to have all of the information of the current selection's row and associated data
		let indexPath: IndexPath! = tableView.indexPathForSelectedRow
		
		guard let destVC = segue.destination as? SelectedEntryTableViewController else {
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
