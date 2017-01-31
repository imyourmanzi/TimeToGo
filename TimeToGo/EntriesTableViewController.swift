//
//  EntriesTableViewController.swift
//  TimeToGo
//
//  Created by Matteo Manzi on 7/4/15.
//  Copyright (c) 2015 VMM Software. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class EntriesTableViewController: UITableViewController, CoreDataHelper {
	
	// CoreData variables
//	var moc: NSManagedObjectContext?
//	var eventName: String!
	var event: Trip!
    var entries: [Interval] = []
	var eventDate: Date!
	
    // Current VC variables
    var selectedEntryIndexPath = IndexPath()
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Use auto-implemented 'Edit' button on right side of navigation bar
		self.navigationItem.leftBarButtonItem = self.editButtonItem
		
		// Assign the moc CoreData variable by referencing the AppDelegate's
//		moc = getContext()
		
    }

	override func viewWillAppear(_ animated: Bool) {
		
//		eventName = UserDefaults.standard.object(forKey: "currentTripName") as! String
//		let fetchRequest = NSFetchRequest<Trip>(entityName: "Trip")
//		fetchRequest.predicate = NSPredicate(format: "tripName == %@", eventName)
//		let events = (try! moc!.fetch(fetchRequest))
        
        getEventData()
        
		performUpdateOnCoreData()
        
//        for entry in entries {
//            print(entry.description)
//        }
        
	}
    
    // Fetch the current event from the persistent store and assign the CoreData variables
    private func getEventData() {
        
        do {
            
            event = try fetchCurrentEvent()
            guard let theEntries = event.entries as? [Interval] else {
                
                displayAlert(title: "Error Retrieving Data", message: "There was an error retrieving saved data.", on: self, dismissHandler: nil)
                return
                
            }
            entries = theEntries
            eventDate = event.flightDate
            tableView.reloadData()
            
        } catch {
            displayAlert(title: "Error Retrieving Data", message: "There was an error retrieving saved data.", on: self, dismissHandler: nil)
        }
        
    }
	
	
	// MARK: - Table view data source
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "M/d/yy '@' h:mm a"
		
		return "Event: \(dateFormatter.string(from: eventDate))"
		
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
	
		return entries.count
		
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = self.tableView.dequeueReusableCell(withIdentifier: "EntryCell", for: indexPath) 
		
		var entry: Interval!
		entry = entries[indexPath.row]
		
		cell.textLabel?.text = entry.scheduleLabel
        cell.detailTextLabel?.text = entry.stringFromTimeValue()
        
		return cell
		
	}
    
    
    // MARK: - Table view delegate
	
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		
		if editingStyle == UITableViewCellEditingStyle.delete {
			
			entries.remove(at: indexPath.row)
			
			tableView.deleteRows(at: [indexPath], with: .fade)
			
			performUpdateOnCoreData()
			
		}
        
	}
	
	override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		
		let movedEntry = entries.remove(at: sourceIndexPath.row)
		entries.insert(movedEntry, at: destinationIndexPath.row)
		
		performUpdateOnCoreData()
		
	}
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        selectedEntryIndexPath = indexPath
        
        return indexPath
        
    }
    
    
    // MARK: - Core Data helper
    
    func prepareForUpdateOnCoreData() {
        
        event.entries = entries as NSArray
        
    }
    
//	func performUpdateOnCoreData() {
//		
//		guard let moc = self.moc else {
//			return
//		}
//		
//		if moc.hasChanges {
//			
//			do {
//				try moc.save()
//			} catch {
//				
//			}
//			
//		}
//		
//	}
		
	
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

		// Prepare a selection's view to have all of the information of the current selection's row and associated data
		if let destVC = segue.destination as? SelectedEntryTableViewController {
            
            destVC.entries = entries
            
            let selectedEntry = entries[selectedEntryIndexPath.row]
            
//            destVC.eventName = eventName
            destVC.currentEntryIndexPath = selectedEntryIndexPath
            destVC.currentEntry = selectedEntry
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

}
