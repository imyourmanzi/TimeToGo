//
//  EditEventTimeTableViewController.swift
//  TimeToGo
//
//  Created by Matteo Manzi on 7/4/15.
//  Copyright (c) 2015 VMM Software. All rights reserved.
//

import UIKit
import CoreData

class EditEventTimeTableViewController: UITableViewController, CoreDataHelper {
	
	// Interface Builder variables
	@IBOutlet var eventDatePicker: UIDatePicker!
	@IBOutlet var dateCell: UITableViewCell!
    @IBOutlet var setTodayButton: UIButton!

	// CoreData variables
//	var moc: NSManagedObjectContext?
//	var currentEventName: String!       // Not used
	var event: Trip!
	
	// Current VC variables
	var pickerHidden = true
	var eventDate = Date()
	let dateFormatter = DateFormatter()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Assign the moc CoreData variable by referencing the AppDelegate's
//		moc = getContext()
		
        setupDateElements()
		
	}
    
    private func setupDateElements() {
        
        // Set the time zone
        let components = Calendar.current.dateComponents(in: TimeZone.current, from: eventDate)
        eventDate = Calendar.current.date(from: components)!
        
        //        print(eventDatePicker.calendar.timeZone)
        
        // Define the date format and apply it to the event time display
        dateFormatter.dateFormat = "M/d/yy '@' h:mm a"
        dateCell.detailTextLabel?.text = dateFormatter.string(from: eventDate)
        
    }
	
	@IBAction func eventDateChanged(_ sender: UIDatePicker) {
		
		// Update the event time and its display
		eventDate = sender.date
		dateCell.detailTextLabel?.text = dateFormatter.string(from: eventDate)
		
	}
	
    // Change the event date to today when tapped
    @IBAction func setEventDateToday(_ sender: UIButton) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        
        // Get a string of:
        // - the current date
        // - the event's date
        var dateString = formatter.string(from: Date())
        var timeString = formatter.string(from: eventDate)
        
//        print("dateString before", dateString)
//        print("timeString before", timeString)
        
        // Of the formatted strings:
        // - get the date (day) from the current
        // - get the time from event's date
        // - Put the date and time together
        let endDateIndex = dateString.index(dateString.startIndex, offsetBy: 10)
        dateString = dateString.substring(to: endDateIndex)
        timeString = timeString.substring(from: endDateIndex)
        let todayString = dateString + timeString
        
//        print("dateString after", dateString)
//        print("timeString after", timeString)
//        print("todayString", todayString)
        
        // Turn the current day into a Date object,
        // the event's time into a Date object,
        // and the default date Jan 1, 2001 into a Date object
//        formatter.dateFormat = "yyyy-MM-dd"
//        guard let theDate = formatter.date(from: dateString) else {
//            return
//        }
//        formatter.dateFormat = " HH:mm:ss Z"
//        guard let theTime = formatter.date(from: timeString) else {
//            return
//        }
//        formatter.dateFormat = "yyyy-MM-dd"
//        guard let exDate = formatter.date(from: "2000-01-01") else {
//            return
//        }
        
        // Parse out the concatenated date and time
        guard let todayDate = formatter.date(from: todayString) else {
            return
        }
        eventDate = todayDate
        
        // Get the number of seconds (a TimeInterval) from Jan 1, 2001 12:00:00 AM until the event's time
        // Then add that amound of time to current date (who's time is 12:00:00 AM)
//        eventDate = theDate.addingTimeInterval(theTime.timeIntervalSince(exDate))
        
        // Set the UI
        eventDatePicker.setDate(eventDate, animated: true)
        dateCell.detailTextLabel?.text = dateFormatter.string(from: eventDate)
        
    }
	
    
    // MARK: - Table view data source

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if pickerHidden {
			return 1
		} else {
			return 2
		}
		
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		if indexPath.row == 0 {
			togglePicker()
		}
		
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		
		if pickerHidden {
			return tableView.rowHeight
		} else {
			
			if indexPath.row == 1 {
				return eventDatePicker.frame.height
			} else {
				return tableView.rowHeight
			}
			
		}
		
	}
	
	
	// MARK: - Date picker show/hide
	
	func togglePicker() {
		
		self.tableView.beginUpdates()
		
		if pickerHidden {
			
			eventDatePicker.setDate(eventDate, animated: true)
			self.tableView.insertRows(at: [IndexPath(row: 1, section: 0)], with: UITableViewRowAnimation.fade)
			tableView.isScrollEnabled = false
            setTodayButton.isEnabled = true
			
		} else {
			
			self.tableView.deleteRows(at: [IndexPath(row: 1, section: 0)], with: UITableViewRowAnimation.fade)
			tableView.isScrollEnabled = true
            setTodayButton.isEnabled = false
			
		}
		
		pickerHidden = !pickerHidden
		
		self.tableView.endUpdates()
		
		self.tableView.deselectRow(at: IndexPath(row: 0, section: 0), animated: true)
		
	}
	
    
    // MARK: - Core Data helper
    
    func prepareForUpdateOnCoreData() {
        
        event.flightDate = self.eventDate
        
    }
    
	
	// MARK: - Navigation
	
	override func viewWillDisappear(_ animated: Bool) {

        performUpdateOnCoreData()
        
//		guard let moc = self.moc else {
//			return
//		}
//		
//		if moc.hasChanges {
//			
//			do {
//				try moc.save()
//			} catch {
//			}
//			
//		}

	}

}
