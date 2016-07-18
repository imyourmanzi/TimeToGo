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
	var indexPathForSaved: NSIndexPath?
	var destinationVC: UIViewController?
	var searchResultsController = UISearchController()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Use auto-implemented 'Edit' button on right side of navigation bar
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
		
		// Assign the moc CoreData variable by referencing the AppDelegate's
		moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
		
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

	override func viewWillAppear(animated: Bool) {
		
		// Fetch all of the managed objects from the persistent store and update the table view
		currentTripName = NSUserDefaults.standardUserDefaults().objectForKey("currentTripName") as! String
		let fetchAll = NSFetchRequest()
		fetchAll.entity = NSEntityDescription.entityForName("Trip", inManagedObjectContext: moc!)
		allTrips = (try! moc!.executeFetchRequest(fetchAll)) as! [Trip]
		
		tableView.reloadData()
		
	}
	
	
    // MARK: - Table view data source

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if searchResultsController.active {
			return filteredTrips.count
		} else {
			return allTrips.count
		}
		
	}
	
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCellWithIdentifier("TripCell", forIndexPath: indexPath) 
		
		var trip: Trip!
		
		if searchResultsController.active {
			 trip = filteredTrips[indexPath.row]
		} else {
			trip = allTrips[indexPath.row]
		}
		
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "M/d/yy '@' h:mm a"
		
		cell.textLabel?.text = trip.tripName
		cell.detailTextLabel?.text = dateFormatter.stringFromDate(trip.flightDate)

        return cell
		
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		
        if editingStyle == .Delete {
			
			// Update the current trip if the current one has been deleted
			if allTrips[indexPath.row].tripName == currentTripName && allTrips.count > 1 {
				
				currentTripName = allTrips[allTrips.count - 2].tripName
				NSUserDefaults.standardUserDefaults().setObject(currentTripName, forKey: "currentTripName")
				
			}
			
            // Delete the row from the data sources and the table view
			moc!.deleteObject(allTrips.removeAtIndex(indexPath.row))
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
			
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
			
			let semiDestVC = self.storyboard?.instantiateViewControllerWithIdentifier("newTripNavVC") as! UINavigationController
			let destVC = semiDestVC.viewControllers[0] as! FlightTimeTableViewController
			destVC.hidesBottomBarWhenPushed = true
			destVC.navigationItem.hidesBackButton = true
			showViewController(destVC, sender: self)
			
		}
	
    }
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		
//		print("a: \(indexPath)")
		
		// Update currentTripName to the chosen tripName
		var theTripName: String!
		
		if searchResultsController.active {
			theTripName = self.filteredTrips[indexPath.row].tripName
		} else {
			theTripName = self.allTrips[indexPath.row].tripName
		}
		
		NSUserDefaults.standardUserDefaults().setObject(theTripName, forKey: "currentTripName")
		
		// Transition to the Scheudle VC
		let mainTabVC = self.storyboard?.instantiateViewControllerWithIdentifier("mainTabVC") as! UITabBarController
		mainTabVC.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
		self.presentViewController(mainTabVC, animated: true, completion: nil)
		
	}
	
	override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
		
//		print("b: \(indexPath)")
		
		self.indexPathForSaved = indexPath
		
	}
	
	
	// MARK: - Search
	
	func updateSearchResultsForSearchController(searchController: UISearchController) {
		
		filteredTrips.removeAll(keepCapacity: false)
		
		let searchPredicate = NSPredicate(format: "tripName CONTAINS[c] %@", searchController.searchBar.text!)
		let tempArr = (allTrips as NSArray).filteredArrayUsingPredicate(searchPredicate)
		filteredTrips = tempArr as! [Trip]
		
		tableView.reloadData()
		
	}
	
	
	// MARK: - Navigation
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		
		searchResultsController.active = false
		
		destinationVC = segue.destinationViewController
		
	}
	
	
	
	override func viewWillDisappear(animated: Bool) {
		
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
		
		let selectedTrip = allTrips[indexPath.row]
		
//		print("c: \(allTrips)")
//		print("d: \(selectedTrip)")
		
		savedTripVC.title = selectedTrip.tripName
		savedTripVC.tripName = selectedTrip.tripName
		savedTripVC.flightDate = selectedTrip.flightDate
		savedTripVC.entries = selectedTrip.entries as! [Interval]
		
	}
	

}
