//
//  AllEventsTableViewController.swift
//  TimeToGo
//
//  Created by Matt Manzi on 7/4/15.
//  Copyright (c) 2017 MRM Software. All rights reserved.
//

import UIKit
import CoreData

private let reuseIdentifier = "eventCell"

class AllEventsTableViewController: UITableViewController, UISearchResultsUpdating, CoreDataHelper {
    
	// CoreData variables
    var allEvents: [Trip] = []
    var filteredEvents: [Trip] = []
	
	// Current VC variables
    var eventName: String = UIConstants.NOT_FOUND
	var savedEventIndexPath = IndexPath()
	var searchResultsController = UISearchController()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
        retrieveCurrentEventName()
        
		// Use auto-implemented 'Edit' button on right side of navigation bar
        self.navigationItem.rightBarButtonItem = self.editButtonItem
		
        setupSearchController()
        
	}
    
    override func viewDidAppear(_ animated: Bool) {
        
        if allEvents.count <= 0 {
            performSegue(withIdentifier: IDs.SGE_TO_HOME, sender: self)
        }
        
    }
    
    // Set up the search controller
    private func setupSearchController() {
        
        if #available(iOS 10.0, *) {
            searchResultsController.loadViewIfNeeded()
        } else if #available(iOS 9.0, *) {
            searchResultsController.loadViewIfNeeded()
        } else {
            searchResultsController.loadView()
        }
        searchResultsController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            
            self.tableView.tableHeaderView = controller.searchBar
            
            return controller
        })()
        
        tableView.reloadData()
        
    }
    
	
    // MARK: - Table view data source

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if searchResultsController.isActive {
			return filteredEvents.count
		} else {
			return allEvents.count
		}
		
	}
	
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
		let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
		
		var event: Trip!
		
		if searchResultsController.isActive {
			 event = filteredEvents[indexPath.row]
		} else {
			event = allEvents[indexPath.row]
		}
		
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = UIConstants.STD_DATETIME_FORMAT
		
		cell.textLabel?.text = event.tripName
		cell.detailTextLabel?.text = dateFormatter.string(from: event.flightDate)

        return cell
		
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		
        if editingStyle == .delete {
			
			// Update the current event if the current one has been deleted but there are others left
			if allEvents[indexPath.row].tripName == eventName && allEvents.count > 1 {
				
				eventName = allEvents[allEvents.count - 2].tripName
                CoreDataConnector.setCurrentEventName(to: eventName)
				
			}
			
            // Delete the row from the data sources and the table view
            let eventRemoved = allEvents.remove(at: indexPath.row)
            guard let theMoc = CoreDataConnector.getMoc() else {
                
                // Unless moc is not available, then put the event back
                allEvents.insert(eventRemoved, at: indexPath.row)
                return
                
            }
            theMoc.delete(eventRemoved)
            tableView.deleteRows(at: [indexPath], with: .fade)
			
            // Save the state of the persistent store
            CoreDataConnector.updateStore(from: self)
            
        }
		
		// Check for more existing events, if there are not, redirect the user back to the new event screen
		if allEvents.count <= 0 {
            performSegue(withIdentifier: IDs.SGE_TO_HOME, sender: self)
		}
        
    }
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		// Update currentTripName UserDefaults key to the chosen eventName
		var theEventName: String!
		
		if searchResultsController.isActive {
			theEventName = self.filteredEvents[indexPath.row].tripName
		} else {
			theEventName = self.allEvents[indexPath.row].tripName
		}
		
        CoreDataConnector.setCurrentEventName(to: theEventName)
		
        // Transition to the Scheudle VC
        guard let mainTabVC = storyboard?.instantiateViewController(withIdentifier: IDs.VC_TAB_MAIN) as? UITabBarController else {
            return
        }
        
        mainTabVC.modalTransitionStyle = .crossDissolve
        mainTabVC.selectedIndex = 1
        
        present(mainTabVC, animated: true, completion: nil)
		
	}
	
	override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        
        savedEventIndexPath = indexPath
        performSegue(withIdentifier: IDs.SGE_VIEW_SAVED, sender: indexPath)
		
	}
	
	
	// MARK: - Search
	
	func updateSearchResults(for searchController: UISearchController) {
		
		filteredEvents.removeAll(keepingCapacity: false)
		
		let searchPredicate = NSPredicate(format: CoreDataConstants.SEARCH_BY_NAME, searchController.searchBar.text!)
		let tempArr = (allEvents as NSArray).filtered(using: searchPredicate)
		filteredEvents = tempArr as! [Trip]
		
		tableView.reloadData()
		
	}
	
    
    // MARK: - Core Data helper
    
    func retrieveCurrentEventName() {
        
        guard let currentEventName = CoreDataConnector.getCurrentEventName() else {
            return
        }
        
        eventName = currentEventName
        
    }
    
	
	// MARK: - Navigation
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        if identifier == IDs.SGE_VIEW_SAVED && sender is IndexPath {
            return true
        } else if identifier != IDs.SGE_VIEW_SAVED {
            return true
        }
        
        return false
        
    }
    
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
		searchResultsController.isActive = false
        
        if segue.identifier == IDs.SGE_VIEW_SAVED {
            
            if let savedEventVC = segue.destination as? SavedEventViewController {
            
                if let theIndexPath = sender as? IndexPath {
                
                let selectedEvent = allEvents[theIndexPath.row]
                
                    savedEventVC.title = selectedEvent.tripName
                    savedEventVC.eventName = selectedEvent.tripName
                    savedEventVC.eventDate = selectedEvent.flightDate
                    savedEventVC.eventType = selectedEvent.eventType
                    savedEventVC.entries = selectedEvent.entries as! [Interval]
                    
                }
                
            }
            
        }
		
    }
    
    deinit {
        
        searchResultsController.view.removeFromSuperview()
        
    }
    
}
