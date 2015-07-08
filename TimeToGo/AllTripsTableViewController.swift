//
//  AllTripsTableViewController.swift
//  TravelTimerBasics10
//
//  Created by Matteo Manzi on 7/1/15.
//  Copyright (c) 2015 VMM Softwares. All rights reserved.
//

import UIKit
import CoreData

class AllTripsTableViewController: UITableViewController {

	var moc: NSManagedObjectContext?
	var allTrips = [Trip]()
	var currentTripName: String!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
		
		moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
		
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	override func viewWillAppear(animated: Bool) {
		
		currentTripName = (UIApplication.sharedApplication().delegate as! AppDelegate).currentTripNameMaster
		let fetchAll = NSFetchRequest()
		fetchAll.entity = NSEntityDescription.entityForName("Trip", inManagedObjectContext: moc!)
		var fetchError: NSError?
		allTrips = moc!.executeFetchRequest(fetchAll, error: &fetchError) as! [Trip]
		if fetchError != nil {
			
			println("could not fetch")
			
		}
		
		tableView.reloadData()
		
	}
	
	
    // MARK: - Table view data source

	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return allTrips.count
		
	}
	
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCellWithIdentifier("TripCell", forIndexPath: indexPath) as! UITableViewCell

		let trip = allTrips[indexPath.row]
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "M/d/yy '@' h:mm a"
		
		cell.textLabel?.text = trip.tripName
		cell.detailTextLabel?.text = dateFormatter.stringFromDate(trip.flightDate)

        return cell
		
    }

	
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		
        // Return NO if you do not want the specified item to be editable.
        return true
		
    }
	

	
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		
        if editingStyle == .Delete {
			
			if allTrips[indexPath.row].tripName == currentTripName && allTrips.count > 1 {
				
				currentTripName = allTrips[allTrips.count - 2].tripName
				(UIApplication.sharedApplication().delegate as! AppDelegate).currentTripNameMaster = currentTripName
				
			}
			
            // Delete the row from the data source
			moc!.deleteObject(allTrips.removeAtIndex(indexPath.row))
			
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
			
        }
		
		var savingError: NSError?
		if moc!.save(&savingError) == false {
			
			if let error = savingError {
				
				println("Failed to delete the trip.\nError = \(error)")
				
			}
			
		}
		
		if allTrips.count <= 0 {
			
			let semiDestVC = self.storyboard?.instantiateViewControllerWithIdentifier("newTripNavVC") as! UINavigationController
			let destVC = semiDestVC.viewControllers[0] as! FlightTimeTableViewController
			destVC.hidesBottomBarWhenPushed = true
			destVC.navigationItem.hidesBackButton = true
			showViewController(destVC, sender: self)
			
		}
	
    }
	
	
	// MARK: - Navigation
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		
		let indexPath: NSIndexPath! = tableView.indexPathForSelectedRow()
		if let destVC = segue.destinationViewController as? SavedTripViewController {

			let selectedTrip = allTrips[indexPath.row]
			
			destVC.title = selectedTrip.tripName
			destVC.tripName = selectedTrip.tripName
			destVC.flightDate = selectedTrip.flightDate
			destVC.numOfEntries = selectedTrip.entries.count
				
		}
		
	}

}
