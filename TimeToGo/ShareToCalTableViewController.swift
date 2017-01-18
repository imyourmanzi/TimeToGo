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
import MapKit

class ShareToCalTableViewController: UITableViewController {
	
	// EventKit variables
	let eventStore = EKEventStore()
	var calendarsToList = [EKCalendar]()
	var calendarToUse: EKCalendar!
	var calendarToUseIndex: IndexPath?
	
	// CoreData vairables
	var currentTrip: Trip!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Check for authorization to use calendars
		switch EKEventStore.authorizationStatus(for: EKEntityType.event) {
			
		case .authorized:
			extractEventEntityCalendarsOutOfSotre(eventStore)
		
		case .notDetermined:
			eventStore.requestAccess(to: EKEntityType.event, completion: {
				(granted: Bool, error: NSError?) -> Void in
				if granted {
					
					self.extractEventEntityCalendarsOutOfSotre(self.eventStore)
					self.tableView.reloadData()
					
				}
			} as! EKEventStoreRequestAccessCompletionHandler)
			
		default:
			let alertViewController = UIAlertController(title: "No Access", message: "Access to Calendars is not allowed.", preferredStyle: UIAlertControllerStyle.alert)
			let dismissAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction) in
				alertViewController.dismiss(animated: true, completion: nil)
				self.dismiss(animated: true, completion: nil)
			})
			alertViewController.addAction(dismissAction)
			
			present(alertViewController, animated: true, completion: nil)
			
			
		}
		
		// Fetch the current trip from the persistent store and assign the CoreData variables
		let moc = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
		let currentTripName = UserDefaults.standard.object(forKey: "currentTripName") as! String
		let fetch = NSFetchRequest<Trip>()
		fetch.entity = NSEntityDescription.entity(forEntityName: "Trip", in: moc!)
		fetch.predicate = NSPredicate(format: "tripName == %@", currentTripName)
		let trips = (try! moc!.fetch(fetch))
		currentTrip = trips[0]
		
    }
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
	
	// Get all calendars that allow modifications
	fileprivate func extractEventEntityCalendarsOutOfSotre(_ eventStore: EKEventStore) {
		
		let calendars = eventStore.calendars(for: EKEntityType.event) 
		
		for calendar in calendars {
			
			if calendar.allowsContentModifications {
				
				calendarsToList.append(calendar)
				
			}
			
		}
		
		// Sort the array of calendars
		calendarsToList.sort(by: { $0.title < $1.title })
		calendarToUse = eventStore.defaultCalendarForNewEvents
		var index = 0
		for calendar in calendarsToList {
			
			if calendar.title == calendarToUse.title && calendar.source == calendarToUse.source {
				
				calendarToUseIndex = IndexPath(row: index, section: 0)
				
			}
			
			index += 1
			
		}
		
	}

	
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
        return calendarsToList.count
	
    }

	
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "calendarCell", for: indexPath) 
		
		cell.textLabel?.text = calendarsToList[(indexPath as NSIndexPath).row].title
		
		if calendarToUseIndex == indexPath {
			
			cell.accessoryType = UITableViewCellAccessoryType.checkmark
			
		} else {
			
			cell.accessoryType = UITableViewCellAccessoryType.none
			
		}
		
        return cell
    }
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		calendarToUseIndex = indexPath
		
		tableView.reloadData()
		
	}
	
	
	// MARK: - Navigation
	
	@IBAction func cancelAddToCal(_ sender: UIBarButtonItem) {
		
		dismiss(animated: true, completion: nil)
		
	}
	
	@IBAction func saveTripToCal(_ sender: UIBarButtonItem) {
		
		guard let calendarIndex = (calendarToUseIndex as NSIndexPath?)?.row else {
			return
		}
		
		calendarToUse = calendarsToList[calendarIndex]
		
		for entry in currentTrip.entries as! [Interval] {
			
			addInterval(entry, toCalendar: calendarToUse)
			
		}
		dismiss(animated: true, completion: nil)
		
	}
	
	
	// MARK: - Interval to calendar event
	
	fileprivate func addInterval(_ entry: Interval, toCalendar calendar: EKCalendar) {
		
		let durationOfInterval = entry.timeIntervalByConvertingTimeValue()
		let endDate = entry.startDate.addingTimeInterval(durationOfInterval)
		var endLocStr: String?
		var notes = ""
		if entry.notesStr != nil && entry.notesStr != "" {
			notes = entry.notesStr!
		}
		notes += "\n\(entry.mainLabel!)\nFor \(currentTrip.tripName)\n\nOrganized and Automatically Added by It's Time To Go"
		if entry.endLocation != nil {
			let endLoc = MKMapItem(placemark: entry.endLocation!)
			endLocStr = "\(endLoc.name!) \(Interval.getAddressFromMapItem(endLoc))"
		}
		createEventWithTitle(entry.scheduleLabel, startDate: entry.startDate, endDate: endDate, location: endLocStr, inCalendar: calendar, inEventStore: eventStore, withNotes: notes)
		
	}
	
	fileprivate func createEventWithTitle(_ title: String, startDate: Date, endDate: Date, location: String?, inCalendar calendar: EKCalendar, inEventStore eventStore: EKEventStore, withNotes notes: String) {
		
		let event = EKEvent(eventStore: eventStore)
		event.calendar = calendar
		event.title = title
		event.notes = notes
		event.startDate = startDate
		event.endDate = endDate
		event.location = location
		
		let alarm = EKAlarm(relativeOffset: 0.0)
		event.alarms = [alarm]
		
		do {
			try eventStore.save(event, span: EKSpan.thisEvent)
        } catch {
		}
		
	}
	
}
