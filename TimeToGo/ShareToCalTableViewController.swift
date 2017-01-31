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

class ShareToCalTableViewController: UITableViewController, CoreDataHelper {
	
	// EventKit variables
	let eventStore = EKEventStore()
	var calendarsToList = [EKCalendar]()
	var calendarToUse: EKCalendar!
	var calendarToUseIndexPath = IndexPath()
    var saveSuccessful = false
	
	// CoreData vairables
//    var moc: NSManagedObjectContext?
	var event: Trip!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		checkForCalendarAccess()
		
		// Fetch the current event from the persistent store and assign the CoreData variables
//		moc = getContext()
//		let eventName = UserDefaults.standard.object(forKey: "currentTripName") as! String
//		let fetch = NSFetchRequest<Trip>()
//		fetch.entity = NSEntityDescription.entity(forEntityName: "Trip", in: moc!)
//		fetch.predicate = NSPredicate(format: "tripName == %@", eventName)
//		let events = (try! moc!.fetch(fetch))
//		event = events[0]
		
    }
    
    // Check for authorization to use calendars
    private func checkForCalendarAccess() {
        
        switch EKEventStore.authorizationStatus(for: EKEntityType.event) {
            
        case .authorized:
            extractEventEntityCalendarsOutOfSotre(eventStore)
            
        case .notDetermined:
            eventStore.requestAccess(to: EKEntityType.event, completion: {
                (granted: Bool, error: NSError?) in
                if granted {
                    
                    self.extractEventEntityCalendarsOutOfSotre(self.eventStore)
                    self.tableView.reloadData()
                    
                }
                } as! EKEventStoreRequestAccessCompletionHandler)
            
        default:
            //			let alertViewController = UIAlertController(title: "No Access", message: "Access to Calendars is not allowed.", preferredStyle: UIAlertControllerStyle.alert)
            //			let dismissAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction) in
            //				alertViewController.dismiss(animated: true, completion: nil)
            //				self.dismiss(animated: true, completion: nil)
            //			})
            //			alertViewController.addAction(dismissAction)
            //			
            //			present(alertViewController, animated: true, completion: nil)
            
            displayAlert(title: "No Access", message: "Access to Calendars is not allowed.", on: self, dismissHandler: nil)
            
        }
        
    }
	
	// Get all calendars that allow modifications
	private func extractEventEntityCalendarsOutOfSotre(_ eventStore: EKEventStore) {
		
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
				
				calendarToUseIndexPath = IndexPath(row: index, section: 0)
				
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
		
		cell.textLabel?.text = calendarsToList[indexPath.row].title
		
		if calendarToUseIndexPath == indexPath {
			
			cell.accessoryType = UITableViewCellAccessoryType.checkmark
			
		} else {
			
			cell.accessoryType = UITableViewCellAccessoryType.none
			
		}
		
        return cell
    }
    
    
    // MARK: - Table view delegate
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		calendarToUseIndexPath = indexPath
		
		tableView.reloadData()
		
	}
	
	
	// MARK: - Navigation
	
//	@IBAction func cancelAddToCal(_ sender: UIBarButtonItem) {
//		
//		dismiss(animated: true, completion: nil)
//		
//	}
	
	@IBAction func saveEventToCal(_ sender: UIBarButtonItem) {
		
//		guard let calendarIndex = calendarToUseIndexPath.row else {
//			return
//		}
		
		calendarToUse = calendarsToList[calendarToUseIndexPath.row]
		
//        print(event)
//        print(event.entries)
//        print(event.entries as! [Interval])
        
        guard let theEntries = event.entries as? [Interval] else {
            
            displayAlert(title: "Error Retrieving Data", message: "There was an error accessing the event's entries.", on: self, dismissHandler: { (_) in
                
                self.saveSuccessful = false
                self.performSegue(withIdentifier: "unwindToSchedule", sender: self)
                
            })
            return
            
        }
        
		for entry in theEntries {
			
            add(entry: entry, to: calendarToUse)
			
		}
//		dismiss(animated: true, completion: nil)
        saveSuccessful = true
        performSegue(withIdentifier: "unwindToScheudle", sender: self)
		
	}
	
	
	// MARK: - Interval to calendar event
	
	private func add(entry: Interval, to calendar: EKCalendar) {
		
		let durationOfInterval = entry.timeIntervalByConvertingTimeValue()
		let endDate = entry.startDate.addingTimeInterval(durationOfInterval)
		var endLocStr: String?
		var notes = ""
		if entry.notesStr != nil && entry.notesStr != "" {
			notes = entry.notesStr!
		}
		notes += "\nFor \(event.tripName)\n\nOrganized and Automatically Added by It's Time To Go"
		if entry.endLocation != nil {
			let endLoc = MKMapItem(placemark: entry.endLocation!)
			endLocStr = "\(endLoc.name!) \(Interval.getAddressFromMapItem(endLoc))"
		}
        createEvent(title: entry.scheduleLabel, startDate: entry.startDate, endDate: endDate, location: endLocStr, inCalendar: calendar, inEventStore: eventStore, withNotes: notes)
		
	}
	
	private func createEvent(title: String, startDate: Date, endDate: Date, location: String?, inCalendar calendar: EKCalendar, inEventStore eventStore: EKEventStore, withNotes notes: String) {
		
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
            
            displayAlert(title: "Save Event Failed", message: "The entry \"\(event.title)\" could not be saved to the calendar.", on: self, dismissHandler: { (_) in
                
                self.saveSuccessful = false
                self.performSegue(withIdentifier: "unwindToSchedule", sender: self)
                
            })
            
		}
		
	}
	
}
