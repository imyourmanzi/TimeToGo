//
//  SettingsTableViewController.swift
//  TravelTimerBasics10
//
//  Created by Matteo Manzi on 7/1/15.
//  Copyright (c) 2015 VMM Softwares. All rights reserved.
//

import UIKit
import CoreData

class SettingsTableViewController: UITableViewController {

	@IBOutlet var flightDateCell: UITableViewCell!
	
	var moc: NSManagedObjectContext?
	var currentTripName: String!
	var currentTrip: Trip!
	var currentTripIndex: Int!
	var allTrips = [Trip]()
	
	var flightDate: NSDate!
	var tripName: String!
	
    override func viewDidLoad() {
        super.viewDidLoad()

		moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
		
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	override func viewWillAppear(animated: Bool) {
		
		currentTripName = (UIApplication.sharedApplication().delegate as! AppDelegate).currentTripNameMaster
		let fetchRequest = NSFetchRequest(entityName: "Trip")
		fetchRequest.predicate = NSPredicate(format: "tripName == %@", currentTripName)
		var fetchingError: NSError?
		let trips = moc!.executeFetchRequest(fetchRequest, error: &fetchingError) as! [Trip]
		currentTrip = trips[0]
		
		self.flightDate = currentTrip.flightDate
		self.tripName = currentTrip.tripName
		
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "M/d/yy '@' h:mm a"
		flightDateCell.detailTextLabel?.text = dateFormatter.stringFromDate(self.flightDate)
		
		currentTripName = (UIApplication.sharedApplication().delegate as! AppDelegate).currentTripNameMaster
		let fetchAll = NSFetchRequest(entityName: "Trip")
		var fetchingAllError: NSError?
		allTrips = moc!.executeFetchRequest(fetchAll, error: &fetchingAllError) as! [Trip]
		
		tableView.reloadData()
		
	}
	
	@IBAction func clickedDeleteTrip(sender: UIButton) {
		
		let deleteAlertController = UIAlertController(title: nil, message: "Delete \(currentTripName)?", preferredStyle: .ActionSheet)
		let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {(action: UIAlertAction!) in
			deleteAlertController.dismissViewControllerAnimated(true, completion: nil)
		})
		let deleteAction = UIAlertAction(title: "Delete Trip", style: UIAlertActionStyle.Destructive, handler: { (action: UIAlertAction!) in
			
			var index = 0
			for trip in self.allTrips {
				
				if trip.tripName == self.currentTripName {
					
					self.currentTripIndex = index
					
				}
				
				index++
				
			}
			
			self.moc!.deleteObject(self.allTrips.removeAtIndex(self.currentTripIndex))
			
			var savingError: NSError?
			if self.moc!.save(&savingError) == false {
				
				if let error = savingError {
					
					println("Failed to delete the trip.\nError = \(error)")
					
				}
				
			}
			
			if self.allTrips.count >= 1 {
				
				self.currentTripName = self.allTrips[self.allTrips.count - 1].tripName
				(UIApplication.sharedApplication().delegate as! AppDelegate).currentTripNameMaster = self.currentTripName
				
				self.viewWillAppear(true)
				
			} else if self.allTrips.count <= 0 {
				
				let semiDestVC = self.storyboard?.instantiateViewControllerWithIdentifier("newTripNavVC") as! UINavigationController
				let destVC = semiDestVC.viewControllers[0] as! FlightTimeTableViewController
				destVC.hidesBottomBarWhenPushed = true
				destVC.navigationItem.hidesBackButton = true
				self.showViewController(destVC, sender: self)
				
			}
			
		})
		
		deleteAlertController.addAction(cancelAction)
		deleteAlertController.addAction(deleteAction)
		
		self.presentViewController(deleteAlertController, animated: true, completion: nil)

	}

	
	// MARK: - Table view data source
	
	override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		
		if section == 1 {
			
			return "Saved Trips: \(allTrips.count)"
			
		}
		
		return nil
		
	}
	
	
	// MARK: - Navigation
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		
		if let timeVC = segue.destinationViewController as? EditFlightTimeTableViewController {
			
			timeVC.currentTripName = self.currentTripName
			timeVC.flightDate = self.flightDate
			timeVC.currentTrip = self.currentTrip
			
		} else if let nameVC = segue.destinationViewController as? EditTripNameTableViewController {
			
			nameVC.currentTripName = self.currentTripName
			nameVC.tripName = self.tripName
			nameVC.currentTrip = self.currentTrip
			
		} else if let newTripNavVC = segue.destinationViewController as? UINavigationController {
			
			if let newTripVC = newTripNavVC.viewControllers[0] as? FlightTimeTableViewController {
				
				newTripVC.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: newTripVC, action: "cancelNewTripFromSettings:")
				
			}
			
		}
		
	}
	
}
