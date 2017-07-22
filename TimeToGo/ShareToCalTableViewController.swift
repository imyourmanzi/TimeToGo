//
//  ShareToCalTableViewController.swift
//  TimeToGo
//
//  Created by Matt Manzi on 7/4/15.
//  Copyright (c) 2017 MRM Software. All rights reserved.
//

import UIKit
import EventKit
import CoreData
import MapKit

private let reuseIdentifier = "calendarCell"

class ShareToCalTableViewController: UITableViewController, CoreDataHelper {
	
	// EventKit variables
	let eventStore = EKEventStore()
	var calendarsToList = [EKCalendar]()
	var calendarToUse: EKCalendar!
	var calendarToUseIndexPath = IndexPath()
    var saveSuccessful = false
	
	// CoreData vairables
	var event: Trip!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		checkForCalendarAccess()
		
    }
    
    // Check for authorization to use calendars
    private func checkForCalendarAccess() {
        
        switch EKEventStore.authorizationStatus(for: EKEntityType.event) {
            
        case .authorized:
            extractEventEntityCalendars(from: eventStore)
            
        case .notDetermined:
            eventStore.requestAccess(to: EKEntityType.event, completion: {
                (granted: Bool, error: Error?) in
                
                if granted {
                    
                    self.extractEventEntityCalendars(from: self.eventStore)
                    self.tableView.reloadData()
                    
                }
                
            })
            
        default:
            displayAlert(title: "No Access", message: "Access to Calendars is not allowed.", on: self, dismissHandler: nil)
            
        }
        
    }
	
	// Get all calendars that allow modifications
	private func extractEventEntityCalendars(from eventStore: EKEventStore) {
		
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
		
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
	
	@IBAction func saveEventToCal(_ sender: UIBarButtonItem) {
		
		calendarToUse = calendarsToList[calendarToUseIndexPath.row]
        
        guard let theEntries = event.entries as? [Interval] else {
            
            displayDataErrorAlert(on: self, dismissHandler: {
                (_) in
                
                self.saveSuccessful = false
                self.performSegue(withIdentifier: IDs.SGE_TO_SCHEDULE, sender: self)
                
            })
            return
            
        }
        
		for entry in theEntries {
			
            save(entry: entry, to: calendarToUse)
			
		}
        
        displayAlert(title: "Save Successful!", message: nil, on: self) {
            (_) in
            
            self.saveSuccessful = true
            self.performSegue(withIdentifier: IDs.SGE_TO_SCHEDULE, sender: self)
            
        }
		
	}
	
	
	// MARK: - Interval to calendar event
	
	private func save(entry: Interval, to calendar: EKCalendar) {
		
		let durationOfInterval = entry.getTimeInterval()
		let endDate = entry.startDate.addingTimeInterval(durationOfInterval)
		var endLocStr: String?
        
        var notes = ""
		if entry.notesStr != nil && entry.notesStr != "" {
			notes = entry.notesStr!
		}
		notes += "\nFor \(event.tripName)\n\nOrganized and Automatically Added by It's Time To Go"
        
        if let endLoc = entry.endLocation {
            endLocStr = "\(endLoc.name!) \(Interval.getAddress(from: MKMapItem(placemark: endLoc)))"
		}
        
        createEventWith(title: entry.scheduleLabel, startDate: entry.startDate, endDate: endDate, location: endLocStr, notes: notes, on: calendar, in: eventStore)
		
	}
	
	private func createEventWith(title: String, startDate: Date, endDate: Date, location: String?, notes: String?, on calendar: EKCalendar, in eventStore: EKEventStore) {
		
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
            
            displayAlert(title: "Save Event Failed", message: "The entry \"\(event.title)\" could not be saved to the calendar. You may want to check your \(event.calendar) calendar to see if there are other entries that were saved.", on: self, dismissHandler: {
                (_) in
                
                self.saveSuccessful = false
                self.performSegue(withIdentifier: IDs.SGE_TO_SCHEDULE, sender: self)
                
            })
            
		}
		
	}
	
}
