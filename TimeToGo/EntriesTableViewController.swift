//
//  EntriesTableViewController.swift
//  TimeToGo
//
//  Created by Matt Manzi on 7/4/15.
//  Copyright (c) 2017 MRM Software. All rights reserved.
//

import UIKit
import CoreData
import MapKit

private let reuseIdentifier = "entryCell"

class EntriesTableViewController: UITableViewController, CoreDataHelper {
	
	// CoreData variables
	var event: Trip!
    var entries: [Interval] = []
	var eventDate: Date!
	
    // Current VC variables
    var selectedEntryIndexPath = IndexPath()
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Use auto-implemented 'Edit' button on right side of navigation bar
		self.navigationItem.leftBarButtonItem = self.editButtonItem
		
    }

	override func viewWillAppear(_ animated: Bool) {
        
        getEventData()
        
		performUpdateOnCoreData()
        
	}
    
    // Fetch the current event from the persistent store and assign the CoreData variables
    private func getEventData() {
        
        do {
            
            event = try fetchCurrentEvent()
            guard let theEntries = event.entries as? [Interval] else {
                
                guard let parentVC = parent else {
                    return
                }
                displayDataErrorAlert(on: parentVC, dismissHandler: {
                    (_) in
                    
                    guard let mainTabVC = self.storyboard?.instantiateViewController(withIdentifier: "mainTabVC") as? UITabBarController else {
                        return
                    }
                    
                    mainTabVC.modalTransitionStyle = .crossDissolve
                    self.present(mainTabVC, animated: true, completion: nil)
                    
                })
                
                return
                
            }
            entries = theEntries
            eventDate = event.flightDate
            tableView.reloadData()
            
        } catch {
            
            guard let parentVC = parent else {
                return
            }
            
            displayDataErrorAlert(on: parentVC, dismissHandler: {
                (_) in
                
                guard let mainTabVC = self.storyboard?.instantiateViewController(withIdentifier: "mainTabVC") as? UITabBarController else {
                    return
                }
                
                mainTabVC.modalTransitionStyle = .crossDissolve
                self.present(mainTabVC, animated: true, completion: nil)
                
            })
            
        }
        
    }
	
	
	// MARK: - Table view data source
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "M/d/yy '@' h:mm a"
		
		return "\(event.eventTimeLabel): \(dateFormatter.string(from: eventDate))"
		
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
	
		return entries.count
		
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = self.tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
		
		var entry: Interval!
		entry = entries[indexPath.row]
		
		cell.textLabel?.text = entry.scheduleLabel
        cell.detailTextLabel?.text = entry.getTimeValueString()
        
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
		
	
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

		// Prepare a selection's view to have all of the information of the current selection's row and associated data
		if let destVC = segue.destination as? SelectedEntryTableViewController {
            
            destVC.entries = entries
            
            let selectedEntry = entries[selectedEntryIndexPath.row]
            
            destVC.currentEntryIndexPath = selectedEntryIndexPath
            destVC.currentEntry = selectedEntry
            destVC.schedLabel = selectedEntry.scheduleLabel
            destVC.timeValueHours = selectedEntry.timeValueHours
            destVC.timeValueMins = selectedEntry.timeValueMins
            destVC.intervalTimeStr = selectedEntry.getTimeValueString()
            destVC.notes = selectedEntry.notesStr
            if selectedEntry.useLocation == true && selectedEntry.startLocation != nil && selectedEntry.endLocation != nil {
                
                destVC.startLocation = MKMapItem(placemark: selectedEntry.startLocation!)
                destVC.endLocation = MKMapItem(placemark: selectedEntry.endLocation!)
                
            }
            
		}
        
    }

}
