//
//  AllEventsTableViewController.swift
//  TimeToGo
//
//  Created by Matteo Manzi on 7/4/15.
//  Copyright (c) 2015 VMM Software. All rights reserved.
//

import UIKit
import CoreData

class AllEventsTableViewController: UITableViewController, UISearchResultsUpdating, CoreDataHelper {
    
	// CoreData variables
//	var moc: NSManagedObjectContext?
    var allEvents: [Trip] = []
    var filteredEvents: [Trip] = []
	var eventName: String!
	
	// Current VC variables
	var savedEventIndexPath = IndexPath()
//	var destinationVC: UIViewController?
	var searchResultsController = UISearchController()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Use auto-implemented 'Edit' button on right side of navigation bar
        self.navigationItem.rightBarButtonItem = self.editButtonItem
		
		// Assign the moc CoreData variable by referencing the AppDelegate's
//		moc = getContext()
		
        setupSearchController()
        
	}

	override func viewWillAppear(_ animated: Bool) {
		
//		eventName = UserDefaults.standard.object(forKey: "currentTripName") as! String
//		let fetchAll = NSFetchRequest<Trip>()
//		fetchAll.entity = NSEntityDescription.entity(forEntityName: "Trip", in: moc!)
//		allEvents = (try! moc!.fetch(fetchAll))
        
        // Fetch all of the managed objects from the persistent store and update the table view
//        do {
//            allEvents = try fetchAllEvents()
//            tableView.reloadData()
//        } catch {
//        }
		
	}
	
    override func viewDidAppear(_ animated: Bool) {
        
        if allEvents.count <= 0 {
            performSegue(withIdentifier: "unwindToHome", sender: self)
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
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) 
		
		var event: Trip!
		
		if searchResultsController.isActive {
			 event = filteredEvents[indexPath.row]
		} else {
			event = allEvents[indexPath.row]
		}
		
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "M/d/yy '@' h:mm a"
		
		cell.textLabel?.text = event.tripName
		cell.detailTextLabel?.text = dateFormatter.string(from: event.flightDate as Date)

        return cell
		
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		
        if editingStyle == .delete {
			
			// Update the current event if the current one has been deleted
			if allEvents[indexPath.row].tripName == eventName && allEvents.count > 1 {
				
				eventName = allEvents[allEvents.count - 2].tripName
				UserDefaults.standard.set(eventName, forKey: "currentTripName")
				
			}
			
            // Delete the row from the data sources and the table view
            let eventRemoved = allEvents.remove(at: indexPath.row)
            guard let theMoc = moc else {
                
                // Unless moc is not available, then put the event back
                allEvents.insert(eventRemoved, at: indexPath.row)
                return
                
            }
            theMoc.delete(eventRemoved)
            tableView.deleteRows(at: [indexPath], with: .fade)
			
        }
		
//		guard let moc = self.moc else {
//			return
//		}
//
//		if moc.hasChanges {
//
//			do {
//				try moc.save()
//			} catch {
//			}
//
//		}
		
		// Check for more existing events, if there are not, redirect the user back to the new event screen
		if allEvents.count <= 0 {
			
            performSegue(withIdentifier: "unwindToHome", sender: self)
            
//            guard let destVC = self.storyboard?.instantiateViewController(withIdentifier: "homeVC") as? HomeViewController else {
//                return
//            }
//            destVC.hidesBottomBarWhenPushed = true
//            destVC.navigationItem.hidesBackButton = true
//            destVC.navigationItem.prompt = ""
//			show(destVC, sender: self)
			
		}
        
        // Save the state of the persistent store
//        print("about to save")
        performUpdateOnCoreData()
	
    }
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		// Update currentTripName to the chosen eventName
		var theEventName: String!
		
		if searchResultsController.isActive {
			theEventName = self.filteredEvents[indexPath.row].tripName
		} else {
			theEventName = self.allEvents[indexPath.row].tripName
		}
		
		UserDefaults.standard.set(theEventName, forKey: "currentTripName")
		
        // Transition to the Scheudle VC
        // TODO: ^^
        
//		let mainTabVC = self.storyboard?.instantiateViewController(withIdentifier: "mainTabVC") as! UITabBarController
//		mainTabVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
//		self.present(mainTabVC, animated: true, completion: nil)
		
	}
	
	override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
//		print("accessory button tapped")
        
        savedEventIndexPath = indexPath
//        print("saved index path")
        performSegue(withIdentifier: "viewSavedEvent", sender: indexPath)
//        print("after perform segue call")
		
	}
	
	
	// MARK: - Search
	
	func updateSearchResults(for searchController: UISearchController) {
		
		filteredEvents.removeAll(keepingCapacity: false)
		
		let searchPredicate = NSPredicate(format: "tripName CONTAINS[c] %@", searchController.searchBar.text!)
		let tempArr = (allEvents as NSArray).filtered(using: searchPredicate)
		filteredEvents = tempArr as! [Trip]
		
		tableView.reloadData()
		
	}
	
	
	// MARK: - Navigation
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        if identifier == "viewSavedEvent" && sender is IndexPath {
//            print("will segue")
            return true
        }
        
//        print("will not segue")
        return false
        
    }
    
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//		print("preparing for segue")
        
		searchResultsController.isActive = false
        
        if segue.identifier == "viewSavedEvent" {
//            print("segue is viewSavedEvent")
        
//        if let theIndexPath = sender as? IndexPath {
//            print("sender is theIndexPath")
        
            if let savedEventVC = segue.destination as? SavedEventViewController {
//                print("it's savedEventVC")
            
                if let theIndexPath = sender as? IndexPath {
                
                let selectedEvent = allEvents[theIndexPath.row]
//                print("found selectedEvent")
                
                    savedEventVC.title = selectedEvent.tripName
                    savedEventVC.eventName = selectedEvent.tripName
                    savedEventVC.eventDate = selectedEvent.flightDate
                    savedEventVC.entries = selectedEvent.entries as! [Interval]
//                    print("set dest vc data")
                    
                }
                
            }
            
        }
//        }
//        print("after segue preparing")
		
    }
    
}
