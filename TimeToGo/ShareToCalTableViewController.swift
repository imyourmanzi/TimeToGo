//
//  ShareToCalTableViewController.swift
//  TimeToGo
//
//  Created by Matteo Manzi on 7/4/15.
//  Copyright (c) 2015 VMM Software. All rights reserved.
//

import UIKit
import EventKit
import CoreData

class ShareToCalTableViewController: UITableViewController {
	
	// EventKit variables
	let eventStore = EKEventStore()
	var calendarsToList = [EKCalendar]()
	var calendarToUse: EKCalendar!
	var calendarToUseIndex: NSIndexPath?
	
	// CoreData vairables
	var currentTrip: Trip!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Check for authorization to use calendars
		switch EKEventStore.authorizationStatusForEntityType(EKEntityType.Event) {
			
		case .Authorized:
			extractEventEntityCalendarsOutOfSotre(eventStore)
		
		case .NotDetermined:
			eventStore.requestAccessToEntityType(EKEntityType.Event, completion: {
				(granted: Bool, error: NSError?) -> Void in
				if granted {
					
					self.extractEventEntityCalendarsOutOfSotre(self.eventStore)
					self.tableView.reloadData()
					
				}
			})
			
		default:
			let alertViewController = UIAlertController(title: "No Access", message: "Access to Calendars is not allowed.", preferredStyle: UIAlertControllerStyle.Alert)
			let dismissAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: {(alert: UIAlertAction) in
				alertViewController.dismissViewControllerAnimated(true, completion: nil)
				self.dismissViewControllerAnimated(true, completion: nil)
			})
			alertViewController.addAction(dismissAction)
			
			presentViewController(alertViewController, animated: true, completion: nil)
			
			
		}
		
		// Fetch the current trip from the persistent store and assign the CoreData variables
		let moc = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
		let currentTripName = (UIApplication.sharedApplication().delegate as! AppDelegate).currentTripNameMaster!
		let fetch = NSFetchRequest()
		fetch.entity = NSEntityDescription.entityForName("Trip", inManagedObjectContext: moc!)
		fetch.predicate = NSPredicate(format: "tripName == %@", currentTripName)
		let trips = (try! moc!.executeFetchRequest(fetch))  as! [Trip]
		currentTrip = trips[0]
		
    }
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
	
	// Get all calendars that allow modifications
	private func extractEventEntityCalendarsOutOfSotre(eventStore: EKEventStore) {
		
		let calendars = eventStore.calendarsForEntityType(EKEntityType.Event) 
		
		for calendar in calendars {
			
			if calendar.allowsContentModifications {
				
				calendarsToList.append(calendar)
				
			}
			
		}
		
		// Sort the array of calendars
		calendarsToList.sortInPlace({ $0.title < $1.title })
		calendarToUse = eventStore.defaultCalendarForNewEvents
		var index = 0
		for calendar in calendarsToList {
			
			if calendar.title == calendarToUse.title && calendar.source == calendarToUse.source {
				
				calendarToUseIndex = NSIndexPath(forRow: index, inSection: 0)
				
			}
			
			index++
			
		}
		
	}

	
    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
        return calendarsToList.count
	
    }

	
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("calendarCell", forIndexPath: indexPath) 
		
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
		
		guard let calendarIndex = calendarToUseIndex?.row else {
			return
		}
		
		calendarToUse = calendarsToList[calendarIndex]
		
		for entry in currentTrip.entries as! [Interval] {
			
			addInterval(entry, toCalendar: calendarToUse)
			
		}
		dismissViewControllerAnimated(true, completion: nil)
		
	}
	
	
	// MARK: - Interval to calendar event
	
	private func addInterval(entry: Interval, toCalendar calendar: EKCalendar) {
		
		let durationOfInterval = entry.timeIntervalByConvertingTimeValue()
		let endDate = entry.startDate.dateByAddingTimeInterval(durationOfInterval)
		let notes = "\(currentTrip.tripName)\n\(entry.mainLabel)\n\nOrganized and Automatically Added by It's Time To Go"
		createEventWithTitle(entry.scheduleLabel, startDate: entry.startDate, endDate: endDate, inCalendar: calendar, inEventStore: eventStore, withNotes: notes)
		
	}
	
	private func createEventWithTitle(title: String, startDate: NSDate, endDate: NSDate, inCalendar calendar: EKCalendar, inEventStore eventStore: EKEventStore, withNotes notes: String) -> Bool {
		
		let event = EKEvent(eventStore: eventStore)
		event.calendar = calendar
		event.title = title
		event.notes = notes
		event.startDate = startDate
		event.endDate = endDate
		
		let alarm = EKAlarm(relativeOffset: 0.0)
		event.alarms = [alarm]
		
		let result: Bool
		do {
			try eventStore.saveEvent(event, span: EKSpan.ThisEvent)
			result = true
		} catch {
			
			print("Could not save event.\nError: \(error)\n")
			result = false
			
		}
		
		return result
		
	}
	
}
