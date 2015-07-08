//
//  FlightTimeTableViewController.swift
//  TravelTimerBasics9
//
//  Created by Matteo Manzi on 6/28/15.
//  Copyright (c) 2015 VMM Softwares. All rights reserved.
//

// No keyboard on dateTextfield DONE
// date should be MM/dd/yy @hh:mm a DONE
// Apple calendar -add event- style table view DONE

import UIKit
import CoreData

class FlightTimeTableViewController: UITableViewController, UITextFieldDelegate {
	
	@IBOutlet var tripNameTextfield: UITextField!
	@IBOutlet var dateCell: UITableViewCell!
	@IBOutlet var flightDatePicker: UIDatePicker!
	
	var moc: NSManagedObjectContext?
	
	var allTrips = [Trip]()
	var tripName: String!
	var flightDate = NSDate()
	var defaultEntries = [
		
		Interval(mainLabel: "Getting Ready", scheduleLabel: "Wake Up", timeValueHours: 0, timeValueMins: 45),
		Interval(mainLabel: "Driving To Airport", scheduleLabel: "Leave for Airport", timeValueHours: 0, timeValueMins: 30),
		Interval(mainLabel: "Arrival to Boarding", scheduleLabel: "Arrive at Airport", timeValueHours: 0, timeValueMins: 45),
		Interval(mainLabel: "Boarding to Departure", scheduleLabel: "Board Plane", timeValueHours: 0, timeValueMins: 30)
		
	]
	
	let dateFormatter = NSDateFormatter()
	
	var pickerHidden = true
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let backgroundImageView = UIImageView(image: UIImage(named: "lookout"))
		backgroundImageView.contentMode = UIViewContentMode.ScaleAspectFill
		self.tableView.backgroundView = backgroundImageView
		
		moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
		
		tripNameTextfield.delegate = self
		
		dateFormatter.dateStyle = .ShortStyle
		dateFormatter.timeStyle = .MediumStyle
		tripName = "TripOn_\(dateFormatter.stringFromDate(flightDate))"
		
		let components = NSCalendar.currentCalendar().componentsInTimeZone(NSTimeZone.systemTimeZone(), fromDate: flightDate)
		components.second = 0
		flightDate = NSCalendar.currentCalendar().dateFromComponents(components)!
		
		dateFormatter.dateFormat = "M/d/yy '@' h:mm a"
		dateCell.detailTextLabel?.text = dateFormatter.stringFromDate(flightDate)
		
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	override func viewWillAppear(animated: Bool) {
		
		let fetchAll = NSFetchRequest()
		fetchAll.entity = NSEntityDescription.entityForName("Trip", inManagedObjectContext: moc!)
		var fetchError: NSError?
		allTrips = moc!.executeFetchRequest(fetchAll, error: &fetchError) as! [Trip]
		if fetchError != nil {
			
			println("could not fetch")
			
		}
		
		
		if allTrips.count > 0 && self.navigationItem.leftBarButtonItem == nil {
			
			self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "cancelNewTrip:")
			(UIApplication.sharedApplication().delegate as! AppDelegate).currentTripNameMaster = allTrips[allTrips.count - 1].tripName
			
		}
		
	}
	
	@IBAction func tripNameDidChange(sender: UITextField) {
		
		tripName = sender.text
		
	}
	
	func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
		
		if pickerHidden == false {
			
			togglePicker()
			
		}
		
		return true
		
	}
	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		
		textField.resignFirstResponder()
		
		tripName = textField.text
		
		return true
		
	}
	
	@IBAction func flightDateChanged(sender: UIDatePicker) {
		
		flightDate = sender.date
		dateCell.detailTextLabel?.text = dateFormatter.stringFromDate(flightDatePicker.date)
		
	}
	
	func cancelNewTripFromSettings(sender: UIBarButtonItem) {
		
		dismissViewControllerAnimated(true, completion: nil)
		
	}
	
	// MARK: - Table view data source
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if pickerHidden {
			
			return 2
			
		} else {
			
			return 3
			
		}
		
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		
		if indexPath.row == 1 {
			
			togglePicker()
			
		}
		
	}
	
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		
		if pickerHidden {
			
			return tableView.rowHeight
			
		} else {
			
			if indexPath.row == 2 {
				
				return flightDatePicker.frame.height
				
			} else {
				
				return tableView.rowHeight
				
			}
			
		}
		
	}
	
	
	// MARK: - Date picker show/hide
	
	func togglePicker() {
		
		self.tableView.beginUpdates()
		
		if pickerHidden {
			
			flightDatePicker.setDate(flightDate, animated: true)
			self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 2, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
			tripNameTextfield.resignFirstResponder()
			tableView.scrollEnabled = false
			
		} else {
			
			self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: 2, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Fade)
			tableView.scrollEnabled = true
			
		}
		
		pickerHidden = !pickerHidden
		
		self.tableView.endUpdates()
		
		self.tableView.deselectRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0), animated: true)
		
	}
	
	
	// MARK: - Navigation
	
	func cancelNewTrip(sender: UIBarButtonItem) {
		
		let mainVC = self.storyboard?.instantiateViewControllerWithIdentifier("mainTabVC") as! UITabBarController
		mainVC.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
		presentViewController(mainVC, animated: true, completion: nil)
		
	}
	
	@IBAction func createNewTrip(sender: UIBarButtonItem) {
		
		var nameIsUnique = true
		
		for trip in allTrips {
			
			if self.tripName == trip.tripName {
				
				nameIsUnique = false
				
			}
			
		}
		
		if nameIsUnique {
			
			let newTrip = NSEntityDescription.insertNewObjectForEntityForName("Trip", inManagedObjectContext: moc!) as! Trip
			newTrip.tripName = self.tripName
			newTrip.flightDate = self.flightDate
			newTrip.entries = self.defaultEntries
			var savingError: NSError?
			if moc!.save(&savingError) == false {
				
				if let theError = savingError {
					
					println("Failed to save the trip.\nError = \(theError)")
					
				}
				
			}
			
			(UIApplication.sharedApplication().delegate as! AppDelegate).currentTripNameMaster = self.tripName
			
			let mainVC = self.storyboard?.instantiateViewControllerWithIdentifier("mainTabVC") as! UITabBarController
			mainVC.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
			presentViewController(mainVC, animated: true, completion: nil)
				
		} else {
			
			let nameAlertController = UIAlertController(title: "Cannot Save Trip", message: "There is already a trip with the same name.", preferredStyle: UIAlertControllerStyle.Alert)
			let dismissAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: { (alert: UIAlertAction!) in
				nameAlertController.dismissViewControllerAnimated(true, completion: nil)
			})
			nameAlertController.addAction(dismissAction)
			
			self.presentViewController(nameAlertController, animated: true, completion: nil)
			
		}
		
	}
	
	override func viewWillDisappear(animated: Bool) {
		
		tripNameTextfield.resignFirstResponder()
		
	}
	
}
