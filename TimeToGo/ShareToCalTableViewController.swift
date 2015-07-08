//
//  ShareToCalTableViewController.swift
//  TravelTimerBasics11
//
//  Created by Matteo Manzi on 7/3/15.
//  Copyright (c) 2015 VMM Softwares. All rights reserved.
//

import UIKit
import EventKit
import CoreData

class ShareToCalTableViewController: UITableViewController {

	let eventStore = EKEventStore()
	var calendarsToList = [EKCalendar]()
	var calendarToUse: EKCalendar!
	var calendarToUseIndex: NSIndexPath?
	var currentTrip: Trip!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		switch EKEventStore.authorizationStatusForEntityType(EKEntityTypeEvent) {
			
		case .Authorized:
			extractEventEntityCalendarsOutOfSotre(eventStore)
			
		case .Denied:
			displayDeniedAccess()
		
		case .NotDetermined:
			eventStore.requestAccessToEntityType(EKEntityTypeEvent, completion: {
				(granted: Bool, error: NSError!) -> Void in
				if granted {
					
					self.extractEventEntityCalendarsOutOfSotre(self.eventStore)
					
				} else {
					
					self.displayDeniedAccess()
					
				}
			})
			
		case .Restricted:
			displayAccessRestricted()
			
		}
		
		let moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
		let currentTripName = (UIApplication.sharedApplication().delegate as! AppDelegate).currentTripNameMaster!
		let fetch = NSFetchRequest()
		fetch.entity = NSEntityDescription.entityForName("Trip", inManagedObjectContext: moc!)
		fetch.predicate = NSPredicate(format: "tripName == %@", currentTripName)
		var fetchError: NSError?
		let trips = moc!.executeFetchRequest(fetch, error: &fetchError)  as! [Trip]
		currentTrip = trips[0]
		
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	private func extractEventEntityCalendarsOutOfSotre(eventStore: EKEventStore) {
		
		let calendarTypes = [
			
			"Local",
			"CalDAV",
			"Exchange",
			"Subscription",
			"Birthday"
		
		]
		
		let calendars = eventStore.calendarsForEntityType(EKEntityTypeEvent) as! [EKCalendar]
		
		for calendar in calendars {
			
			if calendar.allowsContentModifications {
				
				calendarsToList.append(calendar)
				
			}
			
		}
		
		calendarsToList.sort({ $0.title < $1.title })
		calendarToUse = eventStore.defaultCalendarForNewEvents
		var index = 0
		for calendar in calendarsToList {
			
			if calendar.title == calendarToUse.title && calendar.source == calendarToUse.source {
				
				calendarToUseIndex = NSIndexPath(forRow: index, inSection: 0)
				
			}
			
			index++
			
		}
		
		tableView.reloadData()
		
	}
	
	private func displayDeniedAccess() {
		
		let alertViewController = UIAlertController(title: "Not Allowed", message: "Access to Calendars was denied.", preferredStyle: UIAlertControllerStyle.Alert)
		let dismissAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: {(alert: UIAlertAction!) in
			alertViewController.dismissViewControllerAnimated(true, completion: nil)
			self.dismissViewControllerAnimated(true, completion: nil)
		})
		alertViewController.addAction(dismissAction)
		
		presentViewController(alertViewController, animated: true, completion: nil)
		
	}
	
	private func displayAccessRestricted() {
		
		let alertViewController = UIAlertController(title: "Not Allowed", message: "Access to Calendars was restricted.", preferredStyle: UIAlertControllerStyle.Alert)
		let dismissAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: {(alert: UIAlertAction!) in
			alertViewController.dismissViewControllerAnimated(true, completion: nil)
			self.dismissViewControllerAnimated(true, completion: nil)
		})
		alertViewController.addAction(dismissAction)
		
		presentViewController(alertViewController, animated: true, completion: nil)
		
	}

	
    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
        return calendarsToList.count
		
		
		
    }

	
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("calendarCell", forIndexPath: indexPath) as! UITableViewCell

		cell.textLabel?.text = calendarsToList[indexPath.row].title
		
		if calendarToUseIndex == indexPath {
			
			cell.accessoryType = UITableViewCellAccessoryType.Checkmark
			
		} else {
			
			cell.accessoryType = UITableViewCellAccessoryType.None
			
		}

        return cell
    }
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		
		calendarToUseIndex = indexPath
		
		tableView.reloadData()
		
	}
	
	
	// MARK: - Navigation
	
	@IBAction func cancelAddToCal(sender: UIBarButtonItem) {
		
		dismissViewControllerAnimated(true, completion: nil)
		
	}
	
	@IBAction func saveTripToCal(sender: UIBarButtonItem) {
		
		if let calendarIndex = calendarToUseIndex?.row {
			
			calendarToUse = calendarsToList[calendarIndex]
			
			for entry in currentTrip.entries as! [Interval] {
				
				addInterval(entry, toCalendar: calendarToUse)
				
			}
			
		}
		
		dismissViewControllerAnimated(true, completion: nil)
		
	}
	
	private func addInterval(entry: Interval, toCalendar calendar: EKCalendar) {
		
		let durationOfInterval = entry.timeIntervalByConvertingTimeValue()
		let endDate = entry.startDate.dateByAddingTimeInterval(durationOfInterval)
		let notes = "\(currentTrip.tripName)\n\(entry.mainLabel)\n\nOrganized and Automatically Added by TravelTimer"
		createEventWithTitle(entry.scheduleLabel, startDate: entry.startDate, endDate: endDate, inCalendar: calendar, inEventStore: eventStore, withNotes: notes)
		
	}
	
	private func createEventWithTitle(title: String, startDate: NSDate, endDate: NSDate, inCalendar calendar: EKCalendar, inEventStore eventStore: EKEventStore, withNotes notes: String) -> Bool {
		
		var event = EKEvent(eventStore: eventStore)
		event.calendar = calendar
		event.title = title
		event.notes = notes
		event.startDate = startDate
		event.endDate = endDate
		
		let alarm = EKAlarm(relativeOffset: 0.0)
		event.addAlarm(alarm)
		
		var saveError: NSError?
		let result = eventStore.saveEvent(event, span: EKSpanThisEvent, error: &saveError)
		if result == false {
			
			if let theError = saveError {
				
				println("Could not save event.\nError: \(theError)")
				
			}
			
		}
		
		return result
		
	}
	
}
