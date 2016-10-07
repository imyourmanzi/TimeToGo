//
//  AllTripsTableViewController.swift
//  TimeToGo
//
//  Created by Matteo Manzi on 7/4/15.
//  Copyright (c) 2015 VMM Software. All rights reserved.
//

import UIKit
import CoreData

class AllTripsTableViewController: UITableViewController, UISearchResultsUpdating {

	// CoreData variables
	var moc: NSManagedObjectContext?
	var allTrips = [Trip]()
	var filteredTrips = [Trip]()
	var currentTripName: String!
	
	// Current VC variables
	var indexPathForSaved: IndexPath?
	var destinationVC: UIViewController?
	var searchResultsController = UISearchController()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Use auto-implemented 'Edit' button on right side of navigation bar
        self.navigationItem.rightBarButtonItem = self.editButtonItem
		
		// Assign the moc CoreData variable by referencing the AppDelegate's
		moc = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
		
		// Set up the search controller
		if #available(iOS 9.0, *) {
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
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

	override func viewWillAppear(_ animated: Bool) {
		
		// Fetch all of the managed objects from the persistent store and update the table view
		currentTripName = UserDefaults.standard.object(forKey: "currentTripName") as! String
		let fetchAll = NSFetchRequest<Trip>()
		fetchAll.entity = NSEntityDescription.entity(forEntityName: "Trip", in: moc!)
		allTrips = (try! moc!.fetch(fetchAll))
		
		tableView.reloadData()
		
	}
	
	
    // MARK: - Table view data source

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if searchResultsController.isActive {
			return filteredTrips.count
		} else {
			return allTrips.count
		}
		
	}
	
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "TripCell", for: indexPath) 
		
		var trip: Trip!
		
		if searchResultsController.isActive {
			 trip = filteredTrips[(indexPath as NSIndexPath).row]
		} else {
			trip = allTrips[(indexPath as NSIndexPath).row]
		}
		
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "M/d/yy '@' h:mm a"
		
		cell.textLabel?.text = trip.tripName
		cell.detailTextLabel?.text = dateFormatter.string(from: trip.flightDate as Date)

        return cell
		
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		
        if editingStyle == .delete {
			
			// Update the current trip if the current one has been deleted
			if allTrips[(indexPath as NSIndexPath).row].tripName == currentTripName && allTrips.count > 1 {
				
				currentTripName = allTrips[allTrips.count - 2].tripName
				UserDefaults.standard.set(currentTripName, forKey: "currentTripName")
				
			}
			
            // Delete the row from the data sources and the table view
			moc!.delete(allTrips.remove(at: (indexPath as NSIndexPath).row))
            tableView.deleteRows(at: [indexPath], with: .fade)
			
        }
		
		// Save the state of the persistent store
		guard let moc = self.moc else {
			return
		}
		
		if moc.hasChanges {
			
			do {
				try moc.save()
			} catch {
				
			}
			
		}
		
		// Check for more existing trips, if there are not, redirect the user back to the new trip screen
		if allTrips.count <= 0 {
			
			let semiDestVC = self.storyboard?.instantiateViewController(withIdentifier: "newTripNavVC") as! UINavigationController
			let destVC = semiDestVC.viewControllers[0] as! FlightTimeTableViewController
			destVC.hidesBottomBarWhenPushed = true
			destVC.navigationItem.hidesBackButton = true
			show(destVC, sender: self)
			
		}
	
    }
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
//		print("a: \(indexPath)")
		
		// Update currentTripName to the chosen tripName
		var theTripName: String!
		
		if searchResultsController.isActive {
			theTripName = self.filteredTrips[(indexPath as NSIndexPath).row].tripName
		} else {
			theTripName = self.allTrips[(indexPath as NSIndexPath).row].tripName
		}
		
		UserDefaults.standard.set(theTripName, forKey: "currentTripName")
		
		// Transition to the Scheudle VC
		let mainTabVC = self.storyboard?.instantiateViewController(withIdentifier: "mainTabVC") as! UITabBarController
		mainTabVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
		self.present(mainTabVC, animated: true, completion: nil)
		
	}
	
	override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
		
//		print("b: \(indexPath)")
		
		self.indexPathForSaved = indexPath
		
	}
	
	
	// MARK: - Search
	
	func updateSearchResults(for searchController: UISearchController) {
		
		filteredTrips.removeAll(keepingCapacity: false)
		
		let searchPredicate = NSPredicate(format: "tripName CONTAINS[c] %@", searchController.searchBar.text!)
		let tempArr = (allTrips as NSArray).filtered(using: searchPredicate)
		filteredTrips = tempArr as! [Trip]
		
		tableView.reloadData()
		
	}
	
	
	// MARK: - Navigation
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		searchResultsController.isActive = false
		
		destinationVC = segue.destination
		
	}
	
	
	
	override func viewWillDisappear(_ animated: Bool) {
		
//		print("will disappear")
		
		// Prepare the following screen if a previous trip's cell was selected to be viewed
		guard let indexPath = indexPathForSaved else {
//			print("b again: \(indexPathForSaved)")
			return
		}
		
		guard let savedTripVC = destinationVC as? SavedTripViewController else {
//			print("z: no saved trip vc")
			return
		}
		
		let selectedTrip = allTrips[(indexPath as NSIndexPath).row]
		
//		print("c: \(allTrips)")
//		print("d: \(selectedTrip)")
		
		savedTripVC.title = selectedTrip.tripName
		savedTripVC.tripName = selectedTrip.tripName
		savedTripVC.flightDate = selectedTrip.flightDate
		savedTripVC.entries = selectedTrip.entries as! [Interval]
		
	}
	

}
